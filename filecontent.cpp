#include "filecontent.h"
#include <QDir>
#include <QFileInfo>
#include <QSaveFile>
#include <QUrl>
#include <filesystem>
#include <cerrno>

FileContent::FileContent(QObject *parent) : QObject(parent), stream(&file) {}

QString FileContent::getFileName() const { return filename; }

QString FileContent::localFilePath(const QString &selection) const {
    const QUrl url(selection);
    if (url.isLocalFile())
        return url.toLocalFile();
    // Existing configs contain native paths; do not percent-decode these again.
    if (QDir::isAbsolutePath(selection) || url.scheme().isEmpty())
        return selection;
    return {}; // Remote URLs cannot be opened as local files.
}

void FileContent::setFileName(const QString &selection) {
    close();
    filename = localFilePath(selection);
    content.clear();
}

void FileContent::success() {
    succeeded = true;
    code.clear();
    message.clear();
    emit operationFinished();
}

void FileContent::failure(const QString &errorCode, const QString &errorString) {
    succeeded = false;
    code = errorCode;
    message = errorString;
    emit operationFinished();
}

void FileContent::fileFailure(const QFileDevice &device, const QString &path, bool writing) {
    const int nativeError = errno; // Capture before any subsequent filesystem query.
    QString errorCode = QStringLiteral("io_error");
    if (device.error() == QFileDevice::PermissionsError
            || nativeError == EACCES || nativeError == EPERM) {
        errorCode = QStringLiteral("permission_denied");
    } else {
        // QFileInfo::exists() alone collapses inaccessible and missing paths.
        const QString checkedPath = writing ? QFileInfo(path).absolutePath() : path;
        std::error_code error;
#ifdef Q_OS_WIN
        const std::filesystem::path nativePath(checkedPath.toStdWString());
#else
        const std::filesystem::path nativePath(QFile::encodeName(checkedPath).constData());
#endif
        const auto status = std::filesystem::status(nativePath, error);
        if (error == std::errc::permission_denied)
            errorCode = QStringLiteral("permission_denied");
        else if (error == std::errc::no_such_file_or_directory
                 || error == std::errc::not_a_directory
                 || (!error && status.type() == std::filesystem::file_type::not_found))
            errorCode = QStringLiteral("not_found");
    }
    failure(errorCode, device.errorString());
}

bool FileContent::open() {
    close();
    if (filename.isEmpty()) {
        failure(QStringLiteral("no_selection"), tr("Choose a local file first."));
        return false;
    }
    file.setFileName(filename);
    errno = 0;
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        fileFailure(file, filename);
        return false;
    }
    stream.setDevice(&file);
    stream.resetStatus();
    success();
    return true;
}

void FileContent::close() {
    file.close();
    stream.setDevice(nullptr);
}

QString FileContent::readAll(const QString &selection) {
    const QString path = localFilePath(selection);
    if (path.isEmpty()) {
        failure(QStringLiteral("no_selection"), tr("Choose a local file first."));
        return {};
    }
    QFile source(path);
    errno = 0;
    if (!source.open(QIODevice::ReadOnly | QIODevice::Text)) {
        fileFailure(source, path);
        return {};
    }
    errno = 0;
    const QByteArray bytes = source.readAll();
    if (source.error() != QFileDevice::NoError) {
        fileFailure(source, path);
        return {};
    }
    content = QString::fromUtf8(bytes);
    success(); // An empty readable file is a successful read, not access denial.
    return content;
}

QString FileContent::readLine(qint64 maxlen) {
    if (!file.isOpen()) {
        if (succeeded)
            failure(QStringLiteral("not_open"), tr("Select the file again and retry."));
        return {};
    }
    errno = 0;
    const QString line = stream.readLine(maxlen);
    if (file.error() != QFileDevice::NoError)
        fileFailure(file, filename);
    return line;
}

QString FileContent::getContent() { return readAll(filename); }

bool FileContent::write(const QString &text) {
    if (filename.isEmpty()) {
        failure(QStringLiteral("no_selection"), tr("Choose a local destination first."));
        return false;
    }
    QSaveFile destination(filename);
    // Never fall back to truncating the original when atomic replacement fails.
    destination.setDirectWriteFallback(false);
    errno = 0;
    if (!destination.open(QIODevice::WriteOnly)) {
        fileFailure(destination, filename, true);
        return false;
    }
    const QByteArray bytes = text.toUtf8();
    errno = 0;
    if (destination.write(bytes) != bytes.size()) {
        fileFailure(destination, filename, true);
        destination.cancelWriting();
        return false;
    }
    errno = 0;
    if (!destination.commit()) {
        fileFailure(destination, filename, true);
        return false;
    }
    content = text;
    success();
    return true;
}

void FileContent::clearContent() { content.clear(); }
