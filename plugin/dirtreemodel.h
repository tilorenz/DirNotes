#include <KDirModel>
#include <qabstractitemmodel.h>
#include <qnamespace.h>
#include <qqml.h>
/*
 * index
 * parent
 * rowCount
 * columnCount
 * data
 */

class DirTreeModel: public QAbstractItemModel{
	Q_OBJECT
	QML_ELEMENT

	Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

	public:
	DirTreeModel(QObject *parent = nullptr):
		beModel(this) {
		 qDebug() << "DirTreeModel constructed" <<Qt::endl;
		 beModel.openUrl(QUrl("file:///home/tino/projects/plasmoids/notes/testDir/"));

		 KDirLister *dirLister = beModel.dirLister();
		 connect(&beModel, &KDirModel::rowsInserted, this, &DirTreeModel::rowsInserted);
		 connect(&beModel, &KDirModel::rowsInserted, this, &DirTreeModel::printInsertedRows);
	}

	QUrl url() const {
		return m_url;
	}

	void setUrl(QUrl url);
	
	QHash<int, QByteArray> roleNames() const;


	int columnCount(const QModelIndex &parent = QModelIndex()) const{
		qDebug() << "columnCount called" << Qt::endl;
		return beModel.columnCount(parent);
	}

	QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const{
		qDebug() << "index called" << Qt::endl;
		return beModel.index(row, column, parent);
	}

	QModelIndex parent(const QModelIndex &index) const{
		qDebug() << "parent called" << Qt::endl;
		return beModel.parent(index);
	}

	int rowCount(const QModelIndex &parent = QModelIndex()) const{
		int rc = beModel.rowCount(parent);
		qDebug() << "rowCount called: " << rc << Qt::endl;
		return rc;
	}

	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const{
		qDebug() << "data called" << Qt::endl;
		return beModel.data(index, role);
	}

	Q_SIGNALS:
	void urlChanged();
	void rowsInserted(const QModelIndex&, int, int);

	public Q_SLOTS:
	void printInsertedRows(const QModelIndex &index, int a, int b){
		qDebug() << "Rows inserted: " << index << a << ", " << b << Qt::endl;
	}

	private:
	KDirModel beModel;
	QUrl m_url;
};
