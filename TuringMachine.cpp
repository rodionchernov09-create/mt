#include "TuringMachine.h"
#include <QDebug>

TuringMachine::TuringMachine(QObject *parent)
    : QObject(parent)
    , m_headPosition(0)
    , m_currentState("q0")
    , m_isRunning(false)
    , m_speed(5)
    , m_blankSymbol("Λ")
{
    m_timer = new QTimer(this);
    m_timer->setSingleShot(false);
    connect(m_timer, &QTimer::timeout, this, &TuringMachine::executeStep);

    m_states = QStringList() << "q0";
    m_alphabet = QStringList() << "a" << "b" << "Λ";
}

QVariantList TuringMachine::getStates() const
{
    QVariantList list;
    for (const QString &s : m_states) list.append(s);
    return list;
}

QVariantList TuringMachine::getAlphabet() const
{
    QVariantList list;
    for (const QString &s : m_alphabet) list.append(s);
    return list;
}

void TuringMachine::setSpeed(int speed)
{
    m_speed = qBound(1, speed, 20);
    emit speedChanged();
    if (m_isRunning) {
        m_timer->start(1000 / m_speed);
    }
}

void TuringMachine::setAlphabet(const QString &tapeAlphabet, const QString &extraAlphabet)
{
    m_alphabet.clear();

    for (QChar ch : tapeAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol)) {
            m_alphabet.append(symbol);
        }
    }

    for (QChar ch : extraAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol)) {
            m_alphabet.append(symbol);
        }
    }

    if (!m_alphabet.contains("Λ")) {
        m_alphabet.append("Λ");
    }

    emit alphabetChanged();
    qDebug() << "Alphabet:" << m_alphabet;
}

void TuringMachine::addState()
{
    QString newState = "q" + QString::number(m_states.size());
    m_states.append(newState);
    qDebug() << "Added state:" << newState;
    emit statesChanged();
}

void TuringMachine::removeState()
{
    if (m_states.size() > 1) {
        QString stateToRemove = m_states.last();
        m_states.removeLast();
        m_transitions.remove(stateToRemove);
        emit statesChanged();
    }
}

void TuringMachine::addHaltState()
{
    if (!m_states.contains("H")) {
        m_states.append("H");
        qDebug() << "Added halt state: H";
        emit statesChanged();
    }
}

void TuringMachine::addSymbol(const QString &symbol)
{
    if (!m_alphabet.contains(symbol) && symbol != "Λ") {
        m_alphabet.append(symbol);
        qDebug() << "Added symbol:" << symbol;
        emit alphabetChanged();
    }
}

void TuringMachine::removeSymbol(const QString &symbol)
{
    if (symbol != "Λ" && m_alphabet.contains(symbol)) {
        m_alphabet.removeAll(symbol);
        emit alphabetChanged();
    }
}

void TuringMachine::setTransition(const QString &state, const QString &symbol,
                                  const QString &writeSymbol, const QString &move, const QString &nextState)
{
    qDebug() << "=== setTransition ===";
    qDebug() << "State:" << state;
    qDebug() << "Read symbol:" << symbol;
    qDebug() << "Write symbol:" << writeSymbol;
    qDebug() << "Move:" << move;
    qDebug() << "Next state:" << nextState;

    Transition trans;
    trans.writeSymbol = writeSymbol;
    trans.move = move;
    trans.nextState = nextState;

    m_transitions[state][symbol] = trans;

    qDebug() << "Transition saved successfully!";
    emit programChanged();
}

void TuringMachine::setTransitionString(const QString &state, const QString &symbol, const QString &value)
{
    qDebug() << "=== setTransitionString ===";
    qDebug() << "State:" << state;
    qDebug() << "Symbol:" << symbol;
    qDebug() << "Value:" << value;

    if (value.isEmpty()) {
        if (m_transitions.contains(state)) {
            m_transitions[state].remove(symbol);
            qDebug() << "Removed transition";
        }
    } else {
        // Правильно парсим строку: "a,R,q0"
        QStringList parts = value.split(',');
        if (parts.size() == 3) {
            QString writeSymbol = parts[0].trimmed();
            QString move = parts[1].trimmed();
            QString nextState = parts[2].trimmed();

            qDebug() << "Parsed: write=" << writeSymbol << "move=" << move << "next=" << nextState;

            // Проверяем корректность
            if (move != "R" && move != "L" && move != "S") {
                emit error("Move must be R, L, or S");
                return;
            }

            setTransition(state, symbol, writeSymbol, move, nextState);
        } else {
            qDebug() << "ERROR: Invalid format, parts count =" << parts.size();
            emit error("Invalid format. Use: символ,движение,состояние (пример: a,R,q0)");
        }
    }
    emit programChanged();
}

QString TuringMachine::getTransition(const QString &state, const QString &symbol) const
{
    if (!m_transitions.contains(state)) {
        qDebug() << "getTransition: No state" << state;
        return "";
    }
    if (!m_transitions[state].contains(symbol)) {
        qDebug() << "getTransition: No symbol" << symbol << "for state" << state;
        return "";
    }

    const Transition &trans = m_transitions[state][symbol];
    QString result = QString("%1,%2,%3").arg(trans.writeSymbol, trans.move, trans.nextState);
    qDebug() << "getTransition:" << state << symbol << "->" << result;
    return result;
}

void TuringMachine::clearProgram()
{
    m_transitions.clear();
    emit programChanged();
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

void TuringMachine::executeStep()
{
    qDebug() << "========================================";
    qDebug() << "Current state:" << m_currentState;

    if (m_currentState == "H") {
        stop();
        emit halted("Program finished");
        return;
    }

    QString currentSymbol;
    if (m_headPosition < m_tape.size()) {
        currentSymbol = m_tape[m_headPosition];
    } else {
        currentSymbol = m_blankSymbol;
    }

    qDebug() << "Current symbol:" << currentSymbol;
    qDebug() << "Head position:" << m_headPosition;

    if (!m_transitions.contains(m_currentState)) {
        QString msg = "No transitions for state " + m_currentState;
        qDebug() << "ERROR:" << msg;
        stop();
        emit halted(msg);
        return;
    }

    if (!m_transitions[m_currentState].contains(currentSymbol)) {
        QString msg = "No transition for (" + m_currentState + ", '" + currentSymbol + "')";
        qDebug() << "ERROR:" << msg;
        qDebug() << "Available symbols:" << m_transitions[m_currentState].keys();
        stop();
        emit halted(msg);
        return;
    }

    Transition trans = m_transitions[m_currentState][currentSymbol];
    qDebug() << "Found transition: write=" << trans.writeSymbol << "move=" << trans.move << "next=" << trans.nextState;

    // Записываем символ
    if (m_headPosition >= m_tape.size()) {
        m_tape.append(trans.writeSymbol);
    } else {
        m_tape[m_headPosition] = trans.writeSymbol;
    }

    // Двигаем головку
    if (trans.move == "R") {
        m_headPosition++;
    } else if (trans.move == "L") {
        m_headPosition--;
        if (m_headPosition < 0) m_headPosition = 0;
    }

    // Меняем состояние
    m_currentState = trans.nextState;

    qDebug() << "New state:" << m_currentState;
    qDebug() << "New head position:" << m_headPosition;

    emit tapeChanged();
    emit headPositionChanged();
    emit stateChanged();
}

bool TuringMachine::validateAlphabet(const QString &input) const
{
    for (QChar ch : input) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != "Λ") {
            qDebug() << "Invalid symbol:" << symbol;
            return false;
        }
    }
    return true;
}
