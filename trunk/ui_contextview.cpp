#include "ui_contextview.h"
#include "ui_ui_contextview.h"

Ui_ContextView::Ui_ContextView(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Ui_ContextView)
{

}

Ui_ContextView::Ui_ContextView(QWidget *parent, NetworkAccess *netaccess) : QWidget(parent), ui(new Ui::Ui_ContextView)
{
    this->netaccess = netaccess;
    ui->setupUi(this);
#ifdef Q_OS_SYMBIAN
    QFont tempfont = QFont("Arial",8);
    tempfont.setBold(false);
    ui->listWidget->setFont(tempfont);
#endif
    //this->setParent(parent);
    //Initialize fade animations
    //TODO cleanup
    listoutanimation =NULL;
    listinanimation = NULL;
    setupAnimations();
     ui->listWidget->setVerticalScrollMode(QListView::ScrollPerPixel);
     ui->listWidget->setHorizontalScrollMode(QListView::ScrollPerPixel);
     kineticscroller = new QsKineticScroller(this);
     kineticscroller->enableKineticScrollFor(ui->listWidget);
     ui->listWidget->setVerticalScrollBarPolicy(Qt::ScrollBarAsNeeded);
     ui->listWidget->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
     ui->listWidget->setIconSize(QSize(32,32));
     setupContextMenu();
CommonDebug("Context Menu created");
     //Context Menu
     ui->listWidget->setContextMenuPolicy(Qt::CustomContextMenu);
     // Connect to customContextMenuRequested signal
     QObject::connect(ui->listWidget, SIGNAL(customContextMenuRequested(const QPoint&)),
     this, SLOT(showContextMenu(const QPoint&)));

     // Context menu for QListWidget
     m_contextMenu = new QMenu(this);

     // Create one action item
     act_addToPlaylist = new QAction("Add to Playlist",0);
//     m_contextMenu->addAction(act_addToPlaylist);

    playingid = -1;

    songinfo = NULL;
    CommonDebug("Context View created");
    ui->btnAdd->hide();
    ui->btnBack->hide();

    ui->btnClear->hide();
    ui->btnLoadPlaylist->hide();
    ui->btnSavePlaylist->hide();
    connect(netaccess,SIGNAL(statusUpdate(status_struct)),this,SLOT(updateStatus(status_struct)));
    connect(netaccess,SIGNAL(disconnected()),this,SLOT(disconnectedFromServer()));
    connect(netaccess,SIGNAL(connectionestablished()),this,SLOT(connectedToServer()));
    //connect(netaccess,SIGNAL(connectionestablished()),this,SLOT(disconnectedFromServer()));
    connect(ui->btnAdd,SIGNAL(clicked()),this,SLOT(addButtonDispatcher()));
    connect(ui->btnBack,SIGNAL(clicked()),this,SLOT(backButtonDispatcher()));
    connect(ui->btnPlay,SIGNAL(clicked()),this,SLOT(playButtonDispatcher()));
    connect(ui->btnQuit,SIGNAL(clicked()),this,SLOT(quitApplication()));
    connect(ui->btnSavePlaylist,SIGNAL(clicked()),this,SLOT(savePlaylist()));
    connect(ui->btnLoadPlaylist,SIGNAL(clicked()),this,SLOT(showPlaylists()));
    connect(ui->btnClear,SIGNAL(clicked()),this,SLOT(clearPlaylist()));
    currentalbum = "";
    currentartist = "";
    currentplaylist ="";
    lastplaylist = new QList<MpdTrack*>();
    playlistchanged = false;
    currentmode = viewmode_currentplaylist;
}


Ui_ContextView::~Ui_ContextView()
{
    delete ui;
}

void Ui_ContextView::disconnectSelectSignals()
{
    disconnect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),0,0);
    disconnect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),0,0);
  //  disconnect(ui->btnAdd,SIGNAL(clicked()),0,0);
    disconnect(act_addToPlaylist, SIGNAL(triggered()),0,0);
}

void Ui_ContextView::showArtists()
{
    ui->btnAdd->show();
    ui->btnBack->show();
    ui->btnClear->hide();
    ui->btnPlay->show();
    ui->btnLoadPlaylist->hide();
    ui->btnSavePlaylist->hide();
    //Disconnect all Handlers        CommonDebug("Artist:"+artist.toAscii());
    hideLibrarySongInfo();
    disconnectSelectSignals();
    connect(listoutanimation,SIGNAL(finished()),this,SLOT(afterAnimationshowArtists()));
    slideListWidgetLeft();
}

