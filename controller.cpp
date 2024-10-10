#include "controller.h"

Controller::Controller(QObject *parent)
    : QObject{parent}
{
    QTimer * timer = new QTimer(this);
    connect(timer, &QTimer::timeout, this, &Controller::updateWordRatingsSignal);

    timer->start(500);
}
