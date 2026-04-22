import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "Эмулятор Машины Тьюринга"

    property var currentStates: []
    property var currentAlphabet: []
    property var activeCellInput: null
    property string statusMessage: "Готов"

    property var tapeModel: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Панель алфавитов
        GroupBox {
            title: "Настройка алфавитов"
            Layout.fillWidth: true

            RowLayout {
                Column {
                    Label { text: "Алфавит ленты:" }
                    TextField {
                        id: tapeAlphabetInput
                        placeholderText: "Например: abΛ"
                        text: "abΛ"
                        width: 250
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
                    text: "Задать алфавиты"
                    onClicked: {
                        turingMachine.setAlphabet(tapeAlphabetInput.text, extraAlphabetInput.text)
                        statusMessage = "Алфавиты заданы"
                        updateTableData()
                    }
                }
            }
        }

        // Лента
        GroupBox {
            title: "Лента"
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            Rectangle {
                anchors.fill: parent
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    spacing: 5

                    Rectangle {
                        width: 30
                        height: 60
                        color: "#d0d0d0"
                        radius: 5
                        Text { anchors.centerIn: parent; text: "◀"; font.pixelSize: 20 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: tapeListView.contentX -= 100
                        }
                    }

                    ListView {
                        id: tapeListView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        orientation: ListView.Horizontal
                        spacing: 2
                        clip: true

                        model: tapeModel

                        delegate: Rectangle {
                            width: 60
                            height: 60
                            border.color: "black"
                            border.width: 2
                            color: index === turingMachine.headPosition ? "#ffffcc" : "white"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 24
                                font.family: "Courier"
                            }
                        }
                    }

                    Rectangle {
                        width: 30
                        height: 60
                        color: "#d0d0d0"
                        radius: 5
                        Text { anchors.centerIn: parent; text: "▶"; font.pixelSize: 20 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: tapeListView.contentX += 100
                        }
                    }
                }

                // Каретка СНИЗУ ленты, острым концом ВВЕРХ
                Canvas {
                    id: headCanvas
                    width: 30
                    height: 25

                    x: {
                        if (!turingMachine) return 0
                        var headPos = turingMachine.headPosition
                        var scrollOffset = tapeListView.contentX
                        var itemX = headPos * 62 + 15
                        return itemX - scrollOffset + 35
                    }
                    y: 65  // Смещаем вниз, под ленту

                    Behavior on x {
                        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "red"
                        ctx.beginPath()
                        ctx.moveTo(width / 2, 0)   // вершина вверху (указывает на ячейку)
                        ctx.lineTo(0, height)       // левый нижний
                        ctx.lineTo(width, height)   // правый нижний
                        ctx.closePath()
                        ctx.fill()
                    }

                    Connections {
                        target: turingMachine
                        function onHeadPositionChanged() {
                            headCanvas.update()
                            var headPos = turingMachine.headPosition
                            var viewWidth = tapeListView.width
                            var currentScroll = tapeListView.contentX
                            var headScreenPos = headPos * 62 + 15 - currentScroll

                            if (headScreenPos > viewWidth - 100) {
                                tapeListView.contentX = headPos * 62 + 15 - viewWidth + 80
                            } else if (headScreenPos < 100) {
                                tapeListView.contentX = headPos * 62 + 15 - 80
                            }
                            if (tapeListView.contentX < 0) tapeListView.contentX = 0
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
                placeholderText: "Введите строку из символов алфавита"
                Layout.fillWidth: true
                text: "ab"
            }
            Button {
                text: "Задать строку"
                onClicked: {
                    if (turingMachine && turingMachine.loadInputString(inputStringField.text)) {
                        statusMessage = "Строка загружена"
                        updateTapeModel()
                        tapeListView.contentX = 0
                        headCanvas.update()
                    }
                }
            }
        }

        // Таблица программы
        GroupBox {
            title: "Программа"
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent

                RowLayout {
                    Button { text: "+ Состояние"; onClicked: { if(turingMachine) turingMachine.addState(); updateTableData() } }
                    Button { text: "- Состояние"; onClicked: { if(turingMachine) turingMachine.removeState(); updateTableData() } }
                    Button { text: "+ Символ"; onClicked: { if(turingMachine && symbolAdd.text) turingMachine.addSymbol(symbolAdd.text); updateTableData() } }
                    TextField { id: symbolAdd; width: 50; placeholderText: "символ" }
                    Button { text: "- Символ"; onClicked: { if(turingMachine && symbolAdd.text) turingMachine.removeSymbol(symbolAdd.text); updateTableData() } }
                    Button { text: "H (halt)"; onClicked: { if(turingMachine) turingMachine.addHaltState(); updateTableData() } }

                    Item { Layout.fillWidth: true }

                    Label { text: "Быстрый ввод:" }
                    Button { text: "Λ"; onClicked: { if(activeCellInput) activeCellInput.text += "Λ" } }
                    Button { text: "R"; onClicked: { if(activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,R,q1"; else activeCellInput.text = t.replace(/,.,/, ",R,") } } }
                    Button { text: "L"; onClicked: { if(activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,L,q1"; else activeCellInput.text = t.replace(/,.,/, ",L,") } } }
                    Button { text: "S"; onClicked: { if(activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,S,q1"; else activeCellInput.text = t.replace(/,.,/, ",S,") } } }
                }

                // Один ScrollView с двумя скроллбарами
                ScrollView {
                    id: tableScrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                    // Просто Column без лишних вложений
                    Column {
                        id: tableColumn

                        // Заголовок
                        Row {
                            spacing: 0

                            Rectangle { width: 80; height: 35; color: "#d0d0d0"; border.color: "gray"
                                Text { text: "Состояние"; anchors.centerIn: parent; font.bold: true }
                            }
                            Repeater {
                                id: headerRepeater
                                model: currentAlphabet
                                Rectangle { width: 100; height: 35; color: "#d0d0d0"; border.color: "gray"
                                    Text { text: modelData; anchors.centerIn: parent; font.bold: true }
                                }
                            }
                        }

                        // Строки
                        Repeater {
                            id: rowsRepeater
                            model: currentStates

                            Row {
                                spacing: 0
                                property string stateName: modelData

                                Rectangle { width: 80; height: 40; color: "#e0e0e0"; border.color: "gray"
                                    Text { text: stateName; anchors.centerIn: parent; font.bold: true }
                                }
                                Repeater {
                                    model: currentAlphabet
                                    Rectangle { width: 100; height: 40; color: "white"; border.color: "gray"
                                        TextField {
                                            anchors.fill: parent
                                            anchors.margins: 2
                                            text: turingMachine ? turingMachine.getTransition(stateName, modelData) : ""
                                            placeholderText: "a,R,q0"
                                            font.pixelSize: 11
                                            onEditingFinished: {
                                                if (turingMachine) {
                                                    turingMachine.setTransitionString(stateName, modelData, text)
                                                    statusMessage = "✓ " + stateName + "," + modelData + " → " + text
                                                }
                                            }
                                            onActiveFocusChanged: {
                                                if (activeFocus) activeCellInput = this
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
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#f0f0f0"
            border.color: "gray"
            radius: 5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8

                RowLayout {
                    Button { text: "▶ Запуск"; onClicked: { if(turingMachine) turingMachine.start() } }
                    Button { text: "⏸ Шаг"; onClicked: { if(turingMachine) turingMachine.step() } }
                    Button { text: "⏹ Стоп"; onClicked: { if(turingMachine) turingMachine.stop() } }
                    Button { text: "⟳ Сброс"; onClicked: {
                        if(turingMachine) {
                            turingMachine.reset()
                            updateTapeModel()
                            tapeListView.contentX = 0
                            headCanvas.update()
                            statusMessage = "Выполнение сброшено"
                        }
                    } }

                    Rectangle { width: 20; color: "transparent" }

                    Text { text: "Состояние: " + (turingMachine ? turingMachine.currentState : ""); font.bold: true }
                    Text { text: "Позиция: " + (turingMachine ? turingMachine.headPosition : "") }

                    Item { Layout.fillWidth: true }

                    Text { text: "Скорость:" }
                    Slider {
                        id: speedSlider
                        from: 1
                        to: 20
                        value: 5
                        width: 120
                        onValueChanged: { if (turingMachine) turingMachine.speed = value }
                    }
                    Text { text: speedSlider.value.toFixed(0); width: 25 }
                }

                Text {
                    id: statusTextDisplay
                    text: statusMessage
                    font.italic: true
                    color: "green"
                }
            }
        }
    }

    function updateTapeModel() {
        if (!turingMachine) return
        var newModel = []
        for (var i = 0; i < turingMachine.tape.length; i++) {
            newModel.push(turingMachine.tape[i])
        }
        tapeModel = newModel
    }

    function updateTableData() {
        if (!turingMachine) return
        currentStates = turingMachine.states
        currentAlphabet = turingMachine.alphabet
        console.log("States:", currentStates.length, "Alphabet:", currentAlphabet.length)
    }

    Connections {
        target: turingMachine
        function onStatesChanged() { updateTableData() }
        function onAlphabetChanged() { updateTableData() }
        function onTapeChanged() {
            updateTapeModel()
            headCanvas.update()
        }
        function onError(message) { statusMessage = "Ошибка: " + message; statusTextDisplay.color = "red" }
        function onHalted(reason) { statusMessage = "Остановлено: " + reason; statusTextDisplay.color = "orange" }
        function onRunningChanged() {
            if (turingMachine.isRunning) {
                statusMessage = "Выполнение..."
                statusTextDisplay.color = "blue"
            } else {
                statusMessage = "Готов"
                statusTextDisplay.color = "green"
            }
        }
    }

    Component.onCompleted: {
        if (turingMachine) {
            turingMachine.setAlphabet("abΛ", "")
            updateTableData()
            updateTapeModel()
            statusMessage = "Готов"
        }
    }
}
