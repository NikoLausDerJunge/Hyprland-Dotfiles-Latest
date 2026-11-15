import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell.Io

PanelWindow {
    id: wallpaperView

    screen: Quickshell.screens[0]
    visible: false

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 340
    //WlrLayershell
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    color: "transparent"

    property string wallpaperDir: "file:///home/admin/Wallpapers"
    property string selectedWallpaper: ""

    IpcHandler {
        target: "wallpaperView"
        function toggle(): void {
            wallpaperView.visible = !wallpaperView.visible
        }
    }

    FolderListModel {
        id: wallpaperModel
        folder: wallpaperDir
        nameFilters: [
            "*.jpg", "*.jpeg", "*.png", "*.webp",
            "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"
        ]
        showFiles: true
        showDirs: false
        sortField: FolderListModel.Name
    }

    function setWallpaper(path) {
        selectedWallpaper = path

        let cleanPath = path.toString().replace(/^file:\/\//, "")

        Quickshell.execDetached([
            "sh", "-c",
            "pkill -x swaybg 2>/dev/null; " +
            "swaybg -i " + "'" + cleanPath.replace(/'/g, "'\\''") + "' -m fill"
        ])
    }

    MouseArea {
        anchors.fill: parent
        onClicked: wallpaperView.visible = false

        Rectangle {
            id: card
            anchors.top: parent.top
            anchors.topMargin: 7
            anchors.horizontalCenter: parent.horizontalCenter
            width: 1100
            height: 275
            radius: 24
            color: "#000000"
            border.color: Qt.rgba(1, 1, 1, 0.12)
            border.width: 1

            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => mouse.accepted = true
            }

            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    wallpaperView.visible = false
                    event.accepted = true
                } else if (
                    event.key === Qt.Key_Return ||
                    event.key === Qt.Key_Enter
                ) {
                    wallpaperView.visible = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    if (wallpaperList.currentIndex > 0)
                        wallpaperList.currentIndex--
                    event.accepted = true
                } else if (event.key === Qt.Key_Right) {
                    if (wallpaperList.currentIndex < wallpaperModel.count - 1)
                        wallpaperList.currentIndex++
                    event.accepted = true
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 24

                ListView {
                    id: wallpaperList

                    Layout.fillWidth: true
                    Layout.preferredHeight: 240

                    orientation: ListView.Horizontal
                    spacing: 20
                    clip: true
                    model: wallpaperModel

                    highlightRangeMode: ListView.StrictlyEnforceRange
                    preferredHighlightBegin: width / 2 - 180
                    preferredHighlightEnd: width / 2 + 180
                    highlightMoveDuration: 200

                    delegate: Item {
                        required property url fileUrl
                        required property int index

                        readonly property bool isSelected:
                            wallpaperList.currentIndex === index

                        onIsSelectedChanged: {
                            if (isSelected)
                                setWallpaper(fileUrl.toString())
                        }

                        Component.onCompleted: {
                            if (isSelected)
                                setWallpaper(fileUrl.toString())
                        }

                        width: isSelected ? 360 : 260
                        height: isSelected ? 230 : 180

                        Behavior on width {
                            NumberAnimation { duration: 180 }
                        }

                        Behavior on height {
                            NumberAnimation { duration: 180 }
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            radius: 18
                            color: "#242428"
                            border.width: isSelected ? 3 : 1
                            border.color: isSelected
                                ? "#ffffff" : "#38383e"

                            Image {
                                anchors.fill: parent
                                anchors.margins: isSelected ? 5 : 3
                                source: fileUrl
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    wallpaperList.currentIndex = index
                                    setWallpaper(fileUrl.toString())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
