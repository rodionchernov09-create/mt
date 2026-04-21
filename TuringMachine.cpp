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

    m_states = {"q0"};
    m_alphabet = {"0", "1", "Λ"};
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
    m_blankSymbol = "Λ";

    for (QChar ch : tapeAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != m_blankSymbol) {
            m_alphabet.append(symbol);
        }
    }

    for (QChar ch : extraAlphabet) {
        QString symbol(ch);
        if (!m_alphabet.contains(symbol) && symbol != m_blankSymbol) {
            m_alphabet.append(symbol);
        }
    }

    if (!m_alphabet.contains(m_blankSymbol)) {
        m_alphabet.append(m_blankSymbol);
    }

    emit alphabetChanged();
    qDebug() << "Alphabet set:" << m_alphabet;
}

void TuringMachine::addState()
{
    QString newState = "q" + QString::number(m_states.size());
    m_states.append(newState);
    emit statesChanged();
    emit programChanged();
}

void TuringMachine::removeState()
{
    if (m_states.size() > 1) {
        QString stateToRemove = m_states.last();
        m_states.removeLast();
        m_transitions.remove(stateToRemove);

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

        emit statesChanged();
        emit programChanged();
    }
}

void TuringMachine::addSymbol(const QString &symbol)
{
    if (!m_alphabet.contains(symbol) && symbol != "Λ") {
        m_alphabet.append(symbol);
        emit alphabetChanged();
        emit programChanged();
    }
}

void TuringMachine::removeSymbol(const QString &symbol)
{
    if (symbol != "Λ" && m_alphabet.contains(symbol)) {
        m_alphabet.removeAll(symbol);

        for (auto &stateMap : m_transitions) {
            stateMap.remove(symbol);
        }

        emit alphabetChanged();
        emit programChanged();
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

    if (move != "L" && move != "R" && move != "S") {
        emit error("Move must be L, R, or S");
        return;
    }

    Transition trans{writeSymbol, move, nextState};
    m_transitions[state][symbol] = trans;
    emit programChanged();
}

void TuringMachine::setTransitionString(const QString &state, const QString &symbol, const QString &value)
{
    if (value.isEmpty()) {
        if (m_transitions.contains(state)) {
            m_transitions[state].remove(symbol);
        }
    } else {
        QStringList parts = value.split(',');
        if (parts.size() == 3) {
            setTransition(state, symbol, parts[0], parts[1], parts[2]);
        }
    }
}

QString TuringMachine::getTransition(const QString &state, const QString &symbol) const
{
    if (!m_transitions.contains(state)) return "";
    if (!m_transitions[state].contains(symbol)) return "";

    const Transition &trans = m_transitions[state][symbol];
    return QString("%1,%2,%3").arg(trans.writeSymbol, trans.move, trans.nextState);
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

    bool hasHalt = false;
    for (const QString &state : m_states) {
        if (state == "H" || state == "halt") {
            hasHalt = true;
            break;
        }
    }

    if (!hasHalt) {
        emit error("No halt state defined (use 'H' as halt state)");
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
    if (m_currentState == "H" || m_currentState == "halt") {
        stop();
        emit halted("Program finished");
        return;
    }

    QString currentSymbol = (m_headPosition < m_tape.size()) ?
                            m_tape[m_headPosition] : m_blankSymbol;

    if (!m_transitions.contains(m_currentState) ||
        !m_transitions[m_currentState].contains(currentSymbol)) {
        stop();
        emit halted("No transition defined for state " + m_currentState +
                   " and symbol " + currentSymbol);
        return;
    }

    Transition trans = m_transitions[m_currentState][currentSymbol];

    if (m_headPosition >= m_tape.size()) {
        m_tape.append(trans.writeSymbol);
    } else {
        m_tape[m_headPosition] = trans.writeSymbol;
    }

    moveHead(trans.move);
    m_currentState = trans.nextState;

    emit tapeChanged();
    emit headPositionChanged();
    emit stateChanged();

    if (m_headPosition < 2) {
        emit needScroll(-1);
    } else if (m_headPosition > m_tape.size() - 3) {
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
