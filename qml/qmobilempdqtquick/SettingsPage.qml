import QtQuick 1.0
import com.nokia.symbian 1.0

Page{
    id: settingspage
    property alias hostname:  hostnameInput.text;
    property alias password: passwordInput.text;
    property alias port: portInput.text;
    property alias profilename : nameInput.text;
    property int index;
    tools:ToolBarLayout {
        id: settingsTools
//            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        //ToolButton { iconSource: "toolbar-cancel"; onClicked: pageStack.pop()  }
            ToolButton { iconSource: "toolbar-back" ;onClicked: {
//                        netaccess.connectToHost(hostnameInput.text,portInput.text);
//                    window.setHostname(hostnameInput.text);
//                    window.setPassword(passwordInput.text);
//                    window.setPort(portInput.text);
//                    window.connectToServer();
                    console.debug("Change settings profile index:" +index);
                    window.changeProfile([index,profilename,hostname,password,port]);
                    pageStack.pop();
                } }
            ToolButton {text: "Connect"; onClicked: {
                    window.changeProfile([index,profilename,hostname,password,port]);
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
    Column{
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        Text{id: nameTextLabel; text: qsTr("Profile Name:"); color:"white"}
        TextField{id: nameInput;  text: "enter name"; anchors { left: parent.left; right: parent.right}}
        Text{id: hostnameTextLabel; text: qsTr("Hostname:"); color:"white"}
        TextField{id: hostnameInput;  text: "192.168.2.51"; anchors { left: parent.left; right: parent.right}}
        Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
        TextField{id: portInput;validator: portvalidator;text: "6600"; anchors { left: parent.left; right: parent.right}}
        Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
        TextField{id: passwordInput; text:""; echoMode: TextInput.PasswordEchoOnEdit ;anchors { left: parent.left; right: parent.right}}
    }

    IntValidator{
        id:portvalidator
        top: 65536
        bottom: 1
    }

}
