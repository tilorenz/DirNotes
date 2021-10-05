import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents 

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin


ColumnLayout{
	id: nField
	property alias ta: mainTextArea
	property var currDoc: ""
	Layout.fillWidth: true
	Layout.fillHeight: true


	WDNPlugin.DocModel{
		id: docModel
		url: nField.currDoc
	}

	Timer{
		id: autoSaveTimer
		onTriggered: {
			print("Autosaving after stopped typing")
			docModel.save()
			docModel.active = false
		}
		//TODO shorter time for testing, use 20s or so for production
		interval: 10000
	}


	PlasmaComponents.ScrollView{
		id: txtScroll

		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true

		PlasmaComponents.TextArea{
			id: mainTextArea
			Layout.fillWidth: true
			Layout.fillHeight: true
			text: docModel.text
			//text: "Main Area.\nFile:\n" + fChooser.currDoc 

			onTextChanged: {
				print("TA: text changed")
				docModel.text = ta.text
				docModel.active = true
				autoSaveTimer.restart()
			}
		}
	}

	Component.onCompleted: {
		docModel.fileChanged.connect(fileChangedRow.expand)
	}

	GridLayout{
		id: fileChangedRow

		property bool expanded: false
		Layout.maximumHeight: expanded ? implicitHeight : 0
		Behavior on Layout.maximumHeight {
			NumberAnimation {
				duration: PlasmaCore.Units.shortDuration
				easing.type: Easing.InOutQuad
			}
		}
		clip: true

		property string savePath
		function expand(path){
			fileChangedRow.savePath = path
			fileChangedRow.expanded = true
		}

		PlasmaComponents.Label{
			id: fcLabel
			text: "File changed on disk. Saving to " + fileChangedRow.savePath
		}

		PlasmaComponents.Button{
			text: "Ok"
			onClicked: {
				fileChangedRow.expanded = false
			}
		}
	}
}

