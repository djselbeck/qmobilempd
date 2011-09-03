#include "controller.h"
Controller::Controller(QObject *parent) : QObject(parent)
{

}

Controller::Controller(QmlApplicationViewer *viewer,QObject *parent) : QObject(parent),viewer(viewer),password(""),hostname(""),port(6600)
{
    netaccess = new NetworkAccess(0);
    netaccess->setUpdateInterval(1000);
    networkthread = new QThreadEx(this);
    netaccess->moveToThread(networkthread);
    networkthread->start();
    currentsongid=0;
    playlistversion = 0;
    playlist = 0;
    connectSignals();
    readSettings();

}

void Controller::updatePlaylistModel(QList<QObject*>* list)
{
    CommonDebug("PLAYLIST  UPDATE REQUIRED\n");
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
        emit filesModelReady();
    }

}

void Controller::updateSavedPlaylistsModel(QStringList *list)
{
    if(list->length()>0)
    {
        viewer->rootContext()->setContextProperty("savedPlaylistsModel",QVariant::fromValue(*list));
        emit savedPlaylistsReady();
    }
}

void Controller::updateSavedPlaylistModel(QList<QObject*>* list)
{
    if(list->length()>0)
    {
        viewer->rootContext()->setContextProperty("savedPlaylistModel",QVariant::fromValue(*list));
        emit savedPlaylistReady();
    }
}

