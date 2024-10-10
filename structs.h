#ifndef STRUCTS_H
#define STRUCTS_H

#include <QString>
#include <QObject>

struct WordFrequency
{
    Q_GADGET
    Q_PROPERTY(QString word MEMBER word)
    Q_PROPERTY(quint64 frequency MEMBER frequency)

public:
    QString word;
    quint64 frequency;
};

Q_DECLARE_METATYPE(WordFrequency)
#endif // STRUCTS_H
