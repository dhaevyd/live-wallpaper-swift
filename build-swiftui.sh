#!/bin/bash
# Build the SwiftUI version of Wallflow (run on macOS only)
# Set PEXELS_API_KEY in your environment for live data.
set -e

# Generate AppConfig with env var if set, otherwise use empty key
python3 - <<'PY'
import json, os
from pathlib import Path
key = os.environ.get("PEXELS_API_KEY", "")
Path("Sources/LiveWallpaper/AppConfig.swift").write_text(
    "import Foundation\n\nenum AppConfig {\n"
    f"    static let bakedPexelsAPIKey = {json.dumps(key)}\n}}\n"
)
PY

swiftc \
  Sources/LiveWallpaper/AppConfig.swift \
  Sources/LiveWallpaper/Models/Video.swift \
  Sources/LiveWallpaper/Models/Category.swift \
  Sources/LiveWallpaper/Network/PexelsAPI.swift \
  Sources/LiveWallpaper/Network/VideoDownloader.swift \
  Sources/WallpaperApp/WallpaperApp.swift \
  Sources/WallpaperApp/WallpaperViewModel.swift \
  Sources/WallpaperApp/Models/Wallpaper.swift \
  Sources/WallpaperApp/Views/ContentView.swift \
  Sources/WallpaperApp/Views/NavBarView.swift \
  Sources/WallpaperApp/Views/HeroView.swift \
  Sources/WallpaperApp/Views/GalleryRowView.swift \
  Sources/WallpaperApp/Views/VideoDetailView.swift \
  Sources/WallpaperApp/Components/WallpaperCard.swift \
  Sources/WallpaperApp/Components/ThumbnailCard.swift \
  Sources/WallpaperApp/Styles/NavPillStyle.swift \
  Sources/WallpaperApp/Styles/HeroButtonStyle.swift \
  Sources/WallpaperApp/Extensions/Color+Hex.swift \
  -target x86_64-apple-macosx13.0 \
  -framework Cocoa \
  -framework SwiftUI \
  -framework AVFoundation \
  -o WallflowSwiftUI 2>&1

echo "✓ Build succeeded → ./WallflowSwiftUI"
