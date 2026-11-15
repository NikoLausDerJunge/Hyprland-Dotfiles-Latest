import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

PanelWindow {
    id: dockWindow

    anchors {
        bottom: true
        left: true
        right: true
    }

    implicitHeight: 45
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    MouseArea {
        id: hoverZone
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: hoverZone.showDock ? 90 : 4
        
        hoverEnabled: true

        property bool showDock: hoverZone.containsMouse

        Item {
            id: slideContainer
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: parent.width
            height: dockBackground.height + 20

            transform: Translate {
                y: hoverZone.showDock ? 0 : 50
                Behavior on y {
                    NumberAnimation {
                        duration: 220
                        easing.type: Easing.OutCubic
                    }
                }
            }

            opacity: hoverZone.showDock ? 1.0 : 0.0
            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                id: dockBackground

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -1

                width: Math.min(dockRow.implicitWidth + 24, dockWindow.width - 32)
                height: 45
                topLeftRadius: 20
                topRightRadius: 20
                bottomLeftRadius: 0
                bottomRightRadius: 0

                color: "#000000"
                border.color: Qt.rgba(1, 1, 1, 0.12)
                border.width: 1

                Row {
                    id: dockRow
                    anchors.centerIn: parent
                    spacing: 8

                    Repeater {
                        model: Hyprland.toplevels

                        delegate: Rectangle {
                            id: dockItem

                            required property var modelData

                            property string appId:
                                modelData.lastIpcObject?.class
                                ?? modelData.lastIpcObject?.initialClass
                                ?? "application"

                            property string windowTitle:
                                modelData.title || appId

                            property bool focused: modelData.activated

                            property var desktopEntry: DesktopEntries.heuristicLookup(dockItem.appId)
                            property string iconSource: {
                                const iconName = desktopEntry?.icon || dockItem.appId
                                return Quickshell.iconPath(iconName)
                            }

                            width: 34
                            height: 34
                            radius: 14

                            color: dockMouse.containsMouse
                                    ? '#a91c1c1e'
                                    : "transparent"

                            border.color: Qt.rgba(1, 1, 1, 0.03)
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: dockItem.iconSource
                                fillMode: Image.PreserveAspectFit
                            }

                            Rectangle {
                                anchors.bottom: parent.top
                                anchors.bottomMargin: 8
                                anchors.horizontalCenter: parent.horizontalCenter

                                width: Math.min(tooltipText.implicitWidth + 18, 238)
                                height: 28
                                radius: 8

                                color: "#202024"
                                visible: dockMouse.containsMouse
                                z: 10
                            }

                            MouseArea {
                                id: dockMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor

                                onClicked: {
                                    if (dockItem.modelData.wayland) {
                                        dockItem.modelData.wayland.activate();
                                    } else if (dockItem.modelData.handle) {
                                        dockItem.modelData.handle.activate();
                                    }
                                }
                            }

                            Behavior on color {
                                ColorAnimation { duration: 140 }
                            }

                            scale: dockMouse.containsMouse ? 1.12 : 1.0

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutBack
                                }
                            }

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: -4

                                width: 4
                                height: 4
                                radius: 2

                                color: "#ffffff"
                                visible: dockItem.focused
                            }
                        }
                    }
                }
            }
        }
    }
}
