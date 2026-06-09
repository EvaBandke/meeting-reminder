import Foundation

/// Watches for Microsoft Outlook reminder windows via Accessibility/System Events.
/// No calendar read permission needed — just Accessibility access.
final class OutlookCalendarService: CalendarSourceProvider {

    func fetchUpcomingEvents() async throws -> [CalendarEvent] {
        let script = """
        tell application "System Events"
            if not (exists process "Microsoft Outlook") then return {}
            tell process "Microsoft Outlook"
                set result to {}
                repeat with w in every window
                    set wTitle to title of w
                    -- Outlook reminder windows contain "Reminder" in the title
                    if wTitle contains "Reminder" or wTitle contains "Erinnerung" then
                        set result to result & {wTitle}
                    end if
                end repeat
                return result
            end tell
        end tell
        """

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                var error: NSDictionary?
                guard let appleScript = NSAppleScript(source: script) else {
                    continuation.resume(returning: [])
                    return
                }
                let output = appleScript.executeAndReturnError(&error)

                // Accessibility not granted yet — return empty, app will prompt
                if error != nil {
                    continuation.resume(returning: [])
                    return
                }

                var events: [CalendarEvent] = []
                let count = output.numberOfItems
                guard count > 0 else {
                    continuation.resume(returning: [])
                    return
                }
                for i in 1...count {
                    guard let title = output.atIndex(i)?.stringValue else { continue }
                    // Use the window title as the meeting name, fire "now"
                    let now = Date()
                    events.append(CalendarEvent(
                        id:        title, // stable per reminder window
                        title:     title,
                        startDate: now.addingTimeInterval(60 * 10), // treat as 10 min away
                        endDate:   now.addingTimeInterval(60 * 60)
                    ))
                }
                continuation.resume(returning: events)
            }
        }
    }
}
