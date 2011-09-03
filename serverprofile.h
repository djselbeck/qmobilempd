#ifndef SERVERPROFILE_H
#define SERVERPROFILE_H

#include <QObject>

class ServerProfile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString hostname READ getHostname WRITE setHostname  NOTIFY valueChanged)
    Q_PROPERTY(QString password READ getPassword WRITE setPassword  NOTIFY valueChanged)
    Q_PROPERTY(QString name READ getName WRITE setName  NOTIFY valueChanged)
    Q_PROPERTY(int port READ getPort WRITE setPort NOTIFY valueChanged)
public:
    explicit ServerProfile(QObject *parent = 0);
    ServerProfile(QString hostname, QString password, int port, QString name);
    QString getHostname() {return hostname;}
    QString getPassword() {return password;}
    QString getName() {return name;}
    int getPort() {return port;}
    void setPort(int port);
    void setName(QString name);
    void setHostname(QString hostname);
    void setPassword(QString password);

signals:
    void valueChanged();

private:
    QString hostname;
    int port;
    QString password;
    QString name;

public slots:

};

#endif // SERVERPROFILE_H
