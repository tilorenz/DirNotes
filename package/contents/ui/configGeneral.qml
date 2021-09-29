import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page
    property alias cfg_dirPath: dirPathField.text

    RowLayout {
        Kirigami.FormData.label: i18n("Notes Path:")

        TextField {
            id: dirPathField
            placeholderText: i18n("No directory selected.")
        }
        Button {
            text: i18n("Browse")
            icon.name: "folder-symbolic"
            onClicked: fileDialogLoader.active = true

            Loader {
                id: fileDialogLoader
                active: false

                sourceComponent: FileDialog {
                    id: fileDialog
                    folder: shortcuts.documents
                    selectFolder: true
                    onAccepted: {
                        dirPathField.text = fileUrl
                        fileDialogLoader.active = false
                    }
                    onRejected: {
                        fileDialogLoader.active = false
                    }
                    Component.onCompleted: open()
                }
            }
        }
    }
}

