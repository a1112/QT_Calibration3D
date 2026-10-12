import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "qml"
import "qml/core"
ApplicationWindow {
    width: Screen.width*0.7
    height: Screen.height*0.7
    visible: true
    title: qsTr("3d标定查程序")
    property Core core: Core{}
    MainLayOut{


    }
    DropArea{
        anchors.fill: parent
        onDropped:{
            if(drop.hasUrls){
                for (let i = 0; i < drop.urls.length; i++)
                    core.addPointFile(drop.urls[i])

            }
                  }



    }
}
