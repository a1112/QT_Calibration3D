import QtQuick 2.15
import Qt.labs.folderlistmodel
import "core"
import "Labels"
/*
            translation_x:0,
            translation_y:0,
            y_value:0,
            rotate:0,
            zoom:0,


*/

Item {
    id:root


    z:active?9999:index
    x:translation_x
    y:translation_y

    scale:zoom

    Rectangle{
        width: 4
        height: 4
        radius: 5

    }
    transform: Rotation{
        origin.x:0
        origin.y:0
        angle:rotate

    }

    width: global_box_w
    height: global_box_h

    property bool isActiveItem: core.activeFocusIndex == index
    property alias active: dh.active
    property int croesWidth: isActiveItem?30000:20
    property bool useMaxMoveView: true  // 一种查看模式
    Item{
        opacity: isActiveItem?1:0.3
    Rectangle{
        color: "green"
    width: croesWidth
    height: 1
    x:-croesWidth/2
    }
    Rectangle{
        color: "green"
    width: 1
    y:-croesWidth/2
    height: croesWidth
    }
}
    Rectangle{
        id:mr
        MouseArea{
            anchors.fill: parent
            onDoubleClicked:useMaxMoveView=!useMaxMoveView
            onClicked: core.activeFocusIndex=index
        }

        x:global_box_x
        y:global_box_y
        width: useMaxMoveView?global_box_w: 35
        height: useMaxMoveView?global_box_h: 35
        border.width: 1
        opacity:useMaxMoveView?active?0.25:  0.1:0.8
        color: Qt.darker(lineColor)
        DragHandler{
            target: root
            id:dh
        }
        WheelHandler {
            acceptedModifiers: Qt.ControlModifier
                onWheel: (event)=>{
                             if (event.angleDelta.y>0){
                             rotate+=core.rotate_step
                             }
                             else{
                                 rotate-=core.rotate_step
                             }
                         }
            }
    }
    Row{
        spacing: 5
            anchors.right: mr.right
            anchors.top: mr.top
            opacity: 0.55

        BaseLabel{

           color: "#fff"
           font.pixelSize: 9
            text: "x:"+translation_x+
                  " y:"+translation_y+
                  " rotate:"+rotate
            visible: isActiveItem&&useMaxMoveView
        }

            BaseLabel{
               color: "#fff"
               font.pixelSize: 9
                text: " Ctrl(旋转)"

                visible: isActiveItem&&useMaxMoveView
            }

    }
    BaseLabel{
        color: "red"
        text: (index+1)
        font.pixelSize: 20
        anchors.centerIn: mr

    }


    onActiveChanged: {
        if (active){
            core.activeFocusIndex=index
        }
        else{
            root.x=Qt.binding(()=>translation_x)
            root.y=Qt.binding(()=>translation_y)

        }

    }
    onXChanged:{
    translation_x=x


    }
    onYChanged: {
    translation_y=y

    }


        FileContentTool{
            id:fc
        }
        Component.onCompleted:{
            let minX=Number.POSITIVE_INFINITY
            let minY=Number.POSITIVE_INFINITY
            let maxX=-Number.POSITIVE_INFINITY
            let maxY=-Number.POSITIVE_INFINITY
            fc.filename=fileName
            fc.open()
            pointModel.clear()
            while (true){
            var line = fc.readLine()
                console.log(fileName)
                console.log(line)
                if(!line){
                    break
                }
             line = line.split(" ")
             for (let i in line){
             line[i]=Number(line[i])
             }
            if (line[0]<minX){
            minX=line[0]
            }
            if (line[0]>maxX){
            maxX=line[0]
            }
            if (line[2]<minY){
                minY=line[2]
                }
            if (line[2]>maxY){
                maxY=line[2]
                }
            pointModel.append({
                                  "p_x":line[0],
                                  "p_y":line[1],
                                  "p_z":line[2],
                                  "p_gl":line[3]
                              })
             if (line[1]>0){
                break
             }
               }
            global_box_x=minX
            global_box_y=minY
            global_box_w=maxX-minX
            global_box_h=maxY-minY
        }
        property ListModel pointModel: ListModel{
            dynamicRoles: true
        }
        Item{

            Repeater{

            model: pointModel
           delegate: Rectangle{
               color: lineColor
                opacity: 0.85
                width: 1
                height: 1
                border.color: "red"
                border.width: 0.1
                x:p_x
                y:p_z

           }

        }
}


}
