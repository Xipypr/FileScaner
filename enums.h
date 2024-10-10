#ifndef ENUMS_H
#define ENUMS_H

#include <QObject>

namespace FileExplorerEnums
{
Q_NAMESPACE

enum States
{
    IDLE,
    READY_TO_START,
    RUNNIG,
    PAUSED,
    STOPPED,
    READING_ENDED
};

Q_ENUM_NS(States)
}

#endif // ENUMS_H
