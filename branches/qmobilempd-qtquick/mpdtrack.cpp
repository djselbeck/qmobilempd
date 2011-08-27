#include "mpdtrack.h"

MpdTrack::MpdTrack(QObject *parent) :
    QObject(parent)
{
  title="";
  artist="";
  album="";
  length=0;
  filename="";
  
}

MpdTrack::MpdTrack(QObject *parent,QString file, QString title, quint32 length):
        QObject(parent)
{
    this->length = length;
    this->title = title;
    this->filename = file;
}
MpdTrack::MpdTrack(QObject *parent,QString file, QString title, quint32 length,bool playing):
        QObject(parent)
{
    this->length = length;
    this->title = title;
    this->filename = file;
    this->playing = playing;
}

MpdTrack::MpdTrack(QObject *parent, QString file, QString title, QString artist, QString album, quint32 length):
        QObject(parent)
{
    this->length = length;
    this->title = title;
    this->filename = file;
    this->album = album;
    this->artist = artist;
}


QString MpdTrack::getTitle()
{
    return title;
}
QString MpdTrack::getFileUri()
{
    return filename;
}

quint32 MpdTrack::getLength()
{
    return length;
}
QString MpdTrack::getAlbum()
{
    return album;
}

QString MpdTrack::getArtist()
{
    return artist;
}

bool MpdTrack::getPlaying()
{
    return playing;
}
QString MpdTrack::getLengthFormated()
{
    QString temp;
    int hours=0,min=0,sec=0;
    hours = length/3600;
    if(hours>0)
    {
        min=(length-(3600*hours))/60;
    }
    else{
        min=length/60;
    }
    sec = length-hours*3600-min*60;
    if(hours==0)
    {
        temp=QString::number(min)+":"+(sec<10?"0":"")+QString::number(sec);
    }
    else
    {
        temp=QString::number(hours)+":"+QString::number(min)+":"+QString::number(sec);
    }
    return temp;
}

QString MpdTrack::getName()
{
  return filename;
}

void MpdTrack::setAlbum(QString al)
{
    album = al;
}
void MpdTrack::setFileUri(QString uri)
{
  this->filename = uri;
}

void MpdTrack::setArtist(QString art)
{
  this->artist = art;
}

void MpdTrack::setLength(quint32 length)
{
  this->length = length;
}

void MpdTrack::setTitle(QString titti)
{
  this->title = titti;
}

