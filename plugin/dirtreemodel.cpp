#include "dirtreemodel.h"
#include <qobjectdefs.h>
#include <KDirLister>
#include <QStandardPaths>
#include <QDir>

 void DirTreeModel::setUrl(QUrl url){
 	if(url == m_url.path() && url.path() != "")
 		return;
 	// AppDataLocation gives the plasmashell path for plasmoids
 	QString stdPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    const QString suffix = QStringLiteral("dir_notes");

 	 // Calling with an empty URL resets to standard path.
 	if(url.path() == ""){
		QDir(stdPath).mkdir(suffix);
 	 	if(m_url.path() == stdPath + QDir::separator() + suffix)
 	 	 	return;
 		m_url.setPath(stdPath + QDir::separator() + suffix);
	} else{
		m_url = url;
	}

	KDirModel::openUrl(m_url);
 	Q_EMIT urlChanged();
 }


QHash<int, QByteArray> DirTreeModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FileNameRole] = "fileName";
    roles[FileUrlRole] = "fileUrl";
    roles[IsDirRole] = "isDir";
    roles[DisplayRole] = "display";
    roles[ParentUrlRole] = "parentUrl";
    return roles;
}

QVariant DirTreeModel::data(const QModelIndex &index, int role) const{
	//qDebug() << "data called: " << index << roleNames()[role] << Qt::endl;

	const KFileItem item = qvariant_cast<KFileItem>(KDirModel::data(index, KDirModel::FileItemRole));
	switch(role){
		case FileNameRole:
			return KDirModel::data(index, Qt::DisplayRole);
		case IsDirRole:
			return item.isDir();
		case FileUrlRole:
			return item.url();
		case DisplayRole:
			return KDirModel::data(index, Qt::DisplayRole);
		case ParentUrlRole:{
							   const KFileItem parentItem = qvariant_cast<KFileItem>(
									   KDirModel::data(index.parent(), KDirModel::FileItemRole));
							   qDebug() << "parent item: " << parentItem.url();
							   return parentItem.url();
						   }
		default:
			qDebug() << "Requested role: " << role << " for index " << index;
	}
	return KDirModel::data(index, role);
}



void DirTreeModel::dirUp(){
	QDir dir(m_url.path());
	if(! dir.cdUp()){
		qDebug() << "Couldn't go to parent dir." << Qt::endl;
		return;
	}

	m_url.setPath(dir.path());
	KDirModel::openUrl(m_url);
	Q_EMIT urlChanged();
}


bool DirTreeModel::newFile(const QUrl &baseDir, QString name){
	QString path;
	if(baseDir.path().isEmpty()){
		path = QString(m_url.path() + "/" + name);
	} else{
		path = QString(baseDir.path() + "/" + name);
	}
	QFile nFile(path);
	if(! nFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::NewOnly))
		return false;
	nFile.close();
	// make sure the parent dir is listed if it was empty before
	if(! baseDir.path().isEmpty() && canFetchMore(indexForUrl(baseDir))){
		fetchMore(indexForUrl(baseDir));
	}
	return true;
}

bool DirTreeModel::newDir(const QUrl &baseDir, QString name){
	QString path;
	if(baseDir.path().isEmpty()){
		path = m_url.path();
	} else{
		path = baseDir.path();
	}
	QDir dir(path);
	bool ret = dir.mkpath(name);
	// make sure the parent dir is listed if it was empty before
	if(! baseDir.path().isEmpty() && canFetchMore(indexForUrl(baseDir))){
		fetchMore(indexForUrl(baseDir));
	}
	return ret;
}

