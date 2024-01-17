#include "filecontent.h"
#include <QDebug>

FileContent::FileContent(QObject *parent) {

}

FileContent::~FileContent() {
    delete file;
}

QString FileContent::getFileName() {
    return this->filename;
}

void FileContent::setFileName(const QString &filename) {
    this->filename = filename;
}

QString FileContent::open(){
    file = new QFile(filename);
    in = new QTextStream(file);
    file->open(QIODevice::ReadOnly | QIODevice::Text);
    return filename;
}

QString FileContent::readAll(QString filename) {
    file = new QFile(filename);
    file->open(QIODevice::ReadOnly | QIODevice::Text);
    QTextStream in(file);
    return in.readAll();
}


QString FileContent::readLine(qint64 maxlen) {

    return in->readLine(maxlen);
}

QString FileContent::getContent() {
    if( content.length() == 0 ) {
        file->open(QIODevice::ReadOnly | QIODevice::Text);
        QTextStream in(file);
        content = in.readLine();
        if( content.length() == 0) {
            qDebug() << "[Warning] FileContent: file " << this->filename << "is empty";
        }
    }
    return content;
}

void FileContent::write(QString string){
    file = new QFile(filename);
    file->open(QIODevice::WriteOnly | QIODevice::Text);
    QTextStream out(file);
    out<<string;
    file->close();
}

void FileContent::clearContent() {
    content.clear();
}
