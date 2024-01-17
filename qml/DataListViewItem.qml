import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import "Labels"
import "Adjust"
Item {


width: parent.width
height: 120


Item{
    width: parent.width*0.95
    height: parent.height*0.92
    anchors.centerIn: parent
    Pane{
    anchors.fill: parent
        Material.elevation: 5
        MouseArea{
            anchors.fill: parent
            onClicked: {
                core.activeFocusIndex=index
            }
        }
    }

    BaseLabel{
        color: "blue"
        text: (index+1)
        font.pixelSize: 25
        anchors.right: parent.right
        anchors.top: parent.top
    }
    ColumnLayout{
        anchors.fill: parent
    BaseLabel{
        text: (""+fileName).substring(8,100)
    }
AdjustView{

}


    }


}

}
