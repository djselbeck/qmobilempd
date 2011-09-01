import QtQuick 1.0
import com.nokia.symbian 1.0


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
        ButtonRow {
                ToolButton {
                    iconSource: "toolbar-delete"
                    onClicked: {
                        window.deletePlaylist();
                    }
                }
                ToolButton {
                    iconSource: "toolbar-mediacontrol-stop"
                    onClicked: {
                        window.stop();
                    }
                }
                ToolButton {
                    iconSource: playbuttoniconsource
                    onClicked: {
                        window.play();
                    }
                }

            } }
    ListView{
        id: playlist_list_view
        delegate: playlisttrackDelegate
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        clip: true
    }

}
