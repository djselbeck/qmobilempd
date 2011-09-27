import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: albumspage
        property alias listmodel: albums_list_view.model;
        property string artistname;
        tools: ToolBarLayout
        {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ButtonRow {
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


        } }
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
                     }
                 }
             }
        ListView{
            id: albums_list_view
            delegate: albumDelegate
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
            section.property: "sectionprop";
           // section.criteria: ViewSection.FirstCharacter
            section.delegate: sectionHeadingAlbum
    onModelChanged: {
        console.debug("MODEL count:"+model.count);
    }
        }


    SectionScroller{
        listView: albums_list_view
    }


    }
