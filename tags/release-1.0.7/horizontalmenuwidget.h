#ifndef HORIZONTALMENUWIDGET_H
#define HORIZONTALMENUWIDGET_H

#include <QWidget>
#include "abstractmenuwidget.h"

namespace Ui {
    class HorizontalMenuWidget;
}

class HorizontalMenuWidget : public AbstractMenuWidget
{
    Q_OBJECT

public:
    explicit HorizontalMenuWidget(QWidget *parent = 0);
    ~HorizontalMenuWidget();

private:
    Ui::HorizontalMenuWidget *ui;

public slots:
    void connected();
    void disconnected();
};

#endif // HORIZONTALMENUWIDGET_H
