# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

This is a pure Swift macOS app built with `swiftc` directly — no Xcode project, no Swift Package Manager.

**Local build:**
```bash
swiftc \
  Sources/LiveWallpaper/main.swift \
  Sources/LiveWallpaper/AppDelegate.swift \
  Sources/LiveWallpaper/StatusBarController.swift \
  Sources/LiveWallpaper/WallpaperController.swift \
  Sources/LiveWallpaper/WallpaperWindow.swift \
  Sources/LiveWallpaper/Network/PexelsAPI.swift \
  Sources/LiveWallpaper/Network/VideoDownloader.swift \
  Sources/LiveWallpaper/Models/Video.swift \
  Sources/LiveWallpaper/Models/Category.swift \
  Sources/LiveWallpaper/Views/MainWindowController.swift \
  Sources/LiveWallpaper/Views/HomeViewController.swift \
  Sources/LiveWallpaper/Views/ExploreViewController.swift \
  Sources/LiveWallpaper/Views/LibraryViewController.swift \
  Sources/LiveWallpaper/Views/SettingsViewController.swift \
  Sources/LiveWallpaper/Views/Components/NavBar.swift \
  Sources/LiveWallpaper/Views/Components/HeroView.swift \
  Sources/LiveWallpaper/Views/Components/VideoCardView.swift \
  -target x86_64-apple-macosx11.0 \
  -framework Cocoa \
  -framework AVFoundation \
  -framework AVKit \
  -o LiveWallpaper
```

The CI workflow (`.github/workflows/build.yml`) runs the same command on `push` to `main` and uploads a zipped `.app` bundle as an artifact.

**Runtime requirement:** The `PEXELS_API_KEY` environment variable must be set for API calls to work. In CI it comes from repository secrets.

## Architecture

The app runs as an `.accessory` activation policy (no Dock icon) with a menu bar item as the primary entry point.

**Startup flow:** `main.swift` → `AppDelegate` → creates `WallpaperController` + `StatusBarController` → opens `MainWindowController` on first launch.

**Core objects:**

- `WallpaperController` — owns all `WallpaperWindow` instances (one per screen). Coordinates play/pause/stop/mute across all screens.
- `WallpaperWindow` — an `NSWindow` positioned at desktop level (`CGWindowLevelForKey(.desktopWindow)`), borderless, ignores mouse events. Uses `AVPlayer` + `AVPlayerLayer` to render video behind all other windows.
- `StatusBarController` — menu bar item with inline play/pause/stop controls. Calls back into `WallpaperController` and rebuilds the menu after each action.

**Main window:**

- `MainWindowController` (900×640, dark background) hosts a `NavBar` at the top and a content area below.
- Four tabs: Home, Explore, Library, Settings — each backed by a dedicated `NSViewController`.
- The Library tab calls `loadVideos()` on every tab switch to reflect newly downloaded files.

**Network layer:**

- `PexelsAPI` — singleton, talks to `api.pexels.com/videos`. Supports `/popular` and `/search` (with landscape orientation filter). API key read from environment at init.
- `VideoDownloader` — singleton, downloads to `~/Movies/LiveWallpapers/<videoId>.mp4`. Checks for existing file before re-downloading. Tracks in-flight tasks by video ID for cancellation.

**Models:**

- `PexelsVideo` / `PexelsVideoFile` / `PexelsUser` — Codable structs mapping the Pexels API response. `bestVideoFile` picks the widest HD or SD file.
- `Category` — value type with a `query` string sent to Pexels search. The static `all` array defines the fixed category list.

**No storyboards, no XIBs.** All UI is built programmatically with AppKit.