void Ui_ContextView::showTracks()
{
    ui->btnAdd->show();
    ui->btnBack->show();
    ui->btnClear->hide();
    ui->btnLoadPlaylist->hide();
    ui->btnSavePlaylist->hide();
    //Disconnect all Handlers
    disconnectSelectSignals();
    slideListWidgetLeft();
    MpdTrack *temptrack;
    wliTrack *tempitem;
    currentalbum = "";
    currentartist = "";



    QList<MpdTrack*> *temptracks = netaccess->getTracks();
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(false);
    for(int i=0;i<temptracks->length();i++)
        {
            temptrack = temptracks->at(i);
            tempitem = new wliTrack(ui->listWidget,1000,temptrack);
        }

    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showLibrarySongInfo(QListWidgetItem*)));

    //delete(temptracks);
    slideListWidgetRight();
    //FIXME


}

void Ui_ContextView::afterAnimationshowArtists()
{
    QList<MpdArtist*> *tempartists = netaccess->getArtists();
    //Remove old items

    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(true);
    for(int i=0;i<tempartists->length();i++)
        {
            ui->listWidget->addItem(new QListWidgetItem(tempartists->at(i)->getName()));
        }
    slideListWidgetRight();

    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showArtistAlbums(QListWidgetItem*)));

    MpdArtist *tempartist;
    for(int i=0;i<tempartists->length();i++)
    {
        tempartist=tempartists->at(i);
        delete(tempartist);
    }
    delete(tempartists);
    disconnect(listoutanimation,SIGNAL(finished()),0,0);
    //FIXME
    ui->btnAdd->show();
    ui->btnBack->show();
    currentmode = viewmode_artists;
    ui->lblCurrentView->setText(tr("Artists:"));

}

void Ui_ContextView::showAlbums()
{
    ui->btnAdd->show();
    ui->btnBack->show();
    ui->btnClear->hide();
    ui->btnPlay->show();
    ui->btnLoadPlaylist->hide();
    ui->btnSavePlaylist->hide();
    hideLibrarySongInfo();
    currentalbum="";
    currentartist="";
    //Disconnect all Handlers
    disconnectSelectSignals();
    connect(listoutanimation,SIGNAL(finished()),this,SLOT(afterAnimationshowAlbums()));
    slideListWidgetLeft();

}

void Ui_ContextView::afterAnimationshowAlbums()
{
    QList<MpdAlbum*> *tempalbums = netaccess->getAlbums();
    //Remove old items
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(true);
    for(int i=0;i<tempalbums->length();i++)
        {
            ui->listWidget->addItem(new QListWidgetItem(tempalbums->at(i)->getTitle()));
        }
    slideListWidgetRight();
    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showAlbumTracks(QListWidgetItem*)));
    connect(act_addToPlaylist, SIGNAL(triggered()), this, SLOT(addAlbumToPlaylist()));
    ui->btnAdd->show();
    ui->btnBack->show();
    MpdAlbum *tempalbum;
    for(int i=0;i<tempalbums->length();i++)
    {
        tempalbum=tempalbums->at(i);
        delete(tempalbum);
    }
    delete(tempalbums);
    disconnect(listoutanimation,SIGNAL(finished()),0,0);
    //FIXME
    currentmode = viewmode_albums;
    ui->lblCurrentView->setText(tr("Albums:"));
}


void Ui_ContextView::showArtistAlbums(QListWidgetItem *item)
{
    ui->btnClear->hide();
    ui->btnLoadPlaylist->hide();
    ui->btnSavePlaylist->hide();
    //Disconnect all Handlers
    disconnectSelectSignals();
    slideListWidgetLeft();
    QList<MpdAlbum*> *tempalbums = netaccess->getArtistsAlbums(item->text());


    currentartist = item->text();
    CommonDebug("artist clicked:"+currentartist.toUtf8());
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(true);
    for(int i=0;i<tempalbums->length();i++)
        {
            ui->listWidget->addItem(new QListWidgetItem(tempalbums->at(i)->getTitle()));
        }
    slideListWidgetRight();
    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showAlbumTracks(QListWidgetItem*)));
    connect(act_addToPlaylist, SIGNAL(triggered()), this, SLOT(addAlbumToPlaylist()));
    ui->btnAdd->show();
    ui->btnBack->show();
    ui->btnPlay->show();
    MpdAlbum *tempalbum;
    for(int i=0;i<tempalbums->length();i++)
    {
        tempalbum=tempalbums->at(i);
        delete(tempalbum);
    }
    delete(tempalbums);
    //FIXME
    currentmode = viewmode_artistalbums;
    ui->lblCurrentView->setText(currentartist+":");
}

