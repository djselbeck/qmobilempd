#include "currentsongwidget.h"
#include "ui_currentsongwidget.h"
#include "commondebug.h"

CurrentSongWidget::CurrentSongWidget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::CurrentSongWidget)
{
    ui->setupUi(this);
}

CurrentSongWidget::CurrentSongWidget(QWidget *parent,NetworkAccess *netaccess) : QWidget(parent),
ui(new Ui::CurrentSongWidget)
{
    ui->setupUi(this);
    if(netaccess!=NULL)
    {

        this->netaccess = netaccess;
    }
    netaccess->setUpdateInterval(1000);
    ui->sliderposition->setTracking(false);
    connect(ui->sliderposition,SIGNAL(valueChanged(int)),this,SLOT(seekPosition(int)));
    connect(this->netaccess,SIGNAL(statusUpdate(status_struct)),this,SLOT(updateStatus(status_struct)));
    connect(ui->btnBack,SIGNAL(clicked()),this,SIGNAL(backRequested()));
    updateStatus(netaccess->getStatus());

#ifdef Q_OS_SYMBIAN
    QFont font;
    QFont font2;
    font.setPointSize(8);
    font2.setPointSize(8);
    font2.setBold(true);
    font2.setUnderline(true);
    ui->label->setFont(font2);
    ui->label_2->setFont(font2);
    ui->label_3->setFont(font2);
    ui->label_4->setFont(font2);
    ui->label_5->setFont(font2);
    ui->label_6->setFont(font2);
    ui->lblAlbum->setFont(font);
    ui->lblArtist->setFont(font);
    ui->lblBitrate->setFont(font);
    ui->lblFileUri->setFont(font);
    ui->lblTitle->setFont(font);
    ui->lblTrackNr->setFont(font);
#endif


}

CurrentSongWidget::~CurrentSongWidget()
{
    //TODO CHECK if needed
    disconnect(netaccess,0,this,0);

    delete ui;
}

void CurrentSongWidget::updateStatus(status_struct tempstruct)
{
    ui->sliderposition->blockSignals(true);
    ui->lblTitle->setText(tempstruct.title);
    ui->lblAlbum->setText(tempstruct.album);
    ui->lblArtist->setText(tempstruct.artist);
    ui->lblBitrate->setText(QString::number(tempstruct.bitrate)+ " kbit/s");
    ui->lblFileUri->setText(tempstruct.fileuri);
    ui->lblTrackNr->setText(QString::number(tempstruct.tracknr)+((tempstruct.albumtrackcount==0) ? "" :"/"+QString::number(tempstruct.albumtrackcount)));
    ui->sliderposition->setMaximum(tempstruct.length);
    ui->sliderposition->setValue(tempstruct.currentpositiontime);
    songid = tempstruct.id;

    ui->lblLength->setText(getLengthString(tempstruct.length));
    ui->lblCurrentPosition->setText(getLengthString(tempstruct.currentpositiontime));


    ui->sliderposition->blockSignals(false);
}

void CurrentSongWidget::seekPosition(int value)
{
    CommonDebug("Seek to:"+QString::number(value)+" for song id: "+QString::number(songid));
    netaccess->seekPosition(songid,value);
}

QString CurrentSongWidget::getLengthString(int length)
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
