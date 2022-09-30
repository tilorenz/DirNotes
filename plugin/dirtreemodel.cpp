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


QUrl DirTreeModel::newFile(const QUrl &baseDir, QString name){
	QString path = cleanDirPath(baseDir) + "/" + name;
	QFile nFile(path);
	if(! nFile.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::NewOnly))
		return QUrl("");
	nFile.close();
	// make sure the parent dir is listed if it was empty before
	if(! baseDir.path().isEmpty() && canFetchMore(indexForUrl(baseDir))){
		fetchMore(indexForUrl(baseDir));
	}
	return QUrl(path);
}


bool DirTreeModel::newDir(const QUrl &baseDir, QString name){
	QString path = cleanDirPath(baseDir);
	QDir dir(path);
	bool ret = dir.mkpath(name);
	// make sure the parent dir is listed if it was empty before
	if(! baseDir.path().isEmpty() && canFetchMore(indexForUrl(baseDir))){
		fetchMore(indexForUrl(baseDir));
	}
	return ret;
}


// gives a valid path that a new file/directory can be created in.
// handles empty paths and paths to files (in which case it'll return the parent dir)
QString DirTreeModel::cleanDirPath(const QUrl &baseDir){
	if(baseDir.path().isEmpty()){
		return m_url.path();
	} 
	if((qvariant_cast<bool>(data(indexForUrl(baseDir), IsDirRole)))){
		return baseDir.path();
	} 
	QModelIndex baseIndex = indexForUrl(baseDir);
	const KFileItem parentItem = qvariant_cast<KFileItem>(
			KDirModel::data(baseIndex.parent(), KDirModel::FileItemRole));
	QString path = parentItem.url().path();
	return path.isEmpty() ? m_url.path() : path;
}


bool DirTreeModel::deleteUrl(const QUrl &url){
	if(qvariant_cast<bool>(data(indexForUrl(url), IsDirRole))){
		QDir dir(url.path());
		return dir.removeRecursively();
	}
	QFile file(url.path());
	return file.remove();
}


QUrl DirTreeModel::getFirstDoc(QString startDir, const QUrl &except){
	QDir rootDir(startDir);
	QFileInfoList list = rootDir.entryInfoList(
			QDir::Files | QDir::NoDotAndDotDot | QDir::Readable | QDir::Writable);
	for(QFileInfoList::const_iterator i = list.constBegin(); i != list.constEnd(); ++i){
		QString path = (*i).absoluteFilePath();
		if(path != except.path()){
			return path;
		}
	}
	list = rootDir.entryInfoList(QDir::Dirs | QDir:: NoDotAndDotDot);
	for(QFileInfoList::const_iterator i = list.constBegin(); i != list.constEnd(); ++i){
		QString dirPath = (*i).absoluteFilePath();
		if(dirPath == except.path()){
			continue;
		}
		QString ret = getFirstDoc(dirPath, except).path();
		if(! ret.isEmpty()){
			return ret;
		}
	}
	return QUrl("");
}

QUrl DirTreeModel::renameFile(const QUrl &baseUrl, QString newName){
	QFileInfo info(baseUrl.path());
	QDir parentDir = info.dir();
	qDebug() << "renameFile: parentDir: " << parentDir.path();
	QString oldName = baseUrl.fileName();
	if(parentDir.rename(oldName, newName)){
		return QUrl(parentDir.absoluteFilePath(newName));
	} else{
		return baseUrl;
	}
}


QUrl DirTreeModel::renameDir(const QUrl &baseUrl, QString newName, const QUrl &openFile){
	QDir dir(baseUrl.path());
	QString oldName = dir.dirName();
	QString relativePath = dir.relativeFilePath(openFile.path());
	dir.cdUp();
	if(! dir.rename(oldName, newName)){
		qDebug() << "Failed to rename Dir from " << oldName  << " to " << newName;
		return openFile;
	}
	dir.cd(newName);
	return QUrl(dir.absoluteFilePath(relativePath));
}


//bool DirTreeModel::isParent(const QUrl &parent, const QUrl &child) const{
	//QModelIndex parentIndex = indexForUrl(parent);
	//QModelIndex childIndex = indexForUrl(child);
	//if(! parentIndex.isValid() || ! childIndex.isValid()){
		//qDebug() << "isparent: Invalid index.";
		//return true;
	//}
	//for(QModelIndex p = childIndex.parent(); p.isValid(); p = p.parent()){
		//if(p == parentIndex){
			//return true;
		//}
	//}
	//return false;
//}


