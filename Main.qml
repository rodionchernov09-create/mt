import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Turing 1.0

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Эмулятор Машины Тьюринга"

    TuringMachine {
        id: turingMachine
        onError: function(message) {
            errorDialog.messageText = message
            errorDialog.open()
        }
        onHalted: function(reason) {
            statusText.text = "Остановлено: " + reason
            runButton.enabled = true
            stepButton.enabled = true
        }
        onRunningChanged: {
            alphabetInput.enabled = !turingMachine.isRunning
            setAlphabetButton.enabled = !turingMachine.isRunning
            inputStringField.enabled = !turingMachine.isRunning
            setStringButton.enabled = !turingMachine.isRunning
            resetButton.enabled = true
        }
        onNeedScroll: function(direction) {
            if (direction > 0) {
                tapeView.contentX += 100
            } else {
                tapeView.contentX -= 100
            }
        }
    }

    // Диалог ошибок
    MessageDialog {
        id: errorDialog
        title: "Ошибка"
        icon: StandardIcon.Critical
    }

    // Диалог подтверждения сброса алфавита
    Dialog {
        id: resetAlphabetDialog
        title: "Подтверждение"
        standardButtons: Dialog.Yes | Dialog.No
        Label {
            text: "Изменение алфавита приведёт к очистке таблицы программы. Продолжить?"
        }
        onAccepted: {
            applyAlphabet()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Верхняя панель - алфавиты
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
                        if (turingMachine.states.length > 1 ||
                            (tableModel.rowCount > 0 && tableModel.rowCount > 1)) {
                            resetAlphabetDialog.open()
                        } else {
                            applyAlphabet()
                        }
                    }
                }
            }
        }

        // Лента визуализация
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

                            SequentialAnimation on color {
                                id: blinkAnimation
                                running: turingMachine.isRunning && index === turingMachine.headPosition
                                loops: Animation.Infinite
                                ColorAnimation { from: "#90EE90"; to: "#FFFF00"; duration: 300 }
                                ColorAnimation { from: "#FFFF00"; to: "#90EE90"; duration: 300 }
                            }
                        }
                    }
                }
            }
        }

        // Управление строкой
        RowLayout {
            Label { text: "Входная строка:" }
            TextField {
                id: inputStringField
                Layout.fillWidth: true
                placeholderText: "Введите строку из символов алфавита"
                enabled: false
            }
            Button {
                id: setStringButton
                text: "Задать строку"
                enabled: false
                onClicked: {
                    if (turingMachine.loadInputString(inputStringField.text)) {
                        updateTapeDisplay()
                        statusText.text = "Строка загружена"
                    }
                }
            }
        }

        // Таблица программы
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
                        onClicked: {
                            turingMachine.addState()
                            updateTable()
                        }
                    }
                    Button {
                        text: "- Состояние"
                        onClicked: {
                            turingMachine.removeState()
                            updateTable()
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: "Скорость:" }
                    Slider {
                        id: speedSlider
                        from: 1
                        to: 20
                        value: 5
                        onValueChanged: turingMachine.speed = value
                    }
                    Label { text: "Медленнее" }
                    Label { text: "Быстрее" }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    TableView {
                        id: programTable
                        columnSpacing: 1
                        rowSpacing: 1

                        property var states: turingMachine.states
                        property var alphabet: turingMachine.alphabet

                        model: programTableModel

                        Component.onCompleted: {
                            updateTable()
                        }

                        Connections {
                            target: turingMachine
                            function onStatesChanged() { updateTable() }
                            function onAlphabetChanged() { updateTable() }
                        }

                        function updateTable() {
                            programTableModel.clear()

                            // Заголовки столбцов
                            var header = ["Состояние/Символ"]
                            for (var i = 0; i < alphabet.length; i++) {
                                header.push(alphabet[i])
                            }
                            programTableModel.append(header)

                            // Строки для каждого состояния
                            for (var s = 0; s < states.length; s++) {
                                var row = [states[s]]
                                for (var sym = 0; sym < alphabet.length; sym++) {
                                    var transition = turingMachine.getTransition(states[s], alphabet[sym])
                                    row.push(transition || "")
                                }
                                programTableModel.append(row)
                            }
                        }
                    }
                }
            }
        }

        // Кнопки управления
        RowLayout {
            spacing: 10

            Button {
                id: runButton
                text: "Запустить машину"
                enabled: false
                onClicked: {
                    turingMachine.start()
                    runButton.enabled = false
                    stepButton.enabled = false
                    statusText.text = "Выполнение..."
                }
            }

            Button {
                id: stepButton
                text: "Выполнить один шаг"
                enabled: false
                onClicked: {
                    turingMachine.step()
                }
            }

            Button {
                id: stopButton
                text: "Остановить машину"
                onClicked: {
                    turingMachine.stop()
                    runButton.enabled = true
                    stepButton.enabled = true
                    statusText.text = "Остановлено"
                }
            }

            Button {
                id: resetButton
                text: "Сбросить выполнение"
                onClicked: {
                    turingMachine.reset()
                    runButton.enabled = true
                    stepButton.enabled = true
                    statusText.text = "Сброшено"
                    updateTapeDisplay()
                }
            }

            Item { Layout.fillWidth: true }

            Label {
                id: statusText
                text: "Готов к работе"
                font.italic: true
            }
        }
    }

    ListModel {
        id: programTableModel

        function clear() {
            while (count > 0) {
                remove(0)
            }
        }
    }

    function applyAlphabet() {
        turingMachine.setAlphabet(tapeAlphabetInput.text, extraAlphabetInput.text)
        inputStringField.enabled = true
        setStringButton.enabled = true
        runButton.enabled = true
        stepButton.enabled = true
        updateTable()
        statusText.text = "Алфавиты заданы"
    }

    function updateTable() {
        programTable.updateTable()
    }

    function updateTapeDisplay() {
        tapeRepeater.model = turingMachine.tape
    }

    Component.onCompleted: {
        tapeAlphabetInput.text = "01"
        extraAlphabetInput.text = ""
    }
}
