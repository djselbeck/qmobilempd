#include "mainwindow.h"
#include "commondebug.h"
#include <QtGui/QApplication>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("Hendrik Borghorst");
    QCoreApplication::setApplicationName("qmobilempd");
    QString locale = QLocale::system().name();
    CommonDebug("Locale:"+locale);
    QTranslator translator;
    if(translator.load(QString(":/qmobilempd_")+locale))
    {
        CommonDebug("translation loaded");
    }
    app.installTranslator(&translator);
    MainWindow mainWindow;
    mainWindow.setOrientation(MainWindow::ScreenOrientationAuto);
    mainWindow.showExpanded();


    return app.exec();
}
