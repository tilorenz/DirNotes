import QtQuick 2.6
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
	id: root
	Plasmoid.switchHeight: 3 * PlasmaCore.Units.gridUnit
	Plasmoid.switchWidth: 12 * PlasmaCore.Units.gridUnit

	Plasmoid.fullRepresentation: RowLayout{
		id: mainRow

		Layout.minimumWidth: PlasmaCore.Units.gridUnit * 5
		Layout.minimumHeight: PlasmaCore.Units.gridUnit * 5
		Layout.preferredWidth: PlasmaCore.Units.gridUnit * 24
		Layout.preferredHeight: PlasmaCore.Units.gridUnit * 24

		FileList{
			id: fChooser
			Layout.alignment: Qt.AlignLeft
			//Layout.fillWidth: true
			//Layout.fillHeight: true
		}

		NoteArea{
			id: nArea
			Layout.alignment: Qt.AlignRight
			Layout.fillWidth: true
			Layout.fillHeight: true
			currDoc: fChooser.currDoc
		}
	}
}
