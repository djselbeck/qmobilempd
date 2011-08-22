#ifndef UI_CONTEXTVIEW_H
#define UI_CONTEXTVIEW_H

#include <QWidget>
#include <QMenu>
#include <QListWidgetItem>
#include <QPushButton>
#include <QMessageBox>
#include <QInputDialog>
#include <QLabel>

//Local includes
#include "networkaccess.h"
#include "mpdalbum.h"
#include "mpdartist.h"
#include "mpdtrack.h"
#include "mpdfileentry.h"
#include "wlitrack.h"
#include "wlifile.h"
#include "ui_songinfo.h"
#include "QsKineticScroller.h"
#include "commondebug.h"

//DEFINE FOR KDE PLASMOID
//#define QMPDPLASMOID_KDE
//DEFINE FOR QMOBILEMPD don't set unless compiling qmobilempd
#define QMOBILEMPD


enum viewmode {viewmode_currentplaylist,viewmode_artistalbums,viewmode_artists,viewmode_albums,viewmode_albumtracks,viewmode_alltracks,viewmode_savedplaylists,viewmode_playlisttracks,viewmode_files,viewmode_currentsonginfo,viewmode_count};

namespace Ui {
    class Ui_ContextView;
}

class Ui_ContextView : public QWidget
{
    Q_OBJECT

public:
    explicit Ui_ContextView(QWidget *parent = 0);
    Ui_ContextView(QWidget *parent, NetworkAccess *netaccess);
    ~Ui_ContextView();
    void setCurrentPlayingId(qint32 id,quint8 play);
    bool doubleClickToSelect();

private:
    Ui::Ui_ContextView *ui;
    qint32 playingid;
    quint32 playlistversion;
    int currentmode;
    QString currentartist;
    QString currentalbum;
    QString currentplaylist;
    QString currentpath;
    //Holds current tracks in playlist for performance
    ui_SongInfo *songinfo;
    NetworkAccess *netaccess;
    QsKineticScroller *kineticscroller;
    QMenu *m_contextMenu;    
    QAction *act_addToPlaylist;
    void disconnectSelectSignals();
    void setupAnimations();
    //Bounces out
    void slideListWidgetLeft();
    //Bounces in
    void slideListWidgetRight();
    //Bounce Out animation
    QPropertyAnimation *listoutanimation;
    //Bounce In animation
    QPropertyAnimation *listinanimation;
    void setupContextMenu();
    bool playlistchanged;
    quint8 playinglaststate;
    bool doubleclick;
    QList<MpdTrack*> *lastplaylist;
    QString backscrolltext;
    void scrollTo(QString itemtext);
    



public slots:
    void showArtists();
    void showAlbums();
    void showTracks();
    void showFiles(QString path);
    void showArtistAlbums(QListWidgetItem *item);
    void showAlbumTracks(QListWidgetItem *item);
    void showPlaylistTracks(QListWidgetItem *item);
    void showLibrarySongInfo(QListWidgetItem *item);
    void hideLibrarySongInfo();
    void playSelectedSong(QListWidgetItem *item);
    void showCurrentPlaylist();
    void setPlaylistVersion(int version);
    void setDoubleClickNeeded(bool dbl);

protected slots:
    void playButtonDispatcher();
    void addButtonDispatcher();
    void addAlbumToPlaylist();
    void backButtonDispatcher();
    void afterAnimationshowArtists();
    void afterAnimationshowAlbums();
    void afterAnimationshowCurrentPlaylist();
    void realignWidgets();
    void savePlaylist();
    void showPlaylists();
    void clearPlaylist();
    void quitApplication();
    void updateStatus(status_struct tempstruct);
    void disconnectedFromServer();
    void connectedToServer();
    void filesClickedDispatcher(QListWidgetItem *item);
    void selectedDispatcher(QListWidgetItem *item);
    void scrollTo();

signals:
    void exitrequested();
    void requestMaximised(bool);
    void showCurrentSongInfo();



};

#endif // UI_CONTEXTVIEW_H
