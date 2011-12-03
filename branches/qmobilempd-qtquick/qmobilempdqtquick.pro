# Add more folders to ship with the application, here
folder_01.source = qml/qmobilempdqtquick
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH = qml/qmobilempdqtquick

symbian:

CONFIG += qt-components

QT       += core gui network


# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian {
    TARGET.CAPABILITY += NetworkServices
#    TARGET.UID3 = 0xE8E76261
    TARGET.UID3 = 0x2004bca1
    LIBS += -lremconinterfacebase -lremconcoreapi
    SOURCES += mediakeysobserver.cpp
    ICON = icon_converted.svg

    my_deployment.pkg_prerules += vendorinfo

    DEPLOYMENT += my_deployment

    DEPLOYMENT.display_name += qmobilempd

    vendorinfo += "%{\"Hendrik Borghorst\"}" ":\"Hendrik Borghorst\""
}

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    wlitrack.cpp \
    wlifile.cpp \
    networkaccess.cpp \
    mpdtrack.cpp \
    mpdfileentry.cpp \
    mpdartist.cpp \
    mpdalbum.cpp \
    commondebug.cpp \
    controller.cpp \
    qthreadex.cpp \
    serverprofile.cpp \
    artistmodel.cpp \
    albummodel.cpp \

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog

HEADERS += \
    wlitrack.h \
    wlifile.h \
    networkaccess.h \
    mpdtrack.h \
    mpdfileentry.h \
    mpdartist.h \
    mpdalbum.h \
    commondebug.h \
    common.h \
    controller.h \
    qthreadex.h \
    serverprofile.h \
    artistmodel.h \
    albummodel.h \
    mediakeysobserver.h




VERSION = 1.0.6











