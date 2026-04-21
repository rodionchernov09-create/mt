import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1000
    height: 700
    title: "Эмулятор Машины Тьюринга"

    property var currentStates: []
    property var currentAlphabet: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Панель алфавитов
        GroupBox {
            title: "Настройка алфавитов"
            Layout.fillWidth: true

            RowLayout {
                TextField {
                    id: tapeAlphabet
                    placeholderText: "Алфавит ленты (01)"
                    text: "01"
                    Layout.fillWidth: true
                }
                TextField {
                    id: extraAlphabet
                    placeholderText: "Доп. символы"
                    Layout.fillWidth: true
                }
                Button {
                    text: "Задать"
                    onClicked: {
                        turingMachine.setAlphabet(tapeAlphabet.text, extraAlphabet.text)
                    }
                }
            }
        }

        // Лента
        GroupBox {
            title: "Лента"
            Layout.fillWidth: true
            Layout.preferredHeight: 100

            ScrollView {
                anchors.fill: parent
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

                Row {
                    spacing: 2
                    Repeater {
                        id: tapeRepeater
                        model: turingMachine ? turingMachine.tape : []
                        delegate: Rectangle {
                            width: 50
                            height: 50
                            border.color: "black"
                            color: (turingMachine && index === turingMachine.headPosition) ? "lightgreen" : "white"
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 20
                            }
                        }
                    }
                }
            }
        }

        // Ввод строки
        RowLayout {
            TextField {
                id: inputString
                placeholderText: "Входная строка"
                Layout.fillWidth: true
            }
            Button {
                text: "Задать строку"
                onClicked: {
                    if (turingMachine) turingMachine.loadInputString(inputString.text)
                }
            }
        }

        // Таблица программы
        GroupBox {
            title: "Программа"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                RowLayout {
                    Button { text: "+ Состояние"; onClicked: { if(turingMachine) turingMachine.addState() } }
                    Button { text: "- Состояние"; onClicked: { if(turingMachine) turingMachine.removeState() } }
                    Button { text: "+ Символ"; onClicked: { if(turingMachine && symbolInput.text) turingMachine.addSymbol(symbolInput.text) } }
                    Button { text: "- Символ"; onClicked: { if(turingMachine && symbolInput.text) turingMachine.removeSymbol(symbolInput.text) } }
                    TextField { id: symbolInput; placeholderText: "Символ"; width: 60 }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        id: tableContainer

                        // Заголовок
                        Row {
                            Rectangle { width: 80; height: 30; color: "#d0d0d0"; border.color: "gray"
                                Text { text: "Состояние"; anchors.centerIn: parent; font.bold: true }
                            }
                            Repeater {
                                id: headerRepeater
                                model: currentAlphabet
                                Rectangle { width: 100; height: 30; color: "#d0d0d0"; border.color: "gray"
                                    Text { text: modelData; anchors.centerIn: parent; font.bold: true }
                                }
                            }
                        }

                        // Строки состояний
                        Repeater {
                            id: rowsRepeater
                            model: currentStates

                            Row {
                                Rectangle { width: 80; height: 35; color: "#e0e0e0"; border.color: "gray"
                                    Text { text: modelData; anchors.centerIn: parent; font.bold: true }
                                }
                                Repeater {
                                    id: cellsRepeater
                                    model: currentAlphabet
                                    Rectangle { width: 100; height: 35; color: "white"; border.color: "gray"
                                        TextField {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            text: {
                                                if (!turingMachine) return ""
                                                return turingMachine.getTransition(rowsRepeater.model[index], modelData)
                                            }
                                            placeholderText: "1,R,q1"
                                            font.pixelSize: 11
                                            onEditingFinished: {
                                                if (!turingMachine) return
                                                turingMachine.setTransitionString(rowsRepeater.model[index], modelData, text)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Управление
        RowLayout {
            Button { text: "Запуск"; onClicked: { if(turingMachine) turingMachine.start() } }
            Button { text: "Шаг"; onClicked: { if(turingMachine) turingMachine.step() } }
            Button { text: "Стоп"; onClicked: { if(turingMachine) turingMachine.stop() } }
            Button { text: "Сброс"; onClicked: { if(turingMachine) turingMachine.reset() } }
            Text { text: "Состояние: " + (turingMachine ? turingMachine.currentState : "") }
            Text { text: "Позиция: " + (turingMachine ? turingMachine.headPosition : "") }
        }
    }

    function updateTable() {
        if (!turingMachine) return
        currentStates = turingMachine.states
        currentAlphabet = turingMachine.alphabet
        console.log("Table updated:", JSON.stringify(currentStates), JSON.stringify(currentAlphabet))
    }

    Connections {
        target: turingMachine
        function onStatesChanged() { updateTable() }
        function onAlphabetChanged() { updateTable() }
        function onTapeChanged() {
            tapeRepeater.model = turingMachine.tape
        }
    }

    Component.onCompleted: {
        if (turingMachine) {
            turingMachine.setAlphabet("01", "")
            updateTable()
        }
    }
}
Button {
    text: "Λ"
    font.pixelSize: 16
    ToolTip.text: "Вставить пустой символ"
    ToolTip.visible: hovered
    onClicked: {
        // Вставить в активное поле ввода
        if (tapeAlphabetInput.activeFocus) {
            tapeAlphabetInput.text += "Λ"
        } else if (extraAlphabetInput.activeFocus) {
            extraAlphabetInput.text += "Λ"
        } else if (symbolInput.activeFocus) {
            symbolInput.text += "Λ"
        }
    }
}
