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
            spacing:2
            delegate: playlisttrackDelegate
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
                text: playlistname+":"
                color: "white"
                font.pointSize: 7
            }
        }

        Component{
            id: playlisttrackDelegate
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
                        Text { text: (title==="" ? filename : title); color:"white";font.pointSize:8}
                        Text { text: (length===0 ? "": " ("+lengthformated+")"); color:"white";font.pointSize:8}
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        list_view1.currentIndex = index
                        albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
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
            flickableItem: playlistsongs_list_view
            anchors {right:playlistsongs_list_view.right; top:playlistsongs_list_view.top}
        }


    }
