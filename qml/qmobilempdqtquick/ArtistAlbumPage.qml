import QtQuick 1.0
import com.nokia.symbian 1.0

Page{
    id: artistalbumspage
    property string artistname;
    property alias listmodel: artistalbums_list_view.model
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
            onClicked: window.addArtist(artistname);
        }

        ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
        ToolButton {
            iconSource: playbuttoniconsource; onClicked: window.play()
        }
        ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }

    } }
    Component.onCompleted: {
        console.debug("albums completed");
    }

    onStatusChanged: {
        console.debug("albums status changed: "+status);
        if(status==PageStatus.Activating)
        {
            console.debug("albums activating");
        //    artistalbums_list_view.model = albumsModel;
        }
    }
    Component.onDestruction: {
        console.debug("albums destroyed");
    }
    ListView{
        id: artistalbums_list_view
        delegate: artistalbumDelegate
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        clip: true
    }
    Component{
        id:artistalbumDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: title; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    artistalbumClicked(artistalbumspage.artistname,title);
                }
            }
        }
    }
}


