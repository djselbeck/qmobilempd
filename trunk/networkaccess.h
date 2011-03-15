#ifndef NETWORKACCESS_H
#define NETWORKACCESS_H

#include <QObject>
#include <QtNetwork>
#include "mpdalbum.h"
#include "mpdartist.h"
#include "mpdtrack.h"
#include "mpdfileentry.h"
#include "common.h"
#include "commondebug.h"

class MpdAlbum;
class MpdArtist;
class MpdTrack;
class MpdFileEntry;

struct status_struct {quint32 playlistversion; qint32 id; quint8 percent; quint8 volume; QString info; QString title; QString album; QString artist;bool playing; bool repeat; bool shuffle;};

class NetworkAccess : public QObject
{
    Q_OBJECT
public:
    explicit NetworkAccess(QObject *parent = 0);
    bool connectToHost(QString hostname, quint16 port);
    bool savePlaylist(QString name);
    QList<MpdAlbum*> *getAlbums();
    QList<MpdArtist*> *getArtists();
    QList<MpdTrack*> *getTracks();
    QList<MpdAlbum*> *getArtistsAlbums(QString artist);
    QList<MpdTrack*> *getAlbumTracks(QString album);
    QList<MpdTrack*> *getAlbumTracks(QString album, QString cartist);
    QList<MpdTrack*> *getCurrentPlaylistTracks();
    QList<MpdTrack*> *getPlaylistTracks(QString name);
    QStringList *getSavedPlaylists();
    void addPlaylist(QString name);
    void clearPlaylist();
    bool authenticate(QString passwort);
    void suspendUpdates();
    void resumeUpdates();
    QList<MpdFileEntry*> *getDirectory(QString path);


signals:
    void connectionestablished();
    void disconnected();
    void statusUpdate(status_struct status);
    void connectionError(QString);
public slots:
    void addTrackToPlaylist(QString fileuri);
    void addAlbumToPlaylist(QString album);
    void playTrack(QString fileuri);
    void playTrackByNumber(qint32 nr);
    void socketConnected();
    void pause();
    void next();
    void previous();
    void stop();
    void setVolume(quint8 volume);
    void setRandom(bool);
    void setRepeat(bool);
    void disconnect();
    quint32 getPlayListVersion();


protected slots:
    void connectedtoServer();
    void disconnectedfromServer();
    void updateStatusInternal();


private:
    QString hostname;
    quint16 port;
    QString password;
    QTcpSocket* tcpsocket;
    QString mpdversion;
    QTimer *statusupdater;



};

#endif // NETWORKACCESS_H
