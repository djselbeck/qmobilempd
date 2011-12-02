import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page{
    id: savedplaylistpage
    property alias listmodel:savedplaylist_list_view.model
    tools:ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}

    }
    ListView{
        id: savedplaylist_list_view
        delegate: ListItem{
            ListItemText { text: modelData; role:"Title"
                anchors {verticalCenter: parent.verticalCenter}}
            onClicked: {
                window.savedPlaylistClicked(modelData);
            }
            onPressAndHold: {
                window.savedPlaylistClicked(modelData);
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
    }

    ListHeading {
        id:headingrect

        ListItemText{
            text: "Saved playlists:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
            horizontalAlignment: Text.AlignLeft
        }
    }



    ScrollBar
    {
        id:playlistsscroll
        flickableItem: savedplaylist_list_view
        anchors {right:savedplaylist_list_view.right; top:savedplaylist_list_view.top}
    }
}
