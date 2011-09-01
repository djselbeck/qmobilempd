import QtQuick 1.0
import com.nokia.symbian 1.0

Page {
        id: currentsong_page
        property alias title: titleText.text;
        property alias album: albumText.text;
        property alias artist: artistText.text;
        property alias length: positionSlider.maximumValue;
        property alias lengthtext:lengthText.text;
        property alias position: positionSlider.value;
        property alias bitrate: bitrateText.text;
        property bool playing;

        //tools: backTools
        tools: ToolBarLayout {
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ButtonRow {
                ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }
                ToolButton {
                    iconSource: playbuttoniconsource; onClicked: window.play()
                }
                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }
                ToolButton {
                    //text: "Vol"
                    iconSource: Qt.resolvedUrl("res/icon-m-toolbar-volume-white.png");
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
        }

        Column {
            anchors {left:parent.left; right: parent.right;}
            Text{text: "Title:";color:"grey"}
            Text{id:titleText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Album:";color:"grey"}
            Text{id:albumText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Artist:";color:"grey"}
            Text{id:artistText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Length:";color:"grey"}
            Text{id:lengthText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Bitrate:";color:"grey"}
            Text{id:bitrateText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            clip: true;
        }
            Slider
            {
                id: positionSlider
                stepSize: 1;
                orientation: Qt.Horizontal
                valueIndicatorVisible: true
                onPressedChanged: {
                    if(!pressed)
                    {
                        window.seek(value);

                    }
                }
                onValueChanged: {valueIndicatorText=formatLength(value);}

                anchors {left:parent.left; right: parent.right; bottom: parent.bottom}
                }
//        anchors {left:parent.left; right: parent.right; bottom: parent.bottom}

    }
