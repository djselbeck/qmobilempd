import QtQuick 1.0
import com.nokia.symbian 1.0
import com.nokia.extras 1.0



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
            width: list_view1.width
            height: topLayout.height
            property alias color:rectangle.color
            property alias gradient:rectangle.gradient
            Rectangle {
                id: rectangle
                color:"black"
                anchors.fill: parent
                Row{
                    id: topLayout
                    Text { text: modelData; color:"white";font.pointSize:10;}
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.debug("Playlist:"+modelData+" clicked");
                    window.savedPlaylistClicked(modelData);
                }
                onPressed: {
                    itemItem.gradient = selectiongradient;
                }
                onReleased: {
                    itemItem.gradient = fillgradient;
                    itemItem.color = "black";
                }
                onCanceled: {
                    itemItem.gradient = fillgradient;
                    itemItem.color = "black";
                }
            }
        }
    }
}
