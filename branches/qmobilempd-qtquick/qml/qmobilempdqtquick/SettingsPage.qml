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
        id: settingsflick
        property int lasty;
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom:splitViewInput.top}
        contentHeight: settingscolumn.height
        Column{
            id:settingscolumn
            spacing: 10
            anchors {left:parent.left;right:parent.right}
            Text{id: nameTextLabel; text: qsTr("Profile Name:"); color:"white";visible:(nameInput.visible)}
            TextField{id: nameInput;  text: "enter name"; anchors { left: parent.left; right: parent.right}
                visible:(activeFocus||!inputContext.visible)
                inputMethodHints: Qt.ImhNoPredictiveText
            }
            Text{id: hostnameTextLabel; text: qsTr("Hostname:"); color:"white";visible:(hostnameInput.visible)}
            TextField{id: hostnameInput;  text: ""; anchors { left: parent.left; right: parent.right}
                visible:(activeFocus||!inputContext.visible)
                inputMethodHints: Qt.ImhNoPredictiveText}
            Text{id: portLabel; text: qsTr("Port:"); color:"white" ; anchors { left: parent.left;  right: parent.right}
                visible:(portInput.visible)}
            TextField{id: portInput;validator: portvalidator;text: "6600"; anchors { left: parent.left; right: parent.right}
                visible:(activeFocus||!inputContext.visible)
                inputMethodHints: Qt.ImhNoPredictiveText}
            Text{id: passwordLabel; text: qsTr("Password:"); color:"white" ; anchors { left: parent.left;  right: parent.right}
                visible:(passwordInput.visible)}
            TextField{id: passwordInput; text:""; echoMode: TextInput.PasswordEchoOnEdit ;anchors { left: parent.left; right: parent.right}
                visible:(activeFocus||!inputContext.visible)
                inputMethodHints: Qt.ImhNoPredictiveText
            }


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
                visible:(activeFocus||!inputContext.visible)
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

    Item {
        id: splitViewInput

        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }

        Behavior on height { PropertyAnimation { duration: 200 } }

        states: [
            State {
                name: "Visible"; when: inputContext.visible
                PropertyChanges { target: splitViewInput; height: inputContext.height }
                PropertyChanges {
                    target: settingsflick
                    interactive:false
                }

            },

            State {
                name: "Hidden"; when: !inputContext.visible
                PropertyChanges { target: splitViewInput; height: window.pageStack.toolbar }
                PropertyChanges {
                    target: settingsflick
                    interactive:true
                }
            }
        ]

    }
}
