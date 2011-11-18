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

        //tools: backTools
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ButtonRow {
                //ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
//                ToolButton {
//                    iconSource: playbuttoniconsource; onClicked: window.play()
//                }
//                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }
//                ToolButton {
//                    iconSource: volumebuttoniconsource;
//                    onClicked: {
//                        if(volumeslider.visible)
//                        {
//                            volumeblendout.start();
//                        }
//                        else{
//                            volumeslider.visible=true;
//                            volumeblendin.start();
//                        }
//                    }
//                }

                    id: buttonrowaddplay
                    ToolButton{
                        text:"Add"
                        onClicked: {
                            window.addSong(filename);
                            pageStack.pop();
                        }
                    }
                    ToolButton{
                        text:"Play"
                        onClicked: {
                            window.playSong(filename);
                            pageStack.pop();
                        }
                    }
                    //anchors {left: parent.left;right: parent.right;bottom:parent.bottom}

            }
        }
        Flickable{
            anchors {left:parent.left; right: parent.right;bottom:parent.bottom;top: parent.top}
            contentHeight: infocolumn.height
            //contentWidth: infocolumn.width
            clip: true
            Column {
                id: infocolumn
                //anchors {left:parent.left; right: parent.right; top:parent.top; bottom:parent.bottom}
                anchors {left:parent.left; right: parent.right;}
                Text{text: "Title:";color:"grey"}
                Text{id:titleText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "Album:";color:"grey"}
                Text{id:albumText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "Artist:";color:"grey"}
                Text{id:artistText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "Length:";color:"grey"}
                Text{id:lengthText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "Date:";color:"grey"}
                Text{id:dateText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "Nr.:";color:"grey"}
                Text{id:nrText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
                Text{text: "FileUri:";color:"grey"}
                Text{id:fileText ;text: "";color:"white";font.pointSize:10;wrapMode:"WrapAnywhere" ;anchors {left:parent.left; right: parent.right;}}
                clip: true;
            }
        }


//        anchors {left:parent.left; right: parent.right; bottom: parent.bottom}

    }
