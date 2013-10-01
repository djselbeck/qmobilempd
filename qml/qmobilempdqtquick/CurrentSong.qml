import QtQuick 1.1
import com.nokia.symbian 1.1
import com.nokia.extras 1.1

Page {
    id: currentsong_page
    property alias title: titleText.text;
    property alias album: albumText.text;
    property alias artist: artistText.text;
    property alias length: positionSlider.maximumValue;
    property alias lengthtextcurrent:lengthTextcurrent.text;
    property alias lengthtextcomplete:lengthTextcomplete.text;
    property alias position: positionSlider.value;
    property alias bitrate: bitrateText.text;
    property alias shuffle: shufflebtn.checked;
    property alias repeat: repeatbtn.checked;
    property alias nr: nrText.text;
    property alias uri: fileText.text;
    property alias audioproperties: audiopropertiesText.text;
    property alias pospressed: positionSlider.pressed;
    property bool playing;
    property int fontsize:8;
    property int fontsizegrey:7;



    //tools: backTools
    tools: ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
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
    Flickable{
        anchors {left:parent.left; right: parent.right;bottom:positionSlider.top;top: parent.top}
        id: infoFlickable
        contentHeight: infocolumn.height
        //contentWidth: infocolumn.width
        clip: true
        Column {
            id: infocolumn
            Image{
               id: coverImage
               height: infoFlickable.height - (titleText.height + albumText.height + artistText.height)
               width: height
               anchors.horizontalCenter: parent.horizontalCenter
               fillMode: Image.PreserveAspectCrop
               smooth: true
               source: coverimageurl
           }
            //anchors {left:parent.left; right: parent.right; top:parent.top; bottom:parent.bottom}
            anchors {left:parent.left; right: parent.right;}
            Text{id:titleText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter: parent.horizontalCenter}}
            Text{id:albumText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter: parent.horizontalCenter}}
            Text{id:artistText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {horizontalCenter: parent.horizontalCenter;}}
            Text{text: "Nr.:";color:"grey";font.pointSize: fontsizegrey}
            Text{id:nrText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Bitrate:";color:"grey";font.pointSize: fontsizegrey}
            Text{id:bitrateText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "Properties:";color:"grey";font.pointSize: fontsizegrey}
            Text{id:audiopropertiesText ;text: "";color:"white";font.pointSize:fontsize;wrapMode: "WordWrap";anchors {left:parent.left; right: parent.right;}}
            Text{text: "FileUri:";color:"grey";font.pointSize: fontsizegrey}
            Text{id:fileText ;text: "";color:"white";font.pointSize:fontsize;wrapMode:"WrapAnywhere" ;anchors {left:parent.left; right: parent.right;}}
            clip: true;
        }
    }
    ToolBar{
        id: controlrow
        anchors {bottom: parent.bottom}

        tools: ToolBarLayout {
            ButtonRow {
                ToolButton{ iconSource: "toolbar-mediacontrol-backwards"; onClicked: window.prev() }

                ToolButton {
                    iconSource: playbuttoniconsource; onClicked: window.play()
                }
                ToolButton{ iconSource: "toolbar-mediacontrol-forward"; onClicked: window.next() }
                ToolButton {
                    iconSource: "toolbar-mediacontrol-stop"
                    onClicked: {
                        window.stop();
                    }
                }

                ToolButton{
                    id: repeatbtn
                    //text: "Repeat"
                    iconSource: "icons/repeat.svg"
                    checkable: true
                    onClicked: {
                        window.setRepeat(checked);
                    }
                }
                ToolButton{
                    id: shufflebtn

                    iconSource: "icons/shuffle.svg"
                    checkable: true
                    onClicked: {
                        window.setShuffle(checked);
                    }

                }
            }

        }}

    Slider
    {
        id: positionSlider
        stepSize: 1;
        orientation: Qt.Horizontal
        valueIndicatorVisible: true
        valueIndicatorText:formatLength(value)
        onPressedChanged: {
            if(!pressed)
            {
                window.seek(value);

            }
        }

        anchors {left:parent.left; right: parent.right; bottom:positionfield.top}
        Text{id:lengthTextcurrent ;text: "";color:"white";font.pointSize:7;wrapMode: "WordWrap";anchors {left:parent.left; bottom:parent.bottom}}
        Text{id:lengthTextcomplete ; text: "";color:"white";font.pointSize:7;wrapMode: "WordWrap";anchors {right: parent.right; bottom:parent.bottom}}
    }
    Rectangle
    {
        id:positionfield
        color: "black"
        height: childrenRect.height
        anchors {left:parent.left; right: parent.right; bottom:controlrow.top}
        //                Text{id:lengthTextcurrent ;text: "";color:"white";font.pointSize:7;wrapMode: "WordWrap";anchors {left:parent.left;}}
        //                Text{id:lengthTextcomplete ;text: "";color:"white";font.pointSize:7;wrapMode: "WordWrap";anchors {right: parent.right;}}
    }

    function makeLastFMRequestURL()
    {
        var url = "";
        url = "http://ws.audioscrobbler.com/2.0/?method=album.getinfo&api_key="+ lastfmapikey + "&artist="+artist+"&album="+album
        url = url.replace(/#|\|/g,"");
        console.debug("LastFM url created: " + url);
        coverfetcherXMLModel.source = url;

        coverfetcherXMLModel.reload();


        return url;
    }

    XmlListModel
    {
        id: coverfetcherXMLModel
        query: "/lfm/album/image"
        XmlRole { name: "image"; query: "./string()" }
        XmlRole { name: "size"; query: "@size/string()" }
        onStatusChanged: {
            console.debug("XML status changed to: "+ status);
            if(status == XmlListModel.Ready)
            {
                if(count>0)
                {
                    console.debug("Xml model ready, count: "+count);
                    var fetchindex;
                    if ( count >= 3 )
                    {
                        console.debug("item: "+3);
                        console.debug(coverfetcherXMLModel.get(3).size+":");
                        console.debug(coverfetcherXMLModel.get(3).image);
                        fetchindex = 3;
                    }
                    else {
                        console.debug("item: "+count);
                        console.debug(coverfetcherXMLModel.get(count-1).size+":");
                        console.debug(coverfetcherXMLModel.get(count-1).image);
                        fetchindex = count-1;
                    }

                    console.debug("imageurl: " + coverfetcherXMLModel.get(fetchindex).image);
                    var coverurl = coverfetcherXMLModel.get(fetchindex).image;
                    if(coverurl !== coverimageurl) {
                        // global
                        coverimageurl = coverfetcherXMLModel.get(fetchindex).image;
                    }
                }
            }
            if(status == XmlListModel.Error)
            {
                console.debug(coverfetcherXMLModel.errorString());
            }
        }
    }

}