void Ui_ContextView::showAlbumTracks(QListWidgetItem *item)
{
    ui->btnPlay->show();
    //Disconnect all Handlers
    disconnectSelectSignals();
    CommonDebug(item->text().toAscii()+" clicked");
    slideListWidgetLeft();
    MpdTrack *temptrack;
    wliTrack *tempitem;
    currentalbum = item->text();
    ui->btnAdd->show();

    QList<MpdTrack*> *temptracks = netaccess->getAlbumTracks(item->text(),currentartist);
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(false);
    for(int i=0;i<temptracks->length();i++)
        {
            temptrack = temptracks->at(i);
        tempitem = new wliTrack(ui->listWidget,1000,temptrack);

           // ui->listWidget->addItem(new QListWidgetItem(temptracks->at(i)->getTitle()));
        }

    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showLibrarySongInfo(QListWidgetItem*)));

    //delete(temptracks);
    slideListWidgetRight();
    //FIXME
    currentmode = viewmode_albumtracks;
    ui->lblCurrentView->setText(currentalbum+":");

}


void Ui_ContextView::showPlaylistTracks(QListWidgetItem *item)
{
    ui->btnPlay->show();
    //Disconnect all Handlers
    slideListWidgetLeft();
    disconnectSelectSignals();
    CommonDebug(item->text().toAscii()+" clicked");
    slideListWidgetLeft();
    MpdTrack *temptrack;
    wliTrack *tempitem;
    currentalbum = "";
    currentartist = "";
    currentplaylist = item->text();

    ui->btnAdd->hide();
    ui->btnBack->show();

    QList<MpdTrack*> *temptracks = netaccess->getPlaylistTracks(item->text());
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(false);
    for(int i=0;i<temptracks->length();i++)
        {
            temptrack = temptracks->at(i);
            tempitem = new wliTrack(ui->listWidget,1000,temptrack);
        }

    slideListWidgetRight();
    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showLibrarySongInfo(QListWidgetItem*)));

    //delete(temptracks);
    slideListWidgetRight();
    //FIXME
    currentmode = viewmode_playlisttracks;
    ui->lblCurrentView->setText(currentplaylist+":");

}

void Ui_ContextView::showCurrentPlaylist()
{
    CommonDebug("show current Playlist requested");
    hideLibrarySongInfo();
    ui->btnAdd->hide();
    ui->btnBack->hide();
    ui->btnClear->show();
    ui->btnPlay->hide();
    ui->btnLoadPlaylist->show();
    ui->btnSavePlaylist->show();
    ui->listWidget->updateGeometry();
    disconnectSelectSignals();
    connect(listoutanimation,SIGNAL(finished()),this,SLOT(afterAnimationshowCurrentPlaylist()));
    slideListWidgetLeft();
    currentmode = viewmode_currentplaylist;
    ui->lblCurrentView->setText(tr("Current playlist:"));
}

void Ui_ContextView::afterAnimationshowCurrentPlaylist()
{
    disconnect(listoutanimation,SIGNAL(finished()),0,0);
    playingid=-1;
    ui->listWidget->clear();
    if(playlistchanged)
    {
        CommonDebug("Playlist changed :-/");
        for(int i=0;i<lastplaylist->length();i++)
        {
            delete lastplaylist->at(i);
        }
        lastplaylist->clear();
            delete lastplaylist;
        lastplaylist = netaccess->getCurrentPlaylistTracks();
        playinglaststate = false;
    }
    else{CommonDebug("Could use old playlist :-)");}
    wliTrack *tempitem;
    ui->listWidget->setSortingEnabled(false);
    CommonDebug("Start Adding");
    MpdTrack *track;
    for(int i=0;i<lastplaylist->length();i++)
        {
        track = lastplaylist->at(i);
        tempitem = new wliTrack(ui->listWidget,1000,track);
        }
    setCurrentPlayingId(playingid,true);
    slideListWidgetRight();
    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(selectedDispatcher(QListWidgetItem*)));
    playlistchanged = false;
    playingid = -1;
    playinglaststate = NetworkAccess::STOP;
    updateStatus(netaccess->getStatus());
}


