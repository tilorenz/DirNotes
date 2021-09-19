import QtQuick 2.6 
import QtQuick.Controls 2.15 as QQC
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import Qt.labs.folderlistmodel 2.15
import org.kde.kirigami 2.4 as Kirigami

//dir-up, new folder, new file

ColumnLayout{
	id: fSelect
	//anchors.fill: parent

	property url notesPath: "file:///home/tino/projects/plasmoids/notes/testDir/"
	//TODO: remember last used doc
	property url currDoc: ""

	/*TODO:
	 * - write own FolderTreeModel that doesn't need QApplication
	 * - replace the list view by Kirigami.TreeListView
	 */
	FolderListModel{
		id: folderModel
		folder: notesPath
		rootFolder: notesPath
		showOnlyReadable: true
		nameFilters: ["*.md", "*.txt"]
	}

	RowLayout{
		id: ctrlButtons
		Layout.maximumHeight: dirUpBtn.implicitHeight
		Layout.preferredWidth: scrArea.width
		Layout.minimumWidth: scrArea.width

		QQC.ToolButton{
			id: dirUpBtn
			Layout.alignment: Qt.AlignLeft
			icon.name: "arrow-up"
			focusPolicy: Qt.TabFocus
			onClicked: notesPath = folderModel.parentFolder
			QQC.ToolTip{
				text: "Directory up"
			}
		}

		QQC.ToolButton{
			id: newFileBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "document-new-symbolic"
			focusPolicy: Qt.TabFocus
			//TODO
			//onClicked: notesPath = folderModel.parentFolder
			QQC.ToolTip{
				text: "New Note"
			}
		}

		QQC.ToolButton{
			id: newFolderBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "folder-new-symbolic"
			focusPolicy: Qt.TabFocus
			//TODO
			//onClicked: notesPath = folderModel.parentFolder
			QQC.ToolTip{
				text: "New Folder"
			}
		}
	}

	PlasmaExtras.ScrollArea{
		id: scrArea
		Layout.alignment: Qt.AlignBottom
		Layout.fillHeight: true

		ListView{
			id: fLst
			anchors.fill: parent
			clip: true
			focus: true
			boundsBehavior: Flickable.StopAtBounds
			model: folderModel

			delegate: Kirigami.BasicListItem {
				id: fLstDelegate
				label: fileName
				icon: fileIsDir ? "folder-symbolic" : "view-list-text"

				onClicked: if(fileIsDir){
					notesPath = fileUrl
				} else{
					currDoc = fileUrl
					print("path: " + fileUrl)
				}
			}
		}
	}
}

