import test.filecontent 1.0

import QtQuick.Controls
import QtQuick
Item{
    id: content

    readonly property bool ready: __fc__.lastOperationSucceeded
    readonly property bool lastOperationSucceeded: __fc__.lastOperationSucceeded
    readonly property string errorCode: __fc__.errorCode
    readonly property string errorString: __fc__.errorString
    property alias filename: __fc__.filename


    FileContentItem{
        id:__fc__
    filename: ""   // default is craft.obj
    }

    function localFilePath(selection) {
        return __fc__.localFilePath(selection.toString())
    }

    function close() {
        __fc__.close()
    }

    function write(str){
        return __fc__.write(str)

    }

    function open(){
        return __fc__.open()
    }

    function readLine(maxLen=0){
        return __fc__.readLine(maxLen)
    }

    function readAll(filename){
        return __fc__.readAll(filename)
    }

    function processContent(source) {

        if( source !== undefined ) {
            __fc__.filename = source;
        }
        console.time('Read file: "' + __fc__.filename + '"');
        var reData = __fc__.getContent()
        console.timeEnd('Read file: "' + __fc__.filename + '"');
        __fc__.clearContent();  // save memory
        return reData
    }
}
