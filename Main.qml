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
    property int lightIndex: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // ---------------- Панель алфавитов ----------------
        GroupBox {
            title: "Настройка алфавитов"
            Layout.fillWidth: true
            enabled: turingMachine ? !turingMachine.isRunning : true
            RowLayout {
                Column {
                    Label { text: "Алфавит ленты:" }
                    TextField { id: tapeAlphabetInput; placeholderText: "Например: abΛ"; text: "abΛ"; width: 250 }
                }
                Column {
                    Label { text: "Дополнительные символы:" }
                    TextField { id: extraAlphabetInput; placeholderText: "Например: #$%"; width: 200 }
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

        // ---------------- Лента ----------------
        GroupBox {
            id: tapeGroup
            title: "Лента"
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            Rectangle {
                anchors.fill: parent
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    spacing: 5

                    // Кнопка прокрутки влево (мгновенная)
                    Rectangle {
                        width: 30; height: 60; color: "#d0d0d0"; radius: 5
                        Text { anchors.centerIn: parent; text: "◀"; font.pixelSize: 20 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                tapeListView.contentX = Math.max(0, tapeListView.contentX - 100)
                                headCanvas.updatePosition()
                            }
                        }
                    }

                    ListView {
                        id: tapeListView
                        Layout.fillWidth: true; Layout.fillHeight: true
                        orientation: ListView.Horizontal
                        spacing: 2
                        clip: true
                        model: tapeModel

                        delegate: Rectangle {
                            width: 60; height: 60
                            border.color: "black"; border.width: 2
                            color: index === lightIndex ? "#ffffcc" : "white"
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 24; font.family: "Courier"
                            }
                        }
                    }

                    // Кнопка прокрутки вправо (мгновенная)
                    Rectangle {
                        width: 30; height: 60; color: "#d0d0d0"; radius: 5
                        Text { anchors.centerIn: parent; text: "▶"; font.pixelSize: 20 }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var maxX = tapeListView.contentWidth - tapeListView.width
                                tapeListView.contentX = Math.min(maxX, tapeListView.contentX + 100)
                                headCanvas.updatePosition()
                            }
                        }
                    }
                }

                // ========== КАНВАС (каретка) ==========
                Canvas {
                    id: headCanvas
                    width: 30
                    height: 25
                    property real animatedX: 0
                    x: animatedX
                    property int animDuration: 200
                    Behavior on animatedX { NumberAnimation { duration: headCanvas.animDuration; easing.type: Easing.InOutQuad } }

                    y: 65

                    readonly property int cellFullWidth: 62   // 60 + spacing 2

                    // Вычисление позиции каретки (точный центр)
                    function computeHeadX(headPos, contentX) {
                        var cellLeft = headPos * cellFullWidth - contentX
                        var cellCenter = cellLeft + 30   // половина ячейки (60/2)
                        var targetX = cellCenter - width/2   // чтобы центр каретки совпал с центром ячейки
                        // Ручная поправка: сдвигаем каретку вправо (подберите значение: 2, 3, 4...)
                        targetX += 35   // ← добавьте эту строку, если каретка левее; попробуйте 2, 3, 4
                        // Ограничения
                        var minX = 0
                        var maxX = tapeListView.width - width
                        if (maxX < 0) maxX = 0
                        return Math.max(minX, Math.min(targetX, maxX))
                    }

                    function updatePosition() {
                        if (!turingMachine) return
                        var newX = computeHeadX(turingMachine.headPosition, tapeListView.contentX)
                        animatedX = newX
                        requestPaint()
                    }

                    // Мгновенное центрирование ленты (без анимации)
                    function centerOnHead() {
                        if (!turingMachine) return
                        var headPos = turingMachine.headPosition
                        var desiredCenter = headPos * cellFullWidth + 30 - tapeListView.width / 2
                        desiredCenter = Math.max(0, Math.min(desiredCenter, tapeListView.contentWidth - tapeListView.width))
                        tapeListView.contentX = desiredCenter
                        updatePosition()
                    }

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "red"
                        ctx.beginPath()
                        ctx.moveTo(width/2, 0)      // остриё ВВЕРХ
                        ctx.lineTo(0, height)
                        ctx.lineTo(width, height)
                        ctx.fill()
                    }

                    Component.onCompleted: {
                        updatePosition()
                    }
                }

                // Обработка сигналов
                Connections {
                    target: turingMachine
                    function onHeadPositionChanged() {
                        headCanvas.centerOnHead()
                        lightIndex = turingMachine.headPosition
                        tapeListView.forceLayout()
                    }
                    function onTapeChanged() {
                        updateTapeModel()
                        headCanvas.centerOnHead()
                    }
                    function onReset() {
                        updateTapeModel()
                        tapeListView.contentX = 0
                        headCanvas.centerOnHead()
                    }
                }

                Connections {
                    target: tapeListView
                    function onContentXChanged() {
                        headCanvas.updatePosition()
                    }
                }
            }
        }

        // ---------------- Ввод строки ----------------
        RowLayout {
            enabled: turingMachine ? !turingMachine.isRunning : true
            Label { text: "Входная строка:" }
            TextField {
                id: inputStringField
                placeholderText: "Введите строку из символов алфавита"
                Layout.fillWidth: true
                text: "ab"
                onActiveFocusChanged: { if (activeFocus) activeCellInput = this }
            }
            Button {
                text: "Задать строку"
                onClicked: {
                    if (turingMachine && turingMachine.loadInputString(inputStringField.text)) {
                        statusMessage = "Строка загружена"
                        updateTapeModel()
                        tapeListView.contentX = 0
                        lightIndex = turingMachine.headPosition
                        headCanvas.centerOnHead()
                    }
                }
            }
        }

        // ---------------- Таблица программы ----------------
        GroupBox {
            title: "Программа"
            Layout.fillWidth: true
            Layout.fillHeight: true
            enabled: turingMachine ? !turingMachine.isRunning : true

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
                    Button { text: "R"; onClicked: {
                        if (activeCellInput && activeCellInput !== inputStringField) {
                            var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,R,q1"; else activeCellInput.text = t.replace(/,.,/, ",R,")
                        }
                    }}
                    Button { text: "L"; onClicked: {
                        if (activeCellInput && activeCellInput !== inputStringField) {
                            var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,L,q1"; else activeCellInput.text = t.replace(/,.,/, ",L,")
                        }
                    }}
                    Button { text: "S"; onClicked: {
                        if (activeCellInput && activeCellInput !== inputStringField) {
                            var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,S,q1"; else activeCellInput.text = t.replace(/,.,/, ",S,")
                        }
                    }}
                }

                ScrollView {
                    id: tableScrollView
                    Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                    Column {
                        id: tableColumn
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
                                            anchors.fill: parent; anchors.margins: 2
                                            text: turingMachine ? turingMachine.getTransition(stateName, modelData) : ""
                                            placeholderText: "a,R,q0"
                                            font.pixelSize: 11
                                            onEditingFinished: {
                                                if (turingMachine) {
                                                    var success = turingMachine.setTransitionString(stateName, modelData, text)
                                                    if (success) statusMessage = "✓ " + stateName + "," + modelData + " → " + text
                                                }
                                            }
                                            onActiveFocusChanged: { if (activeFocus) activeCellInput = this }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ---------------- Управление ----------------
        Rectangle {
            Layout.fillWidth: true; height: 80; color: "#f0f0f0"; border.color: "gray"; radius: 5
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 8
                RowLayout {
                    Button { text: "▶ Запуск"; onClicked: { if(turingMachine) turingMachine.start() } }
                    Button { text: "⏸ Шаг"; onClicked: { if(turingMachine) turingMachine.step() } }
                    Button { text: "⏹ Стоп"; onClicked: { if(turingMachine) turingMachine.stop() } }
                    Button {
                        text: "⟳ Сброс"
                        onClicked: {
                            if(turingMachine) {
                                turingMachine.reset()
                                updateTapeModel()
                                tapeListView.contentX = 0
                                lightIndex = turingMachine.headPosition
                                headCanvas.centerOnHead()
                                statusMessage = "Выполнение сброшено"
                            }
                        }
                    }
                    Rectangle { width: 20; color: "transparent" }
                    Text { text: "Состояние: " + (turingMachine ? turingMachine.currentState : ""); font.bold: true }
                    Text { text: "Позиция: " + (turingMachine ? turingMachine.headPosition : "") }
                    Item { Layout.fillWidth: true }
                    Text { text: "Скорость:" }
                    Slider {
                        id: speedSlider
                        from: 1; to: 20; value: 5; width: 120
                        onValueChanged: {
                            if (turingMachine) turingMachine.speed = value
                            headCanvas.animDuration = Math.max(40, 200 - value * 8)
                        }
                    }
                    Text { text: speedSlider.value.toFixed(0); width: 25 }
                }
                Text {
                    id: statusTextDisplay
                    text: statusMessage; font.italic: true; color: "green"
                }
            }
        }
    }

    // Функции обновления данных
    function updateTapeModel() {
        if (!turingMachine) return
        var newModel = []
        for (var i = 0; i < turingMachine.tape.length; i++)
            newModel.push(turingMachine.tape[i])
        tapeModel = newModel
    }

    function updateTableData() {
        if (!turingMachine) return
        currentStates = turingMachine.states
        currentAlphabet = turingMachine.alphabet
    }

    // Связь с бэкендом
    Connections {
        target: turingMachine
        function onStatesChanged() { updateTableData() }
        function onAlphabetChanged() { updateTableData() }
        function onTapeChanged() {
            updateTapeModel()
            headCanvas.centerOnHead()
        }
        function onError(message) { statusMessage = "Ошибка: " + message; statusTextDisplay.color = "red" }
        function onHalted(reason) { statusMessage = "Остановлено: " + reason; statusTextDisplay.color = "orange" }
        function onRunningChanged() {
            statusMessage = turingMachine.isRunning ? "Выполнение..." : "Готов"
            statusTextDisplay.color = turingMachine.isRunning ? "blue" : "green"
        }
    }

    Component.onCompleted: {
        if (turingMachine) {
            turingMachine.setAlphabet("abΛ", "")
            updateTableData()
            updateTapeModel()
            lightIndex = turingMachine.headPosition
            headCanvas.centerOnHead()
            statusMessage = "Готов"
        }
    }
}
