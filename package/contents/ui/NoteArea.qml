import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents 
import QtQuick.Controls 2.15 as QQC2
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents



ColumnLayout{
	id: nField
	property alias ta: mainTextArea
	Layout.fillWidth: true
	Layout.fillHeight: true

	QQC2.ScrollView{
		id: txtScroll

		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true

		QQC2.TextArea{
			id: mainTextArea
			Layout.fillWidth: true
			Layout.fillHeight: true

		}
	}
}

