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

                ToolButton{ iconSource:"toolbar-add"; onClicked: {
                        window.addAlbum([artistname,albumname]);
                    }}

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



}
        property alias listmodel: albumsongs_list_view.model;

        ListView{
            id: albumsongs_list_view
            delegate: albumtrackDelegate
            anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
            clip: true
            spacing: 2
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
                property alias color:rectangle.color
                property alias gradient: rectangle.gradient
                Rectangle {
                    id: rectangle
                    color:Qt.rgba(0.07, 0.07, 0.07, 1)
                    anchors.fill: parent
                    Row{
                        id: topLayout
                        anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                        Text { text: ((tracknr===0 ? "":tracknr+"."));color:"white";font.pointSize: 8}
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
                        itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                    }
                    onCanceled: {
                        itemItem.gradient = fillgradient;
                        itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                    }
                    onPressAndHold: {
                        itemItem.gradient = fillgradient;
                        itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                        songmenu.uri = uri;
                        songmenu.artistname = artistname
                        songmenu.albumtitle = albumname
                        songmenu.open();
                    }
                }
            }
        }

        ContextMenu {
            id: songmenu
            property string uri;
            property string albumtitle;
            property string artistname;
            MenuLayout {
                MenuItem {
                    text: "Play track"
                    onClicked: {
                        window.playSong(songmenu.uri);
                    }
                }
                MenuItem {
                    text: "Add track to playlist"
                    onClicked: {
                        window.addSong(songmenu.uri);
                    }
                }
                MenuItem {
                    text: "Play Album"
                    onClicked: { window.playAlbum([songmenu.artistname,songmenu.albumtitle]);
                    }
                }
                MenuItem {
                    text: "Add Album to playlist"
                    onClicked: {window.addAlbum([songmenu.artistname,songmenu.albumtitle]);
                    }
                }
            }
        }

    }
