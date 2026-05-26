import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.wallflowBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 56, weight: .thin))
                    .foregroundStyle(Color.wallflowAccent)

                Text("WALLFLOW")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.white)
                    .tracking(4)

                Text("SwiftUI migration in progress")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.45))

                HStack(spacing: 8) {
                    ForEach(1...11, id: \.self) { phase in
                        Circle()
                            .fill(phase == 1 ? Color.wallflowAccent : Color.white.opacity(0.14))
                            .frame(width: 7, height: 7)
                    }
                }

                Text("Phase 1 / 11 — Foundation & Window Setup")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.wallflowAccent.opacity(0.75))
            }
        }
        .preferredColorScheme(.dark)
    }
}
