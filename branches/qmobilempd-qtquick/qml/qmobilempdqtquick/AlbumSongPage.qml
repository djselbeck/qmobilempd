import QtQuick 1.0
import com.nokia.symbian 1.0

Page{
        id: albumsongspage
        property string albumname;
        property string artistname;
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ToolButton{ iconSource: "toolbar-home";onClicked: {
                    pageStack.clear();
                    pageStack.push(mainPage);
                }}
        //    ButtonRow {
//                ToolButton {
//                    iconSource: "toolbar-mediacontrol-stop"
//                    onClicked: {
//                        window.stop();
//                    }
//                }

                ToolButton{ iconSource:"toolbar-add"; onClicked: {
                        window.addAlbum([artistname,albumname]);
                    }}
//                ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
//                ToolButton {
//                    iconSource: playbuttoniconsource; onClicked: window.play()
//                }
//                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }
                ToolButton {
                    iconSource: volumebuttoniconsource;
                    onClicked: {
                        if(volumeslider.visible)
                        {
                            volumeblendout.start();
                        }
                        else{
                            volumeslider.visible=true;
                            volumeblendin.start();
                        }
                    }
                }


//            }
}
        property alias listmodel: albumsongs_list_view.model;

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
                text: (albumname=="" ? "Albumsongs:" : albumname+":")
                color: "white"
                font.pointSize: 7
            }
        }
        Component{
            id: albumtrackDelegate
            Item {
                id: itemItem
                width: list_view1.width
                height: topLayout.height+liststretch
                Rectangle {
                    color:"black"
                    anchors.fill: parent
                    Row{
                        id: topLayout
                        anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                        Text { text: ((tracknr===0 ? "":tracknr+"."));color:"white";font.pointSize: 8}
                        Text { text: (title==="" ? filename : title); color:"white";font.pointSize:8}
                        Text { text: " ("+lengthformated+")"; color:"white";font.pointSize:8}
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        list_view1.currentIndex = index
                        albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
                    }
                }
            }
        }

    }
