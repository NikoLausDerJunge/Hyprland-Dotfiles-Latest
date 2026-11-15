import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow

            required property var modelData
            screen: modelData

            property var currentScreen: modelData
            property bool expanded: false
            property bool isMuted: false
            property bool isPlaying: true
            property real volumeVal: 0.65
            property string trackTitle: "No Media Playing"
            property string trackArtist: "Hyprland Desktop"

            // Terminal Execute Function
            function execCmd(cmd) {
                Quickshell.execDetached(["sh", "-c", cmd])
            }

            // Check if something Plays and what is Playing
            Process {
                id: mediaProcess

                command: [
                    "sh", "-c",
                    "title=$(playerctl metadata --format '{{title}}' 2>/dev/null); " +
                    "artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null); " +
                    "status=$(playerctl status 2>/dev/null); " +
                    "printf '%s|||%s|||%s\\n' \"$title\" \"$artist\" \"$status\""
                ]

                stdout: StdioCollector {
                    onStreamFinished: {
                        var output = text.trim()
                        var parts = output.split("|||")

                        if (parts.length >= 3 && parts[2] !== "") {
                            panelWindow.trackTitle =
                                parts[0] || "Playing Audio"

                            panelWindow.trackArtist =
                                parts[1] || "Unknown Artist"

                            panelWindow.isPlaying =
                                parts[2] === "Playing"
                        } else {
                            panelWindow.trackTitle = "No Media Playing"
                            panelWindow.trackArtist = " "
                            panelWindow.isPlaying = false
                        }
                    }
                }
            }

            Timer {
                interval: 100
                running: true
                repeat: true

                onTriggered: {
                    if (!mediaProcess.running)
                        mediaProcess.running = true
                }
            }

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: expanded ? 480 : 50

            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.exclusionMode: ExclusionMode.Normal
            exclusiveZone: 40

            color: "transparent"

            Rectangle {
                id: island

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8

                // Maximierte Abmessungen
                width: expanded ? 380 : 180
                height: expanded ? 335 : 38
                radius: expanded ? 28 : 30

                // Deep OLED Aesthetic + Glow Border
                color: "#080809"
                border.color: expanded ? "#2C2C30" : "#1A1A1E"
                border.width: 1

                clip: true

                // Spring Animations (iOS Dynamic Island Feel)
                Behavior on width {
                    NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.7 }
                }

                Behavior on height {
                    NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.7 }
                }

                Behavior on radius {
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }

                Item {
                    id: collapsedContent
                    anchors.fill: parent
                    opacity: panelWindow.expanded ? 0 : 1
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation { duration: 120 }
                    }

                    // Links: Hyprland Workspaces
                    Row {
                        id: workspaceRow
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        Repeater {
                            model: Hyprland.workspaces

                            delegate: Rectangle {
                                required property var modelData

                                property bool belongsToMonitor: modelData.monitor && modelData.monitor.name === currentScreen.name
                                property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

                                visible: belongsToMonitor

                                width: active ? 8 : 5
                                height: 10
                                radius: 2.5

                                color: active ? '#f3f3f3' : "#3A3A3C"

                                Behavior on width {
                                    NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                    }

                    Text {
                        id: collapsedClock
                        anchors.centerIn: parent

                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: "#FFFFFF"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        font.family: "SF Pro Display, Cantarell, Sans-Serif"

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: collapsedClock.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }

                    Row {
                        id: audioVisualizer
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2.5
                        height: 16

                        Repeater {
                            model: 5

                            delegate: Rectangle {
                                id: bar
                                width: 2.5
                                height: isMuted ? 4 : (isPlaying ? Math.max(4, Math.random() * 14) : 4)
                                radius: 1.25

                                opacity: isPlaying ? 1 : 0.2

                                anchors.bottom: parent.bottom
                                color: isMuted ? "#FF453A" : "#30D158"

                                Timer {
                                    interval: 100 + index * 30
                                    running: isPlaying && !isMuted && !panelWindow.expanded
                                    repeat: true
                                    onTriggered: {
                                        bar.height = Math.max(3, Math.floor(Math.random() * 15))
                                    }
                                }

                                Behavior on height {
                                    NumberAnimation { duration: 90 }
                                }

                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: panelWindow.expanded = true
                    }
                }

                
                }
            }
        }
    }
}
