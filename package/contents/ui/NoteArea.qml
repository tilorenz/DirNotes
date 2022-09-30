import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents 
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.4 as Kirigami

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin


ColumnLayout{
	id: nArea
	Layout.fillWidth: true
	Layout.fillHeight: true

	property alias ta: mainTextArea
	property var currDoc: ""
	property alias text: docModel.text
	property var fileAboutToBeRenamed: docModel.fileAboutToBeRenamed

	WDNPlugin.DocModel{
		id: docModel
		url: nArea.currDoc
	}

	Timer{
		id: autoSaveTimer
		onTriggered: {
			//print("Autosaving after stopped typing")
			docModel.save()
			docModel.active = false
		}
		interval: 10000
	}

	// this is needed so we can keep the sidebarToggleBtn above the textfield
	// and anchored to the bottom of the plasmoid (without it scrolling with the text)
	Item{
		id: taContainer
		Layout.fillWidth: true
		Layout.fillHeight: true

		PlasmaComponents.ScrollView{
			id: txtScroll
			anchors.fill: parent
			//Layout.fillWidth: true
			//Layout.fillHeight: true
			clip: true

			PlasmaComponents.TextArea{
				id: mainTextArea
				Layout.fillWidth: true
				Layout.fillHeight: true
				text: docModel.text
				//text: "Main Area.\nFile:\n" + fChooser.currDoc 

				onTextChanged: {
					// if the text change was caused by the model loading a new text,
					// there is no need to save it and set active
					if(docModel.textSetFromModel){
						docModel.textSetFromModel = false
						return
					}

					//print("TA: text changed")
					docModel.text = ta.text
					docModel.active = true
					autoSaveTimer.restart()
				}
			}
		}

		// the button toggling the sidebar with the directory tree
		PlasmaComponents.ToolButton{
			id: sidebarToggleBtn
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			//visible: mainTextArea.hovered || sidebarToggleBtn.hovered
			 ////IDK if the animation really makes it better; will have to get feedback
			visible: opacity > 0
			// TODO find a way to test this (simulate a touch device)
			opacity: mainTextArea.hovered || sidebarToggleBtn.hovered || Kirigami.Settings.tabletModeAvailable
			Behavior on opacity{
				NumberAnimation{
					duration: PlasmaCore.Units.longDuration
					easing.type: Easing.OutQuad
				}
			}
			icon.name: fChooser.expanded ? "sidebar-collapse" : "sidebar-expand"
			focusPolicy: Qt.TabFocus
			onClicked: fChooser.expanded = ! fChooser.expanded
			PlasmaComponents.ToolTip{
				text: fChooser.expanded ? "Collapse Dir Tree" : "Expand Dir tree"
			}
		}
	}


	Component.onCompleted: {
		docModel.fileChanged.connect(fileChangedRow.expand)
	}

	ColumnLayout{
		id: fileChangedRow
		Layout.maximumWidth: mainTextArea.width
		Layout.fillWidth: true

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
			wrapMode: Text.Wrap
			//Layout.maximumWidth: parent.width
			width: mainTextArea.width
			Layout.fillWidth: true
			//Layout.preferredWidth: mainTextArea.width
			//Layout.fillHeight: true
			//anchors{
				//top: fileChangedRow.top
				//right: fileChangedRow.right
				//left: fileChangedRow.left
				//bottom: okBtt.top
			//}
			//implicitWidth: mainTextArea.width
		}

		PlasmaComponents.Button{
			id: okBtt
			//anchors{
				//top: fcLabel.top
				//right: fileChangedRow.right
				//left: fileChangedRow.left
				//bottom: fileChangedRow.top
			//}
			text: "Ok"
			onClicked: {
				fileChangedRow.expanded = false
			}
		}
	}
}

