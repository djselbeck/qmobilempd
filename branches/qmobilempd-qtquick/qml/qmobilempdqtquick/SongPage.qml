import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1
Page {
    id: currentsong_page
    property alias title: titleText.text;
    property alias album: albumText.text;
    property alias artist: artistText.text;
    property alias lengthtext:lengthText.text;
    property alias date: dateText.text;
    property alias nr: nrText.text;
    property alias filename: fileText.text;
    property bool playing;
    tools: ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ButtonRow {
            id: buttonrowaddplay
            ToolButton{
                iconSource: "toolbar-add"
                onClicked: {
                    window.addSong(filename);
                    pageStack.pop();
                }
            }
            ToolButton{
                iconSource: "toolbar-mediacontrol-play"
                onClicked: {
                    window.playSong(filename);
                    pageStack.pop();
                }
            }
        }
    }
    Flickable{
        anchors {left:parent.left; right: parent.right;bottom:parent.bottom;top: parent.top}
        contentHeight: infocolumn.height
        clip: true
        Column {
            id: infocolumn
            anchors {left:parent.left; right: parent.right;}
            Text{text: "Title:";color:"grey"}
            Text{id:titleText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Album:";color:"grey"}
            Text{id:albumText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Artist:";color:"grey"}
            Text{id:artistText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Length:";color:"grey"}
            Text{id:lengthText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Date:";color:"grey"}
            Text{id:dateText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Nr.:";color:"grey"}
            Text{id:nrText ;text: "";color:"white";font.pointSize:8;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "FileUri:";color:"grey"}
            Text{id:fileText ;text: "";color:"white";font.pointSize:8;wrapMode:"WrapAnywhere" ;anchors {left:parent.left; right: parent.right;}}
            clip: true;
        }
    }

}
