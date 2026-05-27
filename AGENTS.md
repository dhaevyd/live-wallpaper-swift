<claude-mem-context>
# Memory Context

# [live-wallpaper-swift] recent context, 2026-05-27 9:11am UTC

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 50 obs (19,008t read) | 836,748t work | 98% savings

### May 26, 2026
S289 LiveWall v2 SwiftUI Migration — Phase 3 Hero Section complete, Phase 4 Gallery Row next (May 26, 1:03 PM)
S290 LiveWall v2 SwiftUI Migration — Phase 4 Gallery Row complete, Phase 5 skipped (already done), Phase 6 ViewModel next (May 26, 1:08 PM)
S291 LiveWall v2 SwiftUI Migration — Phases 5+6 complete (ViewModel, live data, Explore tab), Phase 7 Video Detail next (May 26, 1:11 PM)
533 1:12p 🟣 Wallpaper(from:PexelsVideo) bridge initializer added — SwiftUI model mapped from AppKit network type
534 1:13p 🟣 HeroView gains isLoading state — amber spinner overlay during data fetch
535 " 🟣 ContentView fully wired to WallpaperViewModel — live data, Explore tab, category chips, error/retry UI
536 " 🟣 build-swiftui.sh now compiles full stack — AppKit network layer + Python API key injection
S292 Build verification attempt — confirmed SwiftUI binary cannot be built on Linux host (May 26, 1:14 PM)
S293 CI build compatibility check — confirmed build.yml only covers AppKit, SwiftUI not validated until Phase 9 (May 26, 1:15 PM)
S294 LiveWall v2 SwiftUI Migration — Phases 7, 8, 9 complete; CI SwiftUI job added; Phase 10+11 remain (May 26, 1:16 PM)
537 1:19p 🟣 VideoDetailView.swift created — full-screen SwiftUI video detail with AVPlayer, download, and set-wallpaper
538 " 🟣 Accessibility reduce-motion support added to WallpaperCard and ThumbnailCard
539 " 🟣 NavBar icon touch targets enlarged to 44pt; toolbar with Wallflow branding added to ContentView
540 " ✅ build.yml CI now triggers on swiftui-migration branch pushes
S295 Pre-push verification — confirming commit state before pushing swiftui-migration to remote (May 26, 1:20 PM)
541 1:22p 🔵 Phase 7 VideoDetailView.swift confirmed never committed — not in git history
S296 Push swiftui-migration to remote — CI now running both AppKit and SwiftUI build jobs (May 26, 1:23 PM)
542 1:24p ✅ swiftui-migration branch pushed to remote — CI build jobs now running
S297 CI fix — SwiftUI build target bumped to macOS 13.0 after compile failure on CI (May 26, 1:24 PM)
543 1:26p ✅ SwiftUI CI build target bumped from macos12.0 to macos13.0
544 " 🔴 CI SwiftUI build target fixed — macOS 12.0 → 13.0 required for scrollIndicators and tracking APIs
### May 27, 2026
S298 Check for UPGRADE PLANS in the live-wallpaper-swift project and review current state for Phase 7 implementation (May 27, 8:41 AM)
550 8:41a 🔵 Live Wallpaper macOS App — Dual-Target Swift Project Structure Discovered
551 " 🔵 Wallflow Build System Uses Raw swiftc + Python-Generated AppConfig
552 " 🔵 PexelsAPI Implementation — Missing PexelsResponse Struct, Force-Unwrap URL
553 " 🔵 VideoDownloader Has Silent Failure Bug When tempURL Is Nil
554 " 🔵 Video.swift Data Models — PexelsVideo.bestVideoFile Excludes UHD Quality
555 " 🔵 HomeViewController — AppKit UI Layer with Duplicated setAsWallpaper / showToast Logic
556 " 🔵 ExploreViewController — Generation Counter Prevents Stale Results, Force-Cast in Collection View
557 " 🔵 LibraryViewController — Security-Scoped Bookmarks with Strong Self Retain Cycle in NSOpenPanel
558 8:45a 🔵 LibraryVideoItem Hover Preview — Strong Self Capture in Thumbnail Generation
559 " 🔵 VideoCardView — Invalid AVPlayer URL When bestVideoFile Is Nil
560 " 🔵 HeroView — 4K Badge Uses Container Dimensions Not Video File Width, Player Reuse Pattern
561 8:52a 🔵 WallpaperWindow — Retain Cycle in Loop Observer, Force-Unwraps, and makeKeyAndOrderFront Bug
562 " 🔵 WallpaperController — setLooping() Does Not Update Active Windows, defaultWallpaperFolder Duplicated
563 " 🔵 AppDelegate — Status Bar App Architecture with Force-Unwrap and Strong Self Capture
564 8:53a 🔵 StatusBarController — Status Icon Uses isTemplate=false, Menu State Staleness Risk
565 " 🔵 MainWindowController — Library Tab Rescans Filesystem on Every Tab Switch, pinContentView Constraint Accumulation
566 " 🔵 SettingsViewController — "Launch at Login" and "Same Video on All Screens" Toggles Are UI-Only (Unimplemented)
567 " 🔵 WallflowAssets Falls Back to CWD-Relative Path — Fails in Production Bundles
568 " 🔵 SwiftUI WallpaperApp Entry Point References AppKit NavTab via NotificationCenter Cross-Target Coupling
569 8:59a 🔵 Wallflow macOS Live Wallpaper App — Full Codebase Audit Complete
570 " 🔵 Critical Bug: WallpaperWindow NotificationCenter Retain Cycle + Observer Accumulation
571 " 🔵 Critical Bug: VideoDownloader Silent Failure on tempURL nil
572 " 🔵 Critical Bug: VideoCardView Creates AVPlayer with Empty/Invalid URL
573 " 🔵 Bug: PexelsVideo.bestVideoFile Excludes UHD/4K Quality Files
574 " 🔵 Bug: MainWindowController Accumulates Auto Layout Constraints on Every Tab Switch
575 " 🔵 Bug: LibraryViewController Retain Cycle in changeFolder NSOpenPanel Closure
576 " 🔵 Bug: SettingsViewController Toggle Actions Have No Backing Implementation
577 " 🔵 Structural Issues: Code Duplication, Misplaced Types, and Dead Code
578 9:01a 🔵 GitHub Actions CI Pipeline: Unsigned App Build, x86_64 Only, No Codesign Step
579 " 🔵 Active SwiftUI Migration Branch and UPGRADE_PLAN.md In Progress
580 " 🔵 PexelsAPI Key Resolution: Runtime Env Var Takes Priority Over Baked Binary Key
581 9:05a 🔵 Swift Toolchain Not Available in Dev Environment; Build Only Possible via CI
582 " 🔵 Recent Git History: PlayerNSView Layer Fix and Wallpaper Equatable Conformance
583 " 🔵 Git-Tracked File Inventory: docs/ and AGENTS.md Are Untracked; Legacy WallpaperApp/ Is Tracked
584 " 🔵 VideoDetailView "SET AS WALLPAPER" Button Is a Stub With Empty Action
585 " 🔵 DownloadState in VideoDetailView: Silent Failure on tempURL nil, Same Pattern as VideoDownloader
586 " 🔵 SwiftUI HeroView setupPlayer: NotificationCenter Observer Leaks Old AVPlayer Instances
587 " 🔵 VideoPlayerView NSViewRepresentable: Correct wantsLayer Pattern for AVPlayerLayer Backing

Access 837k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>