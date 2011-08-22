#include "settingsdialog.h"
#include "ui_settingsdialog.h"

SettingsDialog::SettingsDialog(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::SettingsDialog)
{
    ui->setupUi(this);
}

SettingsDialog::SettingsDialog(QList<serverprofile> profiles,QWidget *parent) :
    QWidget(parent),
    ui(new Ui::SettingsDialog)
{
    ui->setupUi(this);
    this->profiles = profiles;
    for(int i=0;i<profiles.length();i++)
    {
        ui->comboBoxProfiles->addItem(profiles.at(i).profilename);
    }
    ui->comboBoxProfiles->setEditable(false);
    ui->btnConnect->hide();
    ui->spinBoxPort->setMaximum(65536);
    ui->spinBoxPort->setMinimum(1);
    connect(ui->leHostname,SIGNAL(editingFinished()),this,SLOT(valueChanged()));
    connect(ui->lePassword,SIGNAL(editingFinished()),this,SLOT(valueChanged()));
    connect(ui->cbDefaultServer,SIGNAL(toggled(bool)),this,SLOT(valueChanged()));
    connect(ui->spinBoxPort,SIGNAL(editingFinished()),this,SLOT(valueChanged()));
    connect(ui->btnCancel,SIGNAL(clicked()),this,SIGNAL(cancelRequested()));
    connect(ui->btnOk,SIGNAL(clicked()),this,SLOT(okClicked()));
    connect(ui->btnAddProfile,SIGNAL(clicked()),this,SLOT(addProfile()));
    connect(ui->btnDeleteProfile,SIGNAL(clicked()),this,SLOT(deleteProfile()));
    connect(ui->comboBoxProfiles,SIGNAL(currentIndexChanged(QString)),this,SLOT(selectedProfileChange(QString)));
    selectedProfileChange(ui->comboBoxProfiles->currentText());
    kineticscroller = new QsKineticScroller(this);
    kineticscroller->enableKineticScrollFor(ui->scrollArea);
    ui->scrollArea->setVerticalScrollBarPolicy(Qt::ScrollBarAlwaysOn);
}

SettingsDialog::~SettingsDialog()
{
    delete ui;
}

void SettingsDialog::selectedProfileChange(QString text)
{
    serverprofile tempprofile = getServerProfile(text);
    if(tempprofile.profilename==text)
    {
        ui->leHostname->setText(tempprofile.hostname);
        ui->lePassword->setText(tempprofile.password);
        ui->spinBoxPort->setValue(tempprofile.port);
        ui->cbDefaultServer->setChecked(tempprofile.defaultprofile);
    }
}

serverprofile SettingsDialog::getServerProfile(QString name)
{
    for(int i=0;i<profiles.length();i++)
    {
        if(name==profiles.at(i).profilename) {
            qDebug("got Profile");
            return profiles.at(i);
        }
    }
    serverprofile tstruct;
    /*tstruct.defaultprofile=false;
    tstruct.profilename="";
    tstruct.hostname="";
    tstruct.password="";*/
    return tstruct;
}

void SettingsDialog::addProfile()
{
    bool canceled = false;
    bool duplicate = false;
    QString profilename = QInputDialog::getText(this,"Profile name","Please enter a profilename:",QLineEdit::Normal,"",&canceled);
    for(int i=0;i<profiles.length();i++)
    {
        if(profilename==profiles.at(i).profilename)
        {
            duplicate = true;
        }
    }
    if( (canceled) && (profilename!="") && !duplicate)
    {
        qDebug("New profile");
        serverprofile tempstruct;
        tempstruct.profilename = profilename;
        tempstruct.port = 6600;
        tempstruct.hostname="";
        tempstruct.password="";
        tempstruct.defaultprofile = false;
        profiles.append(tempstruct);
        ui->comboBoxProfiles->addItem(profilename);
        ui->comboBoxProfiles->setCurrentIndex(ui->comboBoxProfiles->count()-1);
    }
}

void SettingsDialog::deleteProfile()
{
    QString selected = ui->comboBoxProfiles->currentText();
    if(selected!="") {
        for(int i=0;i<profiles.length();i++)
        {
            if(profiles.at(i).profilename==selected)
            {
                profiles.removeAt(i);
                ui->comboBoxProfiles->removeItem(ui->comboBoxProfiles->currentIndex());
            }
        }
    }
}

void SettingsDialog::valueChanged()
{
    QString selected = ui->comboBoxProfiles->currentText();
    if(selected!="") {
        serverprofile tempprofile;
        int index=-1;
        for(int i=0;i<profiles.length();i++)
        {
            if(profiles.at(i).profilename==selected)
            {
                index = i;
            }
        }
        if( (profiles.at(index).defaultprofile!=true) && (ui->cbDefaultServer->isChecked()) )
        {
            makeNoDefault();
        }
        tempprofile.defaultprofile = ui->cbDefaultServer->isChecked();
        tempprofile.hostname = ui->leHostname->text();
        tempprofile.port = ui->spinBoxPort->value();
        tempprofile.password = ui->lePassword->text();
        tempprofile.profilename = selected;
        profiles.replace(index,tempprofile);
    }
}

void SettingsDialog::makeNoDefault()
{
    serverprofile tprofile;
    for(int i=0;i<profiles.length();i++)
    {
        tprofile = profiles.at(i);
        tprofile.defaultprofile = false;
        profiles.replace(i,tprofile);
    }
}

void SettingsDialog::connectionEstablished()
{

}

void SettingsDialog::okClicked()
{
    emit okRequested(profiles);
}
