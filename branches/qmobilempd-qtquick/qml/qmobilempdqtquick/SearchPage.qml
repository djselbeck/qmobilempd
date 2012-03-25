import QtQuick 1.1
import com.nokia.symbian 1.1


Page{
    id: searchpage
    property alias listmodel:albumsongs_list_view.model
    property int currentindex:-1;
    property string selectedsearch;


    tools:ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}
        ToolButton { iconSource: "toolbar-add"; onClicked:{
                window.addlastsearch();

     }       }
    }
    ScrollBar
    {
        id:playlistscroll
        flickableItem: albumsongs_list_view
        anchors {right:albumsongs_list_view.right; top:albumsongs_list_view.top}
        z:1
    }
    Row{
        id: searchhead
        anchors {top:headingrect.bottom}
        TextField {
            id: searchfield
            text: ""
            inputMethodHints: Qt.ImhNoPredictiveText
            width: window.width - searchforbutton.width - startsearchbtn.width
                 platformLeftMargin: search.width + platformStyle.paddingSmall
            Image {
                  id: search
                  anchors { top: parent.top; left: parent.left; margins: platformStyle.paddingMedium }
                  smooth: true
                  fillMode: Image.PreserveAspectFit
                  source: "icons/search.svg"
                  height: parent.height - platformStyle.paddingMedium * 2
                  width: parent.height - platformStyle.paddingMedium * 2
              }

            }
        Button{
            id:searchforbutton
            text:"Search for"
            onClicked: {
                selectsearchdialog.visible=true;
                selectsearchdialog.open();

            }

        }
        Button{
            id:startsearchbtn
            text:"Go"
            onClicked: {
                window.requestSearch([selectedsearch,searchfield.text]);
                albumsongs_list_view.forceActiveFocus();

            }

        }
    }

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
                 ListItemText{text:artist+" - "+album;role:"SubTitle"; anchors {left:parent.left;right:parent.right;}}
            }
            onClicked: {
                list_view1.currentIndex = index
                albumTrackClicked(title,album,artist,lengthformated,uri,year,tracknr);
            }
            onPressAndHold: {
                songmenu.uri = uri;
                songmenu.artistname = artist;
                songmenu.albumtitle = album;
                console.debug(artist+":"+album);
                songmenu.open();
            }
        }
        anchors { left: parent.left; right: parent.right; top: searchhead.bottom; bottom: splitViewInput.top }
        clip: true
    }
    ListHeading {
        id:headingrect

        ListItemText{
            text: "Search tracks:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem

        }
    }

    SelectionDialog{
        id: selectsearchdialog
        titleText: "Search for:"
        visible: false
        model:searchesmodel
        delegate: serverSelectDelegate
        onAccepted: {searchforbutton.text=model.get(selectedIndex).name;
            selectedsearch = model.get(selectedIndex).ident;

        }
    }
    ListModel {
        id: searchesmodel
        ListElement { name: "Titles"; ident:"title"; }
        ListElement { name: "Albums"; ident:"album"; }
        ListElement { name: "Artists"; ident:"artist"; }
        ListElement { name: "Files"; ident:"file"}

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
