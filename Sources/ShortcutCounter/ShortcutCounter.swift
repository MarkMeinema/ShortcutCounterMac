// WERKENDE VERSIE - CMD PRESSED/RELEASED DETECTION WERKT
// Datum: 2025-10-26 02:25
// Status: CMD detection werkt, keyDown nog niet getest

import SwiftUI
import Cocoa
import Carbon
import IOKit.pwr_mgt

@main
struct ShortcutCounterApp: App {
    private let keyLogger = KeyLogger()

    init() {
        keyLogger.start()
        print("[ShortcutCounter] Logbestand: \(keyLogger.logFileURL.path)")
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(keyLogger: keyLogger)
        } label: {
            MenuBarLabel(keyLogger: keyLogger)
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuBarLabel: View {
    @ObservedObject var keyLogger: KeyLogger
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "keyboard")
            Text("\(keyLogger.shortcutsDetected)")
        }
    }
}

struct MenuBarView: View {
    @ObservedObject var keyLogger: KeyLogger
    @AppStorage("secondsPerShortcut") private var secondsPerShortcut: Double = 2.0
    @State private var secondsInput: String = ""
    @State private var inputFocused: Bool = false

    private let workdaySeconds: Double = 8 * 3600

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Shortcut Counter")
                .font(.headline)

            Divider()

            Text("Status: \(keyLogger.isRunning ? "Running" : "Stopped")")
                .foregroundColor(keyLogger.isRunning ? .green : .red)

            Text("Total shortcuts: \(keyLogger.shortcutsDetected)")
                .font(.subheadline)

