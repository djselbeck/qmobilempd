#ifndef SETTINGSDIALOG_H
#define SETTINGSDIALOG_H
#include <QObject>

#include "common.h"

#include <QWidget>
#include <QInputDialog>
#include "QsKineticScroller.h"

namespace Ui {
    class SettingsDialog;
}

class SettingsDialog : public QWidget
{
    Q_OBJECT

public:
    explicit SettingsDialog(QWidget *parent = 0);
    SettingsDialog(QList<serverprofile> profiles,QWidget *parent);
    ~SettingsDialog();
    QList<serverprofile> getProfiles();

private:
    Ui::SettingsDialog *ui;
    QList<serverprofile> profiles;
    serverprofile getServerProfile(QString name);
    QsKineticScroller *kineticscroller;

public slots:
    void connectionEstablished();

protected slots:
    void okClicked();
    void selectedProfileChange(QString text);
    void addProfile();
    void deleteProfile();
    void makeNoDefault();
    void valueChanged();


signals:
    void connectRequest(serverprofile);
    void okRequested(QList<serverprofile>);
    void cancelRequested();

};

#endif // SETTINGSDIALOG_H
