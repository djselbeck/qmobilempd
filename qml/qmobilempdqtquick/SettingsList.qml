import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
    id: settings
    property alias listmodel:settings_list_view.model
    property int currentindex:-1;
    Component.onCompleted: {
        console.debug("Playlist completed");
    }

    onStatusChanged: {
        console.debug("Playlist status changed: "+status);
        if(status==PageStatus.Activating)
        {
            console.debug("Playlist activating");

        }
    }
    Component.onDestruction: {
        console.debug("Playlist destroyed");
    }

    tools:ToolBarLayout {
    ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
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
    }
    Rectangle {
        id:headingrect
        anchors {left:parent.left;right:parent.right;}
        height: artext.height
        color: Qt.rgba(0.07, 0.07, 0.07, 1)
        Text{
            id: artext
            text: "Server list:"
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
            Row{
                id: topLayout
                Text { text: name; color:"white";font.pointSize:listfontsize}
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    var component = Qt.createComponent("SettingsPage.qml");
                    var object = component.createObject(window);
                    object.hostname = hostname;
                    object.port = port;
                    object.profilename = name;
                    object.password = password;
                    settings_list_view.currentIndex = index;
                    object.index = settings_list_view.currentIndex;
                    console.debug("Loaded settings index "+index);
                    pageStack.push(object);
                }
            }
        }
    }

}
