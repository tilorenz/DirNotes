#ifndef DOCMODEL_H
#define DOCMODEL_H
#include <QObject>
#include <QString>
#include <QUrl>
#include <qobjectdefs.h>
#include <qqml.h>
#include <QFileSystemWatcher>

//void qml_register_types_com_github_tilorenz_wdnplugin();

class DocModel : public QObject{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
	Q_PROPERTY(QUrl url READ url WRITE loadDoc NOTIFY urlChanged)
	Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
	// if the latest text change was set from the model.
	// in that case, there is no need to set the active property and save the doc.
	Q_PROPERTY(bool textSetFromModel READ textSetFromModel WRITE setTSFM NOTIFY textSetFromModelChanged)

	public:
	DocModel(QObject *parent = nullptr) : 
		m_watcher(this)
	{
		connect(&m_watcher, &QFileSystemWatcher::fileChanged,
				this, &DocModel::handleFileChanged);
	}

	~DocModel();

	QString text() const{
		return m_text;
	}

	QUrl url() const{
		return m_url;
	}

	bool active() const{
		return m_active;
	}

	bool textSetFromModel() const{
		return m_textSetFromModel;
	}

	void setText(QString);
	void loadDoc(QUrl, bool forceReload = false);
	void setActive(bool);
	void setTSFM(bool);
	
	public Q_SLOTS:
	bool save();
	void handleFileChanged();

	Q_SIGNALS:
	void textChanged();
	void urlChanged();
	void textSetFromModelChanged();

	// the UI listens for this, displaying a message that the file was saved
	// to the specified path.
	void fileChanged(QString path);
	void activeChanged();

	private:
	QString m_text;
	QUrl m_url;
	QFileSystemWatcher m_watcher;
	bool m_active = false;
	bool m_textSetFromModel = false;

	QString saveToBackup();
};
#endif

