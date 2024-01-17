import QtQuick 2.15
import "Labels"
// 画布 ，展示点云信息：2D
Item {
    id:root

    Rectangle{
    anchors.fill: parent
    color: "#000"
}
    BaseLabel{
        text: " x:"+-(core.canvas_translation_x)+
              " y:"+-(core.canvas_translation_y)+
              " xm:"+cavasT.x+
              " ym:"+cavasT.y+
              " 缩放:" + scaleCanvas
        color: "#fff"
    }

Rectangle{
    opacity: 0.7
color: "red"
width: 1
height: parent.height
x:core.canvas_translation_x+cavasT.x
}


Rectangle{
    opacity: 0.7
color: "red"
height: 1
width: root.width
y:core.canvas_translation_y+cavasT.y
}
    Rectangle{
        id:cavasT
    width: parent.width
    height: parent.height
    color: "#00000000"
    border.width: 1
    border.color: "#eee"
    DragHandler{
        onActiveChanged: {
            if(!active)
            {
            core.canvas_translation_x=core.canvas_translation_x+cavasT.x
            core.canvas_translation_y=core.canvas_translation_y+cavasT.y
            cavasT.x=0
            cavasT.y=0
            }
        }
    }
    }
    Item{
        scale: scaleCanvas
x:core.canvas_translation_x+cavasT.x
y:core.canvas_translation_y+cavasT.y
        Repeater{

        model:core.mainModel
        delegate:
        DataViewItem{}
    }
    }
    property real scaleCanvas: 1.0
    WheelHandler {
            onWheel: (event)=>{
                         if (event.angleDelta.y>0){
                         scaleCanvas*=1.05
                         }
                         else{
                             scaleCanvas/=1.05
                         }
                     }
        }
}
