import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

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
        delegate: ListItem{
            id: albumtrackDelegate
            Column{
                anchors{left:parent.left;right:parent.right;verticalCenter: parent.verticalCenter}
                 //   anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                 Row{
                    ListItemText { id:nrtext;text: ((tracknr===0 ? "":tracknr+"."));role:"Title"}
                    ListItemText { text: (title==="" ? filename : title);role:"Title";elide: Text.ElideRight;}
                    ListItemText { id:lengthtext;text: (length===0 ? "": " ("+lengthformated+")");role:"Title"}
                    }
                ListItemText{text:artist;role:"SubTitle"; anchors {left:parent.left;right:parent.right;}}
            }
            onClicked: {
                list_view1.currentIndex = index
                albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
            }
            onPressAndHold: {
                songmenu.uri = uri;
                songmenu.artistname = artistname
                songmenu.albumtitle = albumname
                songmenu.open();
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
    }


    ListHeading {
        id: headingrect

        ListItemText {
            anchors.fill: listHeading.paddingItem
            role: "Heading"
            text: (albumname=="" ? "Albumsongs:" : albumname+":")
//            horizontalAlignment: Text.AlignLeft

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
