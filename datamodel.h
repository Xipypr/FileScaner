#ifndef DATAMODEL_H
#define DATAMODEL_H

#include <mutex>

#include <QHash>
#include <QStringList>

#include "structs.h"


class DataModel
{
public:
    DataModel();

    QHash<QString, quint64> data() const;
    void updateData(QStringList &&newData);

    QList<WordFrequency> getTopWords();

    void reset();

private:
    std::mutex m_mutex;

    QHash<QString, quint64> m_data;
};

#endif // DATAMODEL_H
