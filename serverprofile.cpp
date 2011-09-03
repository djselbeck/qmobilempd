#include "serverprofile.h"

ServerProfile::ServerProfile(QObject *parent) :
    QObject(parent)
{
}

ServerProfile::ServerProfile(QString hostname, QString password, int port, QString name)
{
    this->hostname = hostname;
    this->password = password;
    this->port = port;
    this->name = name;
}

void ServerProfile::setHostname(QString hostname)
{
    this->hostname = hostname;
    emit valueChanged();
}

void ServerProfile::setPassword(QString password)
{
    this->password = password;
    emit valueChanged();
}

void ServerProfile::setName(QString name)
{
    this->name = name;
    emit valueChanged();
}

void ServerProfile::setPort(int port)
{
    this->port = port;
    emit valueChanged();
}
