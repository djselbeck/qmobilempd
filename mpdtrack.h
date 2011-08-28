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

    Q_PROPERTY(QString title READ getTitle )
    Q_PROPERTY(QString uri READ getFileUri )
    Q_PROPERTY(QString lengthformated READ getLengthFormated )
    Q_PROPERTY(QString length READ getLength )
    Q_PROPERTY(QString artist READ getArtist )
    Q_PROPERTY(QString album READ getAlbum )
    Q_PROPERTY(bool playing READ getPlaying NOTIFY playingchanged )
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
    void setPlaying(bool playing);
private:
    QString title;
    QString filename;
    quint32 length;
    QString artist;
    QString album;
    
    bool playing;

signals:
    void playingchanged();

public slots:

};

#endif // MPDTRACK_H
