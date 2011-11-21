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
        spacing: 2
        delegate: savedlistsdelegate
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
    }
    Rectangle {
        id:headingrect
        anchors {left:parent.left;right:parent.right;}
        height: artext.height
        color: Qt.rgba(0.07, 0.07, 0.07, 1)
        Text{
            id: artext
            text: "Saved playlists:"
            color: "white"
            font.pointSize: 7
        }
    }
    Component{
        id:savedlistsdelegate
        Item {
            id: itemItem
            width: parent.width
            height: topLayout.height+liststretch
            property alias color:rectangle.color
            property alias gradient:rectangle.gradient
            Rectangle {
                id: rectangle
                color:Qt.rgba(0.07, 0.07, 0.07, 1)
                anchors.fill: parent
                Row{
                    id: topLayout
                    anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                    Text { text: modelData; color:"white";font.pointSize:10;}
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    window.savedPlaylistClicked(modelData);
                }
                onPressed: {
                    itemItem.gradient = selectiongradient;
                }
                onReleased: {
                    itemItem.gradient = fillgradient;
                }
                onCanceled: {
                    itemItem.gradient = fillgradient;

                }
            }
        }
    }
    ScrollBar
    {
        id:playlistsscroll
        flickableItem: savedplaylist_list_view
        anchors {right:savedplaylist_list_view.right; top:savedplaylist_list_view.top}
    }
}
