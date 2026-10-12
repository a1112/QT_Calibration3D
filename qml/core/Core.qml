import QtQuick
import QtQuick.Dialogs
import test.filecontent 1.0
import "ConfigFile.js" as ConfigFile
Item {
    property int activeFocusIndex: 0

    property int canvas_translation_x: 0
    property int canvas_translation_y: 0
    property real rotate_step: 0.1
    property string configFileName: ""
    property string statusMessage: ""
    property var jsData: {return {}}
    FileContentTool{
        id:fc
    }
    FileDialog{
        fileMode:FileDialog.SaveFile
        nameFilters: ["JSON config files (*.json)"]
        id:configSave
        onAccepted: saveSelectedConfig(selectedFile)
    }

    FileContentTool { id: fc_o }
    FileDialog {
        fileMode: FileDialog.OpenFile
        nameFilters: ["JSON config files (*.json)"]
        id: configOpen
        onAccepted: openSelectedConfig(selectedFile)
    }
    MessageDialog {
        id: fileError
        title: qsTr("File operation failed")
        buttons: MessageDialog.Ok
    }

    function showFileError(tool, action) {
        statusMessage = ""
        let reason = qsTr("The file operation failed.")
        if (tool.errorCode === "permission_denied")
            reason = qsTr("Access to the selected file or folder was denied.")
        else if (tool.errorCode === "not_found")
            reason = qsTr("The selected file or folder could not be found.")
        fileError.text = reason
        fileError.informativeText = action + "\n" +
            qsTr("Your current data is still open. Choose the file again, or use Save As to select a writable folder, then retry.") +
            ((Qt.platform.os === "osx" && tool.errorCode === "permission_denied")
             ? "\n" + qsTr("If this app is listed in System Settings > Privacy & Security > Files and Folders, allow access to the relevant folder and retry.") : "") +
            "\n" + tool.errorString
        fileError.open()
    }

    function saveSelectedConfig(selection) {
        if (!selection.toString())
            return false
        fc.filename = selection.toString()
        if (!fc.write(JSON.stringify(jsData))) {
            showFileError(fc, qsTr("Could not save the configuration."))
            return false
        }
        configFileName = fc.filename
        statusMessage = qsTr("Saved to ") + configFileName
        return true
    }

    function openSelectedConfig(selection) {
        if (!selection.toString())
            return false
        let text = fc_o.readAll(selection.toString())
        if (!fc_o.lastOperationSucceeded) {
            showFileError(fc_o, qsTr("Could not read the configuration."))
            return false
        }
        let rows
        try {
            rows = ConfigFile.parseConfig(text)
        } catch (error) {
            statusMessage = ""
            fileError.text = qsTr("Invalid configuration")
            fileError.informativeText = error.message + "\n" + qsTr("Your current data is still open. Choose a valid configuration and retry.")
            fileError.open()
            return false
        }
        // Validate the entire document before replacing any current entries.
        mainModel.clear()
        for (let i = 0; i < rows.length; i++)
            mainModel.append(rows[i])
        configFileName = fc_o.localFilePath(selection)
        statusMessage = qsTr("Opened ") + configFileName
        return true
    }

    function addPointFile(selection) {
        let path = fc_o.localFilePath(selection)
        if (!path) {
            fileError.text = qsTr("Choose a local point file.")
            fileError.informativeText = qsTr("No data was added. Choose a local file and retry.")
            fileError.open()
            return false
        }
        let args = getBaseArgs()
        args.fileName = path
        mainModel.append(args)
        return true
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
