import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Labels"
Item {
    ColumnLayout{
        anchors.fill: parent

Item{
        Layout.fillWidth: true
        Layout.fillHeight: true

    ListView{

        anchors.fill: parent
        model: core.mainModel
        currentIndex: core.activeFocusIndex
        highlight: Rectangle {
                 border.color: "red"
                border.width: 3
        }
        delegate:DataListViewItem
        {



        }


    }
}

FileDialog{
    fileMode: FileDialog.OpenFiles
    id:fd
    nameFilters: ["txt files (*.txt)"]
    onAccepted: {

        for (let i in selectedFiles){
            var baseArgs = core.getBaseArgs()
            baseArgs["fileName"] = (""+selectedFiles[i]).substring(8)
            core.mainModel.append(
                        baseArgs
                        )
        }
    }

}
Column{
    BaseLabel{
        font.pixelSize: 10
        text: qsTr("配置文件：")+core.configFileName
        color: "#000"
    }

    Row{
Button{
    text: "加载文件。"
    onClicked: {
    fd.open()
    }
}

Button{
    text: "清除全部"
    onClicked: {
    core.mainModel.clear()
    }
}

Button{
    text: "清除全部"
    onClicked: {
    core.mainModel.clear()
    }
}

Button{
    text: "加载配置文件"
    onClicked: {
        core.openConfig()
    }
}
Button{
    text: "另存为。"
    onClicked: {
        core.saveConfig()
    }
}
}
}
    }
}
