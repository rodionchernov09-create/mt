import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Эмулятор Машины Тьюринга"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Панель алфавитов
        GroupBox {
            title: "Настройка алфавитов"
            Layout.fillWidth: true

            RowLayout {
                spacing: 10

                Column {
                    Label { text: "Алфавит ленты:" }
                    TextField {
                        id: tapeAlphabetInput
                        placeholderText: "Например: 01"
                        width: 200
                    }
                }

                Column {
                    Label { text: "Дополнительные символы:" }
                    TextField {
                        id: extraAlphabetInput
                        placeholderText: "Например: #$%"
                        width: 200
                    }
                }

                Button {
                    id: setAlphabetButton
                    text: "Задать алфавиты"
                    onClicked: {
                        turingMachine.setAlphabet(tapeAlphabetInput.text, extraAlphabetInput.text)
                        statusText.text = "Алфавиты заданы"
                    }
                }
            }
        }

        // Лента
        GroupBox {
            title: "Лента"
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            ScrollView {
                id: tapeScrollView
                anchors.fill: parent
                clip: true

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

                Row {
                    id: tapeRow
                    spacing: 2

                    Repeater {
                        id: tapeRepeater
                        model: turingMachine.tape

                        delegate: Rectangle {
                            width: 60
                            height: 60
                            border.color: "black"
                            border.width: 2
                            color: index === turingMachine.headPosition ? "#90EE90" : "white"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 24
                                font.family: "Courier"
                            }
                        }
                    }
                }
            }
        }

        // Ввод строки
        RowLayout {
            Label { text: "Входная строка:" }
            TextField {
                id: inputStringField
                Layout.fillWidth: true
                placeholderText: "Введите строку из символов алфавита"
            }
            Button {
                id: setStringButton
                text: "Задать строку"
                onClicked: {
                    if (turingMachine.loadInputString(inputStringField.text)) {
                        tapeRepeater.model = turingMachine.tape
                        statusText.text = "Строка загружена"
                    }
                }
            }
        }

        // Таблица программы (упрощённая версия)
        GroupBox {
            title: "Программа машины Тьюринга"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 5

                RowLayout {
                    Button {
                        text: "+ Состояние"
                        onClicked: turingMachine.addState()
                    }
                    Button {
                        text: "- Состояние"
                        onClicked: turingMachine.removeState()
                    }
                    Item { Layout.fillWidth: true }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        Repeater {
                            id: statesRepeater
                            model: turingMachine.states

                            delegate: Rectangle {
                                width: 600
                                height: 30
                                color: "transparent"

                                Row {
                                    Rectangle {
                                        width: 80
                                        height: 30
                                        color: "#e0e0e0"
                                        border.color: "gray"
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData
                                            font.bold: true
                                        }
                                    }

                                    Repeater {
                                        model: turingMachine.alphabet

                                        delegate: Rectangle {
                                            width: 100
                                            height: 30
                                            color: "white"
                                            border.color: "gray"

                                            TextField {
                                                anchors.fill: parent
                                                anchors.margins: 2
                                                text: turingMachine.getTransition(statesRepeater.model[index], modelData)
                                                placeholderText: "символ,R,q1"
                                                font.pixelSize: 11

                                                onEditingFinished: {
                                                    turingMachine.setTransitionString(statesRepeater.model[index], modelData, text)
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
        }

        // Информация и управление
        RowLayout {
            Label { text: "Состояние:" }
            Label { id: currentStateLabel; text: turingMachine.currentState }
            Label { text: "Позиция:" }
            Label { id: headPositionLabel; text: turingMachine.headPosition }
            Item { Layout.fillWidth: true }
            Label { text: "Скорость:" }
            Slider {
                id: speedSlider
                from: 1
                to: 20
                value: 5
                onValueChanged: turingMachine.speed = value
            }
        }

        RowLayout {
            spacing: 10

            Button {
                id: runButton
                text: "Запустить"
                onClicked: turingMachine.start()
            }

            Button {
                id: stepButton
                text: "Шаг"
                onClicked: turingMachine.step()
            }

            Button {
                id: stopButton
                text: "Остановить"
                onClicked: turingMachine.stop()
            }

            Button {
                id: resetButton
                text: "Сброс"
                onClicked: turingMachine.reset()
            }

            Item { Layout.fillWidth: true }

            Label {
                id: statusText
                text: "Готов"
                font.italic: true
            }
        }
    }

    Connections {
        target: turingMachine
        function onTapeChanged() {
            tapeRepeater.model = turingMachine.tape
        }
        function onHeadPositionChanged() {
            headPositionLabel.text = turingMachine.headPosition
        }
        function onStateChanged() {
            currentStateLabel.text = turingMachine.currentState
        }
        function onError(message) {
            statusText.text = "Ошибка: " + message
        }
        function onHalted(reason) {
            statusText.text = "Остановлено: " + reason
            runButton.enabled = true
            stepButton.enabled = true
        }
        function onRunningChanged() {
            runButton.enabled = !turingMachine.isRunning
            stepButton.enabled = !turingMachine.isRunning
        }
        function onStatesChanged() {
            statesRepeater.model = turingMachine.states
        }
    }
}
