import QtQuick 2.6 
import QtQuick.Controls 1.4 as QQC1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PCore
import org.kde.plasma.components 3.0 as PComp3
import org.kde.kitemmodels 1.0 as KItemModels

import com.github.tilorenz.wdnplugin 1.0 as WDNPlugin

ColumnLayout{
	id: fSelect
	Layout.fillHeight: true

	property bool expanded: true
	Layout.maximumWidth: expanded ? implicitWidth : 0
	clip: true
	Behavior on Layout.maximumWidth{
		NumberAnimation{
			duration: PCore.Units.shortDuration
			easing.type: Easing.InOutQuad
		}
	}



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

	KItemModels.KSortFilterProxyModel{
		id: prox
		sourceModel: dtMod
		sortRole: "fileName"
		sortOrder: Qt.AscendingOrder
		sortCaseSensitivity: Qt.CaseInsensitive
	}

	RowLayout{
		id: ctrlButtonBar
		Layout.maximumHeight: dirUpBtn.implicitHeight
		Layout.preferredWidth: fileTree.width
		Layout.minimumWidth: fileTree.width
		Layout.maximumWidth: fileTree.width

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
			id: newFileBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "document-new-symbolic"
			focusPolicy: Qt.TabFocus
			onClicked: fnRow.expanded = ! fnRow.expanded
			PComp3.ToolTip{
				text: "New Note"
			}
		}

		PComp3.ToolButton{
			id: fileMgrBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "folder-open-symbolic"
			focusPolicy: Qt.TabFocus
			onClicked: dtMod.openInFileMan()
			PComp3.ToolTip{
				text: "Open folder in File Manager"
			}
		}
	}

	RowLayout{
		id: fnRow
		Layout.preferredWidth: fileTree.width
		Layout.minimumWidth: fileTree.width

		property bool expanded: false
		Layout.maximumHeight: expanded ? implicitHeight : 0
		clip: true

		Behavior on Layout.maximumHeight {
			NumberAnimation{
				duration: PCore.Units.shortDuration
				easing.type: Easing.InOutQuad
			}
		}


		PComp3.TextField{
			id: nfNameField
			placeholderText: "Filename.md..."
		}

		PComp3.ToolButton{
			id: nfAcceptBtn
			icon.name: "dialog-ok"
			focusPolicy: Qt.TabFocus
			onClicked: {
				dtMod.newFile(nfNameField.text)
				fnRow.expanded = ! fnRow.expanded
			}
			PComp3.ToolTip{
				text: "Ok"
			}
		}

		PComp3.ToolButton{
			id: nfCancelBtn
			Layout.alignment: Qt.AlignRight
			icon.name: "dialog-cancel"
			focusPolicy: Qt.TabFocus
			onClicked: fnRow.expanded = ! fnRow.expanded
			PComp3.ToolTip{
				text: "Cancel"
			}
		}
	}




	QQC1.TreeView{
		id: fileTree
		model: prox
		Layout.maximumHeight: parent.height
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

