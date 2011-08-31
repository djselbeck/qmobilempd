#include "controller.h"
Controller::Controller(QObject *parent) : QObject(parent)
{

}

Controller::Controller(QmlApplicationViewer *viewer,QObject *parent) : QObject(parent),viewer(viewer),password(""),hostname(""),port(6600)
{
    netaccess = new NetworkAccess(this);
    netaccess->setUpdateInterval(1000);
    currentsongid=0;
    playlistversion = 0;
    playlist = 0;
}

void Controller::updatePlaylistModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST UPDATE REQUIRED\n");
    if(playlist==0){
        currentsongid=0;
    } else{
        delete(playlist);
       // viewer->rootContext()->setContextProperty("playlistModel",QVariant::fromValue(0));
        playlist=0;
    }
    playlist = (QList<MpdTrack*>*)(list);
    viewer->rootContext()->setContextProperty("playlistModel",QVariant::fromValue(*list));
    CommonDebug("Playlist length:"+QString::number(playlist->length())+"\n");
    emit playlistUpdated();
}

void Controller::updateFilesModel(QList<QObject*>* list)
{
    CommonDebug("FILES UPDATE REQUIRED");
    if(list->length()>0)
    {
        MpdFileEntry *file = dynamic_cast<MpdFileEntry*>(list->at(0));

        viewer->rootContext()->setContextProperty("filesModel",QVariant::fromValue(*list));
        emit filesModelReady(QVariant::fromValue(*list));
    }

}

void Controller::updateArtistsModel(QList<QObject*>* list)
{
    CommonDebug("ARTISTS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("artistsModel",QVariant::fromValue(*list));
}

void Controller::updateArtistAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("ARTIST ALBUMS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
}

void Controller::updateAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("ALBUMS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
}

void Controller::updateAlbumTracksModel(QList<QObject*>* list)
{
    CommonDebug("ALBUM TRACKS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumTracksModel",QVariant::fromValue(*list));
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
    connect(item,SIGNAL(requestArtistAlbums(QString)),this,SLOT(requestArtistAlbums(QString)));
    connect(item,SIGNAL(requestAlbums()),this,SLOT(requestAlbums()));
    connect(item,SIGNAL(requestFiles(QString)),this,SLOT(requestFiles(QString)));
  //  connect(item,SIGNAL(requestCurrentPlaylist()),this,SLOT(requestCurrentPlaylist()));
    connect(item,SIGNAL(playPlaylistTrack(int)),netaccess,SLOT(playTrackByNumber(int)));
    connect(item,SIGNAL(requestAlbum(QVariant)),this,SLOT(requestAlbum(QVariant)));
    connect(item,SIGNAL(stop()),netaccess,SLOT(stop()));
    connect(item,SIGNAL(play()),netaccess,SLOT(pause()));
    connect(item,SIGNAL(next()),netaccess,SLOT(next()));
    connect(item,SIGNAL(prev()),netaccess,SLOT(previous()));
    connect(item,SIGNAL(deletePlaylist()),netaccess,SLOT(clearPlaylist()));
    connect(item,SIGNAL(addAlbum(QVariant)),this,SLOT(addAlbum(QVariant)));
    connect(item,SIGNAL(addFiles(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(item,SIGNAL(seek(int)),this,SLOT(seek(int)));
    connect(this,SIGNAL(sendPopup(QVariant)),item,SLOT(slotShowPopup(QVariant)));
    connect(this,SIGNAL(sendStatus(QVariant)),item,SLOT(updateCurrentPlaying(QVariant)));
    connect(this,SIGNAL(playlistUpdated()),item,SLOT(updatePlaylist()));
    connect(this,SIGNAL(filesModelReady(QVariant)),item,SLOT(receiveFilesModel(QVariant)));
    connect(netaccess,SIGNAL(currentPlayListReady(QList<QObject*>*)),this,SLOT(updatePlaylistModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(albumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(artistsReady(QList<QObject*>*)),this,SLOT(updateArtistsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(artistAlbumsReady(QList<QObject*>*)),this,SLOT(updateArtistAlbumsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(albumTracksReady(QList<QObject*>*)),this,SLOT(updateAlbumTracksModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(filesReady(QList<QObject*>*)),this,SLOT(updateFilesModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(connectionestablished()),this,SLOT(connectedToServer()));
    connect(netaccess,SIGNAL(statusUpdate(status_struct)),this,SLOT(updateStatus(status_struct)));

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
    netaccess->connectToHost(hostname,port,password);
    //Try authentication
    if(password!="")
    {
        netaccess->authenticate(password);
    }
}

void Controller::requestCurrentPlaylist()
{
    //netaccess->getCurrentPlaylistTracks();
}

void Controller::requestAlbums()
{
    netaccess->getAlbums();
}

void Controller::requestArtists()
{
    netaccess->getArtists();
}

void Controller::requestArtistAlbums(QString artist)
{
    netaccess->getArtistsAlbums(artist);
}

void Controller::requestFiles(QString string)
{
    netaccess->getDirectory(string);
}

void Controller::requestAlbum(QVariant array)
{
    QStringList strings = array.toStringList();
    for(int i=0;i<strings.length();i++)
    {
        CommonDebug("STRING: "+strings.at(i));
    }
    netaccess->getAlbumTracks(strings.at(1),strings.at(0));
}

void Controller::addAlbum(QVariant array)
{
    QStringList strings = array.toStringList();
    for(int i=0;i<strings.length();i++)
    {
        CommonDebug("STRING: "+strings.at(i));
    }
    netaccess->addArtistAlbumToPlaylist(strings.at(0),strings.at(1));
}

void Controller::connectedToServer()
{
    emit sendPopup(tr("Connected to server"));
}

void Controller::updateStatus(status_struct status)
{

    if(currentsongid != status.id)
    {
        if(status.playing==NetworkAccess::PLAYING)
            emit sendPopup(status.title+"\n"+status.album+"\n"+status.artist);
        if(playlist!=0&&playlist->length()>status.id&&playlist->length()>currentsongid
                &&status.id>=0){
            CommonDebug("1Changed playlist "+QString::number(status.id)+":"+QString::number(currentsongid));
            playlist->at(currentsongid)->setPlaying(false);
            playlist->at(status.id)->setPlaying(true);
            CommonDebug("2Changed playlist");

        }
    }
    currentsongid = status.id;
    if(playlist==0)
        currentsongid = INT_MAX;
    QStringList strings;
    strings.append(status.title);
    strings.append(status.album);
    strings.append(status.artist);
    strings.append(QString::number(status.currentpositiontime));
    strings.append(QString::number(status.length));
    strings.append(QString::number(status.bitrate));
    emit sendStatus(strings);
}

void Controller::seek(int pos)
{
    netaccess->seekPosition(currentsongid,pos);
}
