import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// Удалите import QtQuick.Dialogs
// Удалите import Turing 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Эмулятор Машины Тьюринга"

    // Используем turingMachine из контекста (не создаём новый)

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

        // Информация
        RowLayout {
            Label { text: "Состояние:" }
            Label { id: currentStateLabel; text: turingMachine.currentState }
            Label { text: "Позиция:" }
            Label { id: headPositionLabel; text: turingMachine.headPosition }
            Item { Layout.fillWidth: true }
            Label {
                id: speedLabel
                text: "Скорость: " + turingMachine.speed
            }
            Slider {
                id: speedSlider
                from: 1
                to: 20
                value: 5
                onValueChanged: turingMachine.speed = value
            }
        }

        // Кнопки управления
        RowLayout {
            spacing: 10

            Button {
                id: runButton
                text: "Запустить"
                onClicked: {
                    turingMachine.start()
                    statusText.text = "Выполнение..."
                }
            }

            Button {
                id: stepButton
                text: "Шаг"
                onClicked: {
                    turingMachine.step()
                }
            }

            Button {
                id: stopButton
                text: "Остановить"
                onClicked: {
                    turingMachine.stop()
                    statusText.text = "Остановлено"
                }
            }

            Button {
                id: resetButton
                text: "Сброс"
                onClicked: {
                    turingMachine.reset()
                    statusText.text = "Сброшено"
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                id: statusText
                text: "Готов"
                font.italic: true
            }
        }
    }

    // Обновление отображения
    Connections {
        target: turingMachine
        function onTapeChanged() {
            tapeRepeater.model = turingMachine.tape
        }
        function onHeadPositionChanged() {
            headPositionLabel.text = turingMachine.headPosition
            // Прокрутка
            if (turingMachine.headPosition < 2) {
                tapeScrollView.contentX = 0
            } else if (turingMachine.headPosition > tapeRepeater.count - 3) {
                tapeScrollView.contentX = (tapeRepeater.count - 5) * 62
            } else {
                tapeScrollView.contentX = (turingMachine.headPosition - 2) * 62
            }
        }
        function onStateChanged() {
            currentStateLabel.text = turingMachine.currentState
        }
        function onError(message) {
            statusText.text = "Ошибка: " + message
        }
        function onHalted(reason) {
            statusText.text = "Остановлено: " + reason
        }
    }
}
