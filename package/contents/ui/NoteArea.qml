import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents 



ColumnLayout{
	id: nField
	property alias ta: mainTextArea
	Layout.fillWidth: true
	Layout.fillHeight: true

	PlasmaComponents.ScrollView{
		id: txtScroll

		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true

		PlasmaComponents.TextArea{
			id: mainTextArea
			Layout.fillWidth: true
			Layout.fillHeight: true

		}
	}
}

