#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QString>
#include "mpdtrack.h"

#include "qmlapplicationviewer.h"
#include <QDeclarativeContext>
#include "networkaccess.h"
#include "commondebug.h"

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QObject *parent = 0);
    Controller(QmlApplicationViewer *viewer,QObject *parent = 0);
    void connectSignals();
public slots:
    void updateAlbumsModel(QList<QObject*>* list);
    void updateArtistsModel(QList<QObject*>* list);
    void updateArtistAlbumsModel(QList<QObject*>* list);
    void updatePlaylistModel(QList<QObject*>* list);
    void updateAlbumTracksModel(QList<QObject*>* list);
    void connectedToServer();
    void setHostname(QString hostname);
    void setPassword(QString password);
    void setPort(int port);
    void connectToServer();

signals:
    void sendPopup(QVariant text);
    void playlistUpdated();


private:
    QmlApplicationViewer *viewer;
    NetworkAccess *netaccess;
    QString hostname,password;
    quint16 port;
    quint32 playlistversion;
    quint32 currentsongid;
    QList<MpdTrack*> *playlist;

private slots:
    void requestCurrentPlaylist();
    void requestAlbums();
    void requestArtists();
    void requestArtistAlbums(QString artist);
    void requestAlbum(QVariant array);
    void requestFiles(QString);
    void updateStatus(status_struct status);


};

#endif // CONTROLLER_H
