import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

ColumnLayout {
	id: root
	Plasmoid.switchHeight: 2 * PlasmaCore.Units.gridUnit
	Plasmoid.switchWidth: 4 * PlasmaCore.Units.gridUnit
	height: (fixedSize ? 30 : 20) * PlasmaCore.Units.gridUnit
	width: (fixedSize ? 30 : 20) * PlasmaCore.Units.gridUnit

	property bool fixedSize: (plasmoid.expanded && 
		(plasmoid.formFactor === PlasmaCore.Types.Vertical 
		|| plasmoid.formFactor === PlasmaCore.Types.Horizontal))

	Layout.maximumWidth: fixedSize ?  (30 * PlasmaCore.Units.gridUnit) : 10000
	Layout.maximumHeight: fixedSize ? (30 * PlasmaCore.Units.gridUnit) : 10000
	Layout.minimumWidth: fixedSize ?  (30 * PlasmaCore.Units.gridUnit) : 30
	Layout.minimumHeight: fixedSize ? (30 * PlasmaCore.Units.gridUnit) : 30
	//Layout.maximumWidth: 30 * PCore.Units.gridUnit
	//Layout.maximumHeight:30 * PCore.Units.gridUnit
	//Layout.minimumWidth: 30 * PCore.Units.gridUnit
	//Layout.minimumHeight:30 * PCore.Units.gridUnit
	//onFixedSizeChanged: print("Fixed size: ", fixedSize)

	//Component.onCompleted: {
		//print("FS: ", fixedSize)
		//print("Exp: ", plasmoid.expanded)
		//print("FF: ", plasmoid.formFactor)
	//}

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
			//Layout.fillWidth: true
			//Layout.fillHeight: true
		}

		NoteArea{
			id: nArea
			Layout.alignment: Qt.AlignRight
			currDoc: fChooser.currDoc
		}
	}
}
