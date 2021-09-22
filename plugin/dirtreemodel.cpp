#include "dirtreemodel.h"
#include <qobjectdefs.h>
#include <KDirLister>

 void DirTreeModel::setUrl(QUrl url){
 	 if(url == m_url){
 	 	 qDebug() << "setUrl: Url matches" << Qt::endl;
 	 	 return;
	 }
 	 qDebug() << "setUrl called: " << url << Qt::endl;
 	 beModel.openUrl(url);
	 //beModel.dirLister()->openUrl(url, KDirLister::NoFlags);
 	 Q_EMIT urlChanged();
 }


QHash<int, QByteArray> DirTreeModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "fileName"; //these should match exactly with that in QML
    return roles;
}
