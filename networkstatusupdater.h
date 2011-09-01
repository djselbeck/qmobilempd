#ifndef NETWORKSTATUSUPDATER_H
#define NETWORKSTATUSUPDATER_H

#include <QThread>
#include <QTimer>
#include <QTcpSocket>
#include "mpdtrack.h"
#include "mpdfileentry.h"
#include "mpdartist.h"
#include "mpdalbum.h"
#include "common.h"
#include "commondebug.h"
#include <QStringList>


class NetworkStatusUpdater : public QThread
{
    Q_OBJECT
public:
    explicit NetworkStatusUpdater(QObject *parent = 0);
    NetworkStatusUpdater(QString hostname, QString password, int port, QObject *parent = 0);
    bool connectToHost(QString hostname, quint16 port,QString password);
    void setInterval(int time);
    void startRunning();
    void stopRunning();
    bool authenticate(QString password);
    QList<MpdTrack*> *getCurrentPlaylistTracks();

private:
    status_struct getStatus();
    QTcpSocket *tcpsocket;
    QTimer *updatetimer;
    QString hostname,password;
    int port;
    bool running;
    int mPlaylistversion;

protected:
    void run();

signals:
    void statusUpdate(status_struct status);
    void currentPlayListReady(QList<QObject*>*);


public slots:
    void stopUpdating();
    void doUpdate();
protected slots:


};

#endif // NETWORKSTATUSUPDATER_H
