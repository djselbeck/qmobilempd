import QtQuick 1.0
import com.nokia.symbian 1.0


    Page{
        id: filespage
        tools: ToolBarLayout {
            id: filesTools
            ToolButton { iconSource: "toolbar-back"; onClicked: pageStack.pop() }
    //            ToolButton { text: "next page"; onClicked: pageStack.push(secondPage) }
        }


    }
