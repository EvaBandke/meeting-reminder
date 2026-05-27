import SwiftUI

struct AirplaneView: View {
    let meetingTitle: String
    let minutesUntil: Int
    let flightDuration: Double
    let screenWidth: CGFloat

    @State private var xOffset: CGFloat
    @State private var opacity: Double = 1.0

    init(meetingTitle: String, minutesUntil: Int, flightDuration: Double, screenWidth: CGFloat = NSScreen.main?.frame.width ?? 1_440) {
        self.meetingTitle   = meetingTitle
        self.minutesUntil   = minutesUntil
        self.flightDuration = flightDuration
        self.screenWidth    = screenWidth
        _xOffset = State(initialValue: -800)   // start fully off-left (wide enough for any banner+plane combo)
    }

    var body: some View {
        HStack(spacing: -10) {
            // Text drives the size; the (already-trimmed) banner stretches to fit behind it
            Text("\(meetingTitle) in \(minutesUntil) min")
                .font(.custom("Comic Sans MS", size: 28))
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 50)
                .padding(.vertical, 22)
                .background(
                    Image("banner")
                        .resizable()
                )

            // Custom airplane asset — drawn behind the banner so the rope tucks under
            Image("airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .zIndex(-1)
        }
        .fixedSize()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .offset(x: xOffset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.linear(duration: flightDuration)) {
                xOffset = screenWidth + 900  // end fully off-right (plane + banner width)
            }
            // Fade out in the last half-second
            DispatchQueue.main.asyncAfter(deadline: .now() + flightDuration - 0.6) {
                withAnimation(.easeIn(duration: 0.6)) {
                    opacity = 0
                }
            }
        }
    }
}

#Preview {
    AirplaneView(meetingTitle: "Weekly Standup", minutesUntil: 5, flightDuration: 14)
        .frame(width: 1000, height: 100)
        .background(Color.gray.opacity(0.2))
}
