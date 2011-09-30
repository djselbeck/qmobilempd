import QtQuick 1.0
import com.nokia.symbian 1.0
import com.nokia.extras 1.0



Page{
    id: playlistpage
    property alias listmodel:playlist_list_view.model
    Component.onCompleted: {
        console.debug("Playlist completed");
    }

    onStatusChanged: {
        console.debug("Playlist status changed: "+status);
        if(status==PageStatus.Activating)
        {
            console.debug("Playlist activating");

        }
    }
    Component.onDestruction: {
        console.debug("Playlist destroyed");
    }

    tools:ToolBarLayout {
    ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
       // ButtonRow {
                ToolButton {
                    iconSource: "toolbar-delete"
                    onClicked: {
                        window.deletePlaylist();
                    }
                }
                ToolButton {
                    iconSource: playbuttoniconsource
                    onClicked: {
                        window.play();
                    }
                }
                ToolButton {
                    iconSource: "icons/document-save.png"
                    onClicked: {
                        playlist_list_view.visible=false;
                        savenamecolumn.visible=true;
                    }
                }
                ToolButton{
                    iconSource: "icons/document-open.png"
                    onClicked: {
                        window.requestSavedPlaylists();
                    }
                }

//                ToolButton {
//                    iconSource: "toolbar-mediacontrol-stop"
//                    onClicked: {
//                        window.stop();
//                    }
//                }

                ToolButton {
                    iconSource: volumebuttoniconsource;
                    onClicked: {
                        if(volumeslider.visible)
                        {
                            volumeblendout.start();
                        }
                        else{
                            volumeslider.visible=true;
                            volumeblendin.start();
                        }
                    }
                }

//            }
}


    ListView{
        id: playlist_list_view
        delegate: playlisttrackDelegate
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        clip: true
    }
    Column {
        id:savenamecolumn
        visible:false
        y: parent.height/2
        anchors {left: parent.left;right:parent.right}
        Text{text: "Enter name for playlist:";color:"white" }
        TextField{ id:playlistname;       anchors {left: parent.left;right:parent.right} }
        ButtonRow{anchors {left: parent.left;right:parent.right}
            Button{text:"Ok"
            onClicked: {
                window.savePlaylist(playlistname.text);
                savenamecolumn.visible=false;
                playlist_list_view.visible=true;
            }}
            Button{text:"Cancel"
            onClicked: {
                savenamecolumn.visible=false;
                playlist_list_view.visible=true;
            }}
        }
    }

    ScrollBar
    {
        id:playlistscroll
        flickableItem: playlist_list_view
        anchors {right:playlist_list_view.right; top:playlist_list_view.top}
    }


}
