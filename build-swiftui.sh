#!/bin/bash
# Build the SwiftUI version of Wallflow (run on macOS only)
set -e

swiftc \
  Sources/WallpaperApp/WallpaperApp.swift \
  Sources/WallpaperApp/Views/ContentView.swift \
  Sources/WallpaperApp/Views/NavBarView.swift \
  Sources/WallpaperApp/Styles/NavPillStyle.swift \
  Sources/WallpaperApp/Styles/HeroButtonStyle.swift \
  Sources/WallpaperApp/Extensions/Color+Hex.swift \
  -target x86_64-apple-macosx12.0 \
  -framework Cocoa \
  -framework SwiftUI \
  -o WallflowSwiftUI 2>&1

echo "✓ Build succeeded → ./WallflowSwiftUI"
