#include "networkaccess.h"
/** Constructor for NetworkAccess object. Handles all the network stuff
  */
NetworkAccess::NetworkAccess(QObject *parent) :
    QObject(parent)
{
    //create socket later used for communication
    tcpsocket = new QTcpSocket(this);
    statusupdater = new QTimer(this);
    connect(tcpsocket,SIGNAL(connected()),this,SLOT(connectedtoServer()));
    connect(tcpsocket,SIGNAL(disconnected()),this,SIGNAL(disconnected()));
    connect(tcpsocket,SIGNAL(disconnected()),this,SLOT(disconnectedfromServer()));
    connect(statusupdater,SIGNAL(timeout()),this,SLOT(updateStatusInternal()));
}


/** connects to host and return true if successful, false if not. Takes an string as hostname and int as port */
bool NetworkAccess::connectToHost(QString hostname, quint16 port)
{
        tcpsocket->connectToHost(hostname ,port,QIODevice::ReadWrite);
        connect(tcpsocket,SIGNAL(connected()),SLOT(socketConnected()));
        this->password = password;
        bool success = tcpsocket->waitForConnected();
        if(!success)
        {
            return false;
        }
        if(tcpsocket->state() == QAbstractSocket::ConnectedState){
            CommonDebug("Connection established\n");
            //Do host authentication
            tcpsocket->waitForReadyRead();
            QString response;
            while (tcpsocket->canReadLine())
            {
                response += tcpsocket->readLine();
            }
            CommonDebug(response.toUtf8());
            QString teststring = response;
            teststring.truncate(6);
            if(teststring==QString("OK MPD"))
            {
                CommonDebug("Valid MPD found\n");

            }
            return true;

        }
        return false;
}

void NetworkAccess::disconnect()
{
    tcpsocket->disconnectFromHost();
}


/** return all albums currently availible from connected MPD as MpdAlbum objects,
  * empty list if not connected or no albums are availible */
QList<MpdAlbum*> *NetworkAccess::getAlbums()
{
    QList<MpdAlbum*> *albums = new QList<MpdAlbum*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        //Start getting list from mpd
        //Send request
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");

        outstream << "list album" << endl;

        //Read all albums until OK send from mpd
        QString response ="";
        MpdAlbum *tempalbum;
        QString name;
        while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(7)==QString("Album: "))
                {
                    name = response.right(response.length()-7);
                    name.chop(1);
                    tempalbum = new MpdAlbum(NULL,name);
                    albums->append(tempalbum);
                }
            }
        }
    }

    //Get album tracks
    return albums;
}

QList<MpdArtist*> *NetworkAccess::getArtists()
{
    QList<MpdArtist*> *artists = new QList<MpdArtist*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        //Start getting list from mpd
        //Send request
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");

        outstream << "list artist" << endl;

        //Read all albums until OK send from mpd
        QString response ="";
        MpdArtist *tempartist;
        QString name;
        while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

                if(response.left(8)==QString("Artist: "))
                {
                    name = response.right(response.length()-8);name.chop(1);
                    tempartist = new MpdArtist(NULL,name);
                    artists->append(tempartist);
                }

            }
        }
    }
    return artists;
}



bool NetworkAccess::authenticate(QString password)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {

        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "password " << password << "\n";
        outstream.flush();
        tcpsocket->waitForReadyRead();
        //Check Response
        QString response;
        while (tcpsocket->canReadLine())
        {
            response += tcpsocket->readLine();
        }
        CommonDebug("Authentication:"+response.toUtf8()+"\n");
        QString teststring = response;
        CommonDebug("teststring:"+teststring.toAscii());
        teststring.truncate(2);
        if(teststring==QString("OK"))
        {
            CommonDebug("Valid password\n");
            return true;
        }
        else {
            CommonDebug("Invalid password sent\n");
            return false;
        }
        return false;
    }
    return false;
}

void NetworkAccess::socketConnected()
{
    emit connectionestablished();
}

QList<MpdAlbum*> *NetworkAccess::getArtistsAlbums(QString artist)
{
    QList<MpdAlbum*> *albums = new QList<MpdAlbum*>();
    //CommonDebug("Check connection state\n");
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        //Start getting list from mpd
        //Send request
        //CommonDebug("Send request for albums\n");
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream.setAutoDetectUnicode(false);
        outstream.setCodec("UTF-8");
        outstream << "list album \"" <<artist<<"\"" << endl;

        //Read all albums until OK send from mpd
        QString response ="";
        MpdAlbum *tempalbum;
        CommonDebug("Artist:"+artist.toAscii());
        QString name;
        while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(7)==QString("Album: "))
                {
                    name = response.right(response.length()-7);
                    name.chop(1);
                    tempalbum = new MpdAlbum(NULL,name);
                    albums->append(tempalbum);
                }
            }
        }
    }

    //Get album tracks

    return albums;
}

