#ifndef COMMON_H
#define COMMON_H

#define VERSION "1.0.7"

#include <QString>

struct serverprofile { QString profilename; QString hostname; QString password; quint16 port;bool defaultprofile;};
struct status_struct {quint32 playlistversion; qint32 id; quint16 bitrate;int tracknr;int albumtrackcount;quint8 percent; quint8 volume; QString info; QString title; QString album; QString artist;QString fileuri;quint8 playing; bool repeat; bool shuffle; quint32 length; quint32 currentpositiontime;quint32 playlistlength;};
#define READYREAD 5000
enum State {PAUSE,PLAYING,STOP};


#endif // COMMON_H
