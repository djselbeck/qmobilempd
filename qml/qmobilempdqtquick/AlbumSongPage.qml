import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: albumsongspage
        property string artistname;
        property string albumname;
        property alias listmodel: albumsongs_list_view.model
        tools: ToolBarLayout
        {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ButtonRow {
    //                ToolButton {
    //                    iconSource: "toolbar-mediacontrol-stop"
    //                    onClicked: {
    //                        window.stop();
    //                    }
    //                }

            ToolButton {
                iconSource: "toolbar-add"
                onClicked: window.addAlbum([artistname,albumname]);
            }

            ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
            ToolButton {
                iconSource: playbuttoniconsource; onClicked: window.play()
            }
            ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }


        } }
        Component.onCompleted: {
            console.debug("albumsongs completed");
        }

        onStatusChanged: {
            console.debug("albumsongs status changed: "+status);
            if(status==PageStatus.Activating)
            {
                console.debug("albumsongs activating");
                //artistalbums_list_view.model = albumsModel;
            }
        }
        Component.onDestruction: {
            console.debug("albumsongs destroyed");
        }
        ListView{
            id: albumsongs_list_view
            delegate: albumtrackDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
        }

    }
