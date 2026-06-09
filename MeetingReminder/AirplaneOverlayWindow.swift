import AppKit
import SwiftUI

// Transparent panel that floats above every window (including fullscreen apps).
// Clicking anywhere on it dismisses the meeting so it won't appear again.
final class AirplaneOverlayWindow: NSPanel {

    var onDismissed: (() -> Void)?

    init(meetingTitle: String, minutesUntil: Int, flightDuration: Double) {
        // Use the screen the user is NOT actively working on (non-main screen).
        // Falls back to main if there's only one screen.
        let allScreens = NSScreen.screens
        let activeScreen = NSScreen.main ?? allScreens[0]
        let screen = allScreens.first(where: { $0 != activeScreen }) ?? activeScreen
        let sf = screen.frame
        let height: CGFloat = 110
        let yPos = sf.minY + 100   // adjusted height

        super.init(
            contentRect: NSRect(x: sf.minX, y: yPos, width: sf.width, height: height),
            styleMask:   [.borderless, .nonactivatingPanel],
            backing:     .buffered,
            defer:       false
        )

        self.level               = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)) + 1)
        self.backgroundColor     = .clear
        self.isOpaque            = false
        self.hasShadow           = false
        self.ignoresMouseEvents  = false  // allow clicks
        self.collectionBehavior  = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.isReleasedWhenClosed = false

        let rootView    = AirplaneView(meetingTitle: meetingTitle,
                                       minutesUntil:  minutesUntil,
                                       flightDuration: flightDuration,
                                       screenWidth: sf.width)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.frame = NSRect(x: 0, y: 0, width: sf.width, height: height)
        hostingView.wantsLayer = true
        hostingView.layer?.backgroundColor = .clear
        self.contentView = hostingView

        // Overlay a transparent click-catcher so the animation still runs underneath
        let clickCatcher = ClickCatcherView(frame: hostingView.frame)
        clickCatcher.onClick = { [weak self] in self?.onDismissed?() }
        hostingView.addSubview(clickCatcher)
    }

    override var canBecomeKey:  Bool { false }
    override var canBecomeMain: Bool { false }
}

// Invisible view that sits on top of the SwiftUI content and forwards clicks.
private final class ClickCatcherView: NSView {
    var onClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        onClick?()
    }

    // Make the view transparent (not opaque, no background)
    override var isOpaque: Bool { false }
}