//Bounces out
void Ui_ContextView::slideListWidgetLeft()
{

    CommonDebug("Slide out");
    setupAnimations();
    if(listoutanimation!=NULL){
        listoutanimation->start();

    }
}

//Bounces in
void Ui_ContextView::slideListWidgetRight()
{
    CommonDebug("Slide in");
    if(listinanimation!=NULL){
        listinanimation->start();
    }

}

void Ui_ContextView::realignWidgets()
{
    /*
    QWidget::updateGeometry();
    QWidget::update();
    //FIXME Workaround for freaky widget scaling
    QLabel *lbl = new QLabel("",this);
    ui->horizontalLayout_3->addWidget(lbl);
    ui->horizontalLayout_3->removeWidget(lbl);
    delete lbl;*/

    ui->listWidget->updateGeometry();

}

void Ui_ContextView::setupAnimations()
{
    if((listoutanimation==NULL)&(listinanimation==NULL)) {
        listoutanimation = new QPropertyAnimation(ui->listWidget, "geometry");
        listinanimation = new QPropertyAnimation(ui->listWidget, "geometry");
        connect(listinanimation,SIGNAL(finished()),this,SLOT(realignWidgets()));

    }

    if((listoutanimation!=NULL)&&(listinanimation!=NULL)) {
        int startx,starty,endx,endy,height,width;

        ui->listWidget->updateGeometry();

        startx = ui->listWidget->geometry().x();
        starty = ui->listWidget->geometry().y();
        endx = (-1)*this->size().width();
        endy = starty;
        height = ui->listWidget->size().height();
        width = ui->listWidget->size().width();
        CommonDebug("LIST:"+QString::number(width).toAscii()+":"+QString::number(height).toAscii());
        listoutanimation->setDuration(300);
        listinanimation->setDuration(400);
        listoutanimation->setStartValue(QRect(startx,starty,width,height));
        listoutanimation->setEndValue(QRect(endx,endy,width,height));
        listoutanimation->setEasingCurve(QEasingCurve::OutCurve);
        //in animation
        listinanimation->setStartValue(QRect(endx,endy,width,height));
        listinanimation->setEndValue(QRect(startx,starty,width,height));
        listinanimation->setEasingCurve(QEasingCurve::InBack);
    }
}

void Ui_ContextView::setupContextMenu()
{
    #ifdef Q_OS_SYMBIAN
    // Remove context menu from all widgets
    QWidgetList widgets = QApplication::allWidgets();
    QWidget* w = 0;
    foreach(w,widgets){
        w->setContextMenuPolicy(Qt::NoContextMenu);
    }
    #endif

    #if defined Q_OS_SYMBIAN || defined Q_WS_MAEMO_5
    #endif


}

void Ui_ContextView::showContextMenu(const QPoint& pos)
{
    // If statement is workaround for QTBUG-6256
    if (pos != QPoint(0,0)) {
        // Execute context menu
        m_contextMenu->exec(pos);
    }
}


void Ui_ContextView::addAlbumToPlaylist()
{
    if(ui->listWidget->selectedItems().first()!=NULL)
    {
      netaccess->addAlbumToPlaylist(ui->listWidget->selectedItems().first()->text());
    }
}


void Ui_ContextView::showLibrarySongInfo(QListWidgetItem *item)
{
    //Hide list widget
    slideListWidgetLeft();
    wliTrack *castitem;
    castitem = dynamic_cast <wliTrack*> (item);

    songinfo = new ui_SongInfo(this,castitem->getTitle(),castitem->getAlbum(),castitem->getArtist(),castitem->getFileUri(),castitem->getInfo(),castitem->getLength());
    ui->horizontalLayout_2->addWidget(songinfo);
    ui->btnAdd->hide();
    ui->btnBack->hide();
    ui->btnPlay->hide();
    ui->btnQuit->hide();

    ui->listWidget->hide();
    songinfo->show();

    //Connect signals

    connect(songinfo,SIGNAL(request_back()),this,SLOT(hideLibrarySongInfo()));
    connect(songinfo,SIGNAL(request_add(QString)),netaccess,SLOT(addTrackToPlaylist(QString)));
    connect(songinfo,SIGNAL(request_playback(QString)),netaccess,SLOT(playTrack(QString)));
    ui->listWidget->setDisabled(true);
    QWidget::updateGeometry();
    QWidget::update();
    if(parentWidget()!=NULL) {
        parentWidget()->showFullScreen();
    }

    CommonDebug("List widget removed");
}

