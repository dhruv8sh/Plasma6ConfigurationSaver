import QtQuick
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root
    compactRepresentation: Kirigami.Icon {
        source: 'system-save-session'
        width: Kirigami.Units.iconSizes.medium
        height: Kirigami.Units.iconSizes.medium
        active: mouseArea.containsMouse

        MouseArea {
            id: mouseArea
            acceptedButtons: Qt.LeftButton | Qt.MiddelButton
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }
    fullRepresentation: FullRepresentation{}
    preferredRepresentation: compactRepresentation
}
