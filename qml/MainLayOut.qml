import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts
Item {
    anchors.fill: parent
    SplitView{
        anchors.fill: parent
    MainShowView{
        id:mainC
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        clip: true
    }
    DataListView{
        SplitView.preferredWidth:500
        SplitView.fillHeight: true
    }
}


    Component.onCompleted: {
    core.canvas_translation_x = (width-500)/2
        core.canvas_translation_y = height/2
        }
}