void Ui_ContextView::hideLibrarySongInfo()
{
    if(songinfo!=NULL)
    {
        ui->listWidget->setEnabled(true);
        ui->listWidget->setVisible(true);
        ui->listWidget->setSizePolicy(QSizePolicy::Preferred,QSizePolicy::Preferred);
        ui->horizontalLayout_3->removeWidget(songinfo);
        ui->listWidget->show();
        disconnect(songinfo,SIGNAL(request_add(QString)),0,0);
        disconnect(songinfo,SIGNAL(request_playback(QString)),0,0);
        disconnect(songinfo,SIGNAL(request_back()),0,0);
        delete(songinfo);
        songinfo = NULL;
        QWidget::updateGeometry();
        QWidget::update();
        if(parentWidget()!=NULL)
        {
            parentWidget()->showFullScreen();
        }
        ui->listWidget->showFullScreen();
        switch(currentmode)
        {
        case viewmode_albumtracks:
            {
                ui->btnAdd->show();
                ui->btnBack->show();
                ui->btnPlay->show();
                ui->btnQuit->show();
                break;
            }
        case viewmode_playlisttracks:
            {
                ui->btnAdd->hide();
                ui->btnBack->show();
                ui->btnPlay->show();
                ui->btnQuit->show();
                break;
            }
        case viewmode_files:
            ui->btnAdd->show();
            ui->btnBack->show();
            ui->btnPlay->show();
            ui->btnQuit->show();
            break;
        }
        slideListWidgetRight();

    }
}

void Ui_ContextView::setCurrentPlayingId(qint32 id, quint8 play)
{
    CommonDebug("State:"+QString::number(play)+"oldid:newid  ->"+QString::number(playingid)+":"+QString::number(id));
        if (    currentmode == viewmode_currentplaylist&&ui->listWidget->count()>id&&id>=0) {
            switch (play)
            {
            case NetworkAccess::PLAYING:
            {
                if (id!=playingid||playinglaststate!=play)
                {
                    //Remove old play/pause icon
                    if ((ui->listWidget->count()>playingid)&&playingid>=0) {
                        ui->listWidget->item(playingid)->setIcon(QIcon());
                    }
                    QListWidgetItem *item = ui->listWidget->item(id);
                    if (play==NetworkAccess::PAUSE)
                    {
                        item->setIcon(QIcon(":/icons/media-playback-pause.png"));
                    }
                    else if (play==NetworkAccess::PLAYING)
                    {
                        item->setIcon(QIcon(":/icons/media-playback-start.png"));
                    }
                    CommonDebug("List icon changed!");
                    ui->listWidget->scrollToItem(item);
                }
                break;
            }
            case NetworkAccess::PAUSE:
            {
                if (id!=playingid||playinglaststate!=play)
                {
                    //Remove old play/pause icon
                    if ((ui->listWidget->count()>playingid)&&playingid>=0) {
                        ui->listWidget->item(playingid)->setIcon(QIcon());
                    }
                    QListWidgetItem *item = ui->listWidget->item(id);
                    if (play==NetworkAccess::PAUSE)
                    {
                        item->setIcon(QIcon(":/icons/media-playback-pause.png"));
                    }
                    else if (play==NetworkAccess::PLAYING)
                    {
                        item->setIcon(QIcon(":/icons/media-playback-start.png"));
                    }
                    CommonDebug("List icon changed!");
                    ui->listWidget->scrollToItem(item);
                }
                break;
            }
            case NetworkAccess::STOP:
            {
              if(playinglaststate!=play) {
              CommonDebug("STOPPED remove ICON old id:"+QString::number(playingid)+":"+QString::number(id));
                if ((ui->listWidget->count()>playingid)&&playingid>=0) {
                    ui->listWidget->item(playingid)->setIcon(QIcon());
                }}
                break;
            }
            };
        }
        if(id==-1&&play==NetworkAccess::STOP&&playingid!=id)
        {
          CommonDebug("STOPPED remove ICON old id:"+QString::number(playingid)+":"+QString::number(id));
                if ((ui->listWidget->count()>playingid)&&playingid>=0) {
                    ui->listWidget->item(playingid)->setIcon(QIcon());
                }
        }
        playingid = id;
        playinglaststate = play;
}


