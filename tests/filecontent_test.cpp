// QtCore-only behavioral test; creates and removes only its own temporary files.
#include "filecontent.h"
#include <QCoreApplication>
#include <QDir>
#include <QTemporaryDir>
#include <QUrl>
#include <iostream>
#include <stdexcept>

#define CHECK(value) do { if (!(value)) throw std::runtime_error(std::to_string(__LINE__) + ": " + #value); } while (false)
int main(int argc, char **argv) {
    QCoreApplication application(argc, argv);
    try {
        QTemporaryDir temporary;
        CHECK(temporary.isValid());
        const QString path = temporary.filePath(QString::fromUtf8("标定 # percent%.json"));
        FileContent content;
        CHECK(!content.open());
        CHECK(content.errorCode() == "no_selection");
        CHECK(content.localFilePath(QUrl::fromLocalFile(path).toString()) == path);
        CHECK(content.localFilePath(path) == path);
        CHECK(content.localFilePath("https://example.invalid/config").isEmpty());
        content.setFileName(QUrl::fromLocalFile(path).toString());
        CHECK(content.write(QString::fromUtf8("{\"title\":\"测试\",\"data\":[]}")));
        CHECK(content.lastOperationSucceeded());
        CHECK(content.readAll(QUrl::fromLocalFile(path).toString()).contains(QString::fromUtf8("测试")));
        CHECK(content.lastOperationSucceeded());
        CHECK(content.open());
        CHECK(!content.readLine().isEmpty());
        CHECK(content.readLine().isNull());
        CHECK(content.lastOperationSucceeded());
        content.close();
        CHECK(content.write(""));
        CHECK(content.readAll(path).isEmpty());
        CHECK(content.lastOperationSucceeded()); // Empty is not denial/not found.
        CHECK(content.readAll(temporary.filePath("absent.json")).isEmpty());
        CHECK(content.errorCode() == "not_found");
        content.setFileName(temporary.filePath("missing-parent/config.json"));
        CHECK(!content.write("data"));
        CHECK(content.errorCode() == "not_found");
        content.setFileName(path);
        CHECK(content.write("original"));
#ifndef Q_OS_WIN
        const auto originalPermissions = QFile::permissions(path);
        CHECK(QFile::setPermissions(path, {}));
        CHECK(content.readAll(path).isEmpty());
        CHECK(content.errorCode() == "permission_denied");
        CHECK(QFile::setPermissions(path, originalPermissions));
        const auto directoryPermissions = QFile::permissions(temporary.path());
        CHECK(QFile::setPermissions(temporary.path(), QFileDevice::ReadOwner | QFileDevice::ExeOwner));
        CHECK(!content.write("replacement"));
        CHECK(content.errorCode() == "permission_denied");
        CHECK(QFile::setPermissions(temporary.path(), directoryPermissions));
        CHECK(content.readAll(path) == "original"); // Failed save did not truncate.
        CHECK(content.write("retry"));
        CHECK(content.readAll(path) == "retry");
#endif
        content.setFileName(temporary.path()); // A directory is not an output file.
        CHECK(!content.write("data"));
        CHECK(!content.lastOperationSucceeded());
        std::cout << "FileContent URL, empty, missing, denial, atomic-save and retry tests passed\n";
        return 0;
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
