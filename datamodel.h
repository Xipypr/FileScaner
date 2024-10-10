#ifndef DATAMODEL_H
#define DATAMODEL_H

#include <queue>
#include <set>
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

private:
    std::mutex m_mutex;

    QHash<QString, quint64> m_data;
    std::priority_queue<WordFrequency, std::set<WordFrequency>> m_priorityQueue;
};

#endif // DATAMODEL_H
