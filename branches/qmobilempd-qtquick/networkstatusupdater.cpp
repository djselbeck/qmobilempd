#include "networkstatusupdater.h"

NetworkStatusUpdater::NetworkStatusUpdater(QObject *parent) :
    QThread(parent)
{
}

NetworkStatusUpdater::NetworkStatusUpdater(QString hostname, QString password, int port, QObject *parent) :
    QThread(parent)
{
    this->hostname = hostname;
    this->password = password;
    this->port = port;
    updatetimer = new QTimer(this);
    updatetimer->setInterval(1000);
    updatetimer->setSingleShot(false);
    connect(updatetimer,SIGNAL(timeout()),this,SLOT(doUpdate()),Qt::QueuedConnection);
    this->tcpsocket = new QTcpSocket(this);
    running = true;


}

/** connects to host and return true if successful, false if not. Takes an string as hostname and int as port */
bool NetworkStatusUpdater::connectToHost(QString hostname, quint16 port,QString password)
{
    tcpsocket->connectToHost(hostname ,port,QIODevice::ReadWrite);
    //connect(tcpsocket,SIGNAL(connected()),SLOT(socketConnected()));
    this->password = password;
    bool success = tcpsocket->waitForConnected(4000);
    if (!success)
    {
        return false;
    }
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        CommonDebug("Connection established\n");
        //Do host authentication
        tcpsocket->waitForReadyRead(READYREAD);
        QString response;
        while (tcpsocket->canReadLine())
        {
            response += tcpsocket->readLine();
            CommonDebug(response+"\n");
        }
        CommonDebug(response.toUtf8());
        QString teststring = response;
        teststring.truncate(6);
        if (teststring==QString("OK MPD"))
        {
            CommonDebug("Valid MPD found\n");

        }
        authenticate(password);
        //emit connectionestablished();
        return true;

    }
    return false;
}


status_struct NetworkStatusUpdater::getStatus()
{
    CommonDebug("updateStatusInternal called"); // &&!tcpsocket->canReadLine()
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        CommonDebug("updateStatusInternal called connect");
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
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
        quint32 playlistlength = 0;
        int elapsed =0;
        int runtime =0;
        QString tracknrstring="";
        int tracknr = 0;
        int albumtrackcount = 0;

        QString timestring;
        QString elapstr,runstr;
        QString volumestring;
        QString fileuri;
        quint8 playing=STOP;
        bool repeat=false;
        bool random=false;
        quint8 volume = 0;

        outstream << "status" << endl;
        while ((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead(READYREAD);
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if (response.left(9)==QString("bitrate: ")) {
                    bitrate = response.right(response.length()-9);
                    bitrate.chop(1);
                    CommonDebug("Bitrate:"+bitrate);
                }
                if (response.left(6)==QString("time: ")) {
                    timestring = response.right(response.length()-6);
                    timestring.chop(1);
                    elapstr = timestring.split(":").at(0);
                    runstr = timestring.split(":").at(1);
                    elapsed = elapstr.toInt();
                    runtime = runstr.toInt();
                }
                if (response.left(6)==QString("song: ")) {
                    playlistidstring = response.right(response.length()-6);
                    playlistidstring.chop(1);
                    playlistid = playlistidstring.toUInt();
                }
                if (response.left(8)==QString("volume: ")) {
                    volumestring = response.right(response.length()-8);
                    volumestring.chop(1);
                    volume = volumestring.toUInt();
                }
                if (response.left(10)==QString("playlist: ")) {
                    volumestring = response.right(response.length()-10);
                    volumestring.chop(1);
                    playlistversion = volumestring.toUInt();
                }
                if (response.left(16)==QString("playlistlength: ")) {
                    volumestring = response.right(response.length()-16);
                    volumestring.chop(1);
                    playlistlength = volumestring.toUInt();
                }
                if (response.left(7)==QString("state: ")) {
                    {
                        volumestring = response.right(response.length()-7);
                        volumestring.chop(1);
                        if (volumestring == "play")
                        {
                            CommonDebug("currently playing:"+volumestring.toAscii());
                            playing = PLAYING;
                        }
                        else if (volumestring == "pause") {
                            CommonDebug("currently paused:"+volumestring.toAscii());
                            playing = PAUSE;
                        }
                        else if (volumestring == "stop") {
                            CommonDebug("currently NOT playing:"+volumestring.toAscii());
                            playing = STOP;
                        }
                    }
                }
                if (response.left(8)==QString("repeat: ")) {
                    {
                        volumestring = response.right(response.length()-8);
                        volumestring.chop(1);
                        CommonDebug("repeat:"+volumestring.toUtf8());
                        if (volumestring == "1")
                        {
                            repeat = true;
                        }
                        else {
                            repeat = false;
                        }
                    }
                }
                if (response.left(8)==QString("random: ")) {
                    {
                        volumestring = response.right(response.length()-8);
                        volumestring.chop(1);
                        CommonDebug("random:"+volumestring.toUtf8());
                        if (volumestring == "1")
                        {
                            random = true;
                        }
                        else {
                            random = false;
                        }
                    }
                }

            }
        }

        response = "";
        outstream << "currentsong" << endl;
        while ((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            tcpsocket->waitForReadyRead(READYREAD);
            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                if (response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                }
                else if (response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                }
                else if (response.left(7)==QString("Album: ")) {
                    album = response.right(response.length()-7);
                    album.chop(1);
                }
                else if (response.left(6)==QString("file: ")) {
                    fileuri = response.right(response.length()-6);
                    fileuri.chop(1);
                }
                else if (response.left(7)==QString("Track: "))
                {
                    tracknrstring = response.right(response.length()-7);
                    tracknrstring.chop(1);
                    //tracknr = tracknrstring.toInt();
                    QStringList tempstrs = tracknrstring.split("/");
                    if(tempstrs.length()==2)
                    {
                        tracknr = tempstrs.first().toUInt();
                        albumtrackcount = tempstrs.at(1).toUInt();

                    }
                    if(tempstrs.length()==1)
                    {
                        tracknr = tracknrstring.toUInt();
                    }
                    CommonDebug("Tracks:"+QString::number(tracknr)+"/"+QString::number(albumtrackcount));
                }
            }
        }

        status_struct tempstat;
        if ((runtime!=0)&&(elapsed!=0)) {
            tempstat.percent = ((elapsed*100)/runtime);
        }
        else {
            tempstat.percent=0;
        }

        //TODO Samplerate,channel count, bit depth
        tempstat.info = "Bitrate: "+bitrate.toUtf8();
        tempstat.album = album;
        tempstat.title = title;
        tempstat.artist = artist;
        tempstat.id = playlistid;
        tempstat.volume = volume;
        tempstat.playing = playing;
        tempstat.playlistversion = playlistversion;
        tempstat.playlistlength = playlistlength;
        tempstat.repeat = repeat;
        tempstat.shuffle = random;
        tempstat.currentpositiontime=elapsed;
        tempstat.length = runtime;
        tempstat.fileuri=fileuri;
        tempstat.tracknr = tracknr;
        tempstat.bitrate = bitrate.toUInt();
        tempstat.albumtrackcount = albumtrackcount;
        if(mPlaylistversion!=tempstat.playlistversion)
        {
            CommonDebug("Playlist version change detected");
            //TODO FIX
            getCurrentPlaylistTracks();
        }
        mPlaylistversion=tempstat.playlistversion;
        return tempstat;
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
    tempstat.playing = STOP;
    tempstat.currentpositiontime=0;
    tempstat.length=0;
    tempstat.fileuri="";
    tempstat.tracknr = 0;
    tempstat.bitrate = 0;
    tempstat.albumtrackcount = 0;
    tempstat.playlistlength = 0;
    if(mPlaylistversion!=tempstat.playlistversion)
    {
        CommonDebug("Playlist version change detected");
        getCurrentPlaylistTracks();
    }
    mPlaylistversion=tempstat.playlistversion;
    return tempstat;
}