QList<MpdTrack*> *NetworkAccess::getAlbumTracks(QString album)
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        album.replace(QString("\""),QString("\\\""));

        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "find album \"" << album << "\""<< endl;
        QString response ="";

        MpdTrack *temptrack;
        QString title;
        QString artist;
        QString albumstring;
        QString file;
        quint32 length=1;
        while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                //New file: so new track begins in mpds output
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=NULL&&length!=0)
                    {
                        temptrack = new MpdTrack(NULL,file,title,artist,album,length);
                        temptracks->append(temptrack);
                        artist= "";
                        albumstring="";
                        length=0;
                        title="";
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                if(response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                }
                if(response.left(6)==QString("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    albumstring.chop(1);
                    length = albumstring.toUInt();
                }
            }
        }
        if(file!=""&&title!=NULL&&length!=0)
        {
            temptrack = new MpdTrack(NULL,file,title,artist,album,length);
            temptracks->append(temptrack);
        }
    }
    return temptracks;
}

QList<MpdTrack*> *NetworkAccess::getAlbumTracks(QString album, QString cartist)
{
    if(cartist=="")
    {
        return getAlbumTracks(album);
    }
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        album.replace(QString("\""),QString("\\\""));
        outstream << "find album \"" << album << "\""<< endl;
        QString response ="";

        MpdTrack *temptrack;
        QString title;
        QString artist;
        QString albumstring;
        QString file;
        quint32 length=0;
        while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                //New file: so new track begins in mpds output
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=NULL&&length!=0&&artist==cartist)
                    {
                        temptrack = new MpdTrack(NULL,file,title,artist,album,length);
                        temptracks->append(temptrack);
                        artist= "";
                        albumstring="";
                        length=0;
                        title="";
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                if(response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                }
                if(response.left(6)==QString("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    albumstring.chop(1);
                    length = albumstring.toUInt();
                }
            }
        }
        if(file!=""&&title!=NULL&&length!=0&&artist==cartist)
        {
            temptrack = new MpdTrack(NULL,file,title,artist,album,length);
            temptracks->append(temptrack);
        }
    }
    return temptracks;
}

QList<MpdTrack*> *NetworkAccess::getTracks()
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "listallinfo" <<endl;
        QString response ="";

        MpdTrack *temptrack;
        QString title;
        QString artist;
        QString albumstring;
        QString file;
        quint32 length=1;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                //New file: so new track begins in mpds output
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=NULL&&length!=0)
                    {
                        temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                        temptracks->append(temptrack);
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                if(response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                }
            }
        }
        if(file!=""&&title!=NULL&&length!=0)
        {
            temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
            temptracks->append(temptrack);
        }
    }
    return temptracks;
}

QList<MpdTrack*> *NetworkAccess::getCurrentPlaylistTracks()
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
            QString response ="";
            MpdTrack *temptrack;
            QString title;
            QString file;
            QString artist;
            QString albumstring;
            quint32 length=-1;
            QTextStream outstream(tcpsocket);
            outstream.setCodec("UTF-8");
            outstream << "playlistinfo " << endl;
            CommonDebug("Start reading playlist");
            while((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
            {
                if(!tcpsocket->waitForReadyRead())
                {
                    CommonDebug("false:waitforreadyread()");
                    CommonDebug("error:"+tcpsocket->errorString().toAscii());
                }

                while (tcpsocket->canReadLine())
                {
                    response = QString::fromUtf8(tcpsocket->readLine());
                    if(response.left(6)==QString("file: ")) {
                        if(file!=""&&title!=NULL&&length>=0)
                        {
                            temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                            temptracks->append(temptrack);
                        }
                        file = response.right(response.length()-6);
                        file.chop(1);
                    }
                    if(response.left(7)==QString("Title: ")) {
                        title = response.right(response.length()-7);
                        title.chop(1);
                    }
                    if(response.left(8)==QString("Artist: ")) {
                        artist = response.right(response.length()-8);
                        artist.chop(1);
                    }
                    if(response.left(7)==QString("Album: ")) {
                        albumstring = response.right(response.length()-7);
                        albumstring.chop(1);
                    }
                    if(response.left(6)==QString("Time: ")) {
                        albumstring = response.right(response.length()-6);
                        albumstring.chop(1);
                        length = albumstring.toUInt();
                    }
                }
            }
            if(file!=""&&title!=NULL&&length>=0)
            {
                temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                temptracks->append(temptrack);
            }
            return temptracks;
    }
    return temptracks;
}