void Ui_ContextView::playSelectedSong(QListWidgetItem *item)
{
    quint32 id = ui->listWidget->row(item);
    netaccess->playTrackByNumber(id);

}

void Ui_ContextView::addButtonDispatcher()
{
    switch (currentmode)
    {
    case viewmode_albumtracks:
        {
            netaccess->addAlbumToPlaylist(currentalbum);
            break;
        }
    case viewmode_albums:
        {
            CommonDebug("Add all albums?");
            emit requestMaximised(false);
            int ok = QMessageBox::question(NULL,"",tr("Do you really want to add ALL albums to current playlist?"),QMessageBox::Yes,QMessageBox::No);
            emit requestMaximised(true);
            if (ok==QMessageBox::Yes) {
                QList <MpdAlbum*> *albums = netaccess->getAlbums();
                for(int i = 0;i<albums->length();i++)
                {
                    netaccess->addAlbumToPlaylist(albums->at(i)->getTitle());
                    CommonDebug("Add album:"+albums->at(i)->getTitle().toAscii()+" to playlist");
                }
            }
            break;
        }
    case viewmode_artists:
        {
            QList <MpdArtist*> *artists = netaccess->getArtists();
            QList <MpdAlbum*> *artistalbums;
            QString artist = "";
            QString album = "";
            for(int i = 0;i<artists->length();i++)
            {
                artist = artists->at(i)->getName();
                artistalbums = netaccess->getArtistsAlbums(artist);
                for(int j = 0;j<artistalbums->length();j++)
                {
                  album = artistalbums->at(j)->getTitle();
                  CommonDebug("Add Artist-album to pl:"+artist+":"+album+":"+QString::number(artistalbums->length()));
                    netaccess->addArtistAlbumToPlaylist(artist,album);
                }
                delete (artistalbums);
            }
            delete (artists);
            break;
        }
    case viewmode_artistalbums:
        {
            QList <MpdAlbum*> *albums = netaccess->getArtistsAlbums(currentartist);
            for(int i = 0;i<albums->length();i++)
            {
                netaccess->addArtistAlbumToPlaylist(currentartist,albums->at(i)->getTitle());
            }
            delete (albums);
            break;
        }
    case viewmode_playlisttracks:
        {
            netaccess->addPlaylist(currentplaylist);
            break;
        }
    case viewmode_files:
        {
            QString oldpath;
            if(ui->listWidget->count()>0)
            {
                WliFile *file = dynamic_cast <WliFile*> (ui->listWidget->item(0));
                if(file!=NULL&&file->getFile()!=NULL)
                {
                    oldpath = file->getFile()->getPrePath();
                    if(oldpath != "")
                    {
                        netaccess->addTrackToPlaylist(oldpath);
                    }
                    else {
                        netaccess->addTrackToPlaylist("/");
                    }
                }
            }
        }
    };
}


void Ui_ContextView::playButtonDispatcher()
{
    switch (currentmode)
    {
    case viewmode_albumtracks:
        {
            netaccess->clearPlaylist();
            netaccess->addAlbumToPlaylist(currentalbum);
            netaccess->playTrackByNumber(0);
            break;
        }
    case viewmode_albums:
        {
            netaccess->clearPlaylist();
            int ok = QMessageBox::question(this,"",tr("Do you really want to add ALL albums to current playlist?"),QMessageBox::Yes,QMessageBox::No);
            if (ok==QMessageBox::Yes) {
                QList <MpdAlbum*> *albums = netaccess->getAlbums();
                for(int i = 0;i<albums->length();i++)
                {
                    netaccess->addAlbumToPlaylist(albums->at(i)->getTitle());
                }
            }
            netaccess->playTrackByNumber(0);
            break;
        }
    case viewmode_artists:
        {
            netaccess->clearPlaylist();
            QList <MpdArtist*> *artists = netaccess->getArtists();
            QList <MpdAlbum*> *artistalbums;
            QString artist = "";
            QString album = "";
            for(int i = 0;i<artists->length();i++)
            {
                artist = artists->at(i)->getName();
                artistalbums = netaccess->getArtistsAlbums(artist);
                for(int j = 0;j<artistalbums->length();j++)
                {
                  album = artistalbums->at(j)->getTitle();
                  CommonDebug("Add Artist-album to pl:"+artist+":"+album+":"+QString::number(artistalbums->length()));
                    netaccess->addArtistAlbumToPlaylist(artist,album);
                }
                delete (artistalbums);
            }
            delete (artists);
            netaccess->playTrackByNumber(0);
            break;
        }
    case viewmode_artistalbums:
        {
            netaccess->clearPlaylist();
            QList <MpdAlbum*> *albums = netaccess->getArtistsAlbums(currentartist);
            for(int i = 0;i<albums->length();i++)
            {
                netaccess->addArtistAlbumToPlaylist(currentartist,albums->at(i)->getTitle());
            }
            delete (albums);
            netaccess->playTrackByNumber(0);
            break;
        }
    case viewmode_playlisttracks:
        {
            netaccess->clearPlaylist();
            netaccess->addPlaylist(currentplaylist);
            netaccess->playTrackByNumber(0);
            break;
        }
    case viewmode_files:
        {
            netaccess->clearPlaylist();
            QString oldpath;
            if(ui->listWidget->count()>0)
            {
                WliFile *file = dynamic_cast <WliFile*> (ui->listWidget->item(0));
                if(file!=NULL&&file->getFile()!=NULL)
                {
                    oldpath = file->getFile()->getPrePath();
                    if(oldpath != "")
                    {
                        netaccess->addTrackToPlaylist(oldpath);
                    }
                    else {
                        netaccess->addTrackToPlaylist("/");
                    }
                }
                netaccess->playTrackByNumber(0);
            }
        }
    };
}

