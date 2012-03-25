import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page{
    id: artistpage


    property alias listmodel: artist_list_view.model;
    tools: ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop(); }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}

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

    ListView{
        id: artist_list_view
        delegate: ListItem{
            ListItemText{
                id: topLayout
                anchors {verticalCenter: parent.verticalCenter}
                role: "Title"
                text: (artist===""? "No Artist Tag": artist); color:"white";font.pointSize:8; verticalAlignment: "AlignVCenter";
            }
            onClicked: {
                list_view1.currentIndex = index
                artistClicked(artist);
            }
            onPressAndHold: {
                artistMenu.artistname = artist;
                artistMenu.open();
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
        section.property: "sectionprop";
        section.delegate: ListHeading {
            id: sectionHeading
            ListItemText {
                anchors.fill: sectionHeading.paddingItem
                role: "Heading"
//                horizontalAlignment: Text.AlignLeft
                text:  section + ":"
            }
        }
    }
    ListHeading {
        id:headingrect

        ListItemText{
            text: "Artists:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
//            horizontalAlignment: Text.AlignLeft
        }
    }




    SectionScroller{
        listView: artist_list_view
    }

    ContextMenu {
        id: artistMenu
        property string artistname;
        MenuLayout {
            MenuItem {
                text: "Add Artist"
                onClicked: {
                    window.addArtist(artistMenu.artistname);
                }
            }
            MenuItem {
                text: "Play Artist"
                onClicked: {
                    window.playArtist(artistMenu.artistname);
                }
            }
        }
    }


}
