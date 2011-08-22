#ifndef VERTICALMENUWIDGET_H
#define VERTICALMENUWIDGET_H

#include <QWidget>
#include "abstractmenuwidget.h"

namespace Ui {
    class VerticalMenuWidget;
}

class VerticalMenuWidget : public AbstractMenuWidget
{
    Q_OBJECT

public:
    explicit VerticalMenuWidget(QWidget *parent = 0);
    ~VerticalMenuWidget();

private:
    Ui::VerticalMenuWidget *ui;

public slots:
    void connected();
    void disconnected();
};

#endif // VERTICALMENUWIDGET_H
