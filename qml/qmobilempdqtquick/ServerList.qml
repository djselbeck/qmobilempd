import QtQuick 1.1
import com.nokia.symbian 1.1


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
                window.newProfile();
            }
        }
    }
    ListView{
        id: settings_list_view
        delegate: ListItem{
            ListItemText { text: name; role:"Title"
                anchors {verticalCenter: parent.verticalCenter}

            }
            onClicked: {
                settings_list_view.currentIndex = index;
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),{hostname:hostname,port:port,profilename:name,password:password,index:index,autoconnect:autoconnect});
            }
            onPressAndHold: {
                settings_list_view.currentIndex = index;
                pageStack.push(Qt.resolvedUrl("SettingsPage.qml"),{hostname:hostname,port:port,profilename:name,password:password,index:index,autoconnect:autoconnect});
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true

    }
    ListHeading {
        id:headingrect

        ListItemText{
            text: "Server list:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
            horizontalAlignment: Text.AlignLeft
        }
    }




}
