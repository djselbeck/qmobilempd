#-------------------------------------------------
#
# Project created by QtCreator 2011-03-08T12:33:19
#
#-------------------------------------------------

QT       += core gui network

TARGET = qmobilempd
TEMPLATE = app

SOURCES += main.cpp mainwindow.cpp \
    networkaccess.cpp \
    mpdalbum.cpp \
    mpdartist.cpp \
    mpdtrack.cpp \
    ui_songinfo.cpp \
    wlitrack.cpp \
    ui_contextview.cpp \
    settingsdialog.cpp \
    mpdfileentry.cpp \
    wlifile.cpp \
    QsKineticScroller.cpp \
    commondebug.cpp \
    currentsongwidget.cpp \
    abstractmenuwidget.cpp \
    verticalmenuwidget.cpp \
    horizontalmenuwidget.cpp
HEADERS += mainwindow.h \
    networkaccess.h \
    mpdalbum.h \
    mpdartist.h \
    mpdtrack.h \
    ui_songinfo.h \
    wlitrack.h \
    ui_contextview.h \
    settingsdialog.h \
    common.h \
    mpdfileentry.h \
    wlifile.h \
    QsKineticScroller.h \
    commondebug.h \
    currentsongwidget.h \
    abstractmenuwidget.h \
    verticalmenuwidget.h \
    horizontalmenuwidget.h
FORMS += mainwindow.ui \
    ui_songinfo.ui \
    ui_contextview.ui \
    settingsdialog.ui \
    currentsongwidget.ui \
    verticalmenuwidget.ui \
    horizontalmenuwidget.ui

# Please do not modify the following two lines. Required for deployment.

RESOURCES += \
    Icons.qrc

OTHER_FILES += \
    README.txt \
    Changelog.txt \
    debian/changelog \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog


#CONFIG += mobility
#MOBILITY = feedback

symbian {
    TARGET.UID3 = 0xe45c4912
    TARGET.CAPABILITY += NetworkServices
    TARGET.EPOCSTACKSIZE = 0x14000
    TARGET.EPOCHEAPSIZE = 0x020000 0x8000000
    ICON = qmobilempd.svg
}


VERSION = 1.0.7

TRANSLATIONS = qmobilempd_en.ts \
                qmobilempd_de.ts

unix:!symbian:!maemo5 {
    target.path = /opt/qmobilempd/bin
    INSTALLS += target
}
