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

        tools: backTools
        Column {
            anchors {left:parent.left; right: parent.right;}
            Text{ text: "Current Song:";color:"white" }
            Text{text: "Title:";color:"white"}
            Text{id:titleText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text­­{text: "Album:";color:"white"}
            Text{id:albumText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Artist:";color:"white"}
            Text{id:artistText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Length:";color:"white"}
            Text{id:lengthText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Bitrate:";color:"white"}
            Text{id:bitrateText ;text: "";color:"white";font.pointSize:10;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
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
        anchors {left:parent.left; right: parent.right; bottom: parent.bottom}

    }
