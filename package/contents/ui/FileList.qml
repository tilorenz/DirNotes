import QtQuick 2.6 
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PCore
import org.kde.plasma.components 3.0 as PComp3
import org.kde.plasma.plasmoid 2.0
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.kirigamiaddons.treeview 1.0 as TreeView

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin

ColumnLayout{
	id: fChooser
	Layout.fillHeight: true
	width: expanded ? expWidth : 0
	implicitWidth: expanded ? expWidth : 0
	Layout.maximumWidth: expanded ? expWidth : 0
	Layout.minimumWidth: expanded ? expWidth : 0

	property bool expanded: true
	//TODO find good value for this
	property double expWidth: Math.min(PCore.Units.gridUnit * 10, mainRow.width * 0.8)
	Behavior on Layout.maximumWidth{
		NumberAnimation{
			duration: PCore.Units.shortDuration
			easing.type: Easing.InOutQuad
		}
	}

	clip: true



	property alias notesPath: dtMod.url
	//TODO: remember last used doc
	property url currDoc: ""

	WDNPlugin.DirTreeModel{
		id: dtMod
		url: plasmoid.configuration.dirPath
		// if the user clicks on a dir, it will be remembered in the config
		onUrlChanged: {
			var path = dtMod.getPath()
			if(path != plasmoid.configuration.dirPath){
				plasmoid.configuration.dirPath = path
			}
		}
	}

	Component.onCompleted: {
		if(plasmoid.configuration.dirPath != ""){
			dtMod.setPath(plasmoid.configuration.dirPath)
		}
	}

	//KItemModels.KRearrangeColumnsProxyModel{
		//id: columnMod
		//sourceModel: dtMod
		//filterString: "Name"
	//}

	KItemModels.KSortFilterProxyModel{
		id: sortMod
		sourceModel: dtMod
		sortRole: "fileName"
		sortOrder: Qt.AscendingOrder
		sortCaseSensitivity: Qt.CaseInsensitive
	}


	TreeView.TreeListView {
		id: fileTree
		clip: true
		Layout.fillWidth: true
		Layout.fillHeight: true

		Timer{
			id: indexSetter
			interval: 200
			property int index: -1
			onTriggered: fileTree.currentIndex = index
		}

		model: sortMod
		// don't automatically highlight/select the first item
		currentIndex: -1

		delegate: TreeView.BasicTreeItem{
			id: tlvDelegate
			label: model.display
			width: fChooser.width
			implicitWidth: fChooser.width
			reserveSpaceForIcon: false

			onClicked: if(isDir){
				// set as root dir
				dtMod.url = fileUrl
			} else{
				// open the document
				print('fileUrl:', fileUrl)
				fChooser.currDoc = fileUrl
			}

			// Setting the index directly doesn't work: it seems when the delegate is added,
			// the view isn't ready to have currentIndex set.
			// Maybe it'll work properly in some future Qt version.
			// And no, Component.onCompleted doesn't work either.
			// So we just wait 200ms and hope nothing else happens during that time.
			ListView.onAdd: {
				if(fileUrl == fChooser.currDoc){
					indexSetter.index = index
					indexSetter.start()
				}
			}
		}
	}


	RowLayout{
		id: ctrlButtonBar
		Layout.maximumHeight: dirUpBtn.implicitHeight
		//Layout.preferredWidth: fileTree.width
		Layout.minimumWidth: fileTree.width
		Layout.maximumWidth: fileTree.width

		PComp3.ToolButton{
			id: sidebarToggleBtn
			Layout.alignment: Qt.AlignLeft
			icon.name: "sidebar-collapse"
			focusPolicy: Qt.TabFocus
			//onClicked: fileTree.expandsByDefault = !fileTree.expandsByDefault
			onClicked: fChooser.expanded = ! fChooser.expanded
			PComp3.ToolTip{
				text: "Collapse Dir Tree"
			}
		}

		PComp3.ToolButton{
			id: dirUpBtn
			Layout.alignment: Qt.AlignLeft
			icon.name: "arrow-up"
			focusPolicy: Qt.TabFocus
			onClicked: dtMod.dirUp()
			PComp3.ToolTip{
				text: "Directory up"
			}
		}

		PComp3.ToolButton{
			id: pinButton
			Layout.alignment: Qt.AlignLeft
			icon.name: "window-pin"
			focusPolicy: Qt.TabFocus
			checkable: true
			// TODO maybe make this a config value
			onToggled: Plasmoid.hideOnWindowDeactivate = !Plasmoid.hideOnWindowDeactivate
			PComp3.ToolTip{
				text: "Keep Open"
			}
		}
	}
}

