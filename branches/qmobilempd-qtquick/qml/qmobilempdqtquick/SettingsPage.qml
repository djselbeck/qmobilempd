import QtQuick 1.0
import com.nokia.symbian 1.0

Page{
    id: settingspage
    tools:ToolBarLayout {
        id: settingsTools
//            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
            ToolButton { text: "Cancel"; onClicked: pageStack.pop()  }
            ToolButton { text: "Ok"; onClicked: {
//                        netaccess.connectToHost(hostnameInput.text,portInput.text);
                    window.setHostname(hostnameInput.text);
                    window.setPassword(passwordInput.text);
                    window.setPort(portInput.text);
                    window.connectToServer();
                    pageStack.pop();
                } }
    }
    Column{
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        Text{id: hostnameTextLabel; text: qsTr("Hostname:"); color:"white"}
        TextField{id: hostnameInput;  text: "192.168.2.51"; anchors { left: parent.left; right: parent.right}}
        Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
        TextField{id: portInput;text: "6600"; anchors { left: parent.left; right: parent.right}}
        Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}}
        TextField{id: passwordInput; text:"nudelsuppe"; anchors { left: parent.left; right: parent.right}}
    }

}
