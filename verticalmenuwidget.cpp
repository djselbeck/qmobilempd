#include "verticalmenuwidget.h"
#include "ui_verticalmenuwidget.h"

VerticalMenuWidget::VerticalMenuWidget(QWidget *parent) :
    AbstractMenuWidget(parent),
    ui(new Ui::VerticalMenuWidget)
{
    ui->setupUi(this);
    connect(ui->btnAbout,SIGNAL(clicked()),this,SIGNAL(showAbout()));
    connect(ui->btnExit,SIGNAL(clicked()),this,SIGNAL(exitClicked()));
    connect(ui->btnFiles,SIGNAL(clicked()),this,SIGNAL(showFiles()));
    connect(ui->btnArtists,SIGNAL(clicked()),this,SIGNAL(showArtists()));
    connect(ui->btnAlbums,SIGNAL(clicked()),this,SIGNAL(showAlbums()));
    connect(ui->btnConnect,SIGNAL(clicked()),this,SIGNAL(connectClicked()));
    connect(ui->btnCurrentSong,SIGNAL(clicked()),this,SIGNAL(showCurrentSong()));
    connect(ui->btnSettings,SIGNAL(clicked()),this,SIGNAL(showSettings()));
    connect(ui->btnPlaylists,SIGNAL(clicked()),this,SIGNAL(showPlaylist()));
}

VerticalMenuWidget::~VerticalMenuWidget()
{
    delete ui;
}


void VerticalMenuWidget::disconnected()
{
    ui->btnConnect->setText(tr("Connect"));
}

void VerticalMenuWidget::connected()
{
    ui->btnConnect->setText(tr("Disconnect"));
}
