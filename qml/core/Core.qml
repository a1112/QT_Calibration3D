import QtQuick
import QtQuick.Dialogs
import test.filecontent 1.0
Item {
    property int activeFocusIndex: 0

    property int canvas_translation_x: 0
    property int canvas_translation_y: 0
    property real rotate_step: 0.1
    property string configFileName: ""
    property var jsData: {return {}}
    FileContentTool{
        id:fc
    }
    FileDialog{
        fileMode:FileDialog.SaveFile
        nameFilters: ["JSON config files (*.json)"]
        id:configSave
        onAccepted: {
            if(Qt.platform.os==="windows"){
                fc.filename=(""+selectedFile).substr(8)
                fc.write(JSON.stringify(jsData));
            }

        }

    }

    FileContentTool{
        id:fc_o
    }
    FileDialog{
        fileMode:FileDialog.OpenFile
        nameFilters: ["JSON config files (*.json)"]
        id:configOpen
        onAccepted: {
            if(Qt.platform.os==="windows"){
                configFileName=(""+selectedFile).substr(8)
                fc_o.filename=configFileName
                let lab=fc.readAll(configFileName)
                console.log(lab)
                let data = JSON.parse(lab)
                mainModel.clear()
                for (let i in data["data"]){
                    mainModel.append(data["data"][i])
                }
            }

        }

    }

    function openConfig(){

        configOpen.open()
    }

    function saveConfig(){
        jsData = {
        "title":"3标注配置文件",
            "data":[]
        }
        for (let i=0;i<mainModel.count;i++){
            let nData = mainModel.get(i)
//            nData["origin_x"]=global_box_w/2
//            nData["origin_y"]=global_box_h/2
            console.log("RT")
        console.log(nData["RT"])
            jsData["data"].push(
                        Object.assign({}, nData,{"RT":[
                                              [Math.cos(nData["rotate"]),0,Math.sin(nData["rotate"]),nData["translation_x"]],
                                              [0,1,0,0],
                                              [-Math.sin(nData["rotate"]),0,Math.cos(nData["rotate"]),nData["translation_y"]],
                                              [0,0,0,1],
                                                      ]})
                        )
        }

        console.log(jsData)
        configSave.open()
    }

    function getBaseArgs(){
        return {
            translation_x:0,
            translation_y:0,
            y_value:0,
            rotate:0,
            zoom:1,
            global_box_x:0.0,
            global_box_y:0.0,
            global_box_w:0.0,
            global_box_h:0.0,
            fileName:"",
            lineColor:"#FFF"
        }



    }

    property ListModel mainModel: ListModel{



    }


}
