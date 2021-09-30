#ifndef DIRTREEMODEL_H
#define DIRTREEMODEL_H
#include <KDirModel>
#include <qabstractitemmodel.h>
#include <qnamespace.h>
#include <qqml.h>
#include "stdlib.h"
#include <QStandardPaths>
#include <QDir>

class DirTreeModel: public KDirModel{
	Q_OBJECT

	Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

	public:

	QUrl url() const {
		return m_url;
	}

	void setUrl(QUrl url);

	Q_INVOKABLE QString getPath() const {
		return m_url.path();
	}

	Q_INVOKABLE void setPath(QString path){
		if(m_url.path() == path)
			return;
		m_url.setPath(path);
		Q_EMIT urlChanged();
	}

	enum Roles{
		FileNameRole = Qt::DisplayRole,
		FileUrlRole,
		IsDirRole,
	};
	
	QHash<int, QByteArray> roleNames() const;


	int columnCount(const QModelIndex &parent = QModelIndex()) const{
		//qDebug() << "columnCount called: " << parent << Qt::endl;
		return KDirModel::columnCount(parent);
	}

	QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const{
		//qDebug() << "index called: " << row << ", " << column << ", "
			//<< parent << Qt::endl;
		return KDirModel::index(row, column, parent);
	}

	QModelIndex parent(const QModelIndex &index) const{
		//qDebug() << "parent called: " << index << Qt::endl;
		return KDirModel::parent(index);
	}

	int rowCount(const QModelIndex &parent = QModelIndex()) const{
		int rc = KDirModel::rowCount(parent);
		//qDebug() << "rowCount called: " << rc << ", " << parent<< Qt::endl;
		return rc;
	}

	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

	public Q_SLOTS:
	void dirUp();

/*
 * QQC1 TreeView is weird, appearantly the items cannot directly access the model via role names.
 */
	QVariant isDir(const QModelIndex &index) const{
		return data(index, Roles::IsDirRole);
	}
	
	QVariant urlForIndex(const QModelIndex &index) const{
		return data(index, Roles::FileUrlRole);
	}

	void openInFileMan(QUrl url){
		//would using XDG portals directly via DBus be more efficient? perhaps.
		system("xdg-open " + url.toString().toLatin1());
	}

	void openInFileMan(){
		openInFileMan(m_url);
	}

	bool newFile(const QUrl &, QString);

	bool newFile(QString name){
		return newFile(m_url, name);
	}

	Q_SIGNALS:
	void urlChanged();

	private:
	QUrl m_url = QUrl::fromLocalFile(
			QStandardPaths::writableLocation(
				QStandardPaths::GenericDataLocation) + QDir::separator() + "dir_notes");
};
#endif

