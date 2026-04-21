/****************************************************************************
** Meta object code from reading C++ file 'TuringMachine.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.10.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../../TuringMachine.h"
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'TuringMachine.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.10.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN13TuringMachineE_t {};
} // unnamed namespace

template <> constexpr inline auto TuringMachine::qt_create_metaobjectdata<qt_meta_tag_ZN13TuringMachineE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "TuringMachine",
        "tapeChanged",
        "",
        "headPositionChanged",
        "stateChanged",
        "runningChanged",
        "speedChanged",
        "halted",
        "reason",
        "needScroll",
        "direction",
        "error",
        "message",
        "executeStep",
        "setAlphabet",
        "tapeAlphabet",
        "extraAlphabet",
        "addState",
        "removeState",
        "setTransition",
        "state",
        "symbol",
        "writeSymbol",
        "move",
        "nextState",
        "getTransition",
        "getStates",
        "getAlphabet",
        "loadInputString",
        "input",
        "start",
        "stop",
        "step",
        "reset",
        "tape",
        "headPosition",
        "currentState",
        "isRunning",
        "speed"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'tapeChanged'
        QtMocHelpers::SignalData<void()>(1, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'headPositionChanged'
        QtMocHelpers::SignalData<void()>(3, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'stateChanged'
        QtMocHelpers::SignalData<void()>(4, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'runningChanged'
        QtMocHelpers::SignalData<void()>(5, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'speedChanged'
        QtMocHelpers::SignalData<void()>(6, 2, QMC::AccessPublic, QMetaType::Void),
        // Signal 'halted'
        QtMocHelpers::SignalData<void(const QString &)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 },
        }}),
        // Signal 'needScroll'
        QtMocHelpers::SignalData<void(int)>(9, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 10 },
        }}),
        // Signal 'error'
        QtMocHelpers::SignalData<void(const QString &)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 12 },
        }}),
        // Slot 'executeStep'
        QtMocHelpers::SlotData<void()>(13, 2, QMC::AccessPrivate, QMetaType::Void),
        // Method 'setAlphabet'
        QtMocHelpers::MethodData<void(const QString &, const QString &)>(14, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 15 }, { QMetaType::QString, 16 },
        }}),
        // Method 'addState'
        QtMocHelpers::MethodData<void()>(17, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'removeState'
        QtMocHelpers::MethodData<void()>(18, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'setTransition'
        QtMocHelpers::MethodData<void(const QString &, const QString &, const QString &, const QString &, const QString &)>(19, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 20 }, { QMetaType::QString, 21 }, { QMetaType::QString, 22 }, { QMetaType::QString, 23 },
            { QMetaType::QString, 24 },
        }}),
        // Method 'getTransition'
        QtMocHelpers::MethodData<QString(const QString &, const QString &) const>(25, 2, QMC::AccessPublic, QMetaType::QString, {{
            { QMetaType::QString, 20 }, { QMetaType::QString, 21 },
        }}),
        // Method 'getStates'
        QtMocHelpers::MethodData<QStringList() const>(26, 2, QMC::AccessPublic, QMetaType::QStringList),
        // Method 'getAlphabet'
        QtMocHelpers::MethodData<QStringList() const>(27, 2, QMC::AccessPublic, QMetaType::QStringList),
        // Method 'loadInputString'
        QtMocHelpers::MethodData<bool(const QString &)>(28, 2, QMC::AccessPublic, QMetaType::Bool, {{
            { QMetaType::QString, 29 },
        }}),
        // Method 'start'
        QtMocHelpers::MethodData<void()>(30, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'stop'
        QtMocHelpers::MethodData<void()>(31, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'step'
        QtMocHelpers::MethodData<void()>(32, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'reset'
        QtMocHelpers::MethodData<void()>(33, 2, QMC::AccessPublic, QMetaType::Void),
    };
    QtMocHelpers::UintData qt_properties {
        // property 'tape'
        QtMocHelpers::PropertyData<QStringList>(34, QMetaType::QStringList, QMC::DefaultPropertyFlags, 0),
        // property 'headPosition'
        QtMocHelpers::PropertyData<int>(35, QMetaType::Int, QMC::DefaultPropertyFlags, 1),
        // property 'currentState'
        QtMocHelpers::PropertyData<QString>(36, QMetaType::QString, QMC::DefaultPropertyFlags, 2),
        // property 'isRunning'
        QtMocHelpers::PropertyData<bool>(37, QMetaType::Bool, QMC::DefaultPropertyFlags, 3),
        // property 'speed'
        QtMocHelpers::PropertyData<int>(38, QMetaType::Int, QMC::DefaultPropertyFlags | QMC::Writable | QMC::StdCppSet, 4),
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<TuringMachine, qt_meta_tag_ZN13TuringMachineE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject TuringMachine::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13TuringMachineE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13TuringMachineE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN13TuringMachineE_t>.metaTypes,
    nullptr
} };

void TuringMachine::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<TuringMachine *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->tapeChanged(); break;
        case 1: _t->headPositionChanged(); break;
        case 2: _t->stateChanged(); break;
        case 3: _t->runningChanged(); break;
        case 4: _t->speedChanged(); break;
        case 5: _t->halted((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 6: _t->needScroll((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 7: _t->error((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 8: _t->executeStep(); break;
        case 9: _t->setAlphabet((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2]))); break;
        case 10: _t->addState(); break;
        case 11: _t->removeState(); break;
        case 12: _t->setTransition((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[3])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[4])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[5]))); break;
        case 13: { QString _r = _t->getTransition((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<QString>>(_a[2])));
            if (_a[0]) *reinterpret_cast<QString*>(_a[0]) = std::move(_r); }  break;
        case 14: { QStringList _r = _t->getStates();
            if (_a[0]) *reinterpret_cast<QStringList*>(_a[0]) = std::move(_r); }  break;
        case 15: { QStringList _r = _t->getAlphabet();
            if (_a[0]) *reinterpret_cast<QStringList*>(_a[0]) = std::move(_r); }  break;
        case 16: { bool _r = _t->loadInputString((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1])));
            if (_a[0]) *reinterpret_cast<bool*>(_a[0]) = std::move(_r); }  break;
        case 17: _t->start(); break;
        case 18: _t->stop(); break;
        case 19: _t->step(); break;
        case 20: _t->reset(); break;
        default: ;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)()>(_a, &TuringMachine::tapeChanged, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)()>(_a, &TuringMachine::headPositionChanged, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)()>(_a, &TuringMachine::stateChanged, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)()>(_a, &TuringMachine::runningChanged, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)()>(_a, &TuringMachine::speedChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)(const QString & )>(_a, &TuringMachine::halted, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)(int )>(_a, &TuringMachine::needScroll, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (TuringMachine::*)(const QString & )>(_a, &TuringMachine::error, 7))
            return;
    }
    if (_c == QMetaObject::ReadProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast<QStringList*>(_v) = _t->getTape(); break;
        case 1: *reinterpret_cast<int*>(_v) = _t->getHeadPosition(); break;
        case 2: *reinterpret_cast<QString*>(_v) = _t->getCurrentState(); break;
        case 3: *reinterpret_cast<bool*>(_v) = _t->isRunning(); break;
        case 4: *reinterpret_cast<int*>(_v) = _t->getSpeed(); break;
        default: break;
        }
    }
    if (_c == QMetaObject::WriteProperty) {
        void *_v = _a[0];
        switch (_id) {
        case 4: _t->setSpeed(*reinterpret_cast<int*>(_v)); break;
        default: break;
        }
    }
}

const QMetaObject *TuringMachine::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *TuringMachine::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN13TuringMachineE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int TuringMachine::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 21)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 21;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 21)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 21;
    }
    if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 5;
    }
    return _id;
}

// SIGNAL 0
void TuringMachine::tapeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void TuringMachine::headPositionChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void TuringMachine::stateChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 2, nullptr);
}

// SIGNAL 3
void TuringMachine::runningChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 3, nullptr);
}

// SIGNAL 4
void TuringMachine::speedChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 4, nullptr);
}

// SIGNAL 5
void TuringMachine::halted(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 5, nullptr, _t1);
}

// SIGNAL 6
void TuringMachine::needScroll(int _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 6, nullptr, _t1);
}

// SIGNAL 7
void TuringMachine::error(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 7, nullptr, _t1);
}
QT_WARNING_POP
