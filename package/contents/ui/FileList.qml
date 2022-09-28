import QtQuick 2.6 
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PCore
import org.kde.plasma.components 2.0 as PComp2
import org.kde.plasma.components 3.0 as PComp3
import org.kde.plasma.plasmoid 2.0
import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.kirigamiaddons.treeview 1.0 as TreeView
import QtQuick.Controls 2.15

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

	Dialog{
		id: confirmationDialog
		standardButtons: Dialog.Ok | Dialog.Cancel
		modal: true
		property string fileName: ""
		property url delUrl: ""

		contentItem: PComp3.Label{
			text: "Do you really want to delete " + confirmationDialog.fileName + "?"
		}

		onAccepted: {
			// load another note in case the current one is deleted
			if(delUrl == fChooser.currDoc || dtMod.isParent(delUrl, fChooser.currDoc)){
				fChooser.currDoc = dtMod.getFirstDoc(delUrl) || fChooser.notesPath + '/New Note.md'
				nArea.text = ""
				dtMod.deleteUrl(delUrl)
				fileTree.currentIndex = -1
			} else{
				dtMod.deleteUrl(delUrl)
			}
		}
	}

	Dialog{
		id: nameDialog
		standardButtons: Dialog.Ok | Dialog.Cancel
		modal: true
		property var createFun: null
		property url baseUrl: ""
		property alias defaultText: nameTextField.text

		contentItem: ColumnLayout{
			PComp3.Label{
				text: "Enter name:"
			}
			PComp3.TextField{
				id: nameTextField
				text: "FileName.md"
			}
		}
		onAccepted: {
			createFun(baseUrl, nameTextField.text)
			nameTextField.text = ""
		}
	}


	TreeView.TreeListView {
		id: fileTree
		clip: true
		Layout.fillWidth: true
		Layout.fillHeight: true
		// IMO the overshoot is annoying when using mouse/laptop touchpad
		boundsBehavior: Flickable.DragOverBounds 

		model: sortMod
		// don't automatically highlight/select the first item
		currentIndex: -1

		MouseArea{
			anchors.fill: parent
			acceptedButtons: Qt.RightButton
			z: -100
			onClicked: {
				viewMenu.popup()
			}
		}

		PComp3.Menu{
			id: viewMenu
			PComp3.MenuItem{
				text: "New note"
				onClicked: {
					nameDialog.baseUrl = dtMod.url
					nameDialog.createFun = dtMod.newFile
					nameDialog.defaultText = "FileName.md"
					nameDialog.open()
				}
			}
			PComp3.MenuItem{
				text: "New directory"
				onClicked: {
					nameDialog.baseUrl = dtMod.url
					nameDialog.createFun = dtMod.newDir
					nameDialog.defaultText = "NewDir"
					nameDialog.open()
				}
			}
			PComp3.MenuItem{
				text: "Open in external program"
				onClicked: dtMod.openInFileMan()
			}
		}

		delegate: TreeView.AbstractTreeItem{
			id: listItem
			Layout.fillWidth: true

			contentItem: Label {
				id: labelItem
				text: model.display
				Layout.fillWidth: true
				color: (highlighted || (pressed && supportsMouseEvents)) ? 
				listItem.activeTextColor : listItem.textColor
				elide: Text.ElideRight
				opacity: 1

				PComp3.Menu{
					id: delegateMenu
					PComp3.MenuItem{
						text: "Rename"
					}
					PComp3.MenuItem{
						text: "New note"
						onClicked: {
							nameDialog.createFun = dtMod.newFile
							nameDialog.defaultText = "FileName.md"
							nameDialog.baseUrl = fileUrl
							nameDialog.open()
						}
					}
					PComp3.MenuItem{
						text: "New directory"
						onClicked: {
							nameDialog.createFun = dtMod.newDir
							nameDialog.defaultText = "NewDir"
							nameDialog.baseUrl = fileUrl
							nameDialog.open()
						}
					}
					PComp3.MenuItem{
						text: "Delete"
						onClicked: {
							confirmationDialog.fileName = fileName
							confirmationDialog.delUrl = fileUrl
							confirmationDialog.open()
						}
					}
					PComp3.MenuItem{
						text: "Open in external program"
						onClicked: dtMod.openInFileMan(fileUrl)
					}
				}

				PCore.ToolTipArea{
					anchors.fill: parent
					mainText: model.display
					icon: isDir ? "folder" :
					(model.display.endsWith(".md") ? "text-markdown" : "text-plain")
				}

				MouseArea{
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					onClicked: {
						if(mouse.button === Qt.LeftButton){
							if(isDir){
								// set as root dir
								dtMod.url = fileUrl
								fileTree.currentIndex = -1
							} else{
								// open the document
								fileTree.currentIndex = index
								fChooser.currDoc = fileUrl
							}
						} else if(mouse.button === Qt.RightButton){
							delegateMenu.popup()
						}
					}
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

