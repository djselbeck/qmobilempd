import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: albumspage
        property alias listmodel: albums_list_view.model;
        tools: backTools
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
            section.property: "title";
            section.criteria: ViewSection.FirstCharacter
            section.delegate: sectionHeadingAlbum
        }

    }