void NetworkStatusUpdater::setInterval(int time)
{
    //updatetimer->setInterval(time);
}

void NetworkStatusUpdater::run()
{
    if(!(tcpsocket->state()==QTcpSocket::ConnectedState))
    {
        CommonDebug("Connected to server:"+hostname+":"+"password"+".  "+QString::number(connectToHost(hostname,port,password)));
    }
    CommonDebug("Start updater thread");
    while(running)
    {
        emit statusUpdate(getStatus());
        sleep(1);
    }
}

void NetworkStatusUpdater::doUpdate()
{
    CommonDebug("DONE UPDATE");
    running = true;
}

void NetworkStatusUpdater::stopUpdating()
{
    running=false;
}

bool NetworkStatusUpdater::authenticate(QString password)
{
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {

        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "password " << password << "\n";
        outstream.flush();
        tcpsocket->waitForReadyRead(READYREAD);
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
        if (teststring==QString("OK"))
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

QList<MpdTrack*> *NetworkStatusUpdater::getCurrentPlaylistTracks()
{
    QList<MpdTrack*> *temptracks = new QList<MpdTrack*>();
    if (tcpsocket->state() == QAbstractSocket::ConnectedState) {
        QString response ="";
        MpdTrack *temptrack=NULL;
        QString title;
        QString file;
        QString artist;
        QString albumstring;
        quint32 length=-1;
        QTextStream outstream(tcpsocket);
        outstream.setCodec("UTF-8");
        outstream << "playlistinfo " << endl;
        CommonDebug("Start reading playlist");
        while ((tcpsocket->state()==QTcpSocket::ConnectedState)&&((response.left(2)!=QString("OK")))&&((response.left(3)!=QString("ACK"))))
        {
            if (!tcpsocket->waitForReadyRead(READYREAD))
            {
                CommonDebug("false:waitforreadyread()");
                CommonDebug("error:"+tcpsocket->errorString().toAscii());
            }

            while (tcpsocket->canReadLine())
            {
                response = QString::fromUtf8(tcpsocket->readLine());
                CommonDebug("Response: "+response);
                if (response.left(6)==QString("file: ")) {
                    if (temptrack!=NULL)
                    {
                        temptracks->append(temptrack);
                        CommonDebug("add Track:");
                        temptrack=NULL;
                    }
                    if (temptrack==NULL)
                    {
                        temptrack = new MpdTrack(NULL);
                        temptrack->setPlaying(false);
                    }
                    file = response.right(response.length()-6);
                    file.chop(1);
                    temptrack->setFileUri(file);
                }
                if (response.left(7)==QString("Title: ")) {
                    title = response.right(response.length()-7);
                    title.chop(1);
                    temptrack->setTitle(title);
                }
                if (response.left(8)==QString("Artist: ")) {
                    artist = response.right(response.length()-8);
                    artist.chop(1);
                    temptrack->setArtist(artist);
                }
                if (response.left(7)==QString("Album: ")) {
                    albumstring = response.right(response.length()-7);
                    albumstring.chop(1);
                    temptrack->setAlbum(albumstring);
                }

                if (response.left(6)==QString("Time: ")) {
                    albumstring = response.right(response.length()-6);
                    albumstring.chop(1);
                    length = albumstring.toUInt();
                    temptrack->setLength(length);
                }
            }

        }
        if (temptrack!=NULL)
        {
            temptracks->append(temptrack);
            CommonDebug("add Track:");
        }
    }
    emit currentPlayListReady((QList<QObject*>*)temptracks);
    return temptracks;
}
