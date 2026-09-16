#pragma once

#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QGuiApplication>
#include <QMap>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlPropertyMap>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSet>
#include <QThread>
#include <QTimer>
#include <memory>
#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#elif defined(Q_OS_LINUX)
#include <unistd.h>
#endif

namespace ProjectResources {
struct Counters {
    quint64 identity = 0, memory = 0, read = 0, written = 0;
    double cpu = 0;
    bool io = false;
};

inline QByteArray readFile(const QString &path) {
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

inline QMap<quint64, Counters> processes() {
    QMap<quint64, quint64> parents;
#ifdef Q_OS_WIN
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return {};
    PROCESSENTRY32 entry{};
    entry.dwSize = sizeof(entry);
    if (Process32First(snapshot, &entry)) {
        do { parents.insert(entry.th32ProcessID, entry.th32ParentProcessID); }
        while (Process32Next(snapshot, &entry));
    }
    CloseHandle(snapshot);
    const quint64 root = GetCurrentProcessId();
#elif defined(Q_OS_LINUX)
    for (const QString &name : QDir(QStringLiteral("/proc")).entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        bool valid = false;
        const quint64 pid = name.toULongLong(&valid);
        if (!valid) continue;
        const QByteArray stat = readFile(QStringLiteral("/proc/%1/stat").arg(pid));
        const auto fields = stat.mid(stat.lastIndexOf(')') + 2).simplified().split(' ');
        if (fields.size() >= 22) parents.insert(pid, fields[1].toULongLong());
    }
    const quint64 root = static_cast<quint64>(getpid());
#else
    return {};
    const quint64 root = 0;
#endif
    QSet<quint64> included{root};
    int before;
    do {
        before = included.size();
        for (auto it = parents.cbegin(); it != parents.cend(); ++it)
            if (included.contains(it.value())) included.insert(it.key());
    } while (before != included.size());
    QMap<quint64, Counters> result;
    for (quint64 pid : included) {
        Counters value;
#ifdef Q_OS_WIN
        HANDLE process = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, static_cast<DWORD>(pid));
        if (!process) continue;
        FILETIME created{}, exited{}, kernel{}, user{};
        PROCESS_MEMORY_COUNTERS memory{};
        memory.cb = sizeof(memory);
        const auto ticks = [](FILETIME time) -> quint64 {
            return (static_cast<quint64>(time.dwHighDateTime) << 32) | time.dwLowDateTime;
        };
        const bool available = GetProcessTimes(process, &created, &exited, &kernel, &user)
            && K32GetProcessMemoryInfo(process, &memory, sizeof(memory));
        if (!available) { CloseHandle(process); continue; }
        value.identity = ticks(created);
        value.cpu = (ticks(kernel) + ticks(user)) / 10000000.0;
        value.memory = memory.WorkingSetSize;
        IO_COUNTERS io{};
        value.io = GetProcessIoCounters(process, &io);
        value.read = io.ReadTransferCount;
        value.written = io.WriteTransferCount;
        CloseHandle(process);
#elif defined(Q_OS_LINUX)
        const QByteArray stat = readFile(QStringLiteral("/proc/%1/stat").arg(pid));
        const auto fields = stat.mid(stat.lastIndexOf(')') + 2).simplified().split(' ');
        if (fields.size() < 22) continue;
        value.identity = fields[19].toULongLong();
        value.cpu = (fields[11].toDouble() + fields[12].toDouble()) / sysconf(_SC_CLK_TCK);
        value.memory = fields[21].toULongLong() * static_cast<quint64>(sysconf(_SC_PAGESIZE));
        const auto io = readFile(QStringLiteral("/proc/%1/io").arg(pid));
        value.io = !io.isEmpty();
        for (const auto &line : io.split('\n')) {
            if (line.startsWith("read_bytes:")) value.read = line.mid(11).trimmed().toULongLong();
            if (line.startsWith("write_bytes:")) value.written = line.mid(12).trimmed().toULongLong();
        }
#endif
        result.insert(pid, value);
    }
    return result;
}

inline void install(QQmlApplicationEngine &engine) {
    auto *values = new QQmlPropertyMap(&engine);
    values->insert(QStringLiteral("summary"), QStringLiteral("资源监控 · 采样中"));
    values->insert(QStringLiteral("details"), QStringLiteral("正在采样…"));
    engine.rootContext()->setContextProperty(QStringLiteral("projectResourceMonitor"), values);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &engine, [&engine](QObject *object, const QUrl &) {
        auto *window = qobject_cast<QQuickWindow *>(object);
        if (!window) return;
        QQmlComponent component(&engine);
        component.setData(R"QML(
import QtQuick 2.12
Rectangle {
    anchors.right: parent.right; anchors.bottom: parent.bottom
    anchors.margins: 12; z: 100000
    width: expanded ? 310 : label.implicitWidth + 20
    height: expanded ? 156 : 30; radius: 6; color: "#182334"; border.color: "#64748b"
    property bool expanded: false
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: "应用资源监控"
    Keys.onSpacePressed: expanded = !expanded
    Keys.onReturnPressed: expanded = !expanded
    Keys.onEscapePressed: expanded = false
    Text { id: label; x: 10; y: 6; color: "#eef2ff"; font.pixelSize: 12; text: projectResourceMonitor.summary }
    Text { x: 10; y: 32; width: parent.width - 20; visible: parent.expanded; color: "#eef2ff"; font.pixelSize: 12; wrapMode: Text.Wrap; text: projectResourceMonitor.details }
    MouseArea { anchors.fill: parent; onClicked: { parent.forceActiveFocus(); parent.expanded = !parent.expanded } }
})QML", QUrl());
        QObject *created = component.create(engine.rootContext());
        if (auto *item = qobject_cast<QQuickItem *>(created)) {
            item->setParent(window->contentItem());
            item->setParentItem(window->contentItem());
        } else { delete created; }
    });
    struct State { QMap<quint64, Counters> previous; QElapsedTimer clock; };
    auto state = std::make_shared<State>();
    auto *timer = new QTimer(values);
    timer->setInterval(2000);
    QObject::connect(timer, &QTimer::timeout, values, [&engine, values, state]() {
        bool visible = false;
        for (QObject *root : engine.rootObjects()) {
            auto *window = qobject_cast<QQuickWindow *>(root);
            if (window && window->isVisible() && window->visibility() != QWindow::Minimized) visible = true;
        }
        if (!visible) { state->clock.invalidate(); state->previous.clear(); return; }
        const auto current = processes();
        if (current.isEmpty()) {
            values->insert(QStringLiteral("summary"), QStringLiteral("资源监控 · 不可用"));
            values->insert(QStringLiteral("details"), QStringLiteral("当前平台或权限不支持进程采样。GPU：不可用。"));
            state->clock.invalidate(); state->previous.clear(); return;
        }
        double cpu = 0, reads = 0, writes = 0, memory = 0;
        bool ioAvailable = true;
        for (auto it = current.cbegin(); it != current.cend(); ++it) {
            memory += it->memory;
            ioAvailable = ioAvailable && it->io;
            const auto old = state->previous.constFind(it.key());
            if (old == state->previous.cend() || old->identity != it->identity) continue;
            cpu += qMax(0.0, it->cpu - old->cpu);
            reads += it->read >= old->read ? it->read - old->read : 0;
            writes += it->written >= old->written ? it->written - old->written : 0;
        }
        const double elapsed = state->clock.isValid() ? state->clock.elapsed() / 1000.0 : 0;
        const QString cpuText = elapsed > 0 ? QString::number(qBound(0.0, cpu / elapsed / qMax(1, QThread::idealThreadCount()) * 100, 100.0), 'f', 1) + "%" : QStringLiteral("采样中");
        const QString ioText = elapsed > 0 && ioAvailable
            ? QStringLiteral("读 %1 KiB/s · 写 %2 KiB/s").arg(reads / elapsed / 1024, 0, 'f', 1).arg(writes / elapsed / 1024, 0, 'f', 1)
            : QStringLiteral("磁盘读写：不可用 / 等待基线");
        values->insert(QStringLiteral("summary"), QStringLiteral("CPU %1 · %2 MiB").arg(cpuText).arg(memory / 1048576, 0, 'f', 1));
        values->insert(QStringLiteral("details"), QStringLiteral("%1\n%2 个可读进程 · GPU：不可用\n本应用及可读取的子进程；CPU 按整机容量计，内存 RSS 求和可能含共享页。每 2 秒更新，隐藏时暂停。").arg(ioText).arg(current.size()));
        state->previous = current;
        state->clock.restart();
    });
    timer->start();
}
} // namespace ProjectResources
