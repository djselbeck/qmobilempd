import QtQuick 1.0
import com.nokia.symbian 1.0
import com.nokia.extras 1.0


Window {
    id: window
    property string hostname;
    property int port;
    property string password;
    property Page currentsongpage;
    property Page playlistpage;
    property Page settingslist;
    property int listfontsize:12;
    property int liststretch:20;
    property string playbuttoniconsource;
    property string volumebuttoniconsource;
    property string lastpath;
    property string artistname;
    property string albumname;
    property string playlistname;
    property bool repeat;
    property bool shuffle;
    property bool quitbtnenabled;
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
    signal savePlaylist(string name);
    signal requestSavedPlaylists();
    signal requestSavedPlaylist(string name);

    signal requestAlbums();
    signal requestFilesPage(string files);
    signal requestFilesModel(string files);
    signal addFiles(string files);
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal deletePlaylist();
    signal playPlaylistTrack(int index);
    signal seek(int position);
    signal newProfile();
    signal changeProfile(variant profile);
    signal deleteProfile(int index);
    signal connectProfile(int index);
    signal playSong(string uri);
    signal addSong(string uri);
    signal addPlaylist(string name);
    signal setRepeat(bool rep);
    signal setShuffle(bool shfl);

    signal quit();

    function startupdateplaylist()
    {
        playlistbusyindicator.running=true;
        playlistbusyindicator.visible=true;
        blockinteraction.enabled=true;
    }

    function settingsModelUpdated()
    {
        settingslist.listmodel = settingsModel;
    }

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
        currentsongpage.repeat = (list[8]=="0" ?  false:true);
        currentsongpage.shuffle = (list[9]=="0" ?  false:true);
    }

    function savedPlaylistClicked(modelData)
    {
        playlistname = modelData;
        window.requestSavedPlaylist(modelData);
    }

    function updateSavedPlaylistModel()
    {
        var component = Qt.createComponent("SavedPlaylistTracks.qml");
        var object = component.createObject(window);
        object.listmodel = savedPlaylistModel;
        object.playlistname = playlistname;
        pageStack.push(object);
    }

    function updateSavedPlaylistsModel()
    {
        var component = Qt.createComponent("SavedPlaylistsPage.qml");
        var object = component.createObject(window);
        object.listmodel = savedPlaylistsModel;
        pageStack.push(object);
    }

    function filesClicked(path)
    {
        console.debug("Files clicked "+path + "/");
        //pageStack.currentPage.listmodel = filesModel;
//        popuptext.text = "Please wait";
//        infobanner.text = qsTr("Please Wait");
//        infobanner.open();
        busyindicator.running=true;
        busyindicator.visible=true;
//        popuptext.visible = "true";
//        popupblendin.start();
//        var filescomponent = Qt.createComponent("FilesPage.qml");
//        var filesobject = filescomponent.createObject(window);

//        pageStack.push(filesobject);
//        pageStack.currentPage.filepath = path;
        lastpath = path;
        window.requestFilesPage(path);
    }

    function updatePlaylist()
    {
        console.debug("Playlist model updated");
        blockinteraction.enabled=false;
        playlistbusyindicator.visible=false;
        playlistbusyindicator.running=false;
        playlistpage.listmodel = playlistModel;
        if(pageStack.currentPage == playlistpage)
        {
            //pageStack.replace(playlistpage);

        }

    }

    function updateAlbumsModel(){
        var albumpagecomponent = Qt.createComponent("AlbumPage.qml");
        var albumpageobject = albumpagecomponent.createObject(window);
        albumpageobject.listmodel = albumsModel;
        albumpageobject.artistname = artistname;
        busyindicator.running=false;
        busyindicator.visible=false;
        pageStack.push(albumpageobject);
        infobanner.close();
    }

    function updateArtistModel(){
        var component = Qt.createComponent("ArtistPage.qml");
        var object = component.createObject(window);
        object.listmodel = artistsModel;
        busyindicator.running=false;
        busyindicator.visible=false;
        pageStack.push(object);
        infobanner.close();
    }

    function updateAlbumModel()
    {
        var component = Qt.createComponent("AlbumSongPage.qml");

        var object = component.createObject(window);
        object.artistname = artistname;
        object.albumname = albumname;
        object.listmodel= albumTracksModel;
        pageStack.push(object);
    }

    function albumTrackClicked(title,album,artist,lengthformatted,uri)
    {
        var component = Qt.createComponent("SongPage.qml");
        var object = component.createObject(window);
        object.title = title;
        object.album = album;
        object.artist = artist;
        object.filename = uri;
        object.lengthtext = lengthformatted;
        pageStack.push(object);
    }


    function receiveFilesModel()
    {        
        console.debug("Files model updated");
    }

    function receiveFilesPage()
    {
        var filescomponent = Qt.createComponent("FilesPage.qml");
        var filesobject = filescomponent.createObject(window);
        filesobject.listmodel = filesModel;
        filesobject.filepath = lastpath;
        infobanner.close();
        busyindicator.running=false;
        busyindicator.visible=false;
        pageStack.push(filesobject);

    }

    function formatLength(length)
    {
        var temphours = Math.floor(length/3600);
        var min = 0;
        var sec = 0;
        var temp="";
       // console.debug("Length format");
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
       // console.debug("Length formatted:" + temp);
        return temp;
    }

    function albumClicked(artist,albumstring)
    {
        console.debug("Currentartist: "+artist + " album: "+ albumstring +"clicked");
        window.requestAlbum([artist,albumstring]);
        artistname = artist;
        this.albumname = albumstring;
    }

    function artistalbumClicked(artist, album)
    {
        console.debug("Currentartist: "+artist + " album: "+ album +"clicked");
        window.requestAlbum([artist,album]);
        artistname = artistname;
        albumname = album;
    }

    function slotShowPopup(string)
    {
        console.debug("POPUP: "+string+" requested");
        popuptext.text=string;
        infobanner.text=string;
        infobanner.open();
//        popuptext.visible=true;
//        //popuptext.textwidth = popuptext.textpaintedwidth;
////        if(popuptext.textwidth>window.width)
////        {
////            popuptext.textwidth = window.width;
////        }
//        popupblendin.start();
//        popupanimationtimer.start();
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

                pageStack.push(playlistpage);
            }
            else if(list_view1.model.get(index).ident=="settings"){
                console.debug("Settings clicked");
                //pageStack.push(Qt.resolvedUrl("SettingsList.qml"));

                pageStack.push(settingslist);

            }
            else if(list_view1.model.get(index).ident=="currentsong"){
                console.debug("Current song clicked");
                pageStack.push(currentsongpage);
            }
            else if(list_view1.model.get(index).ident=="albums"){
                console.debug("Albums clicked");
                busyindicator.running=true;
                busyindicator.visible=true;
                artistname = "";

                window.requestAlbums();

            }
            else if(list_view1.model.get(index).ident=="artists"){
                console.debug("Artists clicked");
                busyindicator.running=true;
                busyindicator.visible=true;
                window.requestArtists();

            }
            else if(list_view1.model.get(index).ident=="files"){
                console.debug("Files clicked");

                filesClicked("/");

            }
        }
    }

    function artistClicked(item)
    {
        console.debug("Artist "+item+" clicked");
        this.artistname = item;
        window.requestArtistAlbums(item);
    }

    Component.onCompleted: {
        var component = Qt.createComponent("CurrentSong.qml");
        var object = component.createObject(window);
        currentsongpage = object;
        var pcomponent = Qt.createComponent("PlaylistPage.qml");
        var pobject = pcomponent.createObject(window);
        playlistpage = pobject;
        playbuttoniconsource = "toolbar-mediacontrol-play";
        volumebuttoniconsource = "icons/audio-volume-high.png"
        var component = Qt.createComponent("SettingsList.qml");
        var object = component.createObject(window);
        settingslist = object;
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
        Text{id: hometext;color: "grey"; text:qsTr("QMobileMPD-QML"); horizontalAlignment: "AlignHCenter";font.pointSize: listfontsize
        anchors {left: parent.left;right:parent.right;top:parent.top;}  }
                ListView{
                    id: list_view1
                    model: mainMenuModel
                    delegate: itemDelegate
                    signal playlistClicked
                    onPlaylistClicked: console.log("Send playlistClicked signal")
                    anchors { left: parent.left; right: parent.right; top: hometext.bottom; bottom: parent.bottom }
                    clip: true
                }
                ListModel {
                    id: mainMenuModel
                    ListElement { name: "Current song"; ident:"currentsong"; }
                    ListElement { name: "Artists"; ident:"artists"; }
                    ListElement { name: "Albums"; ident:"albums";}
                    ListElement { name: "Files"; ident:"files" ;}
                    ListElement { name: "Playlist"; ident:"playlist";}
                    ListElement { name: "Servers"; ident:"settings"}
                }

                onStatusChanged: {
                    console.debug("Main status changed: "+status);
                    if(status==PageStatus.Activating)
                    {
                        console.debug("artis activating");
                        //window.requestArtists();
                        quitbtnenabled = false;
                        activatequitbuttontimer.start();

                    }
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
            ToolButton { iconSource: enabled ? "toolbar-back":"toolbar-home" ; onClicked: window.quit();enabled: quitbtnenabled;

            }

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

    }
    Component{
        id:playlisttrackDelegate
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
                    Text {clip: true; wrapMode: Text.WrapAnywhere; text: title; color:"white";font.pointSize:8;font.italic:(playing) ? true:false;}
                    Text { text: " ("+lengthformated+")"; color:"white";font.pointSize:8}
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
            }
        }
    }



    Component{
        id:albumDelegate
        Item {
            id: itemItem
            width: window.width
            height: topLayout.height+liststretch
            Rectangle {
                color: (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1)
                anchors.fill: parent
                Text{
                    id: topLayout
                    anchors {verticalCenter: parent.verticalCenter}
                    text: title; color:"white";font.pointSize:8; verticalAlignment: "AlignVCenter";
                    //Text {text:artist; color:"grey";font.pointSize:10;}
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    albumClicked(artistname,title);
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
                popuptext.visible=false;
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

    Timer{
        id:updatevolumetimer
        repeat: true
        interval: 180
        onTriggered: {
            console.debug("Volume timer triggered with value:"+volumeslider.value);
            window.setVolume(volumeslider.value);
        }
    }

    Timer{
        id: activatequitbuttontimer
        interval: 1500
        onTriggered: {
            quitbtnenabled = true;
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
        valueIndicatorVisible: true

        onPressedChanged: {
            if(pressed)
            {
                console.debug("Pressed");
                updatevolumetimer.start();
            }
            else{
                console.debug("!Pressed");

                window.setVolume(volumeslider.value);
                updatevolumetimer.stop();

            }
        }
            onValueChanged: {
                if(pressed)
                 //   updatevolumetimer.start();
                valueIndicatorText = value+"%";
            }

    }


    onFocusChanged: {

    }

    InfoBanner{
        id: infobanner
        text: ""
        iconSource: "qtg_fr_popup_infobanner"
    }
    MouseArea {
         anchors.fill: parent
         enabled: pageStack.busy
     }
    MouseArea {
        id:blockinteraction
        anchors.fill: parent
        enabled: false
    }

    BusyIndicator{
        id: busyindicator
        running:false
        visible: false
        anchors.centerIn: parent
        width: 72
        height: 72
    }

    BusyIndicator{
        id: playlistbusyindicator
        running:false
        visible: false
        anchors.centerIn: parent
        width: 72
        height: 72
    }


}
