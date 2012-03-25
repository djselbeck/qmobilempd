import QtQuick 1.1
import com.nokia.symbian 1.1

Page{
    id: settings
    property int currentindex:-1;

    ListModel {
        id: settingsModel
        ListElement { name: "Update database"; ident:"updatedb"; }
        ListElement { name: "Outputs"; ident:"outputs"; }
        ListElement { name: "Servers"; ident:"servers"}
        ListElement { name: "Connect"; ident:"connectto"}
        ListElement { name: "About"; ident:"about"}
    }



    tools: settingstools
    ToolBarLayout { id:settingstools
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}

    }
    ListView{
        id: settings_list_view
        delegate: ListItem{
            id:itemDelegate
            ListItemText {text:name; role:"Title";
                anchors {verticalCenter: parent.verticalCenter}
            }
            onClicked: {
                settings_list_view.currentIndex = index
                parseClickedSettings(index);
            }
            onPressAndHold: {
                settings_list_view.currentIndex = index
                parseClickedSettings(index);
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true
        model: settingsModel
    }


    ListHeading {
        id:headingrect

        ListItemText{
            text: "Settings:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
//            horizontalAlignment: Text.AlignLeft
        }
    }
    function parseClickedSettings(index)
    {
        if(settingsModel.get(index).ident=="updatedb"){
            window.updateDB();
        }
        else if(settingsModel.get(index).ident=="servers"){
            pageStack.push(serverlist);
        }
        else if(settingsModel.get(index).ident=="about"){
            aboutdialog.visible=true;
            aboutdialog.version = versionstring;
            aboutdialog.open();
        }
        else if(settingsModel.get(index).ident=="connectto"){
            selectserverdialog.visible=true;
            selectserverdialog.open();
        }
        else if(settingsModel.get(index).ident=="outputs"){
            window.requestOutputs();
        }
    }

}



