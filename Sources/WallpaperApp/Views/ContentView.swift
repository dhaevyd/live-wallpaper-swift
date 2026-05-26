import SwiftUI

struct ContentView: View {
    @State private var selectedTab: NavTab = .home

    var body: some View {
        ZStack(alignment: .top) {
            Color.wallflowBackground.ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            NavBarView(selectedTab: $selectedTab)
                .padding(.top, 16)
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            ScrollView {
                VStack(spacing: 0) {
                    HeroView(
                        featured: .placeholder,
                        thumbnails: Wallpaper.mockThumbnails
                    )
                    Spacer()
                }
            }
            .scrollIndicators(.never)
        case .explore:
            tabPlaceholder("Explore", icon: "safari.fill")
        case .library:
            tabPlaceholder("Library", icon: "folder.fill")
        case .settings:
            tabPlaceholder("Settings", icon: "gear")
        }
    }

    private func tabPlaceholder(_ name: String, icon: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40, weight: .thin))
                .foregroundStyle(Color.wallflowAccent.opacity(0.6))
            Text(name.uppercased())
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(3)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
