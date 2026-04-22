import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1100
    height: 800
    title: "Эмулятор Машины Тьюринга"

    property var currentStates: []
    property var currentAlphabet: []
    property var activeCellInput: null
    property string statusMessage: "Готов"

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
                    }
                }
            }
        }

        // Лента с треугольной головкой
        GroupBox {
            title: "Лента"
            Layout.fillWidth: true
            Layout.preferredHeight: 120

            Rectangle {
                anchors.fill: parent
                color: "white"

                ScrollView {
                    id: tapeScrollView
                    anchors.fill: parent
                    clip: true

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    Item {
                        width: Math.max(tapeRow.width + 50, tapeScrollView.width - 10)
                        height: 80

                        Row {
                            id: tapeRow
                            spacing: 2
                            y: 10

                            Repeater {
                                id: tapeRepeater
                                model: turingMachine ? turingMachine.tape : []
                                delegate: Rectangle {
                                    width: 60
                                    height: 60
                                    border.color: "black"
                                    border.width: 2
                                    color: "white"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font.pixelSize: 24
                                        font.family: "Courier"
                                    }
                                }
                            }
                        }

                        // Треугольная головка (перевёрнутая, вершиной вниз)
                        Canvas {
                            id: headCanvas
                            width: 30
                            height: 30

                            property int targetX: (turingMachine ? turingMachine.headPosition : 0) * 62 + 15

                            Behavior on x {
                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                            }

                            x: targetX
                            y: -5

                            onPaint: {
                                var ctx = getContext("2d")
                                ctx.clearRect(0, 0, width, height)
                                ctx.fillStyle = "red"
                                ctx.beginPath()
                                // Перевёрнутый треугольник (вершиной вниз)
                                ctx.moveTo(width / 2, height)
                                ctx.lineTo(0, 0)
                                ctx.lineTo(width, 0)
                                ctx.closePath()
                                ctx.fill()
                            }

                            Connections {
                                target: turingMachine
                                function onHeadPositionChanged() {
                                    var newPos = turingMachine.headPosition * 62 + 15
                                    targetX = newPos

                                    // Автоматическая прокрутка
                                    var viewWidth = tapeScrollView.width
                                    var currentScroll = tapeScrollView.contentItem.x
                                    var headScreenPos = newPos + currentScroll

                                    if (headScreenPos > viewWidth - 100) {
                                        tapeScrollView.contentItem.x = -(newPos - viewWidth + 80)
                                    } else if (headScreenPos < 100) {
                                        tapeScrollView.contentItem.x = -(newPos - 50)
                                    }

                                    if (tapeScrollView.contentItem.x > 0) {
                                        tapeScrollView.contentItem.x = 0
                                    }
                                    var maxScroll = -(tapeRow.width + 50 - viewWidth)
                                    if (tapeScrollView.contentItem.x < maxScroll) {
                                        tapeScrollView.contentItem.x = maxScroll
                                    }
                                }
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
                placeholderText: "Введите строку из символов алфавита"
                Layout.fillWidth: true
                text: "ab"
            }
            Button {
                text: "Задать строку"
                onClicked: {
                    if (turingMachine && turingMachine.loadInputString(inputStringField.text)) {
                        statusMessage = "Строка загружена"
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
                spacing: 5

                RowLayout {
                    Button { text: "+ Состояние"; onClicked: { if(turingMachine) turingMachine.addState() } }
                    Button { text: "- Состояние"; onClicked: { if(turingMachine) turingMachine.removeState() } }
                    Button { text: "H (halt)"; onClicked: { if(turingMachine) turingMachine.addHaltState() } }

                    Rectangle { width: 20; color: "transparent" }

                    Label { text: "Добавить символ:"; font.bold: true }
                    TextField {
                        id: symbolInput
                        placeholderText: "Символ"
                        width: 60
                    }
                    Button {
                        text: "+ Добавить"
                        onClicked: {
                            if(turingMachine && symbolInput.text) {
                                turingMachine.addSymbol(symbolInput.text)
                                symbolInput.text = ""
                            }
                        }
                    }

                    Rectangle { width: 20; color: "transparent" }

                    Label { text: "Быстрый ввод:"; font.bold: true }
                    Button { text: "Λ"; onClicked: { if (activeCellInput) activeCellInput.text += "Λ" } }
                    Button { text: "R"; onClicked: { if (activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,R,q1"; else activeCellInput.text = t.replace(/,.,/, ",R,") } } }
                    Button { text: "L"; onClicked: { if (activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,L,q1"; else activeCellInput.text = t.replace(/,.,/, ",L,") } } }
                    Button { text: "S"; onClicked: { if (activeCellInput) { var t = activeCellInput.text; if(t==="") activeCellInput.text = "Λ,S,q1"; else activeCellInput.text = t.replace(/,.,/, ",S,") } } }

                    Item { Layout.fillWidth: true }

                    Label { text: "Формат: символ,R/L/S,состояние"; color: "gray"; font.pixelSize: 10 }
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        id: tableContainer

                        // Заголовок
                        Row {
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

                        // Строки состояний - каждая строка независима
                        Repeater {
                            id: rowsRepeater
                            model: currentStates

                            Row {
                                id: stateRow
                                property string stateName: modelData

                                Rectangle { width: 80; height: 40; color: "#e0e0e0"; border.color: "gray"
                                    Text { text: stateName; anchors.centerIn: parent; font.bold: true }
                                }

                                Repeater {
                                    model: currentAlphabet

                                    Rectangle {
                                        width: 100; height: 40; color: "white"; border.color: "gray"

                                        TextField {
                                            id: cellField
                                            width: parent.width
                                            height: parent.height
                                            anchors.margins: 2

                                            property string myState: stateRow.stateName
                                            property string mySymbol: modelData

                                            text: {
                                                if (!turingMachine) return ""
                                                return turingMachine.getTransition(myState, mySymbol)
                                            }

                                            placeholderText: "a,R,q0"
                                            font.pixelSize: 11

                                            onActiveFocusChanged: {
                                                if (activeFocus) {
                                                    activeCellInput = this
                                                }
                                            }

                                            onEditingFinished: {
                                                if (!turingMachine) return
                                                console.log("Saving:", myState, mySymbol, "=", text)
                                                turingMachine.setTransitionString(myState, mySymbol, text)
                                                statusMessage = "✓ " + myState + "," + mySymbol + " → " + text
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
                    Button { text: "⟳ Сброс"; onClicked: { if(turingMachine) turingMachine.reset() } }

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

                    // Кнопки прокрутки ленты
                    Button {
                        text: "◀"
                        width: 30
                        ToolTip.text: "Прокрутить ленту влево"
                        onClicked: {
                            tapeScrollView.contentItem.x += 80
                            if (tapeScrollView.contentItem.x > 0) tapeScrollView.contentItem.x = 0
                        }
                    }
                    Button {
                        text: "▶"
                        width: 30
                        ToolTip.text: "Прокрутить ленту вправо"
                        onClicked: {
                            var maxScroll = -(tapeRow.width + 50 - tapeScrollView.width)
                            tapeScrollView.contentItem.x -= 80
                            if (tapeScrollView.contentItem.x < maxScroll) tapeScrollView.contentItem.x = maxScroll
                        }
                    }
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

    function updateTable() {
        if (!turingMachine) return
        currentStates = turingMachine.states
        currentAlphabet = turingMachine.alphabet
        console.log("Table updated. States:", JSON.stringify(currentStates))
        console.log("Alphabet:", JSON.stringify(currentAlphabet))
    }

    Connections {
        target: turingMachine
        function onStatesChanged() { updateTable() }
        function onAlphabetChanged() { updateTable() }
        function onTapeChanged() { tapeRepeater.model = turingMachine.tape }
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
            updateTable()
            statusMessage = "Готов. Алфавит: a, b, Λ"
        }
    }
}
