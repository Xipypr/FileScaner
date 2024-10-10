#include "datamodel.h"
#include <queue>

bool operator<(const WordFrequency& first, const WordFrequency& second)
{
    return first.frequency < second.frequency;
}

DataModel::DataModel() {}

QHash<QString, quint64> DataModel::data() const
{
    return m_data;
}

void DataModel::updateData(QStringList &&newData)
{
    for (auto it = newData.begin(); it != newData.end(); ++it)
    {
        const std::lock_guard<std::mutex> lock(m_mutex);
        ++m_data[*it];
    }
}

QList<WordFrequency> DataModel::getTopWords()
{
    std::priority_queue <WordFrequency> pq;
    {
        const std::lock_guard<std::mutex> lock(m_mutex);
        for (auto it = m_data.begin(); it != m_data.end(); ++it)
        {
            pq.push({it.key(), it.value()});
        }
    }

    QList<WordFrequency> result;
    for (int i = 0; i < qMin(15, static_cast<int>(pq.size())); ++i )
    {
        result.push_back(pq.top());
        pq.pop();
    }

    return result;
}
