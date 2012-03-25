import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page{
    id: playlistpage
    property alias songid: playlist_list_view.currentIndex
    property alias listmodel:playlist_list_view.model

    tools:ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        // ButtonRow {
        ToolButton {
            iconSource: "toolbar-delete"
            onClicked: {
                window.deletePlaylist();
            }
        }

        ToolButton {
            iconSource: "icons/document-save.svg"
            onClicked: {
                playlist_list_view.visible=false;

                savenamedialog.visible=true;
            }
        }
        ToolButton{
            iconSource: "icons/playlist.svg"
            onClicked: {
                window.requestSavedPlaylists();
            }
        }
        ToolButton{
            iconSource: "icons/point.svg"
            onClicked: {
                songid = window.lastsongid;
            }
        }
        ToolButton {
            iconSource: playbuttoniconsource
            onClicked: {
                window.play();
            }
        }
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


    ListView{
        id: playlist_list_view
        delegate: ListItem{

            Row{
                anchors {verticalCenter: parent.verticalCenter}
                Image {
                    visible: playing
                    source: "icons/play.svg"

                }
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
                if(!playing)
                {
                    parseClickedPlaylist(index);
                }
                else{
                    pageStack.push(currentsongpage);
                }
            }
            onPressAndHold: {
                currentPlaylistMenu.id = index;
                currentPlaylistMenu.playing = playing;
                currentPlaylistMenu.open();
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
        highlightMoveDuration: 300
    }

    ListHeading {
        id: headingrect
        ListItemText {
            anchors.fill: headingrect.paddingItem
            role: "Heading"
            text: "Current playlist:"
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideLeft
//            horizontalAlignment: Text.AlignLeft

        }
    }
    Rectangle
    {
        id: savenamedialog
        color: Qt.rgba(0,0,0,0.1)
        z:1
        anchors {top:headingrect.bottom;left:parent.left;right:parent.right;bottom:splitViewInput.top}
        visible:false
        Column {
            z:2
            id:savenamecolumn
            onVisibleChanged: playlistname.text="";
            visible:true
            y: parent.height/2
            anchors {left: parent.left;right:parent.right;bottom:parent.bottom}
            Text{text: "Enter name for playlist:";color:"white" }
            TextField{ id:playlistname;       anchors {left: parent.left;right:parent.right}
                Keys.onPressed: {if(event.key==Qt.Key_Enter){
                        window.savePlaylist(playlistname.text);
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }
                }
                inputMethodHints: Qt.ImhNoPredictiveText
            }
            ButtonRow{anchors {left: parent.left;right:parent.right}
                Button{text:"Ok"
                    onClicked: {
                        window.savePlaylist(playlistname.text);
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }}
                Button{text:"Cancel"
                    onClicked: {
                        savenamedialog.visible=false;
                        playlist_list_view.visible=true;
                    }}
            }
        }
    }
    ScrollBar
    {
        id:playlistscroll
        flickableItem: playlist_list_view
        anchors {right:playlist_list_view.right; top:playlist_list_view.top}
    }



    ContextMenu {
        id: currentPlaylistMenu
        property int id;
        property bool playing:false;
        MenuLayout {
            MenuItem
            {
                text: "Show song information"
                visible: currentPlaylistMenu.playing
                onClicked: pageStack.push(currentsongpage);
            }
            MenuItem {
                text: "Playback track"
                onClicked: {
                    window.playPlaylistTrack(currentPlaylistMenu.id);
                }
            }
            MenuItem {
                text: "Delete track from playlist"
                onClicked: {
                    window.deletePlaylistTrack(currentPlaylistMenu.id);
                }
            }
        }
    }

    Item {
        id: splitViewInput

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 200 } }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height }

            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; height: window.pageStack.toolbar }
            }
        ]

    }

}
