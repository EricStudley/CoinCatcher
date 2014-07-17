#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QtQuick2ApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/coincatcher/main.qml"));
    viewer.showFullScreen();
    viewer.SizeRootObjectToView;

    return app.exec();
}
