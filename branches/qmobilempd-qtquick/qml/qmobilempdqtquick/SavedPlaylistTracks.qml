import QtQuick 1.0
import com.nokia.symbian 1.0

Page{
        id: playlistsongspage
        property string playlistname;
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ToolButton{ iconSource: "toolbar-home";onClicked: {
                    pageStack.clear();
                    pageStack.push(mainPage);
                }}

//                ToolButton {
//                    iconSource: "toolbar-mediacontrol-stop"
//                    onClicked: {
//                        window.stop();
//                    }
//                }

                ToolButton{ iconSource:"toolbar-add"; onClicked: {
                        window.addPlaylist(playlistname)
                    }}


            }
        property alias listmodel: playlistsongs_list_view.model;

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
            id: playlistsongs_list_view
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
                width: list_view1.width
                height: topLayout.height
                Row{
                    id: topLayout
                    Text { text: title; color:"white";font.pointSize:10}
                    Text { text: " ("+lengthformated+")"; color:"white";font.pointSize:10}
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        list_view1.currentIndex = index
                        albumTrackClicked(title,album,artist,lengthformated,uri);
                    }
                }
            }
        }

        ScrollBar
        {
            id:playlistscroll
            flickableItem: playlistsongs_list_view
            anchors {right:playlistsongs_list_view.right; top:playlistsongs_list_view.top}
        }


    }