void Controller::updateArtistsModel(QList<QObject*>* list)
{
    CommonDebug("ARTISTS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("artistsModel",QVariant::fromValue(*list));
    emit artistsReady();
}

void Controller::updateArtistAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("ARTIST ALBUMS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
    emit artistAlbumsReady();
}

void Controller::updateAlbumsModel(QList<QObject*>* list)
{
    CommonDebug("ALBUMS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumsModel",QVariant::fromValue(*list));
    emit albumsReady();
}

void Controller::updateAlbumTracksModel(QList<QObject*>* list)
{
    CommonDebug("ALBUM TRACKS UPDATE REQUIRED");
    viewer->rootContext()->setContextProperty("albumTracksModel",QVariant::fromValue(*list));
    emit albumTracksReady();
}

void Controller::connectSignals()
{
    CommonDebug("Connecting Signals with qml part");
    QObject *item = (QObject *)viewer->rootObject();
    qRegisterMetaType<status_struct>("status_struct");
    qRegisterMetaType<QList<MpdTrack*>*>("QList<MpdTrack*>*");
    qRegisterMetaType<QList<MpdAlbum*>*>("QList<MpdAlbum*>*");
    qRegisterMetaType<QList<MpdArtist*>*>("QList<MpdArtist*>*");
    qRegisterMetaType<QList<MpdFileEntry*>*>("QList<MpdFileEntry*>*");
    connect(item,SIGNAL(setHostname(QString)),this,SLOT(setHostname(QString)));
    connect(item,SIGNAL(setPassword(QString)),this,SLOT(setPassword(QString)));
    connect(item,SIGNAL(setPort(int)),this,SLOT(setPort(int)));
    connect(item,SIGNAL(connectToServer()),this,SLOT(connectToServer()));
    connect(item,SIGNAL(requestCurrentPlaylist()),netaccess,SLOT(getCurrentPlaylistTracks()));
    connect(item,SIGNAL(requestArtists()),netaccess,SLOT(getArtists()));
    connect(item,SIGNAL(requestArtistAlbums(QString)),netaccess,SLOT(getArtistsAlbums(QString)));
    connect(item,SIGNAL(requestAlbums()),netaccess,SLOT(getAlbums()));
    connect(item,SIGNAL(requestFilesPage(QString)),this,SLOT(requestFilePage(QString)));
    connect(item,SIGNAL(requestFilesModel(QString)),this,SLOT(requestFileModel(QString)));
  //  connect(item,SIGNAL(requestCurrentPlaylist()),this,SLOT(requestCurrentPlaylist()));
    connect(item,SIGNAL(playPlaylistTrack(int)),netaccess,SLOT(playTrackByNumber(int)));
    connect(item,SIGNAL(requestAlbum(QVariant)),netaccess,SLOT(getAlbumTracks(QVariant)));
    connect(item,SIGNAL(stop()),netaccess,SLOT(stop()));
    connect(item,SIGNAL(play()),netaccess,SLOT(pause()));
    connect(item,SIGNAL(next()),netaccess,SLOT(next()));
    connect(item,SIGNAL(prev()),netaccess,SLOT(previous()));
    connect(item,SIGNAL(deletePlaylist()),netaccess,SLOT(clearPlaylist()));
    connect(item,SIGNAL(addAlbum(QVariant)),netaccess,SLOT(addArtistAlbumToPlaylist(QVariant)));
    connect(item,SIGNAL(addFiles(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(item,SIGNAL(seek(int)),netaccess,SLOT(seek(int)));
    connect(this,SIGNAL(albumsReady()),item,SLOT(updateAlbumsModel()));
    connect(this,SIGNAL(artistsReady()),item,SLOT(updateArtistModel()));
    connect(this,SIGNAL(albumTracksReady()),item,SLOT(updateAlbumModel()));
    connect(this,SIGNAL(savedPlaylistsReady()),item,SLOT(updateSavedPlaylistsModel()));
    connect(this,SIGNAL(savedPlaylistReady()),item,SLOT(updateSavedPlaylistModel()));
    connect(item,SIGNAL(setVolume(int)),netaccess,SLOT(setVolume(int)));
    connect(item,SIGNAL(addArtist(QString)),netaccess,SLOT(addArtist(QString)));
    connect(item,SIGNAL(quit()),this,SLOT(quit()));
    connect(item,SIGNAL(savePlaylist(QString)),netaccess,SLOT(savePlaylist(QString)));
    connect(item,SIGNAL(requestSavedPlaylists()),netaccess,SLOT(getSavedPlaylists()));
    connect(netaccess,SIGNAL(savedPlaylistsReady(QStringList*)),this,SLOT(updateSavedPlaylistsModel(QStringList*)));
    connect(netaccess,SIGNAL(savedplaylistTracksReady(QList<QObject*>*)),this,SLOT(updateSavedPlaylistModel(QList<QObject*>*)));
    connect(this,SIGNAL(sendPopup(QVariant)),item,SLOT(slotShowPopup(QVariant)));
    connect(this,SIGNAL(sendStatus(QVariant)),item,SLOT(updateCurrentPlaying(QVariant)));
    connect(this,SIGNAL(playlistUpdated()),item,SLOT(updatePlaylist()));
    connect(this,SIGNAL(getFiles(QString)),netaccess,SLOT(getDirectory(QString)));
    connect(netaccess,SIGNAL(currentPlayListReady(QList<QObject*>*)),this,SLOT(updatePlaylistModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(albumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(artistsReady(QList<QObject*>*)),this,SLOT(updateArtistsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(artistAlbumsReady(QList<QObject*>*)),this,SLOT(updateAlbumsModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(albumTracksReady(QList<QObject*>*)),this,SLOT(updateAlbumTracksModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(filesReady(QList<QObject*>*)),this,SLOT(updateFilesModel(QList<QObject*>*)));
    connect(netaccess,SIGNAL(connectionestablished()),this,SLOT(connectedToServer()));
    connect(netaccess,SIGNAL(statusUpdate(status_struct)),this,SLOT(updateStatus(status_struct)));
    connect(netaccess,SIGNAL(userNotification(QVariant)),item,SLOT(slotShowPopup(QVariant)));
    connect(this,SIGNAL(requestConnect()),netaccess,SLOT(connectToHost()));
    connect(this,SIGNAL(requestDisconnect()),netaccess,SLOT(disconnect()));
    connect(this,SIGNAL(serverProfilesUpdated()),item,SLOT(settingsModelUpdated()));
    connect(item,SIGNAL(newProfile()),this,SLOT(newProfile()));
    connect(item,SIGNAL(changeProfile(QVariant)),this,SLOT(changeProfile(QVariant)));
    connect(item,SIGNAL(deleteProfile(int)),this,SLOT(deleteProfile(int)));
    connect(item,SIGNAL(connectProfile(int)),this,SLOT(connectProfile(int)));
    connect(item,SIGNAL(playSong(QString)),netaccess,SLOT(playTrack(QString)));
    connect(item,SIGNAL(addSong(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(item,SIGNAL(requestSavedPlaylist(QString)),netaccess,SLOT(getPlaylistTracks(QString)));
    connect(item,SIGNAL(addPlaylist(QString)),netaccess,SLOT(addPlaylist(QString)));
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
    //netaccess->connectToHost(hostname,port,password);
    netaccess->setConnectParameters(hostname,port,password);
    emit requestConnect();
    //Try authentication

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
    CommonDebug("RequestED artists");
}

void Controller::requestArtistAlbums(QString artist)
{
    netaccess->getArtistsAlbums(artist);
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
                &&status.id>=0&&currentsongid>=0){
            CommonDebug("1Changed playlist "+QString::number(status.id)+":"+QString::number(currentsongid));
            playlist->at(currentsongid)->setPlaying(false);
            playlist->at(status.id)->setPlaying(true);
            CommonDebug("2Changed playlist");

        }
        if(currentsongid==-1&&(playlist!=0&&playlist->length()>status.id&&playlist->length()>currentsongid
                               &&status.id>=0))
        {
            playlist->at(status.id)->setPlaying(true);
        }
    }
    currentsongid = status.id;
    if(playlist==0)
        currentsongid = -1;
    QStringList strings;
    strings.append(status.title);
    strings.append(status.album);
    strings.append(status.artist);
    strings.append(QString::number(status.currentpositiontime));
    strings.append(QString::number(status.length));
    strings.append(QString::number(status.bitrate));
    switch (status.playing) {
    case NetworkAccess::PLAYING:
    {
        strings.append("playing");
        break;
    }
    case NetworkAccess::PAUSE:
    {
        strings.append("pause");
        break;
    }
    case NetworkAccess::STOP:
    {
        strings.append("stop");
        break;
    }
    default: strings.append("stop");
    }
    strings.append(QString::number(status.volume));

    emit sendStatus(strings);
}

void Controller::seek(int pos)
{
    netaccess->seekPosition(currentsongid,pos);
}

void Controller::requestFileModel(QString path)
{
    CommonDebug("Connecting Signals with qml part");
    QObject *item = (QObject *)viewer->rootObject();
    disconnect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesModel()));
    disconnect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesPage()));
    connect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesModel()));
    emit getFiles(path);
}

void Controller::requestFilePage(QString path)
{
    CommonDebug("Connecting Signals with qml part");
    QObject *item = (QObject *)viewer->rootObject();
    disconnect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesModel()));
    disconnect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesPage()));
    connect(this,SIGNAL(filesModelReady()),item,SLOT(receiveFilesPage()));
    emit getFiles(path);
}

