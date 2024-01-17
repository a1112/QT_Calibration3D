import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "../Labels"
Item {
    Layout.fillWidth: true
    Layout.fillHeight: true



    ColorDialog{
        id:cd
        onAccepted: {
            console.log(cd.selectedColor.toString())
            lineColor=cd.selectedColor.toString()
        }
    }

    ColumnLayout{
        anchors.fill: parent
        /*
            translation_x:0,
            translation_y:0,
            y_value:0,
            rotate:0,
            zoom:0,

*/

        RowLayout{
            SpinBoxItem{
                text:"x偏移："
                value:translation_x.toFixed(3)
                onValue2Changed:{
                    if (translation_x != value2)
                        translation_x=value2
                }
            }
            SpinBoxItem{
                text:"z偏移："
                value:translation_y.toFixed(3)
                onValue2Changed:{
                    if (translation_y!==value2)
                        translation_y=value2
                }
            }
            SpinBoxItem{

                text:"y值："
                value:y_value
            }
        }
        RowLayout{
            SpinBoxItem{
                text:"旋转 ："
                value:rotate.toFixed(3)
                onValue2Changed:{
                    if (rotate!==value2)
                        rotate=value2
                }
            }
            SpinBoxItem{
                text:"缩放 ："
                value:zoom
                onValue2Changed:{
                    if (zoom!==value2)
                        zoom=value2
                }
            }
            Rectangle{
                width: 25
                height: 25
                border.color: "#000"
                color: lineColor
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        cd.open()

                    }

                }
            }

            Button{
                text: "删除"
                onClicked: {
                    core.mainModel.remove(index)

                }
            }
        }
        RowLayout{
                        Layout.fillWidth: true
        TextField{
            selectByMouse: true
            Layout.fillWidth: true

            text: "" +translation_x+","+translation_y+","+rotate+","+zoom
        }
        BaseLabel{
            text: "旋转步长："
        }
        Row{
            width: 50

        TextField{
            selectByMouse: true
            Layout.fillWidth: true
            text: core.rotate_step

            onTextChanged: {
            core.rotate_step=Number(text)

            }

        }
        }
        }
        Item{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
        }
    }

}
