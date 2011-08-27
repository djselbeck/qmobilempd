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

    signal requestAlbums();
    signal requestFiles(string files);
    signal play();
    signal next();
    signal prev();
    signal stop();
    signal seek(int position);




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
            TextField{id: hostnameInput;  text: "192.168.2.22"; anchors { left: parent.left; right: parent.right}}
            Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: portInput;text: "6600"; anchors { left: parent.left; right: parent.right}}
            Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: passwordInput; anchors { left: parent.left; right: parent.right}}
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
                window.requestCurrentPlaylist();
                playlist_list_view.model = playlistModel;
            }
        }
        Component.onDestruction: {
            console.debug("Playlist destroyed");
        }

        tools: backTools
        ListView{
            id: playlist_list_view
            delegate: trackDelegate
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
                window.requestAlbums();
                albums_list_view.model = albumsModel;
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
            delegate: albumDelegate
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
//            ToolButton { text: "next page"; onClicked: pageStack.push(secondPage) }
    }

    Component{
        id:trackDelegate
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
                    parseClicked(index);
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
                    parseClicked(index);
                }
            }
        }
    }

}


