#include "ui_songinfo.h"
#include "ui_ui_songinfo.h"

ui_SongInfo::ui_SongInfo(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ui_SongInfo)
{
    ui->setupUi(this);
}

ui_SongInfo::ui_SongInfo(QWidget *parent, QString title, QString album, QString artist, QString uri, QString info,QString length) : QWidget(parent),
    ui(new Ui::ui_SongInfo)
{
    ui->setupUi(this);
    ui->lbl_title->setText(title);
    ui->lbl_album->setText(album);
    ui->lbl_artist->setText(artist);
    ui->lbl_uri->setText(uri);
    ui->lbl_length->setText(length);
    connect(ui->btn_addtoplaylist,SIGNAL(clicked()),this,SLOT(addButtonDispatcher()));
    connect(ui->btn_play,SIGNAL(clicked()),this,SLOT(playButtonDispatcher()));
    connect(ui->btn_back,SIGNAL(clicked()),this,SIGNAL(request_back()));
    this->show();
}

ui_SongInfo::~ui_SongInfo()
{
    delete ui;
}

void ui_SongInfo::addButtonDispatcher()
{
    emit request_add(ui->lbl_uri->text());
}
void ui_SongInfo::playButtonDispatcher()
{
    emit request_playback(ui->lbl_uri->text());
}

