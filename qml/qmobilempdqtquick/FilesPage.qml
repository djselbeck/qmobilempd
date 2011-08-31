import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
    id: filespage
    property string filepath;
    property variant model;
    property alias listmodel: files_list_view.model;
    tools: ToolBarLayout {
        id: filesTools
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton { iconSource: "toolbar-add"; onClicked: {
                window.addFiles(filepath);
                console.log("FILEPATH:"+filepath);
            } }
    }
    ListView{
        id: files_list_view
        delegate: filesDelegate
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        clip: true
    }
    onStatusChanged: {
        console.debug("Playlist status changed: "+status);
        if(status==PageStatus.Activating)
        {
            console.debug("File  reactivating: requesting path: "+filepath);
            window.requestFiles((filepath=="")? "/":filepath);
        }
    }

    Component{
        id:filesDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: name; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if(isDirectory){
                        list_view1.currentIndex = index
                        console.log("File: "+prepath+name+" clicked");
                        filesClicked((prepath=="/"? "": prepath+"/")+name);
                    }
                }
            }
        }
    }

}
