import QtQuick 2.6 
import QtQuick.Controls 2.15 as QQC
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PCore
import org.kde.plasma.components 2.0 as PComp2
import org.kde.plasma.components 3.0 as PComp3
import org.kde.plasma.extras 2.0 as PExtras
import org.kde.kquickcontrolsaddons 2.0 as KQuickControlsAddonsComponents
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kirigamiaddons.treeview 1.0 as KiriAdd
import org.kde.kitemmodels 1.0 as KItemModels

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin

ColumnLayout{
	id: fSelect
	Layout.fillWidth: true
	Layout.fillHeight: true
	implicitWidth: scrArea.implicitWidth
	//anchors.fill: parent

	property url notesPath: "file:///home/tino/projects/plasmoids/notes/testDir/"
	//TODO: remember last used doc
	property url currDoc: ""

	WDNPlugin.DirTreeModel{
		id: dtMod
		url: notesPath
		onUrlChanged: notesPath = url
	}
	KItemModels.KSortFilterProxyModel{
		id: prox
		sourceModel: dtMod
		sortRole: "fileName"
		sortOrder: Qt.AscendingOrder
	}

	RowLayout{
		id: ctrlButtonBar
		Layout.maximumHeight: dirUpBtn.implicitHeight
		Layout.preferredWidth: scrArea.width
		Layout.minimumWidth: scrArea.width

		QQC.ToolButton{
			id: dirUpBtn
			Layout.alignment: Qt.AlignLeft
			icon.name: "arrow-up"
			focusPolicy: Qt.TabFocus
			onClicked: dtMod.dirUp()
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
			id: fileMgrBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "folder-open-symbolic"
			focusPolicy: Qt.TabFocus
			//TODO
			//onClicked: notesPath = folderModel.parentFolder
			QQC.ToolTip{
				text: "Open folder in File Manager"
			}
		}
	}
	QQC1.TreeView{
		id: fileTree
		model: prox
		//Layout.fillWidth: true
		Layout.fillHeight: true
		implicitWidth: fileDelegate.implicitWidth


		alternatingRowColors: false
		headerVisible: false

		QQC1.TableViewColumn{
			title: "Name"
			role: "fileName"
		}

		rowDelegate: Rectangle{
			MouseArea{
				id: rowMouseArea
				anchors.fill: parent
				hoverEnabled: true //handle containsMouse...
				propagateComposedEvents: true //...and let other areas do their job
				acceptedButtons: Qt.NoButton
			}
			color: rowMouseArea.containsMouse ? PCore.Theme.highlightColor : PCore.Theme.backgroundColor
		}

		itemDelegate: PComp3.Label{
			id: fileDelegate
			text: styleData.value
			color: PCore.Theme.textColor
			//background: Rectangle{
				//color: PCore.Theme.backgroundColor
			//}

			MouseArea{
				anchors.fill: parent
				onClicked:{
					var ind = prox.mapToSource(styleData.index)
					if(dtMod.isDir(ind)){
						dtMod.url = dtMod.urlForIndex(ind)
					} else{
						currDoc = dtMod.urlForIndex(ind)
					}
				}
			}
		}
	}
}

