#ifndef MPDARTIST_H
#define MPDARTIST_H

#include <QObject>
#include "mpdalbum.h"
#include "mpdtrack.h"

class MpdTrack;
class MpdAlbum;

class MpdArtist : public QObject
{
    Q_OBJECT
public:
    explicit MpdArtist(QObject *parent = 0);
    MpdArtist(QObject *parent, QString name);
    void addTrack(MpdTrack *track);
    void addAlbum(MpdAlbum *album);
    void addAlbums(QList<MpdAlbum*> *albums);
    quint32 albumCount();
    MpdAlbum *getAlbum(quint32 i);
    QString getName();

private:
    QString name;
    QList<MpdAlbum*> *albums;
    QList<MpdTrack*> *tracks;

signals:

public slots:

};

#endif // MPDARTIST_H
