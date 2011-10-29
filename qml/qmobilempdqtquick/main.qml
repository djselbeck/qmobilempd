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
    property bool connected;
    property string selectcolor: "#000077";
    signal setHostname(string hostname);
    signal setPort(int port);
    signal setPassword(string password);
    signal setVolume(int volume);
    signal setCurrentArtist(string artist);
    signal connectToServer();
    //Variant in format [artistname,albumname]
    signal addAlbum(variant album);
    signal addArtist(string artist);
    signal addFiles(string files);
    signal addSong(string uri);
    signal addPlaylist(string name);
    signal playAlbum(variant album);
    signal playArtist(string artist);


    signal requestSavedPlaylists();
    signal requestSavedPlaylist(string name);
    signal requestAlbums();
    signal requestAlbum(variant album);
    signal requestArtists();
    signal requestArtistAlbums(string artist);
    signal requestFilesPage(string files);
    signal requestFilesModel(string files);
    signal requestCurrentPlaylist();

    // Control signals
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal seek(int position);
    signal setRepeat(bool rep);
    signal setShuffle(bool shfl);
    signal updateDB();

    //Playlist signals
    signal savePlaylist(string name);
    signal deletePlaylist();
    signal deleteSavedPlaylist(string name);
    signal playPlaylistTrack(int index);
    signal deletePlaylistTrack(int index);
    signal newProfile();
    signal changeProfile(variant profile);
    signal deleteProfile(int index);
    signal connectProfile(int index);
    //appends song to playlist
    signal playSong(string uri);
    //Clears playlist before adding
    signal playFiles(string uri);


    signal quit();

    function slotConnected()
    {
        connected = true;
        console.debug("Slot connected called");
    }

    function slotDisconnected()
    {
        connected = false;
    }

    function busy()
    {
        playlistbusyindicator.running=true;
        playlistbusyindicator.visible=true;
        blockinteraction.enabled=true;
    }

    function ready()
    {
        playlistbusyindicator.running=false;
        playlistbusyindicator.visible=false;
        blockinteraction.enabled=false;
    }

    function settingsModelUpdated()
    {
        settingslist.listmodel = settingsModel;
        selectserverdialog.model = settingsModel;
    }

    function updateCurrentPlaying(list)
    {
        currentsongpage.title = list[0];
        currentsongpage.album = list[1];
        currentsongpage.artist = list[2];
        if(currentsongpage.pospressed===false) {
            currentsongpage.position = list[3];
        }
        currentsongpage.length = list[4];
        currentsongpage.lengthtextcurrent = formatLength(list[3]);
        currentsongpage.lengthtextcomplete = list[4]==0 ? "": formatLength(list[4]);
        currentsongpage.bitrate = list[5]+"kbps";
        playbuttoniconsource = (list[6]=="playing") ? "toolbar-mediacontrol-pause" : "toolbar-mediacontrol-play";
        if(volumeslider.pressed===false){
            volumeslider.value = list[7];
        }
        currentsongpage.repeat = (list[8]=="0" ?  false:true);
        currentsongpage.shuffle = (list[9]=="0" ?  false:true);
        currentsongpage.nr = (list[10]===0? "":list[10]);
        currentsongpage.uri = list[11];
        playlistpage.songid = list[12];
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
        lastpath = path;
        window.requestFilesPage(path);
    }

    function updatePlaylist()
    {
        console.debug("Playlist model updated");
        blockinteraction.enabled=false;
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
        pageStack.push(albumpageobject);
        infobanner.close();
    }

    function updateArtistModel(){
        var component = Qt.createComponent("ArtistPage.qml");
        var object = component.createObject(window);
        object.listmodel = artistsModel;
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

    function albumTrackClicked(title,album,artist,lengthformatted,uri,year,tracknr)
    {
        var component = Qt.createComponent("SongPage.qml");
        var object = component.createObject(window);
        object.title = title;
        object.album = album;
        object.artist = artist;
        object.filename = uri;
        object.lengthtext = lengthformatted;
        object.date = year;
        object.nr = tracknr;
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
            temp=((min<10?"0":"")+min)+":"+(sec<10?"0":"")+(sec);
        }
        else
        {
            temp=((temphours<10?"0":"")+temphours)+":"+((min<10?"0":"")+min)+":"+(sec<10?"0":"")+(sec);
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
        infobanner.text=string;
        infobanner.open();
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
                artistname = "";

                window.requestAlbums();

            }
            else if(list_view1.model.get(index).ident=="artists"){
                console.debug("Artists clicked");
                window.requestArtists();

            }
            else if(list_view1.model.get(index).ident=="files"){
                console.debug("Files clicked");

                filesClicked("/");

            }
            else if(list_view1.model.get(index).ident=="connectto"){
                console.debug("Connect to clicked");
                selectserverdialog.visible=true;
                selectserverdialog.open();
            }
            else if(list_view1.model.get(index).ident=="about"){
                console.debug("about to clicked:"+versionstring);
                aboutdialog.visible=true;
                aboutdialog.version = versionstring;
                aboutdialog.open();
            }
            else if(list_view1.model.get(index).ident=="updatedb"){
                window.updateDB();
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
        volumebuttoniconsource = "icons/volume.svg"
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
        Text{id: hometext;color: "grey"; text:(connected ? " Connected" : "Disconnected"); horizontalAlignment: "AlignHCenter";font.pointSize: listfontsize
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
                    ListElement { name: "Update database"; ident:"updatedb"; }
                    ListElement { name: "Servers"; ident:"settings"}
                    ListElement { name: "Connect"; ident:"connectto"}
                    ListElement { name: "About"; ident:"about"}
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
                        property alias color:rectangle.color
                        width: list_view1.width
                        height: 50
                        enabled: (ident ==="updatedb"? (connected) : true)
                        Rectangle {
                            id: rectangle
                            color:"black"
                            anchors.fill: parent
                            Row{
                                id: topLayout
                                Text { text: name; color:(ident ==="updatedb"? (connected ? "white" : "darkgrey") : "white");font.pointSize:12;}
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                                list_view1.currentIndex = index
                                parseClicked(index);
                            }
                            onPressed: {
                                itemItem.color = selectcolor;
                            }
                            onReleased: {
                                itemItem.color = "black";
                            }
                            onCanceled: {
                                itemItem.color = "black";
                            }
                        }
                    }

                }


        tools: ToolBarLayout {
            id: pageSpecificTools
            ToolButton { iconSource: enabled ? "icons/close_stop.svg":"toolbar-home" ; onClicked: window.quit();enabled: quitbtnenabled;

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
        id:updatevolumetimer
        repeat: true
        interval: 200
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
        valueIndicatorText: value+"%";
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


    }

    InfoBanner{
        id: infobanner
        text: ""
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
        id: playlistbusyindicator
        running:false
        visible: false
        anchors.centerIn: parent
        width: 72
        height: 72
    }

    SelectionDialog{
        id: selectserverdialog
        titleText: "Select server:"
       // model: settingsModel
        visible: false
        delegate: serverSelectDelegate
        onAccepted: window.connectProfile(selectedIndex);
    }

    Component {
        id: serverSelectDelegate

        MenuItem {
            text: name
            onClicked: {
                selectedIndex = index
                root.accept()
            }
        }
    }

    CommonDialog{
        id:aboutdialog
        property string version : "noversion";
        titleText: "About:"
        content: [ Text{color: "white"
            text: "QMobileMPD-QML, copyright 2011 by Hendrik Borghorst. Version: "+aboutdialog.version
            wrapMode: "WordWrap"
            //anchors {left:parent.left; right: parent.right;}
            width: parent.width
        }]
        onClickedOutside: {aboutdialog.close();}


    }


}
