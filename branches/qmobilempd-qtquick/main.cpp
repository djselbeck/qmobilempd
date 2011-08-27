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
    Controller *control = new Controller(viewer,0);
    MpdArtist *artist1 = new MpdArtist(0,"aa");
    MpdArtist *artist2 = new MpdArtist(0,"bb");
    CommonDebug("BLAAAA: "+QString::number(*artist1<*artist2));
    viewer->setMainQmlFile(QLatin1String("qml/qmobilempdqtquick/main.qml"));
    control->connectSignals();
    viewer->showFullScreen();

    return app.exec();
}