QList<MpdTrack*> *NetworkAccess::getPlaylistTracks(QString name)
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {

        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");

        outstream << "listplaylistinfo \"" << name << "\"" << endl;
        QString response ="";
        MpdTrack *temptrack;
        QString title;
        QString file;
        QString lengthstring;
        QString albumstring;
        QString artist;
        quint32 length=1;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=NULL&&length!=0)
                    {
                        temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                        temptracks->append(temptrack);
                        artist= "";
                        albumstring="";
                        length=0;
                        title="";
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                if(response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                }
                if(response.left(6)==QString("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    albumstring.chop(1);
                    length = albumstring.toUInt();
                }
            }
        }
        if(file!=""&&title!=NULL&&length!=0)
        {
            temptrack = new MpdTrack(NULL,file,title,artist,albumstring ,length);
            temptracks->append(temptrack);
        }
    }
    return temptracks;
}

void NetworkAccess::updateStatusInternal()
{
    CommonDebug("updateStatusInternal called");
    if (tcpsocket->state() == QAbstractSocket::ConnectedState&&!tcpsocket->canReadLine()) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "status" << endl;
        QString response ="";
        MpdAlbum *tempalbum;
        QString name;
        QString title;
        QString album;
        QString artist;
        QString bitrate;

        qint32 percentage;
        quint32 playlistid=-1;
        QString playlistidstring="-1";
        quint32 playlistversion = 0;
        int elapsed =0;
        int runtime =0;

        QString timestring;
        QString elapstr,runstr;
        QString volumestring;
        bool playing=false;
        bool repeat=false;
        bool random=false;
        quint8 volume = 0;

        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(9)==QString("bitrate: ")) {
                    bitrate = response.right(response.length()-9);
                    bitrate.chop(1);
                }
                if(response.left(6)==QString("time: ")) {
                    timestring = response.right(response.length()-6);
                    timestring.chop(1);
                    elapstr = timestring.split(":").at(0);
                    runstr = timestring.split(":").at(1);
                    elapsed = elapstr.toInt();
                    runtime = runstr.toInt();
                }
                if(response.left(6)==QString("song: ")) {
                    playlistidstring = response.right(response.length()-6);
                    playlistidstring.chop(1);
                    playlistid = playlistidstring.toUInt();
                }
                if(response.left(8)==QString("volume: ")) {
                    volumestring = response.right(response.length()-8);
                    volumestring.chop(1);
                    volume = volumestring.toUInt();
                }
                if(response.left(10)==QString("playlist: ")) {
                    volumestring = response.right(response.length()-10);
                    volumestring.chop(1);
                    playlistversion = volumestring.toUInt();
                }
                if(response.left(7)==QString("state: ")) {
                    {
                        volumestring = response.right(response.length()-7);
                        volumestring.chop(1);
                        if(volumestring == "play")
                        {
                            playing = true;
                        }
                        else{
                                                        CommonDebug("currently NOT playing:"+volumestring.toAscii());playing = false;}
                    }
                }
                if(response.left(8)==QString("repeat: ")) {
                    {
                        volumestring = response.right(response.length()-8);
                        volumestring.chop(1);
                        CommonDebug("repeat:"+volumestring.toUtf8());
                        if(volumestring == "1")
                        {
                           repeat = true;
                        }
                        else{
                             repeat = false;
                        }
                    }
                }
                if(response.left(8)==QString("random: ")) {
                    {
                        volumestring = response.right(response.length()-8);
                        volumestring.chop(1);
                        CommonDebug("random:"+volumestring.toUtf8());
                        if(volumestring == "1")
                        {
                            random = true;
                        }
                        else{
                            random = false;
                        }
                    }
                }

                            }
        }

        response = "";
        outstream << "currentsong" << endl;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                else if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                else if(response.left(7)==QString("Album: ")) {
                    album = response.right(response.length()-7);
                    album.chop(1);
                }
            }
        }

        status_struct tempstat;
        if((runtime!=0)&&(elapsed!=0)){
            tempstat.percent = ((elapsed*100)/runtime);
        }
        else {tempstat.percent=0;}

        //TODO Samplerate,channel count, bit depth
        tempstat.info = "Bitrate: "+bitrate.toUtf8();
        tempstat.album = album;
        tempstat.title = title;
        tempstat.artist = artist;
        tempstat.id = playlistid;
        tempstat.volume = volume;
        tempstat.playing = playing;
        tempstat.playlistversion = playlistversion;
        tempstat.repeat = repeat;
        tempstat.shuffle = random;
        emit statusUpdate(tempstat);
        return;
    }
    status_struct tempstat;
    tempstat.repeat=false;
    tempstat.shuffle=false;
    tempstat.id = -1;
    tempstat.percent = 0;
    tempstat.album="";
    tempstat.info="";
    tempstat.title="";
    tempstat.artist="";
    tempstat.volume=0;
    tempstat.playlistversion = 0;
    tempstat.playing = false;
    emit statusUpdate(tempstat);
}

