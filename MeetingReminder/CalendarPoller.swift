import Foundation

@MainActor
final class CalendarPoller {
    /// Alert windows (minutes before meeting) — airplane fires at each of these.
    static let alertWindows: [Int] = [10, 6, 2]

    var onMeetingSoon: ((CalendarEvent, Int) -> Void)?

    private let service: any CalendarSourceProvider
    private var timer: Timer?
    // Key: eventID, Value: set of alert-minute values already fired
    private var notifiedWindows: [String: Set<Int>] = [:]
    // Events the user dismissed by clicking — never show again
    var dismissedIDs: Set<String> = []

    init(service: any CalendarSourceProvider) {
        self.service = service
    }

    func start() {
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
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
            guard let events = try? await service.fetchUpcomingEvents() else { return }

            let now = Date()
            for event in events {
                guard !dismissedIDs.contains(event.id) else { continue }

                let minutes = Int(event.startDate.timeIntervalSince(now) / 60)

                for window in Self.alertWindows {
                    // Fire if within ±1 minute of this alert window
                    guard abs(minutes - window) <= 1 else { continue }
                    var fired = notifiedWindows[event.id] ?? []
                    guard !fired.contains(window) else { continue }

                    fired.insert(window)
                    notifiedWindows[event.id] = fired
                    onMeetingSoon?(event, minutes)
                    break
                }
            }
        }
    }
}
