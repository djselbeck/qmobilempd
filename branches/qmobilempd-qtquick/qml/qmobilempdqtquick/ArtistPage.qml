import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: artistpage

        property alias listmodel: artist_list_view.model;
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
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
            anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
            clip: true
            section.property: "sectionprop";
            section.delegate: sectionHeading
            onModelChanged: {
                console.debug("MODEL count:"+model.count);
            }
        }

        Component{
            id:artistDelegate
            Item {
                id: itemItem
                width: list_view1.width
                height: topLayout.height
                Rectangle{
                    color: (index%2===0) ? Qt.rgba(0.14, 0.14, 0.14, 1) : Qt.rgba(0.07, 0.07, 0.07, 1)
                    anchors.fill: parent
                    Row{
                        id: topLayout
                        Text { text: artist; color:"white";font.pointSize:10}

                    }
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

        SectionScroller{
            listView: artist_list_view
        }


    }