void NetworkAccess::pause()
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "pause" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::stop()
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "stop" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::next()
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "next" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::previous()
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "previous" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::addAlbumToPlaylist(QString album)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        album.replace(QString("\""),QString("\\\""));
        outstream << "find album \"" << album << "\""<< endl;
        QString response ="";
        MpdAlbum *tempalbum;
        MpdTrack *temptrack;
        QString title;
        QString file;
        quint32 length=1;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=NULL&&length!=0)
                    {
                        temptrack = new MpdTrack(NULL,file,title,length);
                        temptracks->append(temptrack);
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
            }
        }
        if(file!=""&&title!=NULL&&length!=0)
        {
            temptrack = new MpdTrack(NULL,file,title,length);
            temptracks->append(temptrack);
        }

        //Add Tracks to Playlist
        outstream.setCodec("UTF-8");
        outstream << "command_list_begin" << endl;
        for(int i=0;i<temptracks->length();i++)
        {
            outstream << "add \"" << temptracks->at(i)->getFileUri() << "\""<< endl;
        }
        outstream << "command_list_end" << endl;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
            }
        }
    }
 //   updateStatusInternal();
}

void NetworkAccess::addTrackToPlaylist(QString fileuri)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "add \"" << fileuri << "\"" << endl;
        QString response ="";
        //Clear read buffer
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
    }
}



//Appends song with uri and plays it back
void NetworkAccess::playTrack(QString fileuri)
{
    CommonDebug("Play request:"+fileuri.toAscii());
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "add \"" << fileuri << "\"" << endl;
        QString response ="";
        //Clear read buffer
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        //Get song id in playlist

        response = "";
        QString idstring;
        QString fileuristring;
        outstream.setCodec("UTF-8");
        outstream << "playlist " << endl;
        QStringList stringlist;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response!="OK" && response!="ACK") {
                    //TODO performance optimaization checks
                    stringlist = response.split(":");
                    if(stringlist.length()==3){
                        idstring = stringlist.first();
                        fileuristring = stringlist.at(2);
                        fileuristring.chop(1);
                        if(fileuristring.right(fileuristring.length()-1) == fileuri)
                        {
                            outstream << "play " << idstring << endl;
                        }
                    }
                }
            }
        }

    }
}

void NetworkAccess::playTrackByNumber(qint32 nr)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "play " << QString::number(nr).toAscii() << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::setRepeat(bool repeat)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "repeat " << (repeat ? "1":"0") << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
    }
}

void NetworkAccess::setRandom(bool random)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "random " << (random ? "1":"0") << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();

    }

}

void NetworkAccess::setVolume(quint8 volume)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "setvol " << QString::number(volume).toAscii() << endl;
        QString response ="";
        CommonDebug("setVolume called with:"+QString::number(volume).toAscii());
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
    }
}

bool NetworkAccess::savePlaylist(QString name)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "save \"" << name << "\"" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        if(response.left(2)=="OK")
        {
            return true;
        }
        else { return false;}

    }
    return false;
}

QStringList *NetworkAccess::getSavedPlaylists()
{
    QStringList *tempplaylists  = new QStringList();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "listplaylists" <<endl;
        QString response ="";

        MpdTrack *temptrack;
        QString name;

        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(10)==QString("playlist: ")) {
                    name = response.right(response.length()-10);
                    name.chop(1);
                    CommonDebug("found playlist:"+name.toAscii());
                    tempplaylists->append(name);
                }
            }
        }

    }
    return tempplaylists;
}


void NetworkAccess::addPlaylist(QString name)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "load \"" << name << "\"" <<endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
    }
}

