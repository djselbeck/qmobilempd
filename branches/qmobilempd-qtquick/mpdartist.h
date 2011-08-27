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
    Q_PROPERTY(QString artist READ getName)
public:
    explicit MpdArtist(QObject *parent = 0);
    MpdArtist(QObject *parent, QString name);
    void addTrack(MpdTrack *track);
    void addAlbum(MpdAlbum *album);
    void addAlbums(QList<MpdAlbum*> *albums);
    quint32 albumCount();
    MpdAlbum *getAlbum(quint32 i);
    QString getName();
    bool operator< (const MpdArtist& other) const { return (name < other.name); }
    bool operator==(MpdArtist & rhs) {return getName()==rhs.getName();}
    static bool lessThan(const MpdArtist *lhs, const MpdArtist* rhs) {
        return *lhs<*rhs;
    }


private:
    QString name;
    QList<MpdAlbum*> *albums;
    QList<MpdTrack*> *tracks;

signals:

public slots:

};

#endif // MPDARTIST_H
