#ifndef FILECONTENT_H
#define FILECONTENT_H

#include <QObject>
#include <QFile>
#include <QTextStream>

class FileContent : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString content READ getContent)
    Q_PROPERTY(QString filename READ getFileName WRITE setFileName)
    Q_PROPERTY(bool lastOperationSucceeded READ lastOperationSucceeded NOTIFY operationFinished)
    Q_PROPERTY(QString errorCode READ errorCode NOTIFY operationFinished)
    Q_PROPERTY(QString errorString READ errorString NOTIFY operationFinished)
public:
    explicit FileContent(QObject *parent = nullptr);
    Q_INVOKABLE QString getContent();
    Q_INVOKABLE bool open();
    Q_INVOKABLE void close();
    Q_INVOKABLE QString getFileName() const;
    Q_INVOKABLE QString localFilePath(const QString &selection) const;
    Q_INVOKABLE QString readAll(const QString &selection);
    Q_INVOKABLE bool write(const QString &text);
    Q_INVOKABLE QString readLine(qint64 maxlen = 0);
    bool lastOperationSucceeded() const { return succeeded; }
    QString errorCode() const { return code; }
    QString errorString() const { return message; }

signals:
    void operationFinished();

public slots:
    void setFileName(const QString &filename);
    void clearContent();

private:
    void success();
    void failure(const QString &errorCode, const QString &errorString);
    void fileFailure(const QFileDevice &device, const QString &path, bool writing = false);
    QFile file;
    QTextStream stream;
    QString content;
    QString filename;
    QString code;
    QString message;
    bool succeeded = false;
};
#endif