void NetworkAccess::clearPlaylist()
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream << "clear" << endl;
        QString response ="";
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());

            }
        }
        updateStatusInternal();
    }
}

void NetworkAccess::disconnectedfromServer()
{
    statusupdater->stop();
    CommonDebug("got disconnected!");
}

void NetworkAccess::connectedtoServer(){
    statusupdater->start(5000);
}

quint32 NetworkAccess::getPlayListVersion()
{
    quint32 playlistversion = 0;
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "status" << endl;
        QString response ="";
        QString versionstring;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if(response.left(10)==QString("playlist: ")) {
                    versionstring = response.right(response.length()-10);
                    versionstring.chop(1);
                    playlistversion = versionstring.toUInt();
                }
            }
        }
    }
    return playlistversion;
}

QList<MpdFileEntry*> *NetworkAccess::getDirectory(QString path)
{
         QList<MpdFileEntry*> *tempfiles = new QList<MpdFileEntry*>();
         if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        path.replace(QString("\""),QString("\\\""));

        QTextStream outstream(tcpsocket);

        outstream.setCodec("UTF-8");

        outstream << "lsinfo \"" << path << "\"" << endl;
        QString response ="";

        MpdTrack *temptrack;
        MpdFileEntry *tempfile;
        QString title;
        QString artist;
        QString albumstring;
        QString file;
        QString filename;
        QString prepath;
        QStringList tempsplitter;
        quint8 filetype=-1;
        quint32 length=0;
        while(((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead();
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                //New file: so new track begins in mpds output
                if(response.left(6)==QString("file: ")) {
                    if(file!=""&&title!=""&&length!=0)
                    {
                        tempsplitter = file.split("/");
                        if(tempsplitter.length()>0)
                        {
                            temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                            prepath ="";
                            for(int j=0;j<tempsplitter.length()-1;j++)
                            {
                                prepath += tempsplitter.at(j);
                                if(j!=tempsplitter.length()-2)
                                {
                                    prepath += "/";
                                }

                            }
                            tempfile = new MpdFileEntry(prepath,tempsplitter.last(),MpdFileEntry::MpdFileType_File,temptrack,NULL);
                            tempfiles->append(tempfile);
                            tempsplitter.clear();
                        }
                        artist= "";
                        albumstring="";
                        length=0;
                        title="";
                        CommonDebug("got File:"+file.toAscii());
                        filename="";
                        filetype = -1;
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                }
                if(response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                if(response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                if(response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                }
                if(response.left(6)==QString("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    albumstring.chop(1);
                    length = albumstring.toUInt();
                }
                //Directory found. WORKS
                if(response.left(11)==QString("directory: "))
                {
                    filename = response.right(response.length()-11);
                    filename.chop(1);
                    tempsplitter = filename.split("/");
                    if(tempsplitter.length()>0)
                    {
                        prepath ="";
                        for(int j=0;j<tempsplitter.length()-1;j++)
                        {
                            prepath += tempsplitter.at(j);
                            if(j!=tempsplitter.length()-2)
                            {
                                prepath += "/";
                            }

                        }
                        tempfile = new MpdFileEntry(path,tempsplitter.last(),1,NULL);
                        tempfiles->append(tempfile);
                        filename = "";
                        tempsplitter.clear();
                    }

                }
            }
        }
        //LAST FILE ADD
        if(file!=""&&title!=""&&length!=0)
        {
            tempsplitter = file.split("/");
            if(tempsplitter.length()>0)
            {
                temptrack = new MpdTrack(NULL,file,title,artist,albumstring,length);
                prepath ="";
                for(int j=0;j<tempsplitter.length()-1;j++)
                {
                    prepath += tempsplitter.at(j);
                    if(j!=tempsplitter.length()-2)
                    {
                        prepath += "/";
                    }

                }
                tempfile = new MpdFileEntry(prepath,tempsplitter.last(),MpdFileEntry::MpdFileType_File,temptrack,NULL);
                tempfiles->append(tempfile);
                tempsplitter.clear();
            }
        }
    }
    return tempfiles;
}

void NetworkAccess::resumeUpdates()
{
    if(tcpsocket->state()==QTcpSocket::ConnectedState){
        updateStatusInternal();
        statusupdater->start(5000);
        CommonDebug("resumed status updates");
    }
}

void NetworkAccess::suspendUpdates()
{
    CommonDebug("suspended status updates");
    statusupdater->stop();;
}

