#ifndef MPDALBUM_H
#define MPDALBUM_H

#include <QObject>
#include "mpdtrack.h"

class MpdTrack;

class MpdAlbum : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString title READ getTitle)
public:
    explicit MpdAlbum(QObject *parent = 0);
    MpdAlbum(QObject *parent,QString title);
    QString getTitle();
    bool operator< (const MpdAlbum& other) const { return (title < other.title); }
    bool operator==(MpdAlbum & rhs) {return getTitle()==rhs.getTitle();}
    static bool lessThan(const MpdAlbum *lhs, const MpdAlbum* rhs) {
        return *lhs<*rhs;
    }


private:
    QString title;
    QList<MpdTrack*> *tracks;

signals:

public slots:

};

#endif // MPDALBUM_H
