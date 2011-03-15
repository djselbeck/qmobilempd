#include "wlitrack.h"

wliTrack::wliTrack( QListWidget * parent , int type ):
    QListWidgetItem(parent)
{
}

wliTrack::wliTrack(QListWidget * parent, int type, MpdTrack *track) : QListWidgetItem(parent,1000)
{
    this->track = track;
    setText(text());
}

wliTrack::~wliTrack()
{
 //   delete(track);
}

QString wliTrack::text()
{
    if(track!=NULL)
    {
        return track->getTitle()+" ("+track->getLengthFormated()+")";
    }
}


QString wliTrack::getFileUri(){
    if(track!=NULL)
       return track->getFileUri();
}

QString wliTrack::getTitle(){
    if(track!=NULL)
        return track->getTitle();
}

QString wliTrack::getArtist(){
    if(track!=NULL)
        return track->getArtist();
}

QString wliTrack::getAlbum(){
    if(track!=NULL)
        return track->getAlbum();
}

QString wliTrack::getInfo(){
    if(track!=NULL)
        return "FIXIT!";
}

QString wliTrack::getLength()
{
    if(track!=NULL)
        return track->getLengthFormated();
}

MpdTrack *wliTrack::getTrack()
{
    return track;
}
