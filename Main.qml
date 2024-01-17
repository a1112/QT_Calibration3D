import QtQuick
import QtQuick.Controls.Windows
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
    FileContentTool{
        id:fc
    }
    Component.onCompleted: {
        fc.open()
    }

    DropArea{
        anchors.fill: parent
        onDropped:{
            if(drop.hasUrls){
                for (let i in drop.urls){
                    var baseArgs = core.getBaseArgs()
                    baseArgs["fileName"] = (""+drop.urls[i]).substring(8)
                    core.mainModel.append(
                                baseArgs
                                )
                }

            }
                  }



    }
}
