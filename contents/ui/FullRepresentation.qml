import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import Qt.labs.platform

Item {
    id: "parentItem"
    property string loadPath: ""
    property string exportPath: ""
    property string importPath: ""
    property string configPath : StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0].toString().split("//")[1]
    property string dataPath : StandardPaths.standardLocations(StandardPaths.GenericDataLocation)[0].toString().split("//")[1]
    property string savePath: configPath + "/plasmaConfSaver"
    property string modelData : ""

    anchors.fill: parent

    Plasma5Support.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(sourceName, exitCode, exitStatus, stdout, stderr)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd) {
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)
    }
    Plasma5Support.DataSource {
        id: placesSource
        engine: 'filebrowser'
        interval: 500
        connectedSources: savePath
    }

    Column {
        id: col1
        anchors.fill: parent
        spacing : Kirigami.Units.mediumSpacing
        PlasmaExtras.Heading {
            id: heading
            level: 3
            opacity: 0.6
            text: "Plasma Configuration Saver"
        }
        Row {
            spacing : Kirigami.Units.smallSpacing
            id: row1
            height:text1.height
            width: parent.width
            PlasmaComponents.TextField {
                x: Kirigami.Units.smallSpacing
                id: text1
                placeholderText: i18n("Enter a name to save...")
                text: ""
                background: Kirigami.Theme.backgroundColor
                width: (parent.width) - (2 * (2*Kirigami.Units.smallSpacing + Kirigami.Units.iconSizes.medium))
                height: Kirigami.Units.iconSizes.medium
            }
            PlasmaComponents.Button {
                id: button1
                text: ""
                height: Kirigami.Units.iconSizes.medium
                width: height
                enabled: text1.text != ""
                Kirigami.Icon {
                    anchors.fill: parent
                    source: "document-save"
                    // active: isHovered
                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        id: tooltip
                        mainText: i18n("Save")
                        subText: i18n("Save your current customization")
                        icon: "document-save"
                        active: true
                    }
                }
                onClicked: {
                    if(text1.text == "" || text1.text == null || text1.text == undefined) {
                        text1.text = "default"
                    }
                    var plasmaConfSaverFolder = configPath + "/plasmaConfSaver/";
                    var configFolder = plasmaConfSaverFolder + text1.text;
                    var saveScript = dataPath+"/plasma/plasmoids/com.dhruv8sh.plasmaConfSaver/contents/scripts/save.sh";
                    loadMask.visible = true;
                    col1.enabled = false;
                    executeSource.connectSource("sh "+ saveScript + " " + configPath + " " + configFolder + " " + dataPath + " ")
                    listView.forceLayout()
                    text1.text = ""
                }
                Connections {
                    target: executeSource
                    onExited : {

                        console.log("Task Completed: "+cmd + ' '+ exitCode + ' exitStatus:' + exitStatus + ' stdout:' +stdout + " stderr:" +stderr)

                        if(cmd.indexOf("save.sh") != -1 || cmd.indexOf("rm -Rf") != -1 || cmd.indexOf("load.sh") != -1) {
                            listView.forceLayout();
                            loadMaskOff.start()
                        }
                        if(cmd.indexOf("tar cvzf") != -1) {
                            executeSource.connectSource("kdialog --getsavefilename $(pwd)/" + modelData +  ".tar.gz ")
                        }

                        if(cmd.indexOf("kdialog --getsavefilename") != -1) {
                            exportPath = stdout.replace("\n","")
                            executeSource.connectSource("cp " + savePath + "/tmpExport.tar.gz " + exportPath)
                            executeSource.connectSource("rm " + savePath + "/tmpExport.tar.gz")
                            loadMaskOff.start()
                        }
                        if(cmd.indexOf("kdialog --getopenfilename") != -1) {
                            importPath = stdout.replace("\n","")
                            var pathArray = importPath.split("/")
                            var fileName = pathArray[pathArray.length - 1]
                            var nameFolder = fileName.split(".")
                            executeSource.connectSource("mkdir " + savePath + "/" + nameFolder[0])
                            executeSource.connectSource("tar xzvf " + importPath + " -C " + savePath + "/" + nameFolder[0])
                        }
                    }
                }
            }
            PlasmaComponents.Button {
                height: Kirigami.Units.iconSizes.medium
                width: height
                id: btnImport
                text: ""
                Kirigami.Icon {
                    anchors.fill: parent
                    source: "document-import"
                    // active: isHovered
                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        mainText: i18n("Import")
                        subText: i18n("Import a customization")
                        icon: "document-import"
                        active: true
                    }
                }
                onClicked:{
                    executeSource.connectSource("kdialog --getopenfilename $(pwd)")
                    listView.forceLayout()
                }
            }
        }
        Rectangle {
            width: parent.width
            height: 1
            opacity: 0.3
        }
        Kirigami.ScrollablePage {
            width: parent.width
            height: parent.height - ((3*Kirigami.Units.mediumSpacing) + Kirigami.Units.iconSizes.medium + 1 + heading.height )
            background: Kirigami.Theme.backgroundColor
            ListView {
                id: listView
                anchors.fill: parent
                model:
                    if(placesSource.data[savePath] != undefined) {
                        return placesSource.data[savePath]["directories.all"]
                    } else {
                        return ""
                    }
                highlightMoveDuration: 0
                highlightResizeDuration: 0
                delegate: Item {
                    width: parent.width
                    height: 125
                    property bool isHovered: false
                    property bool isEjectHovered: false
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: listView.currentIndex = index
                        onClicked: text1.text = listView.currentIndex.text
                    }
                    Row {
                        id: localRow
                        x: Kirigami.Units.mediumSpacing
                        y: Kirigami.Units.mediumSpacing
                        width: parent.width - Kirigami.Units.mediumSpacing
                        height: Kirigami.Units.iconSizes.medium + 11*Kirigami.Units.mediumSpacing
                        spacing: 30
                        Image {
                            id: screenshot
                            width: 177
                            height: 100
                            fillMode: Image.Stretch
                            source: savePath + "/" + model.modelData + "/screenshot.png"
                        }
                        Column {
                            spacing: 10
                            width: parent.width - 170
                            PlasmaComponents.Label {
                                id: title
                                text: model.modelData
                                width: parent.width
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Row {
                                spacing: Kirigami.Units.mediumSpacing
                                PlasmaComponents.Button {
                                    width: Kirigami.Units.iconSizes.medium
                                    height: width
                                    id: btnLoad
                                    text: ""
                                    Kirigami.Icon {
                                        anchors.fill: parent
                                        source: "checkmark"
                                        active: isHovered
                                        PlasmaCore.ToolTipArea {
                                            anchors.fill: parent
                                            mainText: i18n("Load")
                                            subText: i18n("Load this customization")
                                            icon: "checkmark"
                                            active: true
                                        }
                                    }
                                    onClicked: {
                                        loadMask.visible = true;
                                        col1.enabled = false;
                                        var loadScript = dataPath+"/plasma/plasmoids/com.dhruv8sh.plasmaConfSaver/contents/scripts/load.sh";
                                        executeSource.connectSource("cp " + loadScript + " " + savePath + "/load.sh && nohup sh "+ savePath + "/load.sh "+ configPath + " " + savePath + " " + dataPath + " " + model.modelData + " &")
                                    }
                                }
                                PlasmaComponents.Button {
                                    id: btnExport
                                    text: ""
                                    width: Kirigami.Units.iconSizes.medium
                                    height: width
                                    Kirigami.Icon {
                                        anchors.fill: parent
                                        source: "document-export"
                                        PlasmaCore.ToolTipArea {
                                            anchors.fill: parent
                                            mainText: i18n("Export")
                                            subText: i18n("Export this customization")
                                            icon: "document-export"
                                            active: true
                                        }
                                    }
                                    onClicked: {
                                        parentItem.modelData = model.modelData
                                        loadMask.visible = true;
                                        col1.enabled = false;
                                        executeSource.connectSource("tar cvzf " + savePath + "/tmpExport.tar.gz " + "-C "+ savePath + "/" + model.modelData + " .")
                                        listView.forceLayout()
                                    }
                                }
                                PlasmaComponents.Button {
                                    id: btnDelete
                                    text: ""
                                    width: Kirigami.Units.iconSizes.medium
                                    height: width
                                    Kirigami.Icon {
                                        anchors.fill: parent
                                        source: "albumfolder-user-trash"
                                        PlasmaCore.ToolTipArea {
                                            anchors.fill: parent
                                            mainText: i18n("Delete")
                                            subText: i18n("Delete this customization")
                                            icon: "albumfolder-user-trash"
                                            active: true
                                        }
                                    }
                                    onClicked:{
                                        loadMask.visible = true;
                                        col1.enabled = false;
                                        executeSource.connectSource("rm -Rf " + savePath + "/" + model.modelData)
                                        listView.forceLayout()
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: 1
                        opacity: 0.3
                    }
                }
            }
        }
    }
    Timer {
        id: loadMaskOff
        interval: Kirigami.Units.humanMoment
        running: false
        repeat: false
        onTriggered: {
            loadMask.visible = false;
            col1.enabled = true;
        }
    }
    PlasmaComponents.BusyIndicator {
        id: loadMask
        anchors.centerIn: parent
        visible: false
    }
}
