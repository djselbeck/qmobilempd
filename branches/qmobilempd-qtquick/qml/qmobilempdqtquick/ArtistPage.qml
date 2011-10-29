import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: artistpage

        property alias listmodel: artist_list_view.model;
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ToolButton{ iconSource: "toolbar-home";onClicked: {
                    pageStack.clear();
                    pageStack.push(mainPage);
                }}
           /* ButtonRow {
//                ToolButton {
//                    iconSource: "toolbar-mediacontrol-stop"
//                    onClicked: {
//                        window.stop();
//                    }
//                }


//                ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
//                ToolButton {
//                    iconSource: playbuttoniconsource; onClicked: window.play()
//                }
//                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }


            }*/
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
                     color: "darkgrey"

                     Text {
                         text: section
                         font.bold: true
                     }
                 }
             }
        ListView{
            id: artist_list_view
            delegate: artistDelegate
            anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
            clip: true
            section.property: "sectionprop";
            section.delegate: sectionHeading
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
                text: "Artists:"
                color: "white"
                font.pointSize: 7
            }
        }

        Component{
            id:artistDelegate
            Item {
                id: itemItem
                width: window.width
                height: topLayout.height+liststretch
                property alias color:rectangle.color
                Rectangle {
                    id: rectangle;
                    color: (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1)
                    anchors.fill: parent
                    Text{
                        id: topLayout
                        anchors {verticalCenter: parent.verticalCenter}
                        text: (artist===""? "No Artist Tag": artist); color:"white";font.pointSize:8; verticalAlignment: "AlignVCenter";
                        //Text {text:artist; color:"grey";font.pointSize:10;}
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        list_view1.currentIndex = index
                        artistClicked(artist);
                    }
                    onPressAndHold: {
                        artistMenu.artistname = artist;
                        artistMenu.open();
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

        SectionScroller{
            listView: artist_list_view
        }

        ContextMenu {
            id: artistMenu
            property string artistname;
            MenuLayout {
                MenuItem {
                    text: "Add Artist"
                    onClicked: {console.debug("Add Artist:"+artistMenu.artistname);
                                window.addArtist(artistMenu.artistname);
                    }
                }
                MenuItem {
                    text: "Play Artist"
                    onClicked: {console.debug("Play Artist:"+artistMenu.artistname);
                                window.playArtist(artistMenu.artistname);
                    }
                }
            }
        }


    }
