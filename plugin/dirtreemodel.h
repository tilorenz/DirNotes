#include <KDirModel>
#include <qabstractitemmodel.h>
#include <qnamespace.h>
#include <qqml.h>

class DirTreeModel: public KDirModel{
	Q_OBJECT

	Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

	public:

	QUrl url() const {
		return m_url;
	}

	void setUrl(QUrl url);

	enum Roles{
		FileNameRole = Qt::DisplayRole,
		FileUrlRole,
		IsDirRole,
	};
	
	QHash<int, QByteArray> roleNames() const;


	int columnCount(const QModelIndex &parent = QModelIndex()) const{
		qDebug() << "columnCount called" << Qt::endl;
		return KDirModel::columnCount(parent);
	}

	QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const{
		qDebug() << "index called" << Qt::endl;
		return KDirModel::index(row, column, parent);
	}

	QModelIndex parent(const QModelIndex &index) const{
		qDebug() << "parent called" << Qt::endl;
		return KDirModel::parent(index);
	}

	int rowCount(const QModelIndex &parent = QModelIndex()) const{
		int rc = KDirModel::rowCount(parent);
		qDebug() << "rowCount called: " << rc << Qt::endl;
		return rc;
	}

	QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;

	public Q_SLOTS:
	void dirUp();


	Q_SIGNALS:
	void urlChanged();

	private:
	QUrl m_url;
};
