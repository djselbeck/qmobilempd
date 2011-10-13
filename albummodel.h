#ifndef ALBUMMODEL_H
#define ALBUMMODEL_H

#include <QAbstractListModel>
#include "mpdalbum.h"

class AlbumModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)
public:
    explicit AlbumModel(QObject *parent = 0);
    AlbumModel(QList<MpdAlbum*> *list,QObject *parent = 0);

    enum EntryRoles {
        AlbumRole = Qt::UserRole + 1,
        SectionRole = Qt::UserRole + 2
    };

    Q_INVOKABLE MpdAlbum* get(int index) {
        return m_entries->at(index);
    }
    Q_INVOKABLE int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;


private:
    QList<MpdAlbum*> *m_entries;

signals:

public slots:

};

#endif // ALBUMMODEL_H
