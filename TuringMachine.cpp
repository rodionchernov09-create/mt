#include "TuringMachine.h"
#include <QDebug>
#include <QThread>

TuringMachine::TuringMachine(QObject *parent)
    : QObject(parent)
    , m_headPosition(0)
    , m_currentState("q0")
    , m_isRunning(false)
    , m_speed(500)
    , m_blankSymbol("Λ")
{
    m_timer = new QTimer(this);
    m_timer->setSingleShot(false);
    connect(m_timer, &QTimer::timeout, this, &TuringMachine::executeStep);

    // Начальные состояния
    m_states = {"q0"};
}

void TuringMachine::setAlphabet(const QString &tapeAlphabet, const QString &extraAlphabet)
{
    m_alphabet.clear();
    m_blankSymbol = "Λ";

    // Добавляем символы алфавита ленты
    for (QChar ch : tapeAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != m_blankSymbol) {
            m_alphabet.append(symbol);
        }
    }

    // Добавляем дополнительные символы
    for (QChar ch : extraAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != m_blankSymbol) {
            m_alphabet.append(symbol);
        }
    }

    // Добавляем пустой символ
    if (!m_alphabet.contains(m_blankSymbol)) {
        m_alphabet.append(m_blankSymbol);
    }

    qDebug() << "Alphabet set:" << m_alphabet;
}

void TuringMachine::addState()
{
    QString newState = "q" + QString::number(m_states.size());
    m_states.append(newState);
    qDebug() << "Added state:" << newState;
}

void TuringMachine::removeState()
{
    if (m_states.size() > 1) {
        QString stateToRemove = m_states.last();
        m_states.removeLast();

        // Удаляем все переходы из этого состояния
        m_transitions.remove(stateToRemove);

        // Удаляем переходы в это состояние
        for (auto &stateMap : m_transitions) {
            QList<QString> symbolsToRemove;
            for (auto it = stateMap.begin(); it != stateMap.end(); ++it) {
                if (it.value().nextState == stateToRemove) {
                    symbolsToRemove.append(it.key());
                }
            }
            for (const QString &symbol : symbolsToRemove) {
                stateMap.remove(symbol);
            }
        }

        qDebug() << "Removed state:" << stateToRemove;
    }
}

void TuringMachine::setTransition(const QString &state, const QString &symbol,
                                  const QString &writeSymbol, const QString &move, const QString &nextState)
{
    if (!m_states.contains(state) || !m_states.contains(nextState)) {
        emit error("Invalid state");
        return;
    }

    if (!m_alphabet.contains(symbol) || !m_alphabet.contains(writeSymbol)) {
        emit error("Invalid symbol");
        return;
    }

    Transition trans{writeSymbol, move, nextState};
    m_transitions[state][symbol] = trans;
    qDebug() << "Set transition:" << state << symbol << "->" << writeSymbol << move << nextState;
}

QString TuringMachine::getTransition(const QString &state, const QString &symbol) const
{
    if (!m_transitions.contains(state)) return "";
    if (!m_transitions[state].contains(symbol)) return "";

    const Transition &trans = m_transitions[state][symbol];
    return QString("%1,%2,%3").arg(trans.writeSymbol, trans.move, trans.nextState);
}

bool TuringMachine::loadInputString(const QString &input)
{
    if (!validateAlphabet(input)) {
        emit error("Input string contains characters not in alphabet");
        return false;
    }

    m_originalTape = input;
    reset();
    return true;
}

void TuringMachine::start()
{
    if (m_isRunning) return;

    // Проверяем наличие остановки
    bool hasHalt = false;
    for (const QString &state : m_states) {
        if (state.startsWith("halt") || state == "H") {
            hasHalt = true;
            break;
        }
    }

    if (!hasHalt) {
        emit error("No halt state defined");
        return;
    }

    m_isRunning = true;
    emit runningChanged();
    m_timer->start(1000 / m_speed);
}

void TuringMachine::stop()
{
    if (m_timer->isActive()) {
        m_timer->stop();
    }
    m_isRunning = false;
    emit runningChanged();
}

void TuringMachine::step()
{
    if (!m_isRunning) {
        executeStep();
    }
}

void TuringMachine::reset()
{
    stop();

    // Восстанавливаем исходную ленту
    m_tape.clear();
    for (QChar ch : m_originalTape) {
        m_tape.append(QString(ch));
    }

    if (m_tape.isEmpty()) {
        m_tape.append(m_blankSymbol);
    }

    m_headPosition = 0;
    m_currentState = "q0";

    emit tapeChanged();
    emit headPositionChanged();
    emit stateChanged();
}

void TuringMachine::setSpeed(int speed)
{
    m_speed = qBound(1, speed, 20);
    emit speedChanged();

    if (m_isRunning) {
        m_timer->start(1000 / m_speed);
    }
}

void TuringMachine::executeStep()
{
    if (m_currentState.startsWith("halt") || m_currentState == "H") {
        stop();
        emit halted("Program finished");
        return;
    }

    // Получаем текущий символ
    QString currentSymbol = (m_headPosition < m_tape.size()) ?
                            m_tape[m_headPosition] : m_blankSymbol;

    // Проверяем наличие перехода
    if (!m_transitions.contains(m_currentState) ||
        !m_transitions[m_currentState].contains(currentSymbol)) {
        stop();
        emit halted("No transition defined for state " + m_currentState +
                   " and symbol " + currentSymbol);
        return;
    }

    Transition trans = m_transitions[m_currentState][currentSymbol];

    // Записываем символ
    if (m_headPosition >= m_tape.size()) {
        m_tape.append(trans.writeSymbol);
    } else {
        m_tape[m_headPosition] = trans.writeSymbol;
    }

    // Двигаем головку
    moveHead(trans.move);

    // Меняем состояние
    m_currentState = trans.nextState;

    // Обновляем отображение
    emit tapeChanged();
    emit headPositionChanged();
    emit stateChanged();

    // Проверяем необходимость скролла
    if (m_headPosition < 3) {
        emit needScroll(-1);
    } else if (m_headPosition > m_tape.size() - 4) {
        emit needScroll(1);
    }
}

void TuringMachine::moveHead(const QString &direction)
{
    if (direction == "R") {
        m_headPosition++;
    } else if (direction == "L") {
        m_headPosition--;
        if (m_headPosition < 0) m_headPosition = 0;
    }
    // "S" - stay, ничего не делаем
}

bool TuringMachine::validateAlphabet(const QString &input) const
{
    for (QChar ch : input) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != m_blankSymbol) {
            return false;
        }
    }
    return true;
}

void TuringMachine::updateTapeDisplay()
{
    emit tapeChanged();
}
