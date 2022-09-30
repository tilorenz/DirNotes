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

	DirTreeModel(QObject *parent = nullptr) : 
		KDirModel(parent)
	{
		KDirModel::openUrl(m_url);
	}

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
		KDirModel::openUrl(m_url);
		Q_EMIT urlChanged();
	}

	enum Roles{
		FileNameRole = Qt::DisplayRole,
		FileUrlRole,
		IsDirRole,
		DisplayRole,
	};
	
	QHash<int, QByteArray> roleNames() const;


	int columnCount(const QModelIndex &parent = QModelIndex()) const{
		//qDebug() << "columnCount called: " << parent << Qt::endl;
		//return KDirModel::columnCount(parent);
		return 1;
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

	QVariant urlIsDir(const QUrl &url) const{
		return isDir(indexForUrl(url));
	}
	
	QVariant urlForIndex(const QModelIndex &index) const{
		return data(index, Roles::FileUrlRole);
	}

	void openInFileMan(QUrl url){
		//would using XDG portals directly via DBus be more efficient? perhaps.
		// should I escape the string properly for shell? perhaps.
		system("xdg-open \"" + url.toString().toLatin1().replace("\"", "\\\"") + "\"");
	}

	void openInFileMan(){
		openInFileMan(m_url);
	}

	QUrl newFile(const QUrl &, QString);

	bool newDir(const QUrl &, QString);

	bool deleteUrl(const QUrl &url);

	bool isParent(const QUrl &parent, const QUrl &child) const{
		return parent.isParentOf(child);
	}

	// gets a file in directory startDir that is not except or a child of except
	QUrl getFirstDoc(QString startDir, const QUrl &except);
	QUrl getFirstDoc(const QUrl &except){
		return getFirstDoc(m_url.path(), except);
	}

	QUrl renameFile(const QUrl &baseUrl, QString newName);

	QUrl renameDir(const QUrl &baseUrl, QString newName, const QUrl &openFile);

Q_SIGNALS:
	void urlChanged();

private:
	QUrl m_url = QUrl::fromLocalFile(
			QStandardPaths::writableLocation(
				QStandardPaths::GenericDataLocation) + QDir::separator() + "dir_notes");

	QString cleanDirPath(const QUrl&);
};
#endif

