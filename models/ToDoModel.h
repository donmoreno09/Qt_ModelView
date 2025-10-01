#ifndef TODOMODEL_H
#define TODOMODEL_H

#include <QObject>
#include <QAbstractListModel>

class ToDoModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ToDoModel(QObject *parent = nullptr);

    enum {
        DoneRole = Qt::UserRole,
        DescriptionRole
    };

    //Basic Functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

signals:
};

#endif // TODOMODEL_H
