#ifndef WDNPLUGIN_H
#define WDNPLUGIN_H
#include <QQmlEngine>
#include <QQmlExtensionPlugin>
#include <qobjectdefs.h>


//void qml_register_types_com_github_tilorenz_wdnplugin();

class WDNPlugin: public QQmlExtensionPlugin{
	Q_OBJECT
	Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

	public:
	void registerTypes(const char *uri) override;
};
#endif

