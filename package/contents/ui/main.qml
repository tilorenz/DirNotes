import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin

RowLayout {
	id: root
	Plasmoid.switchHeight: 2 * PlasmaCore.Units.gridUnit
	Plasmoid.switchWidth: 4 * PlasmaCore.Units.gridUnit
	height: 20 * PlasmaCore.Units.gridUnit
	width: 20 * PlasmaCore.Units.gridUnit

	WDNPlugin.DocModel{
		id: handler
		url: fChooser.currDoc
	}

	Timer{
		id: autoSaveTimer
		onTriggered: {
			print("Autosaving after stopped typing")
			handler.save()
		}
		//TODO shorter time for testing, use 20s or so for production
		interval: 5000
	}


	FileList{
		id: fChooser
		Layout.alignment: Qt.AlignLeft
		Layout.fillWidth: true
		Layout.fillHeight: true

	}

	NoteArea{
		id: nArea
		Layout.alignment: Qt.AlignRight
		//ta.text: "Main Area.\nFile:\n" + fChooser.currDoc 
		ta.text: handler.text
		ta.onEditingFinished: print("editing finished")
		ta.onTextChanged: {
			print("TA: text changed")
			handler.text = ta.text
			autoSaveTimer.restart()
		}
	}

	//onHeightChanged: console.log("new height: " + height)
}
