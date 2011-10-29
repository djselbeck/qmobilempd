import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
    id: albumspage
    property alias listmodel: albums_list_view.model;
    property string artistname;
    tools: ToolBarLayout
    {
    ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
    ToolButton{ iconSource: "toolbar-home";onClicked: {
            pageStack.clear();
            pageStack.push(mainPage);
        }}
    //        ButtonRow {
    //                ToolButton {
    //                    iconSource: "toolbar-mediacontrol-stop"
    //                    onClicked: {
    //                        window.stop();
    //                    }
    //                }

    ToolButton {
        iconSource: "toolbar-add"
        onClicked: window.addArtist(artistname);
    }

    //            ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
    //            ToolButton {
    //                iconSource: playbuttoniconsource; onClicked: window.play()
    //            }
    //            ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }
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


    //}
}
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
Component {
    id: sectionHeadingAlbum
    Rectangle {
        width: window.width
        height: childrenRect.height
        color: "darkgrey"

        Text {
            text: section
            font.bold: true
            style: Text.Raised
        }
    }
}
ListView{
    id: albums_list_view
    delegate: albumDelegate
    anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
    clip: true
    section.property: "sectionprop";
    section.delegate: sectionHeadingAlbum
    onModelChanged: {
        console.debug("MODEL count:"+model.count);
    }
}
Rectangle {
    id:headingrect
    anchors {left:parent.left;right:parent.right;}
    height: artext.height
    color: Qt.rgba(0.07, 0.07, 0.07, 1)
    Text{
        id: artext
        text: (artistname==="" ? "Albums:" :artistname+":")
        color: "white"
        font.pointSize: 7
    }
}


SectionScroller{
    listView: albums_list_view
}

Component{
    id:albumDelegate
    Item {
        id: itemItem
        width: window.width
        height: topLayout.height+liststretch
        property alias color:rectangle.color
        Rectangle {
            id: rectangle
            color: (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1)
            anchors.fill: parent
            Text{
                id: topLayout
                anchors {verticalCenter: parent.verticalCenter}
                text: (title===""? "No Album Tag":title); color:"white";font.pointSize:8; verticalAlignment: "AlignVCenter";
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {

                list_view1.currentIndex = index
                albumClicked(artistname,title);
            }
            onPressAndHold: {
                console.debug("Long Tap"+":"+title);
                albumMenu.albumtitle = title;
                albumMenu.artistname = artistname;
                albumMenu.open();
            }
            onPressed: {
                itemItem.color = selectcolor;
            }
            onReleased: {
                itemItem.color = (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1);
            }
            onCanceled: {
                itemItem.color = (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1);
            }

        }
    }

}

ContextMenu {
    id: albumMenu
    property string albumtitle;
    property string artistname;
    MenuLayout {
        MenuItem {
            text: "Add Album"
            onClicked: {console.debug("Add album:"+albumMenu.albumtitle+":"+albumMenu.artistname);
                        window.addAlbum([albumMenu.artistname,albumMenu.albumtitle]);
            }
        }
        MenuItem {
            text: "Play Album"
            onClicked: {console.debug("Play album:"+albumMenu.albumtitle+":"+albumMenu.artistname);
                        window.playAlbum([albumMenu.artistname,albumMenu.albumtitle]);
            }
        }
    }
}


}
