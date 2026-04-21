#ifndef TURINGMACHINE_H
#define TURINGMACHINE_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QList>
#include <QTimer>
#include <QSet>
#include <QVariant>

struct Transition {
    QString writeSymbol;
    QString move; // "L", "R", "S"
    QString nextState;
};

class TuringMachine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList tape READ getTape NOTIFY tapeChanged)
    Q_PROPERTY(int headPosition READ getHeadPosition NOTIFY headPositionChanged)
    Q_PROPERTY(QString currentState READ getCurrentState NOTIFY stateChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(int speed READ getSpeed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(QVariantList states READ getStates NOTIFY statesChanged)
    Q_PROPERTY(QVariantList alphabet READ getAlphabet NOTIFY alphabetChanged)

public:
    explicit TuringMachine(QObject *parent = nullptr);

    // Геттеры
    QStringList getTape() const { return m_tape; }
    int getHeadPosition() const { return m_headPosition; }
    QString getCurrentState() const { return m_currentState; }
    bool isRunning() const { return m_isRunning; }
    int getSpeed() const { return m_speed; }
    void setSpeed(int speed);

    Q_INVOKABLE QVariantList getStates() const {
        QVariantList list;
        for (const QString &s : m_states) list.append(s);
        return list;
    }
    Q_INVOKABLE QVariantList getAlphabet() const {
        QVariantList list;
        for (const QString &s : m_alphabet) list.append(s);
        return list;
    }

    // Управление алфавитами и программой
    Q_INVOKABLE void setAlphabet(const QString &tapeAlphabet, const QString &extraAlphabet);
    Q_INVOKABLE void addState();
    Q_INVOKABLE void removeState();
    Q_INVOKABLE void addSymbol(const QString &symbol);
    Q_INVOKABLE void removeSymbol(const QString &symbol);
    Q_INVOKABLE void setTransition(const QString &state, const QString &symbol,
                                   const QString &writeSymbol, const QString &move, const QString &nextState);
    Q_INVOKABLE void setTransitionString(const QString &state, const QString &symbol, const QString &value);
    Q_INVOKABLE QString getTransition(const QString &state, const QString &symbol) const;
    Q_INVOKABLE void clearProgram();

    // Управление выполнением
    Q_INVOKABLE bool loadInputString(const QString &input);
    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void step();
    Q_INVOKABLE void reset();

signals:
    void tapeChanged();
    void headPositionChanged();
    void stateChanged();
    void runningChanged();
    void speedChanged();
    void halted(const QString &reason);
    void needScroll(int direction);
    void error(const QString &message);
    void statesChanged();
    void alphabetChanged();
    void programChanged();

private slots:
    void executeStep();

private:
    QStringList m_tape;
    int m_headPosition;
    QString m_currentState;
    bool m_isRunning;
    int m_speed;
    QTimer *m_timer;

    QStringList m_states;
    QStringList m_alphabet;
    QString m_blankSymbol;
    QMap<QString, QMap<QString, Transition>> m_transitions;
    QString m_originalTape;
    int m_originalHeadPosition;

    bool validateAlphabet(const QString &input) const;
    void moveHead(const QString &direction);
};

#endif
