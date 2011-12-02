#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include <QDeclarativeContext>
#include "networkaccess.h"
#include "controller.h"
#include "mpdartist.h"
#include "commondebug.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QmlApplicationViewer *viewer = new QmlApplicationViewer();
    QCoreApplication::setOrganizationName("Hendrik Borghorst");
    QCoreApplication::setApplicationName("qmobilempd");

    viewer->setMainQmlFile(QLatin1String("qml/qmobilempdqtquick/main.qml"));
    Controller *control = new Controller(viewer,0);

    viewer->showFullScreen();
    return app.exec();
}

