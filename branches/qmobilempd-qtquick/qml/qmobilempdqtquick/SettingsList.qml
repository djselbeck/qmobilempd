import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
    id: settings
    property int currentindex:-1;

    ListModel {
        id: settingsModel
        ListElement { name: "Update database"; ident:"updatedb"; }
        ListElement { name: "Servers"; ident:"servers"}
        ListElement { name: "Connect"; ident:"connectto"}
        ListElement { name: "About"; ident:"about"}
    }



    tools:ToolBarLayout {
    ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
    ToolButton{ iconSource: "toolbar-home";onClicked: {
            pageStack.clear();
            pageStack.push(mainPage);
        }}
    ToolButton { iconSource: "toolbar-add";

        onClicked:{
            console.debug("Settings add clicked");
            window.newProfile();
        }
    }
    }
    ListView{
        id: settings_list_view
        delegate: settingsDelegate
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
        model: settingsModel
    }
    Rectangle {
        id:headingrect
        anchors {left:parent.left;right:parent.right;}
        height: artext.height
        color: Qt.rgba(0.07, 0.07, 0.07, 1)
        Text{
            id: artext
            text: "Settings:"
            color: "white"
            font.pointSize: 7
        }
    }


    Component{
        id:settingsDelegate
        Item {
            id: itemItem
            width: list_view1.width
            height: topLayout.height
            property alias color:rectangle.color
            property alias gradient: rectangle.gradient
            Rectangle {
                id: rectangle
                color:"black"
                anchors.fill: parent
                Row{
                    id: topLayout
                    Text { text: name; color:"white";font.pointSize:listfontsize}
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {

                    list_view1.currentIndex = index
                    parseClickedSettings(index);
                }
                onPressed: {
                    itemItem.gradient = selectiongradient;
                }
                onReleased: {
                    itemItem.gradient = fillgradient;
                    itemItem.color = "black";
                }
                onCanceled: {
                    itemItem.gradient = fillgradient;
                    itemItem.color = "black";
                }
            }
        }
    }
    function parseClickedSettings(index)
    {
            console.debug("parseClickedSettings("+index+")")
            if(settingsModel.get(index).ident=="updatedb"){
                window.updateDB();
            }
            else if(settingsModel.get(index).ident=="servers"){
                console.debug("Servers clicked");
                pageStack.push(serverlist);
            }
            else if(settingsModel.get(index).ident=="about"){
                console.debug("about to clicked:"+versionstring);
                aboutdialog.visible=true;
                aboutdialog.version = versionstring;
                aboutdialog.open();
            }
            else if(settingsModel.get(index).ident=="connectto"){
                console.debug("Connect to clicked");
                selectserverdialog.visible=true;
                selectserverdialog.open();
            }
    }

}



