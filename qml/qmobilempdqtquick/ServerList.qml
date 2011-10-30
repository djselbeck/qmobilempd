import QtQuick 1.0
import com.nokia.symbian 1.0


Page{
    id: settings
    property alias listmodel:settings_list_view.model
    property int currentindex:-1;


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
        spacing: 2
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
            height: topLayout.height+liststretch
            property alias color:rectangle.color
            property alias gradient: rectangle.gradient
            Rectangle {
                id: rectangle
                color:Qt.rgba(0.07, 0.07, 0.07, 1)
                anchors.fill: parent
                Row{
                    id: topLayout
                    anchors {verticalCenter: parent.verticalCenter;left:parent.left; right: parent.right}
                    Text { text: name; color:"white";font.pointSize:12
                    }
                }
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
                onPressed: {
                    itemItem.gradient = selectiongradient;                }
                onReleased: {
                    itemItem.gradient = fillgradient;
                    itemItem.color = Qt.rgba(0.07, 0.07, 0.07, 1);
                }
                onCanceled: {
                    itemItem.gradient = fillgradient;
                    itemItem.color =Qt.rgba(0.07, 0.07, 0.07, 1);
                }
            }
        }
    }

}
