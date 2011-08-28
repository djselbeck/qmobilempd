import QtQuick 1.0
import com.nokia.symbian 1.0


Window {
    id: window
    property string hostname;
    property int port;
    property string password;
    signal setHostname(string hostname);
    signal setPort(int port);
    signal setPassword(string password);
    signal connectToServer();
    signal requestCurrentPlaylist();
    signal requestArtists();
    signal requestArtistAlbums(string artist);
    signal setCurrentArtist(string artist);
    signal requestAlbum(variant album);

    signal requestAlbums();
    signal requestFiles(string files);
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal deletePlaylist();
    signal playPlaylistTrack(int index);
    signal seek(int position);


    function updateCurrentPlaying(list)
    {

    }

    function updatePlaylist()
    {
        playlist_list_view.model = playlistModel;
        if(pageStack.currentPage == playlistpage)
        {
            //pageStack.replace(playlistpage);
          console.debug("Playlist repushed");
        }

    }

    function albumClicked(albumname)
    {
        console.debug("Currentartist: "+"" + " album: "+ albumname +"clicked");
        window.requestAlbum(["",albumname]);
        albumsongspage.artistname = "";
        albumsongs_list_view.model= albumTracksModel;
        pageStack.push(albumsongspage);
    }

    function artistalbumClicked(artistname, album)
    {
        console.debug("Currentartist: "+artistname + " album: "+ album +"clicked");
        window.requestAlbum([artistname,album]);
        albumsongspage.artistname = artistname;
        albumsongs_list_view.model= albumTracksModel;
        pageStack.push(albumsongspage);
    }

    function slotShowPopup(string)
    {
        console.debug("POPUP: "+string+" requested");
        popuptext.text=string;
        popuptext.visible=true;
        popuptext.textwidth = popuptext.textpaintedwidth;
        if(popuptext.textwidth>window.width)
        {
            popuptext.textwidth = window.width;
        }
        popupblendin.start();
        popupanimationtimer.start();
    }

    function parseClickedPlaylist(index)
    {
        window.playPlaylistTrack(index);
    }
    function parseClicked(index)
    {
        if(pageStack.currentPage==mainPage){
            console.debug("parseClicked("+index+")")
            if(list_view1.model.get(index).ident=="playlist"){
                console.debug("Playlist clicked");
                pageStack.push(playlistpage);
            }
            else if(list_view1.model.get(index).ident=="settings"){
                console.debug("Settings clicked");
                pageStack.push(settingspage);
            }
            else if(list_view1.model.get(index).ident=="currentsong"){
                console.debug("Current song clicked");
                pageStack.push(currentsong_page);
            }
            else if(list_view1.model.get(index).ident=="albums"){
                console.debug("Albums clicked");
                window.requestAlbums();
                albums_list_view.model = albumsModel;
                pageStack.push(albumspage);
            }
            else if(list_view1.model.get(index).ident=="artists"){
                console.debug("Artists clicked");
                window.requestArtists();
                artist_list_view.model = artistsModel;

                pageStack.push(artistpage);
            }
            else if(list_view1.model.get(index).ident=="files"){
                console.debug("Files clicked");
                pageStack.push(Qt.createComponent("FilesPage.qml"));
            }
        }
    }

    function artistClicked(item)
    {
        console.debug("Artist "+item+" clicked");
        window.requestArtistAlbums(item);
        artistalbums_list_view.model = albumsModel;
        artistalbumspage.artistname = item;
        pageStack.push(artistalbumspage);
    }

    Component.onCompleted: {
        pageStack.push(mainPage);
    }

    StatusBar {
        id: statusBar
        anchors.top: parent.top
    }

    PageStack {
        id: pageStack
        toolBar: commonToolBar
        anchors { left: parent.left; right: parent.right; top: statusBar.bottom; bottom: toolBar.top }
    }

    ToolBar {
        id: commonToolBar
        anchors.bottom: parent.bottom
    }

    Page {
        id: mainPage
                ListView{
                    id: list_view1

                    model: mainMenuModel
                    delegate: itemDelegate
                    signal playlistClicked
                    onPlaylistClicked: console.log("Send playlistClicked signal")
                    anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
                    clip: true
                }
                ListModel {
                    id: mainMenuModel
                    ListElement { name: "Current song"; ident:"currentsong"; }
                    ListElement { name: "Artists"; ident:"artists"; }
                    ListElement { name: "Albums"; ident:"albums";}
                    ListElement { name: "Files"; ident:"files" ;}
                    ListElement { name: "Playlist"; ident:"playlist";}
                    ListElement { name: "Settings"; ident:"settings"}
                }


                Component{
                    id:itemDelegate
                    Item {
                        id: itemItem
                        width: list_view1.width
                        height: 70
                        Row{
                            id: topLayout
                            Text { text: name; color:"white";font.pointSize:10}
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                                list_view1.currentIndex = index
                                parseClicked(index);
                            }
                        }
                    }
                }


        tools: ToolBarLayout {
            id: pageSpecificTools
            ToolButton { iconSource: "toolbar-back"; onClicked: Qt.quit() }

//            ToolButton { text: "next page"; onClicked: pageStack.push(secondPage) }
        }

    }

    Page{
        id: settingspage
        tools:ToolBarLayout {
            id: settingsTools
//            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
                ToolButton { text: "Cancel"; onClicked: pageStack.pop()  }
                ToolButton { text: "Ok"; onClicked: {
//                        netaccess.connectToHost(hostnameInput.text,portInput.text);
                        window.setHostname(hostnameInput.text);
                        window.setPassword(passwordInput.text);
                        window.setPort(portInput.text);
                        window.connectToServer();
                        pageStack.pop();
                    } }
        }
        Column{
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            Text{id: hostnameTextLabel; text: qsTr("Hostname:"); color:"white"}
            TextField{id: hostnameInput;  text: "192.168.2.51"; anchors { left: parent.left; right: parent.right}}
            Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: portInput;text: "6600"; anchors { left: parent.left; right: parent.right}}
            Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: passwordInput; text:"nudelsuppe"; anchors { left: parent.left; right: parent.right}}
        }

    }
    Page{
        id: playlistpage
        Component.onCompleted: {
            console.debug("Playlist completed");
        }

        onStatusChanged: {
            console.debug("Playlist status changed: "+status);
            if(status==PageStatus.Activating)
            {
                console.debug("Playlist activating");

            }
        }
        Component.onDestruction: {
            console.debug("Playlist destroyed");
        }

        tools:ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ButtonRow {
                    ToolButton {
                        iconSource: "toolbar-delete"
                        onClicked: {
                            window.deletePlaylist();
                        }
                    }
                    ToolButton {
                        iconSource: "toolbar-mediacontrol-stop"
                        onClicked: {
                            window.stop();
                        }
                    }
                    ToolButton {
                        iconSource: "toolbar-mediacontrol-play"
                        onClicked: {
                            window.play();
                        }
                    }

                } }
        ListView{
            id: playlist_list_view
            delegate: playlisttrackDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
        }

    }

    Page{
        id: artistpage
        tools: backTools
        Component.onCompleted: {
            console.debug("artis completed");
        }

        onStatusChanged: {
            console.debug("artis status changed: "+status);
            if(status==PageStatus.Activating)
            {
                console.debug("artis activating");
                //window.requestArtists();

            }
        }
        Component.onDestruction: {
            console.debug("artis destroyed");
        }
        Component {
                 id: sectionHeading
                 Rectangle {
                     width: window.width
                     height: childrenRect.height
                     color: "lightsteelblue"

                     Text {
                         text: section
                         font.bold: true
                     }
                 }
             }
        ListView{
            id: artist_list_view
            delegate: artistDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
            section.property: "artist";
                     section.criteria: ViewSection.FirstCharacter
                              section.delegate: sectionHeading
        }


    }
    Page{
        id: albumspage
        tools: backTools
        Component.onCompleted: {
            console.debug("albums completed");
        }

        onStatusChanged: {
            console.debug("albums status changed: "+status);
            if(status==PageStatus.Activating)
            {
                console.debug("albums activating");

            }
        }
        Component.onDestruction: {
            console.debug("albums destroyed");
        }
        ListView{
            id: albums_list_view
            delegate: albumDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
        }

    }
    Page{
        id: artistalbumspage
        property string artistname;
        tools: backTools
        Component.onCompleted: {
            console.debug("albums completed");
        }

        onStatusChanged: {
            console.debug("albums status changed: "+status);
            if(status==PageStatus.Activating)
            {
                console.debug("albums activating");
                artistalbums_list_view.model = albumsModel;
            }
        }
        Component.onDestruction: {
            console.debug("albums destroyed");
        }
        ListView{
            id: artistalbums_list_view
            delegate: artistalbumDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
        }

    }

    Page{
        id: albumsongspage
        tools: backTools
        property string artistname;
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
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
        }

    }

    Page {
        id: currentsong_page
        tools: backTools
        Column {
            Text{ text: "Current Song:";color:"white" }
            Text{text: "Title:";color:"white"}
            Text{id:titleText ;text: "";color:"white";font.pointSize:10}
            Text{text: "Album:";color:"white"}
            Text{id:albumText ;text: "";color:"white";font.pointSize:10}
            Text{text: "Artist:";color:"white"}
            Text{id:artistText ;text: "";color:"white";font.pointSize:10}
        }
    }


    ToolBarLayout {
        id: backTools
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ButtonRow {
            id: mediaButtons
                checkedButton: stop3b

                ToolButton {
                    id: stop3b;
                    iconSource: "toolbar-mediacontrol-stop"
                    onClicked: {
                        window.stop();
                    }
                }
                ToolButton {
                    id: prevButton;
                    iconSource: "toolbar-mediacontrol-backwards"
                    onClicked: {
                        window.prev();
                    }
                }
                ToolButton {
                    iconSource: "toolbar-mediacontrol-play"
                    onClicked: {
                        window.play();
                    }
                }
                ToolButton {
                    id: nextButton;
                    iconSource: "toolbar-mediacontrol-forward"
                    onClicked: {
                        window.next();
                    }
                }
            }

//            ToolButton { text: "next page"; onClicked: pageStack.push(secondPage) }
    }

    Component{
        id:playlisttrackDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: title; color:"white";font.pointSize:10;font.italic:(playing) ? true:false;}
                Text { text: " ("+lengthformated+")"; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    parseClickedPlaylist(index);
                }
            }
        }
    }
    Component{
        id: albumtrackDelegate
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
                    albumTrackClicked(index);
                }
            }
        }
    }

    Component{
        id:artistDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: artist; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    artistClicked(artist);
                }
            }
        }
    }

    Component{
        id:albumDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: title; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    albumClicked(title);
                }
            }
        }
    }

    Component{
        id:artistalbumDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            Row{
                id: topLayout
                Text { text: title; color:"white";font.pointSize:10}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    artistalbumClicked(artistalbumspage.artistname,title);
                }
            }
        }
    }

    Rectangle{
        id: popuptext
         property alias text: textoutput.text;
        property alias textwidth: textoutput.width;
        property alias textpaintedwidth : textoutput.paintedWidth;
        color: "white";
        width: textoutput.width;
        height: textoutput.height;
        Text{
            id: textoutput;
            text: "TEST POPUP"
            color: "black";
            font.pointSize: 10;
            horizontalAlignment: "AlignHCenter";
            wrapMode: "WrapAnywhere";
        }
       // anchors { left: parent.left; right: parent.right; }
        x:window.width/2-(width/2);
        y: window.height/2-20;
        opacity: 0;
        visible: false;
    }


    PropertyAnimation {id: popupblendin; target: popuptext; properties: "opacity"; to: "0.8"; duration: 500}
    PropertyAnimation {id: popupblendout; target: popuptext; properties: "opacity"; to: "0"; duration: 500
    onCompleted: {popuptext.visible=false;popuptext.textwidth=0;}}
    Timer{
        id: popupanimationtimer;
        interval: 3000;
        onTriggered: {
            popupblendout.start();
        }
    }


}


