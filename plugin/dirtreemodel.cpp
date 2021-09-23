#include "dirtreemodel.h"
#include <qobjectdefs.h>
#include <KDirLister>

 void DirTreeModel::setUrl(QUrl url){
 	 if(url == m_url)
 	 	 return;
 	 qDebug() << "setUrl called: " << url << Qt::endl;
	 m_url = url;
	 KDirModel::openUrl(m_url);
	 //beModel.dirLister()->openUrl(url, KDirLister::NoFlags);
 	 Q_EMIT urlChanged();
 }


QHash<int, QByteArray> DirTreeModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FileNameRole] = "fileName";
    roles[FileUrlRole] = "fileUrl";
    roles[IsDirRole] = "isDir";
    return roles;
}

	QVariant DirTreeModel::data(const QModelIndex &index, int role) const{
		qDebug() << "data called" << Qt::endl;

		const KFileItem item = qvariant_cast<KFileItem>(KDirModel::data(index, KDirModel::FileItemRole));
		switch(role){
			case FileNameRole:
				return KDirModel::data(index, Qt::DisplayRole);
			case IsDirRole:
				return item.isDir();
			case FileUrlRole:
				return item.url();
		}
		return KDirModel::data(index, role);
	}



void DirTreeModel::dirUp(){
	qDebug() << "dirUp called. path: " << m_url.path() 
		<< ", url: " << m_url << Qt::endl;
	QString path = m_url.path();
	if(path == "/" || path.isEmpty()){
		return;
	}
	qDebug() << "Path before chopping: " << path << Qt::endl;

	while(path.back() == '/'){
		path.chop(1);
	}
	// "ab/de" -> lastIndex is 2
	int newLen = path.lastIndexOf("/");
	qDebug() << "Path before truncating: " << path << Qt::endl;
	path.truncate(newLen);
	qDebug() << "Path after truncating: " << path << Qt::endl;

	m_url.setPath(path);
	KDirModel::openUrl(m_url);
	Q_EMIT urlChanged();
}
