#ifndef CURRENTSONGWIDGET_H
#define CURRENTSONGWIDGET_H

#include <QWidget>
#include "networkaccess.h"

namespace Ui {
    class CurrentSongWidget;
}

class CurrentSongWidget : public QWidget
{
    Q_OBJECT

public:
    explicit CurrentSongWidget(QWidget *parent = 0);
    CurrentSongWidget(QWidget *parent,NetworkAccess *netaccess);
    ~CurrentSongWidget();

private:
    Ui::CurrentSongWidget *ui;
    NetworkAccess *netaccess;
    QString getLengthString(int time);
    int songid;

protected slots:
    void updateStatus(status_struct);
    void seekPosition(int value);

signals:
    void backRequested();
};

#endif // CURRENTSONGWIDGET_H
