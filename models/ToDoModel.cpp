#include "ToDoModel.h"

ToDoModel::ToDoModel(QObject *parent)
    : QAbstractListModel{parent}
{}

QHash<int, QByteArray> ToDoModel::roleNames() const
{
    QHash<int, QByteArray> names;
    names[DoneRole] = "done";
    names[DescriptionRole] = "description";
    return names;
}
