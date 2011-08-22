#ifndef UI_SONGINFO_H
#define UI_SONGINFO_H

#include <QWidget>

namespace Ui {
    class ui_SongInfo;
}

class ui_SongInfo : public QWidget
{
    Q_OBJECT

public:
    explicit ui_SongInfo(QWidget *parent = 0);
    ui_SongInfo(QWidget *parent,QString title, QString album,QString artist, QString uri, QString info,QString length);
    virtual ~ui_SongInfo();

protected slots:
    void playButtonDispatcher();
    void addButtonDispatcher();

signals:
    void request_back();
    void request_playback(QString fileuri);
    void request_add(QString fileuri);

private:
    Ui::ui_SongInfo *ui;
};

#endif // UI_SONGINFO_H
