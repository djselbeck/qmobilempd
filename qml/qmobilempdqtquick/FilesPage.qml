import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page{
    id: filespage
    property string filepath;
    property variant model;
    property alias listmodel: files_list_view.model;
    property bool first: true;
    tools: ToolBarLayout {
        id: filesTools
        ToolButton { iconSource: "toolbar-back"; onClicked: {pageStack.pop();
                popfilemodelstack();
            }
        }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
                window.cleanFileStack();
            }}
        ToolButton { iconSource: "toolbar-add"; onClicked: {
                window.addFiles(filepath);
            } }
    }
    ListView{
        id: files_list_view
        delegate: ListItem{
            id:filesDelegate
//            Row{
//                anchors {verticalCenter: parent.verticalCenter}

                Image {
                    id: fileicon
                    source: (isDirectory===true ? "icons/folder.svg":"icons/music_file.svg");
                    height: platformStyle.graphicSizeMedium
                    width: height
                    anchors.verticalCenter: parent.verticalCenter
                }
                Column{
                    anchors{left: fileicon.right;right:parent.right;verticalCenter:parent.verticalCenter;}
                ListItemText{
                    id:filenametext
                    role: "Title"
                    text: name
                    wrapMode: "NoWrap"
                    anchors {left: parent.left;right:parent.right}
                    elide: Text.ElideMiddle;
                }
                ListItemText
                {
                    visible: isDirectory===false
                    role:"SubTitle"
                    text: (isDirectory===true ? "" : (title==="" ?"" : title+ " - ") + (artist==="" ?  "" : artist) );
                    anchors {left: parent.left;right:parent.right;}
                }
                }


           // }
            onClicked: {
                if(isDirectory){
                    list_view1.currentIndex = index
                    filesClicked((prepath=="/"? "": prepath+"/")+name);
                }
                if(isFile) {
                    console.debug("Album:"+album)
                    albumTrackClicked(title,album,artist,length,path,year,tracknr);
                }
            }
            onPressAndHold: {
                filesMenu.filepath = (prepath=="/"? "": prepath+"/")+name;
                filesMenu.currentfilepath = filepath;
                filesMenu.directory = isDirectory;
                if(isFile){
                    filesMenu.title = title;
                    filesMenu.album = album;
                    filesMenu.artist = artist;
                    filesMenu.length = length;
                    filesMenu.year = year;
                    filesMenu.nr = tracknr;
                }
                filesMenu.open();
            }

        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
    }
    ListHeading {
        id: headingrect
        ListItemText {
            anchors.fill: headingrect.paddingItem
            role: "Heading"
            text: (filepath===""? "Files:" : filepath+":")
            wrapMode: Text.WrapAnywhere
            elide: Text.ElideLeft
//            horizontalAlignment: Text.AlignLeft

        }
    }

    ScrollBar
    {
        id:filescrollbar
        flickableItem: files_list_view
        anchors {right:files_list_view.right; top:files_list_view.top}
    }

    ContextMenu {
        id: filesMenu
        property string filepath;
        property string currentfilepath;
        property string title;
        property string album;
        property string artist;
        property string length;
        property string year;
        property int nr;
        property bool directory:false;
        MenuLayout {
            MenuItem {
                text: "Show song information"
                visible: !filesMenu.directory
                onClicked: {
                    albumTrackClicked(filesMenu.title,filesMenu.album,filesMenu.artist,filesMenu.length,filesMenu.filepath,filesMenu.year,filesMenu.nr);
                }
            }
            MenuItem {
                text: filesMenu.directory ?  "Add directory" : "Add file"
                onClicked: {
                    window.addFiles(filesMenu.filepath);
                }
            }
            MenuItem {
                text: filesMenu.directory ?  "Playback directory" : "Playback file"
                onClicked: {
                    if(filesMenu.directory)
                        window.playFiles(filesMenu.filepath);
                    else
                        window.playSong(filesMenu.filepath);
                }
            }
            MenuItem {
                text: "Add current folder"
                onClicked: {
                    window.addFiles(filesMenu.currentfilepath);
                }
            }
            MenuItem {
                text: "Play current folder"
                onClicked: {
                    window.playFiles(filesMenu.currentfilepath);
                }
            }
        }
    }

}
