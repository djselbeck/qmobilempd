#include "controller.h"
Controller::Controller(QObject *parent) : QObject(parent)
{

}

Controller::Controller(QmlApplicationViewer *viewer,QObject *parent) : QObject(parent),viewer(viewer),password(""),hostname(""),port(6600)
{
    netaccess = new NetworkAccess(this);
}

void Controller::updatePlaylistModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("playlistModel",QVariant::fromValue(*list));
}

void Controller::updateArtistsModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("artistsModel",QVariant::fromValue(*list));
}

void Controller::updateAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
}
void Controller::connectSignals()
{
    CommonDebug("Connecting Signals with qml part");
    QObject *item = (QObject *)viewer->rootObject();
    connect(item,SIGNAL(setHostname(QString)),this,SLOT(setHostname(QString)));
    connect(item,SIGNAL(setPassword(QString)),this,SLOT(setPassword(QString)));
    connect(item,SIGNAL(setPort(int)),this,SLOT(setPort(int)));
    connect(item,SIGNAL(connectToServer()),this,SLOT(connectToServer()));
    connect(item,SIGNAL(requestCurrentPlaylist()),this,SLOT(requestCurrentPlaylist()));
    connect(item,SIGNAL(requestArtists()),this,SLOT(requestArtists()));
    connect(item,SIGNAL(requestAlbums()),this,SLOT(requestAlbums()));
    connect(item,SIGNAL(requestFiles(QString)),this,SLOT(requestFiles(QString)));
    connect(item,SIGNAL(requestCurrentPlaylist()),this,SLOT(requestCurrentPlaylist()));
    connect(netaccess,SIGNAL(currentPlayListReady(QList<QObject*>*)),this,SLOT(updatePlaylistModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(albumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(artistsReady(QList<QObject*>*)),this,SLOT(updateArtistsModel(QList<QObject*>*)));
}

void Controller::setPassword(QString password)
{
    this->password = password;
}

void Controller::setHostname(QString hostname)
{
    this->hostname = hostname;
    CommonDebug("Hostname set");
}


void Controller::setPort(int port)
{
    this->port = port;
}

void Controller::connectToServer()
{
    netaccess->connectToHost(hostname,port);
    //Try authentication
    if(password!="")
    {
        netaccess->authenticate(password);
    }
}

void Controller::requestCurrentPlaylist()
{
    netaccess->getCurrentPlaylistTracks();
}

void Controller::requestAlbums()
{
    netaccess->getAlbums();
}

void Controller::requestArtists()
{
    netaccess->getArtists();
}

void Controller::requestFiles(QString string)
{
    netaccess->getDirectory(string);
}

