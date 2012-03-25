import QtQuick 1.1
import com.nokia.symbian 1.1


Page{
    id: outputs
    property alias listmodel:outputs_list_view.model
    property int currentindex:-1;


    tools:ToolBarLayout {
        ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
        ToolButton{ iconSource: "toolbar-home";onClicked: {
                pageStack.clear();
                pageStack.push(mainPage);
            }}

    }
    ListView{
        id: outputs_list_view
        delegate: ListItem{
            CheckBox{
             checked: outputenabled;
             text: outputname;
             anchors {verticalCenter: parent.verticalCenter}
            }

            onClicked: {
                outputs_list_view.currentIndex = index;
                if(outputenabled){
                    window.disableOutput(id);
                    outputenabled = false;
                }
                else {
                    window.enableOutput(id);
                    outputenabled = true;
                }
            }
            onPressAndHold: {
                outputs_list_view.currentIndex = index;
            }
        }
        anchors { left: parent.left; right: parent.right; top: headingrect.bottom; bottom: parent.bottom }
        clip: true

    }
    ListHeading {
        id:headingrect

        ListItemText{
            text: "Output list:"
            role: "Heading"
            anchors.fill: headingrect.paddingItem
//            horizontalAlignment: Text.AlignLeft
        }
    }




}
