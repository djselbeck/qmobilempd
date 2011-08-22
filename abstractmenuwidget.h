#ifndef ABSTRACTMENUWIDGET_H
#define ABSTRACTMENUWIDGET_H

#include <QWidget>

class AbstractMenuWidget : public QWidget
{
    Q_OBJECT
public:
    explicit AbstractMenuWidget(QWidget *parent = 0);

signals:
    void showAbout();
    void showFiles();
    void showAlbums();
    void showArtists();
    void showPlaylist();
    void exitClicked();
    void showSettings();
    void connectClicked();
    void showCurrentSong();
    void hideRequest();

public slots:
    virtual void connected() = 0;
    virtual void disconnected() = 0;

};

#endif // ABSTRACTMENUWIDGET_H
