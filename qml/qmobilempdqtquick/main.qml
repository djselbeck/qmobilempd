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
    property Page serverlist;
    property Page artistspage;
    property Page albumspage;
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
    property bool playing:false;
    property string selectcolor: "lightblue";
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
    signal popfilemodelstack();
    signal cleanFileStack();

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
        console.debug("Profilename:" + profilename);
    }

    function slotDisconnected()
    {
        connected = false;
        profilename = "";
        playing = false;
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
        serverlist.listmodel = settingsModel;
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
        playing = (list[6]=="playing") ? true : false;
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
        pageStack.push(Qt.resolvedUrl("SavedPlaylistTracks.qml"),{listmodel:savedPlaylistModel,playlistname:playlistname});
    }

    function updateSavedPlaylistsModel()
    {
        pageStack.push(Qt.resolvedUrl("SavedPlaylistsPage.qml"),{listmodel:savedPlaylistsModel});
    }

    function filesClicked(path)
    {
        lastpath = path;
        window.requestFilesPage(path);
    }

    function updatePlaylist()
    {
        blockinteraction.enabled=false;
        playlistpage.listmodel = playlistModel;
    }

    function updateAlbumsModel(){
        pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),{listmodel:albumsModel,artistname:artistname});
        infobanner.close();
    }

    function updateArtistModel(){
        pageStack.push(Qt.resolvedUrl("ArtistPage.qml"),{listmodel:artistsModel});
        infobanner.close();
    }

    function updateAlbumModel()
    {
        pageStack.push(Qt.resolvedUrl("AlbumSongPage.qml"),{artistname:artistname,albumname:albumname,listmodel:albumTracksModel});
    }

    function albumTrackClicked(title,album,artist,lengthformatted,uri,year,tracknr)
    {
        pageStack.push(Qt.resolvedUrl("SongPage.qml"),{title:title,album:album,artist:artist,filename:uri,lengthtext:lengthformatted,date:year,nr:tracknr});
    }


    function receiveFilesModel()
    {
    }

    function receiveFilesPage()
    {
        infobanner.close();
        pageStack.push(Qt.resolvedUrl("FilesPage.qml"), {listmodel: filesModel,filepath :lastpath});

    }

    function formatLength(length)
    {
        var temphours = Math.floor(length/3600);
        var min = 0;
        var sec = 0;
        var temp="";
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
        return temp;
    }

    function albumClicked(artist,albumstring)
    {
        window.requestAlbum([artist,albumstring]);
        artistname = artist;
        this.albumname = albumstring;
    }

    function artistalbumClicked(artist, album)
    {
        window.requestAlbum([artist,album]);
        artistname = artistname;
        albumname = album;
    }

    function slotShowPopup(string)
    {
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
            if(list_view1.model.get(index).ident=="playlist"){
                if(connected)
                    pageStack.push(playlistpage);
            }
            else if(list_view1.model.get(index).ident=="settings"){
                pageStack.push(Qt.resolvedUrl("SettingsList.qml"));

                //pageStack.push(settingslist);

            }
            else if(list_view1.model.get(index).ident=="currentsong"){
                if(connected)
                    pageStack.push(currentsongpage);
            }
            else if(list_view1.model.get(index).ident=="albums"){
                artistname = "";
                if(connected)
                    window.requestAlbums();

            }
            else if(list_view1.model.get(index).ident=="artists"){
                if(connected)
                    window.requestArtists();

            }
            else if(list_view1.model.get(index).ident=="files"){
                if(connected)
                    filesClicked("/");

            }
            else if(list_view1.model.get(index).ident=="connectto"){
                selectserverdialog.visible=true;
                selectserverdialog.open();
            }
            else if(list_view1.model.get(index).ident=="about"){ 
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
        var component = Qt.createComponent("ServerList.qml");
        var object = component.createObject(window);
        serverlist = object;
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
        Text{id: hometext;color: "grey"; text:(connected ? " Connected to: " + profilename : "Disconnected"); horizontalAlignment: "AlignHCenter";font.pointSize: 7
        anchors {left: parent.left;right:parent.right;top:parent.top;}  }
        Flickable {
            id: mainflickable
            contentHeight: maincolumn.height
            anchors {top:hometext.bottom;left:parent.left; right: parent.right; bottom:parent.bottom}
            MouseArea {
                x: titletext.x
                y: titletext.y
                width: parent.width
                height: titletext.height+albumtext.height+artisttext.height
                onClicked: {
                    if(connected)
                        pageStack.push(currentsongpage);
                }
            }
            Column{
                anchors {top:parent.top;left:parent.left; right: parent.right;}
                id: maincolumn
                Text{visible: playing&&text!=="";id: titletext;color: "white"; text:currentsongpage.title; horizontalAlignment: "AlignHCenter";font.pointSize: 7
                anchors {left: parent.left;right:parent.right;}
                }
                Text{visible: playing&&text!=="";id: artisttext;color: "white"; text:currentsongpage.artist; horizontalAlignment: "AlignHCenter";font.pointSize: 7
                anchors {left: parent.left;right:parent.right;}
                }
                Text{id: albumtext;visible: playing&&text!=="";color: "white"; text:currentsongpage.album; horizontalAlignment: "AlignHCenter";font.pointSize: 7
                anchors {left: parent.left;right:parent.right;}
                }
                Rectangle {
                    color: Qt.rgba(0.13,0.13,0.13,1)
                    height: 2
                    width: parent.width
                }

                ListView{
                    id: list_view1
                    model: mainMenuModel
                    delegate: itemDelegate
                    signal playlistClicked
                    onPlaylistClicked: console.log("Send playlistClicked signal")

                    height: count*50+25;
                    width: parent.width
                   //anchors { left: parent.left; right: parent.right; top: mainflickable.bottom; bottom: parent.bottom }
                    clip: true
                    interactive: false
                    spacing:2
                }
            }
            clip: true
        }


                ListModel {
                    id: mainMenuModel
                    ListElement { name: "Song information"; ident:"currentsong"; }
                    ListElement { name: "Artists"; ident:"artists"; }
                    ListElement { name: "Albums"; ident:"albums";}
                    ListElement { name: "Files"; ident:"files" ;}
                    ListElement { name: "Playlist"; ident:"playlist";}
                    ListElement { name: "Connect"; ident:"connectto"}
                    ListElement { name: "Settings"; ident:"settings"}
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
                    if(status==PageStatus.Active)
                    {
                        window.cleanFileStack();
                    }
                }

                Component{
                    id:itemDelegate
                    Item {
                        id: itemItem
                        property alias color:rectangle.color
                        property alias gradient: rectangle.gradient
                        width: list_view1.width
                        height: 50
                        Rectangle {
                            id: rectangle
                            color:Qt.rgba(0.07, 0.07, 0.07, 1)
                            gradient: Gradient{}
                            anchors.fill: parent
                            Row{
                                id: topLayout
                                anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                                Text { text: name; color:"white";font.pointSize:12;}
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {

                                list_view1.currentIndex = index
                                parseClicked(index);
                            }
                            onPressed: {
                                itemItem.gradient = selectiongradient;
                            }
                            onReleased: {
                                itemItem.gradient = fillgradient;
                                itemItem.color =Qt.rgba(0.07, 0.07, 0.07, 1);
                            }
                            onCanceled: {
                                itemItem.gradient = fillgradient;
                                itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                            }
                        }
                    }

                }


        tools: ToolBarLayout {
            id: pageSpecificTools
            ToolButton { iconSource: enabled ? "icons/close_stop.svg":"toolbar-home" ; onClicked: window.quit();enabled: quitbtnenabled;

            }
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




    PropertyAnimation {id: volumeblendin; target: volumeslider; properties: "opacity"; to: "1"; duration: 500
        onCompleted: {
            hidevolumeslidertimer.start();
        }
    }
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
        id:hidevolumeslidertimer
        repeat: false
        interval: 2500
        onTriggered: {
            volumeblendout.start();
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
                if(hidevolumeslidertimer.running)
                {
                    console.debug("Hidevolume slider stopped");
                    hidevolumeslidertimer.stop();
                }
            }
            else{
                console.debug("!Pressed");

                window.setVolume(volumeslider.value);
                updatevolumetimer.stop();
                hidevolumeslidertimer.start();

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
        onAccepted: {window.connectProfile(selectedIndex);

        }
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

    Gradient {
        id: selectiongradient
        GradientStop { position:0.0;color:"#1180dd"}
        GradientStop { position:1.0;color:"#52a3e6"}
    }

    Gradient {
        id: fillgradient
    }


}