            if !keyLogger.shortcutCounts.isEmpty {
                Divider()

                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Breakdown:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(keyLogger.shortcutCounts.sorted(by: { $0.value > $1.value }), id: \.key) { shortcut, count in
                            HStack {
                                Text(shortcut)
                                    .font(.system(.caption, design: .monospaced))
                                Spacer()
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
            }

            Divider()

            // Rapport sectie
            Text("Tijdsbesparing")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            reportRow(
                label: "Afgelopen week",
                count: keyLogger.shortcutCount(from: daysAgo(7), to: Date()),
                activeTime: keyLogger.activeTime(from: daysAgo(7), to: Date())
            )

            reportRow(
                label: "Afgelopen maand",
                count: keyLogger.shortcutCount(from: daysAgo(30), to: Date()),
                activeTime: keyLogger.activeTime(from: daysAgo(30), to: Date())
            )

            let twelveMonthsAgo = daysAgo(365)
            let availableMonths = keyLogger.availableMonths(since: twelveMonthsAgo)
            if availableMonths > 1 {
                let label = availableMonths >= 12 ? "Afgelopen 12 maanden" : "Afgelopen \(availableMonths) mnd (van 12)"
                reportRow(
                    label: label,
                    count: keyLogger.shortcutCount(from: twelveMonthsAgo, to: Date()),
                    activeTime: keyLogger.activeTime(from: twelveMonthsAgo, to: Date())
                )
            }

            let projection = keyLogger.yearProjectionShortcuts()
            let projectedSaved = projection * secondsPerShortcut
            VStack(alignment: .leading, spacing: 1) {
                Text("Jaarprojectie (gem. 3 mnd)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("→ \(formatTimeSaved(projectedSaved)) \(formatWorkdays(projectedSaved))")
                    .font(.caption)
                    .foregroundColor(.primary)
            }

            Divider()

            // Instelling: seconden per sneltoets
            HStack(spacing: 4) {
                Text("Sec/sneltoets:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("2.00", text: Binding(
                    get: {
                        inputFocused ? secondsInput : String(format: "%.2f", secondsPerShortcut)
                    },
                    set: { secondsInput = $0 }
                ))
                .font(.system(.caption, design: .monospaced))
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
                .onTapGesture {
                    inputFocused = true
                    secondsInput = String(format: "%.2f", secondsPerShortcut)
                }
                .onSubmit {
                    commitSecondsInput()
                }
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 280)
    }

    @ViewBuilder
    private func reportRow(label: String, count: Int, activeTime: TimeInterval) -> some View {
        let savedSeconds = Double(count) * secondsPerShortcut
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                Text("\(count) sneltoetsen")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("→ \(formatTimeSaved(savedSeconds)) \(formatWorkdays(savedSeconds))")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    private func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    private func commitSecondsInput() {
        let cleaned = secondsInput.replacingOccurrences(of: ",", with: ".")
        if let value = Double(cleaned) {
            secondsPerShortcut = min(max(value, 0.01), 60.0)
        }
        inputFocused = false
    }

    private func formatTimeSaved(_ seconds: Double) -> String {
        if seconds < 60 {
            return "< 1 min"
        } else if seconds < 3600 {
            return "\(Int(seconds / 60)) min"
        } else {
            let hours = Int(seconds / 3600)
            let minutes = Int((seconds.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes == 0 {
                return "\(hours) uur"
            }
            return "\(hours) uur \(minutes) min"
        }
    }

    private func formatWorkdays(_ seconds: Double) -> String {
        let days = seconds / workdaySeconds
        if days < 0.05 { return "" }
        let formatted = String(format: "%.1f", days).replacingOccurrences(of: ".", with: ",")
        let label = days < 1.05 ? "werkdag" : "werkdagen"
        return "≈ \(formatted) \(label)"
    }
}

// MARK: - Data types

enum LogEntryType {
    case shortcut, sleep, wake
}

struct LogEntry {
    let date: Date
    let type: LogEntryType
    let shortcut: String?
}

@MainActor
class KeyLogger: ObservableObject {
    let logFileURL: URL = {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let dir = home.appendingPathComponent("Applications/ShortcutCounter", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("shortcut_log.txt")
    }()
    @MainActor @Published var isRunning = false
    @MainActor @Published var shortcutsDetected = 0
    @MainActor @Published var shortcutCounts: [String: Int] = [:]
    @MainActor @Published var logEntries: [LogEntry] = []

    private var eventTap: CFMachPort?
    private var cmdPressed = false
    private var optionPressed = false
    private var ctrlPressed = false
    private var shiftPressed = false

    func toggle() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    func start() {
        guard !isRunning else { return }

        // Load existing shortcuts from log file
        loadShortcutsFromLog()

        // Setup sleep/wake notifications
        setupSleepWakeNotifications()

        // Check Input Monitoring permission (required for keyDown events)
        if !CGPreflightListenEventAccess() {
            print("❌ No Input Monitoring permission - requesting...")
            CGRequestListenEventAccess()
            print("🔄 Grant permission and RESTART the app")
            return
        }
        print("✅ Input Monitoring permission OK")
        let eventMask = CGEventMask(1 << CGEventType.keyDown.rawValue) | CGEventMask(1 << CGEventType.flagsChanged.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, type, event, refcon in
                let keyLogger = Unmanaged<KeyLogger>.fromOpaque(refcon!).takeUnretainedValue()
                return keyLogger.handleEvent(type: type, event: event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        guard let eventTap = eventTap else {
            print("❌ Failed to create event tap")
            return
        }
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        isRunning = true
        print("✅ KeyLogger started")
    }

    func stop() {
        guard isRunning, let eventTap = eventTap else { return }

        CGEvent.tapEnable(tap: eventTap, enable: false)
        CFMachPortInvalidate(eventTap)
        self.eventTap = nil

        isRunning = false
        print("🛑 KeyLogger stopped")
    }

    private var capsLockDown = false
    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
    let flags = event.flags
    let timestamp = DateFormatter.logFormatter.string(from: Date())
        switch type {
        case .flagsChanged:
            let flags = event.flags
            let newCmdPressed = flags.contains(.maskCommand)
            let newOptionPressed = flags.contains(.maskAlternate)
            let newCtrlPressed = flags.contains(.maskControl)
            let newShiftPressed = flags.contains(.maskShift)
            if newCmdPressed != cmdPressed {
                cmdPressed = newCmdPressed
            }
            if newOptionPressed != optionPressed {
                optionPressed = newOptionPressed
            }
            if newCtrlPressed != ctrlPressed {
                ctrlPressed = newCtrlPressed
            }
            if newShiftPressed != shiftPressed {
                shiftPressed = newShiftPressed
            }
            // Detecteer Caps Lock status (lampje)
            let capsLockActive = flags.contains(.maskAlphaShift)
            if capsLockActive != capsLockDown {
                capsLockDown = capsLockActive
                let timestamp = DateFormatter.logFormatter.string(from: Date())
                print("[\(timestamp)] CAPS LOCK STATUS \(capsLockDown ? "ON" : "OFF") (lampje)")
            }
        case .keyDown:
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            // Log fysieke toetsaanslag Caps Lock
            if keyCode == 57 {
                let timestamp = DateFormatter.logFormatter.string(from: Date())
                print("[\(timestamp)] CAPS LOCK KEY DOWN (fysiek)")
            }
            // Detecteer CMD+Tab, Option+toets, Ctrl+toets, of combinaties
            if (cmdPressed || optionPressed || ctrlPressed) && isShortcutKey(keyCode: keyCode) {
                let mods = [cmdPressed ? "CMD" : nil, optionPressed ? "OPT" : nil, ctrlPressed ? "CTRL" : nil, shiftPressed ? "SHIFT" : nil].compactMap { $0 }.joined(separator: "+")
                let shortcutKey = "\(mods)+\(getKeyCharacter(keyCode: keyCode))"
                let now = Date()

                Task { @MainActor in
                    self.shortcutsDetected += 1
                    self.shortcutCounts[shortcutKey, default: 0] += 1
                    self.logEntries.append(LogEntry(date: now, type: .shortcut, shortcut: shortcutKey))
                }

                let timestamp = DateFormatter.logFormatter.string(from: Date())
                let logLine = "\(timestamp) \(shortcutKey)\n"
                print(logLine.trimmingCharacters(in: .whitespacesAndNewlines))
                appendLog(logLine)
            }
        case .keyUp:
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            if keyCode == 57 {
                let timestamp = DateFormatter.logFormatter.string(from: Date())
                print("[\(timestamp)] CAPS LOCK KEY UP (fysiek)")
            }
        default:
            break
        }
        return Unmanaged.passUnretained(event)
    }

    func appendLog(_ line: String) {
        guard let data = line.data(using: .utf8) else { return }
        if FileManager.default.fileExists(atPath: logFileURL.path) {
            if let handle = try? FileHandle(forWritingTo: logFileURL) {
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.close()
            }
        } else {
            try? data.write(to: logFileURL)
        }
    }

    private func loadShortcutsFromLog() {
        guard FileManager.default.fileExists(atPath: logFileURL.path) else {
            print("📂 No existing log file found")
            return
        }

        guard let logContent = try? String(contentsOf: logFileURL, encoding: .utf8) else {
            print("❌ Could not read log file")
            return
        }

        let lines = logContent.components(separatedBy: .newlines)
        var tempCounts: [String: Int] = [:]
        var totalCount = 0
        var tempEntries: [LogEntry] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let components = trimmed.components(separatedBy: " ")
            guard components.count >= 3 else { continue }

            // Parse datum+tijd: "2025-10-26 12:34:56"
            let dateString = "\(components[0]) \(components[1])"
            let entryText = components.dropFirst(2).joined(separator: " ")
            let date = DateFormatter.logFormatter.date(from: dateString)

            if entryText.contains("=== LAPTOP SLEEP") {
                if let date = date {
                    tempEntries.append(LogEntry(date: date, type: .sleep, shortcut: nil))
                }
            } else if entryText.contains("=== LAPTOP WAKE") {
                if let date = date {
                    tempEntries.append(LogEntry(date: date, type: .wake, shortcut: nil))
                }
            } else if !entryText.contains("===") {
                // Sneltoets-regel
                tempCounts[entryText, default: 0] += 1
                totalCount += 1
                if let date = date {
                    tempEntries.append(LogEntry(date: date, type: .shortcut, shortcut: entryText))
                }
            }
        }

        Task { @MainActor in
            self.shortcutCounts = tempCounts
            self.shortcutsDetected = totalCount
            self.logEntries = tempEntries
        }

        print("📊 Loaded \(totalCount) shortcuts from log (\(tempCounts.count) unique), \(tempEntries.count) total entries")
    }

    private func setupSleepWakeNotifications() {
        let notificationCenter = NSWorkspace.shared.notificationCenter

        // Sleep notification
        notificationCenter.addObserver(
            forName: NSWorkspace.willSleepNotification,
            object: nil,
            queue: .main
        ) { _ in
            let now = Date()
            let timestamp = DateFormatter.logFormatter.string(from: now)
            let logLine = "\(timestamp) === LAPTOP SLEEP/STANDBY ===\n"
            print(logLine.trimmingCharacters(in: .whitespacesAndNewlines))
            self.appendLog(logLine)
            Task { @MainActor in
                self.logEntries.append(LogEntry(date: now, type: .sleep, shortcut: nil))
            }
        }

        // Wake notification
        notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            let now = Date()
            let timestamp = DateFormatter.logFormatter.string(from: now)
            let logLine = "\(timestamp) === LAPTOP WAKE UP ===\n"
            print(logLine.trimmingCharacters(in: .whitespacesAndNewlines))
            self.appendLog(logLine)
            Task { @MainActor in
                self.logEntries.append(LogEntry(date: now, type: .wake, shortcut: nil))
            }
        }

        print("🛌 Sleep/Wake notifications setup")
    }

    // MARK: - Rapport hulpmethoden

    /// Aantal sneltoetsen in de opgegeven datumrange
    func shortcutCount(from: Date, to: Date) -> Int {
        logEntries.filter { $0.type == .shortcut && $0.date >= from && $0.date <= to }.count
    }

    /// Actieve computergebruikstijd (slaaptijd uitgesloten) in de opgegeven datumrange
    func activeTime(from: Date, to: Date) -> TimeInterval {
        var totalActive: TimeInterval = 0
        var sessionStart: Date? = nil
        var currentlyAwake = false

        for entry in logEntries {
            switch entry.type {
            case .wake:
                currentlyAwake = true
                let effectiveStart = max(entry.date, from)
                if effectiveStart <= to {
                    sessionStart = effectiveStart
                }
            case .sleep:
                if currentlyAwake, let start = sessionStart {
                    let effectiveEnd = min(entry.date, to)
                    if effectiveEnd > start {
                        totalActive += effectiveEnd.timeIntervalSince(start)
                    }
                    sessionStart = nil
                }
                currentlyAwake = false
            case .shortcut:
                // Eerste sneltoets impliceert dat de computer awake was voor het eerste log
                if !currentlyAwake {
                    currentlyAwake = true
                    sessionStart = max(entry.date, from)
                }
            }
        }

        // Als computer aan het einde van de periode nog awake is
        if currentlyAwake, let start = sessionStart {
            let effectiveEnd = min(to, Date())
            if effectiveEnd > start {
                totalActive += effectiveEnd.timeIntervalSince(start)
            }
        }

        return totalActive
    }

    /// Jaarprojectie: gemiddeld per kalenderdag in de afgelopen 90 dagen × 365
    func yearProjectionShortcuts() -> Double {
        let from = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        let count = shortcutCount(from: from, to: Date())
        let perDay = Double(count) / 90.0
        return perDay * 365.0
    }

    /// Aantal maanden waarvoor data beschikbaar is, te rekenen vanaf de opgegeven datum
    func availableMonths(since date: Date) -> Int {
        guard let oldest = logEntries.first?.date else { return 0 }
        let effectiveStart = max(oldest, date)
        let months = Calendar.current.dateComponents([.month], from: effectiveStart, to: Date()).month ?? 0
        return months
    }

    /// Detecteer letters, cijfers, Tab en andere vaak gebruikte toetsen
    private func isShortcutKey(keyCode: Int64) -> Bool {
        let letterKeyCodes: Set<Int64> = [0,1,2,3,4,5,6,7,8,9,11,12,13,14,15,16,17,31,32,34,35,37,38,40,45,46]
        let numberKeyCodes: Set<Int64> = [18,19,20,21,23,22,26,28,25,29] // 1-0 bovenaan
        let specialKeyCodes: Set<Int64> = [
            48, // Tab
            50, // ` (backtick/grave accent)
            33, // [ (left bracket)
            30, // ] (right bracket)
            27, // - (minus/hyphen)
            24, // = (equals)
            39, // ' (single quote/apostrophe)
            41, // ; (semicolon)
            43, // , (comma)
            47, // . (period)
            44, // / (forward slash)
            42, // \ (backslash)
            53, // Escape
            36, // Return/Enter
            49, // Space
            51, // Delete (backspace)
            117, // Forward Delete
            123, // Left arrow
            124, // Right arrow
            125, // Down arrow
            126  // Up arrow
        ]
        return letterKeyCodes.contains(keyCode) || numberKeyCodes.contains(keyCode) || specialKeyCodes.contains(keyCode)
    }

    private func getKeyCharacter(keyCode: Int64) -> String {
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 23: return "5"
        case 22: return "6"
        case 26: return "7"
        case 28: return "8"
        case 25: return "9"
        case 29: return "0"
        case 48: return "Tab"
        case 50: return "`"
        case 33: return "["
        case 30: return "]"
        case 27: return "-"
        case 24: return "="
        case 39: return "'"
        case 41: return ";"
        case 43: return ","
        case 47: return "."
        case 44: return "/"
        case 42: return "\\"
        case 53: return "Esc"
        case 36: return "Return"
        case 49: return "Space"
        case 51: return "Delete"
        case 117: return "ForwardDelete"
        case 123: return "←"
        case 124: return "→"
        case 125: return "↓"
        case 126: return "↑"
        default: return "[\(keyCode)]"
        }
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}
