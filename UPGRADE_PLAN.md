# LiveWallpaper SwiftUI Upgrade Plan

## Overall Progress
- [x] Phase 0: Preparation completed
- [x] Phase 1: Foundation & Window Setup completed
- [x] Phase 2: Navigation Bar Implementation completed
- [x] Phase 3: Hero Section Development completed
- [ ] Phase 4: Gallery Row Component completed
- [ ] Phase 5: Thumbnail Card Implementation completed
- [ ] Phase 6: Data Flow & State Management completed
- [ ] Phase 7: Video Detail View completed
- [ ] Phase 8: Styling & Theme Compliance completed
- [ ] Phase 9: Final Integration & Polish completed
- [ ] Phase 10: Verification & Optimization completed
- [ ] Phase 11: Cleanup & Documentation completed

## Overview
This plan outlines the migration from the current AppKit-based UI to a SwiftUI implementation following the macos-wallpaper-ui skill guidelines. The goal is to achieve a premium Wallspace-style aesthetic with full-bleed backgrounds, floating pill navigation, frosted glass cards, and smooth horizontal galleries.

## Current State Assessment
- **Architecture**: AppKit (NSViewController, NSView) imperative UI
- **Key Files**: HomeViewController.swift, VideoDetailViewController.swift, HeroView.swift, etc.
- **Issues**: Manual layout, no modern SwiftUI patterns, missing skill-defined components, inconsistent styling

## Target State (Per macos-wallpaper-ui Skill)
- **Framework**: SwiftUI declarative UI
- **Components**: Floating Nav Bar, Hero Section, Horizontal Gallery Row, WallpaperCard, ThumbnailCard, etc.
- **Styling**: UltraThinMaterial, specific color schemes, typography scale, spacing rules
- **Window**: minWidth 900, minHeight 600, hidden title bar
- **Patterns**: AsyncImage, LazyHStack, proper state management, hover effects

## Upgrade Phases

### Phase 0: Preparation (Day 1)
**Goal**: Set up safe migration environment
- [x] Create git branch: `swiftui-migration`
- [x] Backup current Sources/ directory
- [x] Create new SwiftUI project structure:
  ```
  WallpaperApp/
  WallpaperApp.swift
  Views/
    ContentView.swift
    HeroView.swift
    NavBarView.swift
    GalleryRowView.swift
    VideoDetailView.swift
  Components/
    WallpaperCard.swift
    ThumbnailCard.swift
    ProBadge.swift
    FavoriteButton.swift
  Styles/
    NavPillStyle.swift
    HeroButtonStyle.swift
    Color+Hex.swift
  Models/
    Wallpaper.swift
  Extensions/
    (if needed)
  Resources/
    (images, assets)
  ```
- [x] Verify SwiftUI preview works in Xcode
- [x] Document current API contracts (PexelsAPI, VideoDownloader, WallpaperController)

### Phase 1: Foundation & Window Setup (Day 2)
**Goal**: Establish basic SwiftUI window and app structure
- [ ] Create WallpaperApp.swift:
  ```swift
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
  ```
- [ ] Implement Color+Hex.swift extension from skill
- [ ] Create basic ContentView.swift with placeholder text
- [ ] Verify app launches and meets window requirements
- [ ] Commit: "Foundation: SwiftUI app structure and window setup"

### Phase 2: Navigation Bar Implementation (Day 3)
**Goal**: Build floating pill nav bar per skill specification
- [ ] Create NavBarView.swift:
  - HStack with NavPillStyle buttons for tabs (Explore, Library, etc.)
  - Gift icon (SF Symbol: gift)
  - Search icon (SF Symbol: magnifyingglass)
  - PRO badge: amber capsule with white bold text
  - Background: .ultraThinMaterial in Capsule
  - Stroke border: .white.opacity(0.15)
  - Shadow radius: 12
- [ ] Implement NavPillStyle.swift per skill specification
- [ ] Integrate NavBarView into ContentView
- [ ] Verify hover/selection states work
- [ ] Commit: "Navigation: Floating pill bar with NavPillStyle"

### Phase 3: Hero Section Development (Day 4-5)
**Goal**: Create full-bleed hero with video preview and overlay controls
- [ ] Create HeroView.swift:
  - ZStack with:
    * Background image: .resizable(), .scaledToFill(), .clipped(), frame height 500
    * LinearGradient: [.clear, .black.opacity(0.75)] top to bottom
    * VStack with:
      - FEATURED label (size 11, semibold, tracking 1.5, white opacity 0.7)
      - Title label (size 28, bold, white)
      - Meta label (size 11, white opacity 0.6)
      - HStack with View Wallpaper button and Favorite button
  - Trailing thumbnail scroll (frame maxWidth .infinity, alignment .trailing, padding)
