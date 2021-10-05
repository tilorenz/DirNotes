#include "docmodel.h"
#include <QFile>
#include <QDebug>
#include <QStandardPaths>
#include <QDir>
#include <QDateTime>


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


/**
 * Writes the current text to a backup path and sets the current file there.
 *
 * @return The save path.
 */
QString DocModel::saveToBackup(){
 	const QString basePath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);
    const QString suffix = QStringLiteral("dir_notes_backup");
    QDir(basePath).mkdir(suffix);

    QString baseFileName = m_url.fileName();
	QString timeStamp = QDateTime::currentDateTime().toString(".yyMMdd_hhmmss");

	QString path = basePath + QDir::separator() + suffix + QDir::separator()
		+ baseFileName + timeStamp;
	QFile doc(path);

	if(! doc.open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::NewOnly)){
		qDebug() << "Couldn't open file" << path;
		return "";
	}

	QTextStream out(&doc);
	out << m_text;
	out.flush();
	doc.close();

	m_url.setPath(path);
	m_watcher.removePaths(m_watcher.files());
	// maybe someone gets the idea to change the backup file in another editor too...
	// you never know
	m_watcher.addPath(path);
	Q_EMIT urlChanged();
	return path;
}


void DocModel::handleFileChanged(){
	qDebug() << "File changed on disk.";

	if(m_active){
		// save file to backup path and set current file there (so the user can finish typing)
		// emit fileChanged
		QString path = saveToBackup();
		Q_EMIT fileChanged(path);
	} else{
		// reload
		loadDoc(m_url, true);
	}
}


DocModel::~DocModel(){
	qDebug() << "Destructor called.";
	save();
}
