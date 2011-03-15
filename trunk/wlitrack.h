#ifndef WLITRACK_H
#define WLITRACK_H

#include <QListWidgetItem>
#include "mpdtrack.h"

class wliTrack : public QListWidgetItem
{

public:
    explicit wliTrack( QListWidget * parent = 0, int type = 1000 );
    wliTrack( QListWidget * parent = 0, int type = 1000, MpdTrack *track = 0);
    virtual ~wliTrack();
    virtual QString text();
    QString getFileUri();
    QString getTitle();
    QString getArtist();
    QString getAlbum();
    QString getInfo();
    QString getLength();
    MpdTrack *getTrack();



signals:

public slots:

private:
    MpdTrack *track;


};

#endif // WLITRACK_H
