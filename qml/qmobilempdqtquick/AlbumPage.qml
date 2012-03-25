import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1


Page{
    id: albumslistpage
    property alias listmodel: albums_list_view.model;
    property string artistname;
    tools: ToolBarLayout
    {
    ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
    ToolButton{ iconSource: "toolbar-home";onClicked: {
            pageStack.clear();
            pageStack.push(mainPage);
        }}
    ToolButton {
        iconSource: "toolbar-add"
        onClicked: window.addArtist(artistname);
    }


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

ListHeading {
    id: listHeading

    ListItemText {
        anchors.fill: listHeading.paddingItem
        role: "Heading"
        text: (artistname==="" ? "Albums" : artistname)
//        horizontalAlignment: Text.AlignLeft

    }
}
ListView{
    id: albums_list_view
    delegate: ListItem{
        id:listitem
        ListItemText{
            role: "Title"
            anchors {verticalCenter: parent.verticalCenter}
            text: (title===""? "No Album Tag":title)
        }
        onClicked: {
            list_view1.currentIndex = index
            albumClicked(artistname,title);
        }
        onPressAndHold: {
            albumMenu.albumtitle = title;
            albumMenu.artistname = artistname;
            albumMenu.open();
        }

    }

    anchors { left: parent.left; right: parent.right; top: listHeading.bottom; bottom: parent.bottom }
    clip: true
    focus: true
    section.property: "sectionprop";
    section.delegate: ListHeading {
        id: sectionHeading
        ListItemText {
            anchors.fill: sectionHeading.paddingItem
            role: "Heading"
//            horizontalAlignment: Text.AlignLeft
            text:  section + ":"
        }
    }

}



SectionScroller{
    listView: albums_list_view
}



ContextMenu {
    id: albumMenu
    property string albumtitle;
    property string artistname;
    MenuLayout {
        MenuItem {
            text: "Add Album"
            onClicked: {
                window.addAlbum([albumMenu.artistname,albumMenu.albumtitle]);
            }
        }
        MenuItem {
            text: "Play Album"
            onClicked: {
                window.playAlbum([albumMenu.artistname,albumMenu.albumtitle]);
            }
        }
    }
}


}
