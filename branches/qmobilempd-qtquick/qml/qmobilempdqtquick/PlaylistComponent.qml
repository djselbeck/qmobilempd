import QtQuick 1.0

Rectangle {
    width: 300
    height: 300
    color: "#000000"
    property alias model: listview_1.model

    ListView {
        id: listview_1
        anchors.fill: parent
        delegate: Text { text: name; color:"white"}
    }
}
