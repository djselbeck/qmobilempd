import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    id: playlistsongspage
    property string playlistname;
    tools: ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}

        ToolButton{ iconSource:"toolbar-add"; onClicked: {
                window.addPlaylist(playlistname)
            }}
        ToolButton {
            iconSource: "toolbar-delete"
            onClicked: {
                window.deleteSavedPlaylist(playlistname);
                pageStack.clear()
                pageStack.push([mainPage,playlistpage]);
            }
        }


    }
    property alias listmodel: playlistsongs_list_view.model;

    ListView{
        id: playlistsongs_list_view
        delegate: ListItem{
            Row{
                id: topLayout
                anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                ListItemText { text: (title==="" ? filename : title);role:"Title"
                    anchors {verticalCenter: parent.verticalCenter}}
                ListItemText { text: (length===0 ? "": " ("+lengthformated+")"); role:"Title"
                    anchors {verticalCenter: parent.verticalCenter}}
            }
            onClicked: {
                list_view1.currentIndex = index
                albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
            }
            onPressAndHold:  {
                list_view1.currentIndex = index
                albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
    }

    ListHeading {
        id:headingrect

        ListItemText{
            text: playlistname+":"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
            horizontalAlignment: Text.AlignLeft
        }
    }





    ScrollBar
    {
        id:playlistsscroll
        flickableItem: playlistsongs_list_view
        anchors {right:playlistsongs_list_view.right; top:playlistsongs_list_view.top}
    }


}
