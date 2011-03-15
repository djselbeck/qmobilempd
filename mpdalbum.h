#ifndef MPDALBUM_H
#define MPDALBUM_H

#include <QObject>
#include "mpdtrack.h"

class MpdTrack;

class MpdAlbum : public QObject
{
    Q_OBJECT
public:
    explicit MpdAlbum(QObject *parent = 0);
    MpdAlbum(QObject *parent,QString title);
    QString getTitle();

private:
    QString title;
    QList<MpdTrack*> *tracks;

signals:

public slots:

};

#endif // MPDALBUM_H
