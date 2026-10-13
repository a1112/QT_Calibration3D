import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "qml"
import "qml/core"
ApplicationWindow {

    // Screen dimensions are Qt logical pixels; do not multiply by devicePixelRatio.
    property bool startupGeometryReady: false
    Settings {
        id: startupGeometry
        category: "MainWindowGeometry"
        // Explicit isolated profile for automated/synthetic window smoke tests.
        location: {
            var prefix = "--window-geometry-settings="
            for (var i = 0; i < Qt.application.arguments.length; ++i) {
                var argument = Qt.application.arguments[i]
                if (argument.indexOf(prefix) === 0) return argument.substring(prefix.length)
            }
            return ""
        }
        property real savedX: -100000
        property real savedY: -100000
        property real savedWidth: 0
        property real savedHeight: 0
    }
    function fitStartupGeometry(useSaved) {
        var screens = Qt.application.screens
        var target = screen
        var px = useSaved ? startupGeometry.savedX : x
        var py = useSaved ? startupGeometry.savedY : y
        var pw = useSaved ? startupGeometry.savedWidth : width
        var ph = useSaved ? startupGeometry.savedHeight : height
        var saved = pw > 0 && ph > 0 && isFinite(px) && isFinite(py) && isFinite(pw) && isFinite(ph)
        var bestArea = 0
        for (var i = 0; i < screens.length; ++i) {
            var candidate = screens[i]
            var overlap = Math.max(0, Math.min(px + pw, candidate.virtualX + candidate.width) - Math.max(px, candidate.virtualX))
                * Math.max(0, Math.min(py + ph, candidate.virtualY + candidate.height) - Math.max(py, candidate.virtualY))
            if (overlap > bestArea) { target = candidate; bestArea = overlap }
        }
        if (!target) return
        screen = target
        // Reserve desktop edges and titlebar space in addition to the work-area limit.
        var aw = Math.max(1, Math.min(target.width, target.desktopAvailableWidth) - 48)
        var ah = Math.max(1, Math.min(target.height, target.desktopAvailableHeight) - 64)
        var left = target.virtualX + (target.width - aw) / 2
        var top = target.virtualY + (target.height - ah) / 2
        minimumWidth = Math.min(800, aw)
        minimumHeight = Math.min(520, ah)
        if (useSaved && !saved) {
            pw = Math.min(1000, Math.floor(aw * 0.82))
            ph = Math.min(680, Math.floor(ah * 0.82))
            px = left + (aw - pw) / 2
            py = top + (ah - ph) / 2
        }
        if (saved && px >= target.virtualX && py >= target.virtualY
                && px + pw <= target.virtualX + target.width
                && py + ph <= target.virtualY + target.height
                && pw <= target.desktopAvailableWidth && ph <= target.desktopAvailableHeight) {
            width = pw; height = ph; x = px; y = py
            return
        }
        width = Math.min(Math.max(pw, minimumWidth), aw)
        height = Math.min(Math.max(ph, minimumHeight), ah)
        x = Math.max(left, Math.min(px, left + aw - width))
        y = Math.max(top, Math.min(py, top + ah - height))
    }
    onScreenChanged: if (startupGeometryReady && visibility === Window.Windowed) fitStartupGeometry(false)
    onClosing: {
        if (visibility === Window.Windowed) {
            startupGeometry.savedX = x
            startupGeometry.savedY = y
            startupGeometry.savedWidth = width
            startupGeometry.savedHeight = height
        }
    }

    id: startupWindow

    width: 1000

    height: 680
    visible: true
    title: qsTr("3d标定查程序")
    property Core core: Core{}
    MainLayOut{


    }
    FileContentTool{
        id:fc
    }
    Component.onCompleted: {
        fitStartupGeometry(true); startupGeometryReady = true;
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
