import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    id: settingspage
    property alias hostname:  hostnameInput.text;
    property alias password: passwordInput.text;
    property alias port: portInput.text;
    property alias profilename : nameInput.text;
    property alias autoconnect: autoconnectswitch.checked;
    property int index;
    tools:ToolBarLayout {
        id: settingsTools
            ToolButton { iconSource: "toolbar-back" ;onClicked: {
                    console.debug("Change settings profile index:" +index);
                    window.changeProfile([index,profilename,hostname,password,port,autoconnect?1:0]);
                    pageStack.pop();
                }
            }
            ToolButton {text: "Connect"; onClicked: {
                    window.changeProfile([index,profilename,hostname,password,port,autoconnect?1:0]);
                    window.connectProfile(index);
                    pageStack.clear();
                    pageStack.push(mainPage);
                }
            }
            ToolButton {iconSource: "toolbar-delete"; onClicked: {
                    console.debug("Delete profile index "+index)
                    window.deleteProfile(index);
                    pageStack.pop();
                }
            }
    }
    Rectangle {
        id:headingrect
        anchors {left:parent.left;right:parent.right;}
        height: artext.height
        color: Qt.rgba(0.07, 0.07, 0.07, 1)
        Text{
            id: artext
            text: "Server settings:"
            color: "white"
            font.pointSize: 7
        }
    }
    Flickable {
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        contentHeight: settingscolumn.height
        Column{
            id:settingscolumn
            spacing: 10
            anchors {left:parent.left;right:parent.right}
            Text{id: nameTextLabel; text: qsTr("Profile Name:"); color:"white"}
            TextField{id: nameInput;  text: "enter name"; anchors { left: parent.left; right: parent.right}}
            Text{id: hostnameTextLabel; text: qsTr("Hostname:"); color:"white"}
            TextField{id: hostnameInput;  text: ""; anchors { left: parent.left; right: parent.right}}
            Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: portInput;validator: portvalidator;text: "6600"; anchors { left: parent.left; right: parent.right}}
            Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
            TextField{id: passwordInput; text:""; echoMode: TextInput.PasswordEchoOnEdit ;anchors { left: parent.left; right: parent.right}}
            Row{
                id:acswitchrow
                spacing: 10
                Switch{
                    id:autoconnectswitch

                }
                Text{id: defaultLabel
                    text: autoconnectswitch.checked ? "Auto-connect": "No auto-connect"
                    color:"white";
                    height: autoconnectswitch.height
                    verticalAlignment: Text.AlignVCenter
                }
            }
            clip:true
        }
         clip: true
    }

    IntValidator{
        id:portvalidator
        top: 65536
        bottom: 1
    }
}
