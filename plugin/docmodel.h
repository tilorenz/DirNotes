#ifndef DOCMODEL_H
#define DOCMODEL_H
#include <QObject>
#include <QString>
#include <QUrl>
#include <qobjectdefs.h>
#include <qqml.h>

//void qml_register_types_com_github_tilorenz_wdnplugin();

class DocModel : public QObject{
	Q_OBJECT
	QML_ELEMENT
	Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
	Q_PROPERTY(QUrl url READ url WRITE loadDoc NOTIFY urlChanged)

	public:
	~DocModel();

	QString text() const;
	QUrl url() const;

	void setText(QString);
	void loadDoc(QUrl);
	
	public Q_SLOTS:
	bool save();

	Q_SIGNALS:
	void textChanged();
	void urlChanged();

	private:
	QString m_text;
	QUrl m_url;
};
#endif

