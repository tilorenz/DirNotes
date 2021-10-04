#include "docmodel.h"
#include <QFile>
#include <QDebug>


void DocModel::setText(QString str){
	if(str == m_text)
		return;
	m_text = str;
	Q_EMIT textChanged();
}


void DocModel::setActive(bool active){
	if(m_active == active)
		return;
	m_active = active;
	Q_EMIT activeChanged();
}


void DocModel::loadDoc(QUrl url, bool forceReload){
	if(url == m_url && ! forceReload)
		return;
	if(!url.isValid()){
		qDebug() << "URL " << url << " is invalid." <<Qt::endl;
		return;
	}

	// save any changes to the previous document before opening a new one
	if(m_url.isValid() && ! forceReload){
		save();
	}

	m_url = url;
	QFile doc(url.path());

	if(! doc.open(QIODevice::ReadOnly | QIODevice::Text | QIODevice::ExistingOnly)){
		qDebug() << "Couldn't open file" << url.path();
		m_text = "Couldn't open file\n" + url.path();
		Q_EMIT urlChanged();
		Q_EMIT textChanged();
		return;
	}

	// handle file watcher
	m_watcher.removePaths(m_watcher.files());
	m_watcher.addPath(m_url.path());

	m_text = doc.readAll();
	doc.close();
	Q_EMIT urlChanged();
	Q_EMIT textChanged();
}


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

	// unwatch file while writing to it...
	m_watcher.removePath(m_url.path());

	QTextStream out(&doc);
	out << m_text;
	out.flush();
	doc.close();

	// ...and resume watching once it's done
	m_watcher.addPath(m_url.path());
	return true;
}


void DocModel::handleFileChanged(){
	qDebug() << "File changed on disk.";

	if(m_active){
		// save file to /tmp and set current file there (so the user can finish typing)
		// emit fileChanged
	} else{
		// reload
		loadDoc(m_url, true);
	}
}


DocModel::~DocModel(){
	qDebug() << "Destructor called.";
	save();
}
