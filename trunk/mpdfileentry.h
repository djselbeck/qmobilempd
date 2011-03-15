#ifndef MPDFILEENTRY_H
#define MPDFILEENTRY_H

#include <QObject>
#include "mpdtrack.h"


class MpdFileEntry : public QObject
{
    Q_OBJECT
public:
    enum MpdFileType {MpdFileType_File,MpdFileType_Directory,MpdFileType_Playlist,MpdFileType_NR};
    explicit MpdFileEntry(QObject *parent = 0);
    MpdFileEntry(QString prepath,QString name, quint8 type ,MpdTrack *track,QObject *parent);
    MpdFileEntry(QString prepath,QString name, quint8 type ,QObject *parent);
    ~MpdFileEntry();
    bool isFile();
    bool isDirectory();
    bool isPlaylist();
    QString getName();
    QString getPrePath();
    MpdTrack *getTrack();

private:
    quint8 type;
    QString name;
    QString prepath;
    MpdTrack *track;

signals:

public slots:

};

#endif // MPDFILEENTRY_H
