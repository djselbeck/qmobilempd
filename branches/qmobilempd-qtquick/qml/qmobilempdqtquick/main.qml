import QtQuick 1.0
import com.nokia.symbian 1.0


Window {
    id: window
    property string hostname;
    property int port;
    property string password;
    property Page currentsongpage;
    property string playbuttoniconsource;
    signal setHostname(string hostname);
    signal setPort(int port);
    signal setPassword(string password);
    signal setVolume(int volume);
    signal connectToServer();
    signal requestCurrentPlaylist();
    signal requestArtists();
    signal requestArtistAlbums(string artist);
    signal setCurrentArtist(string artist);
    //Variant in format [artistname,albumname]
    signal requestAlbum(variant album);
    signal addAlbum(variant album);
    signal addArtist(string artist);
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

    function updateCurrentPlaying(list)
    {
        currentsongpage.title = list[0];
        currentsongpage.album = list[1];
        currentsongpage.artist = list[2];
        currentsongpage.position = list[3];
        currentsongpage.length = list[4];
        currentsongpage.lengthtext = "("+formatLength(list[3])+"/"+formatLength(list[4])+")";
        currentsongpage.bitrate = list[5]+"kbps";
        playbuttoniconsource = (list[6]=="playing") ? "toolbar-mediacontrol-pause" : "toolbar-mediacontrol-play";
        volumeslider.value = list[7];

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
        var component = Qt.createComponent("AlbumSongPage.qml");
        var object = component.createObject(window);
        object.artistname = "";
        object.albumname = albumname;
        object.listmodel= albumTracksModel;
        pageStack.push(object);
    }

    function artistalbumClicked(artistname, album)
    {
        console.debug("Currentartist: "+artistname + " album: "+ album +"clicked");
        window.requestAlbum([artistname,album]);
        var component = Qt.createComponent("AlbumSongPage.qml");
        var object = component.createObject(window);
        object.artistname = artistname;
        object.albumname = album;
        object.listmodel= albumTracksModel;
        pageStack.push(object);
    }

    function slotShowPopup(string)
    {
        console.debug("POPUP: "+string+" requested");
        popuptext.text=string;
        popuptext.visible=true;
        //popuptext.textwidth = popuptext.textpaintedwidth;
//        if(popuptext.textwidth>window.width)
//        {
//            popuptext.textwidth = window.width;
//        }
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
                var component = Qt.createComponent("PlaylistPage.qml");
                var object = component.createObject(window);
                object.listmodel = playlistModel;
                pageStack.push(object);
            }
            else if(list_view1.model.get(index).ident=="settings"){
                console.debug("Settings clicked");
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"));

            }
            else if(list_view1.model.get(index).ident=="currentsong"){
                console.debug("Current song clicked");
                pageStack.push(currentsongpage);
            }
            else if(list_view1.model.get(index).ident=="albums"){
                console.debug("Albums clicked");
                var albumpagecomponent = Qt.createComponent("AlbumPage.qml");
                var albumpageobject = albumpagecomponent.createObject(window);
                window.requestAlbums();
                albumpageobject.listmodel = albumsModel;
                pageStack.push(albumpageobject);
            }
            else if(list_view1.model.get(index).ident=="artists"){
                console.debug("Artists clicked");
                window.requestArtists();
                var component = Qt.createComponent("ArtistPage.qml");
                var object = component.createObject(window);
                object.listmodel = artistsModel;
                pageStack.push(object);
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
        var component = Qt.createComponent("ArtistAlbumPage.qml");
        var object = component.createObject(window);
        window.requestArtistAlbums(item);
        object.listmodel = albumsModel;
        object.artistname = item;
        pageStack.push(object);
    }

    Component.onCompleted: {
        var component = Qt.createComponent("CurrentSong.qml");
        var object = component.createObject(window);
        currentsongpage = object;
        playbuttoniconsource = "toolbar-mediacontrol-play";
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
                        height: 50
                        Row{
                            id: topLayout
                            Text { text: name; color:"white";font.pointSize:12;}
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

        //                ToolButton {
        //                    iconSource: "toolbar-mediacontrol-stop"
        //                    onClicked: {
        //                        window.stop();
        //                    }
        //                }
                ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
                ToolButton {
                    iconSource: playbuttoniconsource; onClicked: window.play()
                }
                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }

            }

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

    Rectangle{
        id: popuptext
        property alias text: textoutput.text
        color: "white"
        width: window.width
        height: textoutput.height
                x:0
        y: 0
        opacity: 0
        visible: false
        Text{
            id: textoutput
            text: "TEST POPUP"
            color: "black"
            font.pointSize: 10
            horizontalAlignment: "AlignHCenter"
            wrapMode: "WrapAnywhere"
            //anchors.fill: parent
            width: parent.width
        }
       // anchors { left: parent.left; right: parent.right; }
        
    }


    PropertyAnimation {id: popupblendin; target: popuptext; properties: "opacity"; to: "0.8"; duration: 500}
    PropertyAnimation {id: popupblendout
		target: popuptext
		properties: "opacity"
		to: "0"
		duration: 500
    onCompleted: {
		popuptext.visible=false;popuptext.textwidth=0;
		}
	}

    PropertyAnimation {id: volumeblendin; target: volumeslider; properties: "opacity"; to: "1"; duration: 500}
    PropertyAnimation {id: volumeblendout
                target: volumeslider
                properties: "opacity"
                to: "0"
                duration: 500
    onCompleted: {
                volumeslider.visible=false;
                }
        }

    Timer{
        id: popupanimationtimer;
        interval: 3000;
        onTriggered: {
            popupblendout.start();
        }
    }
    Slider{
        id: volumeslider
        orientation: Qt.Vertical
        maximumValue: 100
        minimumValue: 0
        stepSize: 1
        visible:false
        opacity:0
        inverted: true
        height: (window.height/3>100) ? 200 : window.height/3
        anchors {right:parent.right;bottom:commonToolBar.top;}
        onValueChanged: {
            if(pressed)
            {
                window.setVolume(value);
            }
        }
    }

    onFocusChanged: {

    }
}