void Ui_ContextView::selectedDispatcher(QListWidgetItem *item)
{
    switch (currentmode)
    {
    case viewmode_albumtracks:
        {

            break;
        }
    case viewmode_albums:
        {

            break;
        }
    case viewmode_artistalbums:
        {

            break;
        }
    case viewmode_artists:
        {

            break;
        }
    case viewmode_alltracks:
        {

            break;
        }
    case viewmode_savedplaylists:
        {

            break;
        }
    case viewmode_playlisttracks:
        {

            break;
        }
    case viewmode_files:
        {

            break;
        }
    case viewmode_currentplaylist:
        {
            if(playingid==ui->listWidget->currentIndex().row()&&playinglaststate!=NetworkAccess::STOP)
            {
                emit showCurrentSongInfo();
            }
            else{
                playSelectedSong(item);
            }
            break;
        }
    };
}


void Ui_ContextView::backButtonDispatcher()
{
    switch (currentmode)
    {
    case viewmode_albumtracks:
        {
            if(currentartist!="")
            {
                showArtistAlbums(new QListWidgetItem(currentartist));
            }
            else
            {
                showAlbums();
            }
            break;
        }
    case viewmode_albums:
        {
            showCurrentPlaylist();
            break;
        }
    case viewmode_artistalbums:
        {
            showArtists();
            break;
        }
    case viewmode_artists:
        {
            showCurrentPlaylist();
            break;
        }
    case viewmode_alltracks:
        {
            showCurrentPlaylist();
            break;
        }
    case viewmode_savedplaylists:
        {
            showCurrentPlaylist();
            break;
        }
    case viewmode_playlisttracks:
        {
            showPlaylists();
            break;
        }
    case viewmode_files:
        {
            if(currentpath=="")
            {
                showCurrentPlaylist();
            }
            else if(1)
            {
                QStringList splittedold = currentpath.split("/");
                QString oldpath;
                for(int i=0;i<splittedold.length()-1;i++)
                {
                    oldpath += splittedold.at(i);
                    if(i!=splittedold.length()-2)
                    {
                        oldpath += "/";
                    }
                }
                showFiles(oldpath);
            }
            break;
        }
    };
}

void Ui_ContextView::setPlaylistVersion(int version)
{
    if(playlistversion!=version)
    {
        CommonDebug("Playlist version change:"+QString::number(version).toAscii());
        playlistversion = version;
        playlistchanged = true;
        if(currentmode==viewmode_currentplaylist)
        {
            showCurrentPlaylist();
        }
    }
}



void Ui_ContextView::savePlaylist()
{
    bool cancel;
    emit requestMaximised(false);
    QString name = QInputDialog::getText(this,tr("Name"),tr("Please enter name for playlist."),QLineEdit::Normal,"",&cancel);
    emit requestMaximised(true);
    if(cancel)
    {
        bool success = netaccess->savePlaylist(name);
        if(!success||(name==""))
        {
            emit requestMaximised(false);
            QMessageBox::warning(this,tr("Error"),tr("Sorry save list could not get saved"),QMessageBox::Ok,QMessageBox::NoButton);
            emit requestMaximised(true);
        }
    }
}