- [ ] Implement HeroButtonStyle.swift per skill
- [ ] Connect to PexelsAPI for data (maintain current API contract)
- [ ] Verify gradient overlay and text readability
- [ ] Commit: "Hero: Full-bleed section with video background and controls"

### Phase 4: Gallery Row Component (Day 6)
**Goal**: Implement horizontal gallery with proper cards and spacing
- [ ] Create GalleryRowView.swift:
  - VStack with:
    * HStack: section title, subtitle, Spacer(), chevron.right button
    * ScrollView(.horizontal, showsIndicators: false):
      - LazyHStack(spacing: 12):
        * ForEach wallpapers → WallpaperCard
        * Padding .horizontal 20
  - Section title: size 16, bold
  - Section subtitle: size 12, secondary color
- [ ] Create WallpaperCard.swift:
  - ZStack alignment .topTrailing:
    * Image: .resizable(), .scaledToFill(), frame 300x180, clipShape RoundedRectangle(cornerRadius 12)
    * Overlay: RoundedRectangle fill Color.black.opacity(isHovered ? 0.2 : 0)
    * PRO badge: Text("PRO") styling per skill (black text, amber capsule, padding)
  - Hover effects:
    * scaleEffect(isHovered ? 1.03 : 1.0)
    * shadow color: .black.opacity(isHovered ? 0.4 : 0.15), radius: isHovered ? 16 : 6
    * animation .easeInOut(duration: 0.18)
    * onHover { isHovered = $0 }
    * contentShape Rectangle
- [ ] Verify hover animations and PRO badge display
- [ ] Commit: "Gallery: Horizontal row with hover-enabled WallpaperCards"

### Phase 5: Thumbnail Card Implementation (Day 7)
**Goal**: Create interactive thumbnail cards for hero section
- [ ] Create ThumbnailCard.swift:
  - Image: .resizable(), .scaledToFill(), frame 120x72, clipShape RoundedRectangle(cornerRadius 10)
  - Overlay: RoundedRectangle strokeBorder .white.opacity(hovered ? 0.6 : 0.2), lineWidth 1
  - Shadow radius: hovered ? 10 : 4
  - onHover { hovered = $0 }
- [ ] Integrate into HeroView thumbnail row
- [ ] Verify hover stroke and shadow effects
- [ ] Commit: "Thumbnails: Interactive cards with hover states"

### Phase 6: Data Flow & State Management (Day 8-9)
**Goal**: Connect SwiftUI views to existing networking/model layers
- [ ] Create ViewModel (e.g., WallpaperViewModel):
  - @Published properties: featuredVideo, relatedVideos, exploreVideos, libraryVideos
  - Methods: fetchFeatured(), fetchExplore(), fetchLibrary() using existing PexelsAPI
  - Handle loading/error states
- [ ] Refactor views to use @StateObject or @ObservedObject
- [ ] Replace manual ImageCache with AsyncImage where appropriate (skill recommends AsyncImage for remote images)
- [ ] Maintain current API contracts with PexelsAPI/VideoDownloader/WallpaperController
- [ ] Verify data loads correctly and UI updates reactively
- [ ] Commit: "Data: ViewModel layer and reactive data binding"

### Phase 7: Video Detail View (Day 10)
**Goal**: Implement full-screen video detail per new UX requirement
- [ ] Create VideoDetailView.swift:
  - Full-screen AVPlayer video background (muted, looping)
  - LinearGradient overlay for text readability
  - Back button (chevron.left SF Symbol)
  - Title label: video.title.uppercased(), size 26, weight black, white
  - Meta label: dimensions × duration, size 12, medium, textSecondary
  - Button stack: SET AS WALLPAPER (accent background, black text) and DOWNLOAD (white text, border)
  - Progress bar and status label
  - DetailGradientView equivalent using SwiftUI
- [ ] Implement video playback using AVPlayer wrapped in SwiftUI (UIViewRepresentable if needed)
- [ ] Connect download functionality to existing VideoDownloader
- [ ] Verify full-screen experience and button actions
- [ ] Commit: "Detail: Full-screen video view with controls"

