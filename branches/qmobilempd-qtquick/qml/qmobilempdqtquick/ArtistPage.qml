import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
        id: artistpage
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
            section.property: "artist";
                     section.criteria: ViewSection.FirstCharacter
                              section.delegate: sectionHeading
        }


    }
