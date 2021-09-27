#include "wdnplugin.h"
#include "docmodel.h"
#include "dirtreemodel.h"
#include <qqml.h>

void WDNPlugin::registerTypes(const char *uri){
    Q_ASSERT(QLatin1String(uri) == QLatin1String("com.github.tilorenz.wdnplugin"));

    qmlRegisterType<DocModel>(uri, 1, 0, "DocModel");
    qmlRegisterType<DirTreeModel>(uri, 1, 0, "DirTreeModel");

    qmlProtectModule("com.github.tilorenz.wdnplugin", 1);
}





#include "wdnplugin.moc"

