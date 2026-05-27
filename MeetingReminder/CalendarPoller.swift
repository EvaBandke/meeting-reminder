import Foundation

@MainActor
final class CalendarPoller {
    /// How many minutes before a meeting to fire the alert.
    static let alertMinutesBefore: Double = 5
    /// Trigger when remaining time falls in [alertMinutesBefore - 1, alertMinutesBefore + 1].
    /// Use a 2-minute window to guarantee at least one poll hit with a 30s interval.
    private static let alertWindowLow:  Double = alertMinutesBefore - 1   // 4.0 min
    private static let alertWindowHigh: Double = alertMinutesBefore + 1   // 6.0 min

    var onMeetingSoon: ((CalendarEvent, Int) -> Void)?

    private let service: any CalendarSourceProvider
    private var timer: Timer?
    // Persists across poll cycles so we don't fire the same alert twice.
    // Capped at 200 entries to avoid unbounded growth in long-running sessions.
    private var notifiedIDs: Set<String> = []
    private var notifiedIDsOrder: [String] = []  // insertion-order tracker for eviction

    init(service: any CalendarSourceProvider) {
        self.service = service
    }

    func start() {
        poll()
        // Poll every 30 s — snappier response, still well within battery budget
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            DispatchQueue.main.async { [weak self] in self?.poll() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: Private

    private func poll() {
        Task {
            let now = Date()
            guard let events = try? await service.fetchUpcomingEvents() else {
                print("[CalendarPoller] ⚠️ fetchUpcomingEvents returned nil or threw")
                return
            }

            print("[CalendarPoller] 🔍 poll at \(now) — \(events.count) event(s) in next hour")

            for event in events {
                let minutesDouble = event.startDate.timeIntervalSince(now) / 60
                let minutesInt    = Int(minutesDouble)
                print("[CalendarPoller]   • '\(event.title)' starts in \(String(format: "%.1f", minutesDouble)) min (notified: \(notifiedIDs.contains(event.id)))")

                guard minutesDouble >= Self.alertWindowLow,
                      minutesDouble <= Self.alertWindowHigh,
                      !notifiedIDs.contains(event.id) else { continue }

                print("[CalendarPoller] ✈️ FIRING alert for '\(event.title)' — \(minutesInt) min away")
                notifiedIDs.insert(event.id)
                notifiedIDsOrder.append(event.id)
                // Evict oldest entries beyond cap to prevent unbounded growth
                if notifiedIDsOrder.count > 200 {
                    let evicted = notifiedIDsOrder.removeFirst()
                    notifiedIDs.remove(evicted)
                }
                onMeetingSoon?(event, minutesInt)
            }
        }
    }
}