### Phase 8: Styling & Theme Compliance (Day 11)
**Goal**: Ensure all skill-defined styling rules are implemented
- [ ] Verify all colors use semantic values or hex extensions
- [ ] Check typography scale matches skill specification
- [ ] Confirm spacing: outer padding 20, inner spacing 12
- [ ] Validate card sizes: thumbnail ~160x100, featured ~300x180
- [ ] Check materials: .ultraThinMaterial for nav/cards, .regularMaterial where appropriate
- [ ] Verify dark/light mode support via semantic colors
- [ ] Check accessibility: minimum 44pt touch targets, respect reduce motion
- [ ] Commit: "Styling: Skill-compliant colors, typography, spacing, materials"

### Phase 9: Final Integration & Polish (Day 12)
**Goal**: Assemble all components and refine user experience
- [ ] Integrate NavBarView, HeroView, GalleryRowViews into ContentView
- [ ] Implement tab navigation (Explore/Library) showing different content
- [ ] Add video detail presentation as sheet or full-screen cover
- [ ] Implement proper loading/error states with skill-aligned styling
- [ ] Add subtle animations where appropriate (skill mentions .easeInOut)
- [ ] Verify PRO badge appears correctly on relevant content
- [ ] Test window resizing and minimum constraints
- [ ] Commit: "Integration: Complete UI assembly and navigation"

### Phase 10: Verification & Optimization (Day 13)
**Goal**: Ensure quality, performance, and compliance
- [ ] Run app and verify:
  * Window meets minWidth 900/minHeight 600
  * Title bar is hidden
  * All SF Symbols used correctly (magnifyingglass, gear, plus, heart, heart.fill, gift, chevron.right, chevron.left)
  * Hover effects work on all interactive elements
  * PRO badge styling matches skill (amber capsule)
  * Gradients and materials appear correct
  * Text readability on backgrounds
  * No blocking operations on main thread
  * AsyncImage used for remote images
  * LazyHStack for performant scrolling
  * Dark/light mode transition works
- [ ] Performance check: smooth scrolling, no lag on hover
- [ ] Compare against skill specification point-by-point
- [ ] Commit: "Verification: Final QA against skill requirements"

### Phase 11: Cleanup & Documentation (Day 14)
**Goal**: Finalize migration and document changes
- [ ] Remove unused AppKit files (after verifying functionality)
- [ ] Update any documentation or comments
- [ ] Create migration summary document
- [ ] Ensure git history is clean and meaningful
- [ ] Merge to main branch after team review
- [ ] Commit: "Cleanup: Removal of AppKit remnants and final docs"

## Risk Mitigation Strategies
1. **Incremental Migration**: Replace one view/controller at a time, keeping both implementations running temporarily via feature flags if needed
2. **API Contract Preservation**: Maintain exact same interfaces for PexelsAPI, VideoDownloader, WallpaperController to minimize backend changes
3. **Fallback Mechanisms**: Keep original AppKit views as reference during migration
4. **Preview-Driven Development**: Use SwiftUI previews extensively to verify UI without constant building
5. **Component Isolation**: Develop and test each SwiftUI component in isolation before integration

## Success Criteria
- [ ] All UI built with SwiftUI (zero AppKit views in production)
- [ ] Window meets size and title bar requirements from skill
- [ ] All 8 component patterns from skill implemented correctly
- [ ] Styling adheres to color, material, typography, spacing rules
- [ ] Modern SwiftUI patterns used (AsyncImage, LazyHStack, proper state management)
- [ ] Hover effects, animations, and interactive states work as specified
- [ ] Dark/light mode supported via semantic colors
- [ ] Accessibility guidelines followed (touch targets, reduce motion)
- [ ] Performance equivalent or better to original (smooth scrolling, responsive UI)
- [ ] All existing functionality preserved (video fetching, downloading, wallpaper setting)

## Estimated Timeline
- **Total**: 14 days (2 weeks)
- **Daily**: Focused implementation of 1-2 major components per day
- **Buffer**: Days 13-14 for verification, polishing, and risk mitigation

## Open Questions for Clarification
1. Should the tab navigation preserve the existing NavTab enum from memory context, or implement new SwiftUI navigation?
2. How should the VideoDetailView be presented? As a sheet, full-screen cover, or separate window?
3. Are there specific wallpaper categories or sorting beyond featured/explore/library that need UI representation?
4. Should we maintain the existing error/toast views or replace with SwiftUI alerts/overlays?

---
*Plan created based on macos-wallpaper-ui skill requirements and current LiveWallpaper Swift codebase analysis. Adjustments may be needed during implementation based on technical discoveries.*