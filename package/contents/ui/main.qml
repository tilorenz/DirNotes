import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

ColumnLayout {
	id: root
	Plasmoid.switchHeight: 2 * PlasmaCore.Units.gridUnit
	Plasmoid.switchWidth: 4 * PlasmaCore.Units.gridUnit
	height: 20 * PlasmaCore.Units.gridUnit
	width: 20 * PlasmaCore.Units.gridUnit


	RowLayout{
		id: topBar

		PlasmaComponents.ToolButton{
			id: dirUpBtn
			Layout.alignment: Qt.AlignLeft
			icon.name: fChooser.expanded ? "sidebar-collapse" : "sidebar-expand"
			focusPolicy: Qt.TabFocus
			onClicked: fChooser.expanded = ! fChooser.expanded
			PlasmaComponents.ToolTip{
				text: fChooser.expanded ? "Collapse Dir Tree" : "Expand Dir tree"
			}
		}
	}

	RowLayout{
		id: contentRow

		FileList{
			id: fChooser
			Layout.alignment: Qt.AlignLeft
			Layout.fillWidth: true
			Layout.fillHeight: true
		}

		NoteArea{
			id: nArea
			Layout.alignment: Qt.AlignRight
			currDoc: fChooser.currDoc
		}
	}
}