void Controller::readSettings()
{
    serverprofiles = new QList< ServerProfile*> ();
    QSettings settings;
    settings.beginGroup("server_properties");
    int size = settings.beginReadArray("profiles");
    CommonDebug(QString::number(size).toAscii()+" Settings found");
    QString hostname,password,name;
    int port;
    for(int i = 0;i<size;i++)
    {
        settings.setArrayIndex(i);
        hostname = settings.value("hostname").toString();
        password = settings.value("password").toString();
        name = settings.value("profilename").toString();
        port = settings.value("port").toUInt();
        serverprofiles->append(new ServerProfile(hostname,password,port,name));
    }
    settings.endArray();
    settings.endGroup();
    viewer->rootContext()->setContextProperty("settingsModel",QVariant::fromValue(*(QList<QObject*>*)serverprofiles));
    emit serverProfilesUpdated();
}

void Controller::writeSettings()
{
    QSettings settings;
        settings.beginGroup("server_properties");
        settings.beginWriteArray("profiles");
        for(int i=0;i<serverprofiles->length();i++)
        {
            settings.setArrayIndex(i);
            settings.setValue("hostname",serverprofiles->at(i)->getHostname());
            settings.setValue("password",serverprofiles->at(i)->getPassword());
            settings.setValue("profilename",serverprofiles->at(i)->getName());
            settings.setValue("port",serverprofiles->at(i)->getPort());
            CommonDebug("wrote setting:"+QString::number(i).toAscii());
        }
        settings.endArray();
        settings.endGroup();
        CommonDebug("Settings written");
}

void Controller::quit()
{
    writeSettings();
    exit(0);
}

void Controller::newProfile()
{
    serverprofiles->append(new ServerProfile("","",6600,"Profile_"+QString::number(serverprofiles->length())));
    viewer->rootContext()->setContextProperty("settingsModel",QVariant::fromValue(*(QList<QObject*>*)serverprofiles));
    emit serverProfilesUpdated();
}

void Controller::changeProfile(QVariant profile)
{
    QStringList strings = profile.toStringList();
    int i = strings.at(0).toInt();
    serverprofiles->at(i)->setName(strings[1]);
    serverprofiles->at(i)->setHostname(strings[2]);
    serverprofiles->at(i)->setPassword(strings[3]);
    serverprofiles->at(i)->setPort(strings.at(4).toInt());
    emit serverProfilesUpdated();
}

void Controller::deleteProfile(int index)
{
    serverprofiles->removeAt(index);
    viewer->rootContext()->setContextProperty("settingsModel",QVariant::fromValue(*(QList<QObject*>*)serverprofiles));
    emit serverProfilesUpdated();
}

void Controller::connectProfile(int index)
{
    ServerProfile *profile = serverprofiles->at(index);
    setHostname(profile->getHostname());
    setPort(profile->getPort());
    setPassword(profile->getPassword());
    if(netaccess->connected())
    {
        emit requestDisconnect();
    }
    connectToServer();
}