void Ui_ContextView::showPlaylists()
{
    slideListWidgetLeft();
        ui->btnClear->hide();
        ui->btnLoadPlaylist->hide();
        ui->btnSavePlaylist->hide();
        ui->btnBack->show();
        ui->listWidget->clear();
        ui->listWidget->setSortingEnabled(true);
        ui->btnPlay->hide();
        disconnectSelectSignals();
        QStringList *playlists = netaccess->getSavedPlaylists();
        for(int i=0;i<playlists->length();i++)
        {
                ui->listWidget->addItem(new QListWidgetItem(playlists->at(i)));
        }
        slideListWidgetRight();
        delete playlists;
        connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(showPlaylistTracks(QListWidgetItem*)));
        currentmode = viewmode_savedplaylists;
        ui->lblCurrentView->setText(tr("Saved playlists:"));

}

void Ui_ContextView::clearPlaylist()
{
    emit requestMaximised(false);
    int result = QMessageBox::question(this,tr("Clear playlist"),tr("Are you sure to delete current playlist?"),QMessageBox::Yes,QMessageBox::No);
    emit requestMaximised(true);
    if(result==QMessageBox::Yes)
    {
        netaccess->clearPlaylist();
    }
}

void Ui_ContextView::quitApplication()
{

    emit requestMaximised(false);
    int result = QMessageBox::question(this,tr("Quit?"),tr("Are you sure to quit?"),QMessageBox::Yes,QMessageBox::No);
    emit requestMaximised(true);
    if(result==QMessageBox::Yes)
    {
        emit exitrequested();
    }

}

void Ui_ContextView::updateStatus(status_struct tempstruct)
{
    setCurrentPlayingId(tempstruct.id,tempstruct.playing);
    if(!playlistchanged)
    {
        setPlaylistVersion(tempstruct.playlistversion);
    }
}

void Ui_ContextView::disconnectedFromServer()
{
    CommonDebug("contextview disconnectedfromserver called");
    setPlaylistVersion(0);
  //  showCurrentPlaylist();
}


void Ui_ContextView::showFiles(QString path)
{
    slideListWidgetLeft();
    ui->btnAdd->show();
    ui->btnQuit->show();
    ui->btnPlay->show();
    ui->btnBack->show();
    ui->btnClear->hide();
    ui->btnSavePlaylist->hide();
    ui->btnLoadPlaylist->hide();
    hideLibrarySongInfo();

    disconnectSelectSignals();
    ui->listWidget->clear();
    ui->listWidget->setSortingEnabled(false);
    QList<MpdFileEntry*> *files = netaccess->getDirectory(path);
    WliFile *tempwli;
    for(int i=0;i<files->length();i++)
    {
        tempwli = new WliFile(files->at(i),ui->listWidget,1000);
    }
    delete(files);
    currentmode = viewmode_files;
    currentpath = path;
    connect(ui->listWidget,SIGNAL(itemClicked(QListWidgetItem*)),this,SLOT(filesClickedDispatcher(QListWidgetItem*)));
    QStringList splittedold = currentpath.split("/");
    if(splittedold.length()>0)
    {
        ui->lblCurrentView->setText(splittedold.last()+":");
    }
    slideListWidgetRight();
}

void Ui_ContextView::filesClickedDispatcher(QListWidgetItem *item)
{
    WliFile *fileitem = dynamic_cast <WliFile*> (item);
    QString newpath;
    if(currentpath!="")
    {
        newpath = fileitem->getFile()->getPrePath() + QString::fromUtf8("/") +fileitem->getFile()->getName();
       }
    else{ newpath = fileitem->getFile()->getName(); }
    MpdFileEntry *tempfile = fileitem->getFile();
    if(tempfile!=NULL)
    {
        if(fileitem->getFile()->isDirectory())
        {
            CommonDebug("going in:"+newpath.toAscii());
            showFiles(newpath);
        }
        else if(fileitem->getFile()->isFile())
        {
            showLibrarySongInfo(new wliTrack(NULL,1000,fileitem->getFile()->getTrack()));
        }
    }
}

void Ui_ContextView::connectedToServer()
{
//    updateStatus(netaccess->getStatus());
    showCurrentPlaylist();
}
