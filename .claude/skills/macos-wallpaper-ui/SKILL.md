---
name: macos-wallpaper-ui
description: >
  Design sleek, native macOS app UIs inspired by a Wallspace-style aesthetic:
  full-bleed hero backgrounds, floating pill navigation, frosted glass cards,
  and smooth horizontal scroll galleries, all implemented in SwiftUI.
---

# macOS Wallpaper App UI Designer

This skill defines the visual language, component patterns, and SwiftUI code
snippets to build a native, premium-feeling macOS wallpaper app UI.

Color and Materials
- Use .ultraThinMaterial and .regularMaterial for overlays on nav and cards
- Background and hero images go edge-to-edge using .scaledToFill() and .clipped()
- Hero text is white with a subtle shadow or gradient backdrop for readability
- Active nav pill has white background and dark text
- Inactive nav has clear background and secondary text
- PRO badge is an amber capsule using Color(hex: "F5A623")
- Card hover overlay uses Color.black.opacity between 0.2 and 0.4

Layout Rules
- Window minimum is minWidth 900 and minHeight 600
- Hidden title bar using .windowStyle(.hiddenTitleBar)
- Centered floating nav bar in a capsule with material background
- Hero section uses ZStack with a bottom gradient to lift text
- Rows use ScrollView horizontal with LazyHStack spacing 12
- Thumbnail size is approximately 160 by 100
- Featured card size is approximately 300 by 180
- Outer padding is 20 and inner spacing is 12

Typography
- App title uses .system size 14 weight semibold
- Hero title uses .system size 28 weight bold in white
- Hero meta uses .system size 11 in white with opacity 0.6 to 0.7
- Section title uses .system size 16 weight bold
- Section subtitle uses .system size 12 in secondary color
- Badge text uses .system size 10 weight bold

Window and Chrome
- Standard macOS traffic lights remain visible
- Content bleeds to top edge with no visible title bar
- Top right has SF Symbols plus and gear
- Top left has app logo and name beside traffic lights

Component Patterns

1) Floating Nav Bar

HStack(spacing: 4) {
    ForEach(navItems, id: \.self) { item in
        Button(item) { selectedNav = item }
            .buttonStyle(NavPillStyle(isSelected: selectedNav == item))
    }
    Button { } label: { Image(systemName: "gift") }
        .buttonStyle(.plain)
    Button { } label: { Image(systemName: "magnifyingglass") }
        .buttonStyle(.plain)
    Text("PRO")
        .font(.system(size: 12, weight: .bold))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black, in: Capsule())
        .foregroundStyle(.white)
}
.padding(6)
.background(.ultraThinMaterial, in: Capsule())
.overlay(Capsule().strokeBorder(.white.opacity(0.15), lineWidth: 1))
.shadow(radius: 12)

2) Hero Section

ZStack(alignment: .bottomLeading) {
    Image("hero_wallpaper")
        .resizable()
        .scaledToFill()
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .clipped()

    LinearGradient(
        colors: [.clear, .black.opacity(0.75)],
        startPoint: .top,
        endPoint: .bottom
    )

    VStack(alignment: .leading, spacing: 6) {
        Text("FEATURED")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.7))
            .tracking(1.5)
        Text("Abandoned Train Station Scenic View")
            .font(.system(size: 28, weight: .bold))
            .foregroundStyle(.white)
        Text("Nature  3840x2160  63MB")
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.6))
        HStack(spacing: 10) {
            Button("View Wallpaper") { }
                .buttonStyle(HeroButtonStyle())
            Button { isFav.toggle() } label: {
                Image(systemName: isFav ? "heart.fill" : "heart")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
    .padding(28)

    HStack(spacing: 8) {
        ForEach(thumbnails) { thumb in
            ThumbnailCard(image: thumb)
        }
    }
    .frame(maxWidth: .infinity, alignment: .trailing)
    .padding(.trailing, 20)
    .padding(.bottom, 90)
}

3) Horizontal Gallery Row

VStack(alignment: .leading, spacing: 10) {
    HStack(alignment: .bottom) {
        VStack(alignment: .leading, spacing: 2) {
            Text("Wallspace Pick")
                .font(.system(size: 16, weight: .bold))
            Text("Curated selection of the finest wallpapers")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        Spacer()
        Button { } label: {
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
    }
    .padding(.horizontal, 20)

    ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 12) {
            ForEach(wallpapers) { item in
                WallpaperCard(wallpaper: item)
            }
        }
        .padding(.horizontal, 20)
    }
}

4) Wallpaper Card with Hover

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(wallpaper.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(isHovered ? 0.2 : 0))
                )
            if wallpaper.isPro {
                Text("PRO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "F5A623"), in: Capsule())
                    .padding(10)
            }
        }
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .shadow(color: .black.opacity(isHovered ? 0.4 : 0.15),
                radius: isHovered ? 16 : 6)
        .animation(.easeInOut(duration: 0.18), value: isHovered)
        .onHover { isHovered = $0 }
        .contentShape(Rectangle())
    }
}

5) Thumbnail Card

struct ThumbnailCard: View {
    let image: String
    @State private var hovered = false

    var body: some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(.white.opacity(hovered ? 0.6 : 0.2), lineWidth: 1)
            )
            .shadow(radius: hovered ? 10 : 4)
            .onHover { hovered = $0 }
    }
}

6) NavPillStyle

struct NavPillStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(isSelected ? Color.black : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(isSelected ? Color.white : Color.clear, in: Capsule())
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

7) HeroButtonStyle

struct HeroButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.white, in: Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

8) App Entry Point

@main
struct WallpaperApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
    }
}

9) Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

Key SwiftUI APIs
- .ultraThinMaterial for frosted glass nav and cards
- .onHover for hover effects on cards
- LazyHStack for performant horizontal galleries
- .windowStyle(.hiddenTitleBar) for full bleed seamless window
- .scaledToFill() and .clipped() for hero and card images
- LinearGradient for hero text readability overlay
- AsyncImage for remote wallpaper loading

SF Symbols Used
- magnifyingglass for search
- gear for settings
- plus for add
- heart for favourite empty
- heart.fill for favourite filled
- gift for promo
- chevron.right for section nav

Rules Always Follow
- SwiftUI first and AppKit only for system level integration
- AsyncImage for all remote images and never block main thread
- Always use .clipped() after .scaledToFill()
- Support Dark and Light Mode via semantic colors
- Respect @Environment(\.colorScheme) and @Environment(\.accessibilityReduceMotion)
- Minimum click target 44 by 44 pt
- Follow Apple HIG for macOS

Anti-Patterns Never Do
- No hardcoded colors without dark mode fallback
- No custom fonts without system font fallback
- No UIKit imports in a macOS SwiftUI target
- No blocking operations on main thread

Recommended File Structure
WallpaperApp/
WallpaperApp.swift
Views/
  ContentView.swift
  HeroView.swift
  NavBarView.swift
  GalleryRowView.swift
Components/
  WallpaperCard.swift
  ThumbnailCard.swift
  ProBadge.swift
  FavoriteButton.swift
Styles/
  NavPillStyle.swift
  HeroButtonStyle.swift
Models/
  Wallpaper.swift
Extensions/
  Color+Hex.swift
