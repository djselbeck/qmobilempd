#ifndef MPDTRACK_H
#define MPDTRACK_H

#include <QObject>
#include "mpdalbum.h"
#include "mpdartist.h"

class MpdArtist;
class MpdAlbum;

class MpdTrack : public QObject
{
    Q_OBJECT
public:
    explicit MpdTrack(QObject *parent = 0);
    MpdTrack(QObject *parent,QString file,QString title, quint32 length);
    MpdTrack(QObject *parent,QString file,QString title, quint32 length,bool playing);
    MpdTrack(QObject *parent,QString file,QString title,QString artist, QString album, quint32 length);
    QString getName();

    QString getTitle();
    QString getFileUri();
    quint32 getLength();
    QString getAlbum();
    QString getArtist();
    QString getLengthFormated();
    void    setTitle(QString);
    void 	setFileUri(QString);
    void 	setLength(quint32 length);
    void 	setAlbum(QString);
    void	setArtist(QString);

    bool getPlaying();
private:
    QString title;
    QString filename;
    quint32 length;
    QString artist;
    QString album;
    
    bool playing;

signals:

public slots:

};

#endif // MPDTRACK_H
