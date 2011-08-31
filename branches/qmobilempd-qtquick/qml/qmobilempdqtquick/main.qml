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
    //Variant in format [artistname,albumname]
    signal requestAlbum(variant album);
    signal addAlbum(variant album);
    signal playAlbum(variant album);

    signal requestAlbums();
    signal requestFiles(string files);
    signal addFiles(string files);
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal deletePlaylist();
    signal playPlaylistTrack(int index);
    signal seek(int position);

    property list<ListModel> filemodels;

    function updateCurrentPlaying(list)
    {
        currentsong_page.title = list[0];
        currentsong_page.album = list[1];
        currentsong_page.artist = list[2];
        currentsong_page.position = list[3];
        currentsong_page.length = list[4];
        currentsong_page.lengthtext = "("+formatLength(list[3])+"/"+formatLength(list[4])+")";
        currentsong_page.bitrate = list[5]+"kbps";
    }

    function filesClicked(path)
    {
        console.debug("Files clicked "+path + "/");
        //pageStack.currentPage.listmodel = filesModel;
        var filescomponent = Qt.createComponent("FilesPage.qml");
        var filesobject = filescomponent.createObject(window);

        pageStack.push(filesobject);
        pageStack.currentPage.filepath = path;
        window.requestFiles(path);
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

    function receiveFilesModel(modelid)
    {
        pageStack.currentPage.listmodel = filesModel;
    }


    function formatLength(length)
    {
        var temphours = Math.floor(length/3600);
        var min = 0;
        var sec = 0;
        var temp="";
        console.debug("Length format");
        if(temphours>1)
        {
            min=(length-(3600*temphours))/60;
        }
        else{
            min=Math.floor(length/60);
        }
        sec = length-temphours*3600-min*60;
        if(temphours===0)
        {
            temp=(min)+":"+(sec<10?"0":"")+(sec);
        }
        else
        {
            temp=(temphours)+":"+(min)+":"+(sec);
        }
        console.debug("Length formatted:" + temp);
        return temp;
    }

    function albumClicked(albumname)
    {
        console.debug("Currentartist: "+"" + " album: "+ albumname +"clicked");
        window.requestAlbum(["",albumname]);
        albumsongspage.artistname = "";
        albumsongspage.albumname = albumname;
        albumsongs_list_view.model= albumTracksModel;
        pageStack.push(albumsongspage);
    }

    function artistalbumClicked(artistname, album)
    {
        console.debug("Currentartist: "+artistname + " album: "+ album +"clicked");
        window.requestAlbum([artistname,album]);
        albumsongspage.artistname = artistname;
        albumsongspage.albumname = album;
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
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));

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

                var filescomponent = Qt.createComponent("FilesPage.qml");
                var filesobject = filescomponent.createObject(window);

                pageStack.push(filesobject);
                window.requestFiles("/");

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


