import QtQuick 2.0
import QtQuick.Window 2.3

import "."

Window {
    id: root
    visible: true
    width: 1000
    height: 1000
    title: "Paint! — Лабораторная работа №4"

    Rectangle {
        id: tools
        width: parent.width
        height: 150
        color: "#545454"

        property color paintColor: "#33B5E5"
        property int thickness: 1
        property int spacing: 4

        Column {
            spacing: tools.spacing
            anchors.centerIn: parent

            Row {
                spacing: tools.spacing
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: ["#33B5E5", "#99CC00", "#FFBB33", "#FF4444"]

                    Square {
                        active: tools.paintColor === color
                        color: modelData
                        onClicked: tools.paintColor = color
                    }
                }
            }

            Row {
                spacing: tools.spacing
                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    model: [1, 2, 3, 4, 5]

                    Circle {
                        active: tools.thickness === thickness
                        thickness: modelData
                        text: thickness
                        onClicked: tools.thickness = thickness
                    }
                }
            }
        }

        Text {
            id: saveStatus
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            color: "white"
            text: "Автосохранение каждые 5 секунд"
            font.pixelSize: 14
        }
    }

    Canvas {
        id: canvas

        anchors {
            left: parent.left
            right: parent.right
            top: tools.bottom
            bottom: parent.bottom
            margins: 8
        }

        property real lastX
        property real lastY
        property color color: tools.paintColor

        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = tools.thickness
            ctx.strokeStyle = canvas.color
            ctx.beginPath()
            ctx.moveTo(lastX, lastY)

            lastX = paint_area.mouseX
            lastY = paint_area.mouseY

            ctx.lineTo(lastX, lastY)
            ctx.stroke()
        }

        MouseArea {
            id: paint_area
            anchors.fill: parent

            onPressed: {
                canvas.lastX = mouseX
                canvas.lastY = mouseY
            }

            onPositionChanged: {
                if (pressed) {
                    canvas.requestPaint()
                }
            }
        }
    }

    /*
      QTimer находится в Python-классе Interface.
      Каждые 5 секунд backend испускает saveRequested.
      QML преобразует Canvas в PNG data URL и передаёт его обратно
      в Interface.save_canvas(), где файл записывается на диск.
    */
    Connections {
        target: _backend

        onSaveRequested: {
            var dataUrl = canvas.toDataURL("image/png")
            _backend.save_canvas(dataUrl)
        }

        onSaveFinished: {
            saveStatus.text = "Сохранено: " + path
        }

        onSaveFailed: {
            saveStatus.text = message
        }
    }
}
