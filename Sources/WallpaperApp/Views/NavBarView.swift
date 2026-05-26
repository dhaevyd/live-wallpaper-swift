import SwiftUI

enum NavTab: String, CaseIterable {
    case home    = "Home"
    case explore = "Explore"
    case library = "Library"
    case settings = "Settings"
}

struct NavBarView: View {
    @Binding var selectedTab: NavTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(NavTab.allCases, id: \.self) { tab in
                Button(tab.rawValue) { selectedTab = tab }
                    .buttonStyle(NavPillStyle(isSelected: selectedTab == tab))
            }

            Divider()
                .frame(height: 16)
                .padding(.horizontal, 4)

            Button {
            } label: {
                Image(systemName: "gift")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Button {
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)

            Text("PRO")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.wallflowAccent, in: Capsule())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 4)
    }
}
