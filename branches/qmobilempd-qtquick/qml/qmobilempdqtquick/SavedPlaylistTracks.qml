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
                anchors {verticalCenter: parent.verticalCenter}
                Column{
                    Row{
                        ListItemText {text: (index+1)+". ";anchors {verticalCenter: parent.verticalCenter}}
                        ListItemText {clip: true; wrapMode: Text.WrapAnywhere; elide: Text.ElideRight; text:  (title==="" ? filename : title);font.italic:(playing) ? true:false;anchors {verticalCenter: parent.verticalCenter}}
                        ListItemText { text: (length===0 ? "": " ("+lengthformated+")");anchors {verticalCenter: parent.verticalCenter}}
                    }
                    ListItemText{text:(artist!=="" ? artist + " - " : "" )+(album!=="" ? album : "");
                        role: "SubTitle";
                    }
                }

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
