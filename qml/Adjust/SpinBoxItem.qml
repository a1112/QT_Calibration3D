import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Labels"
Row{
    property alias text:  title.text
    property real value:  0.0
    property real value2: 0.0
        onValueChanged: {
        spinBox.text=(value+"")

        }

    BaseLabel{
        id:title
        text: qsTr("x 偏移")
        font.pixelSize: 18
    }
    TextField{
        onTextChanged: {
            value2=Number(text).toFixed(3)
        }
        selectByMouse: true
        id:spinBox
        height: 25
        width: 65
    }
}
