#include "docmodel.h"
#include <QFile>
#include <QDebug>


QString DocModel::text() const{
	return m_text;
}

QUrl DocModel::url() const{
	return m_url;
}

void DocModel::setText(QString str){
	if(str == m_text)
		return;
	m_text = str;
	Q_EMIT textChanged();
}

void DocModel::loadDoc(QUrl url){
	if(url == m_url)
		return;
	if(!url.isValid()){
		qDebug() << "URL " << url << " is invalid." <<Qt::endl;
		return;
	}

	if(m_url.isValid()){
		save();
	}

	m_url = url;
#if 1
	QFile doc(url.path());
#else
	QFile doc("metadata.desktop");
#endif

	if(! doc.open(QIODevice::ReadOnly | QIODevice::Text | QIODevice::ExistingOnly)){
		qDebug() << "Couldn't open file" << url.path() << Qt::endl;
		qDebug() << doc.fileName();
		qDebug() << doc.size();
		qDebug() << doc.exists();
		qDebug() << doc.isReadable();
		doc.dumpObjectInfo();
		m_text = "Couldn't open file\n" + url.path();
		Q_EMIT urlChanged();
		Q_EMIT textChanged();
		return;
	}

	m_text = doc.readAll();
	doc.close();
	Q_EMIT urlChanged();
	Q_EMIT textChanged();
}
//

bool DocModel::save(){
	if(!m_url.isValid()){
		qDebug() << "Can't save to URL " << m_url <<" (empty or invalid)" << Qt::endl;
		return false;
	}

	QFile doc(m_url.path());

	if(! doc.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text | QIODevice::ExistingOnly)){
		qDebug() << "Couldn't open file" << m_url << Qt::endl;
		return false;
	}

	qDebug() << "Writing to file " << m_url.path() << Qt::endl;

	QTextStream out(&doc);
	out << m_text;
	out.flush();
	doc.close();
	return true;
}


DocModel::~DocModel(){
	save();
}
