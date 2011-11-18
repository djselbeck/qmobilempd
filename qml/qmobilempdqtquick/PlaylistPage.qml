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
                    iconSource: playbuttoniconsource
                    onClicked: {
                        window.play();
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
        delegate: playlisttrackDelegate
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
        highlightMoveDuration: 300
        spacing: 2

    }
    Rectangle {
        id:headingrect
        anchors {left:parent.left;right:parent.right;}
        height: artext.height
        color: Qt.rgba(0.07, 0.07, 0.07, 1)
        Text{
            id: artext
            text: "Current playlist:"
            color: "white"
            font.pointSize: 7
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
    Component{
        id:playlisttrackDelegate
        Item {
            id: itemItem
            width: parent.width
            height: topLayout.height+liststretch
            property alias color:rectangle.color
            property alias gradient: rectangle.gradient
            Rectangle {
                id: rectangle
                color:playing ? "#8cb2ff" : Qt.rgba(0.07, 0.07, 0.07, 1)
                anchors.fill: parent
                Row{
                    id: topLayout
                    anchors {verticalCenter: parent.verticalCenter}
                    Text {text: (index+1)+". ";color: playing ? "black" :"white";font.pointSize: 8}
                    Text {clip: true; wrapMode: Text.WrapAnywhere; text:  (title==="" ? filename : title); color:playing ? "black" :"white";font.pointSize:8;font.italic:(playing) ? true:false;}
                    Text { text: (length===0 ? "": " ("+lengthformated+")"); color:playing ? "black" :"white";font.pointSize:8}
                }
            }
            MouseArea {
                anchors.fill: parent
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
                   // itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                    currentPlaylistMenu.id = index;
                    currentPlaylistMenu.playing = playing;
                    currentPlaylistMenu.open();
                }
                onPressed: {
                    itemItem.gradient = selectiongradient;
                }
                onReleased: {
                    itemItem.gradient = fillgradient;
                   // itemItem.color = playing ? "#c7e0ff" : Qt.rgba(0.07, 0.07, 0.07, 1);
                }
                onCanceled: {
                    itemItem.gradient = fillgradient;
                    //itemItem.color = playing ? "#c7e0ff" : Qt.rgba(0.07, 0.07, 0.07, 1);
                }

            }
        }
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
        onStateChanged: {
            if(state=="Visible")
            {
                console.debug("input now visible");
                //settingsflick.contentY = settingsflick.lasty;
            }
            else if(state=="Hidden")
            {
                console.debug("input now hidden");
            }
        }
    }
}
