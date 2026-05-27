#!/bin/bash
set -e

swiftc \
  Sources/LiveWallpaper/main.swift \
  Sources/LiveWallpaper/AppDelegate.swift \
  Sources/LiveWallpaper/WallpaperController.swift \
  Sources/LiveWallpaper/WallpaperWindow.swift \
  Sources/LiveWallpaper/StatusBarController.swift \
  Sources/LiveWallpaper/Views/ScreenPickerViewController.swift \
  -target x86_64-apple-macosx13.0 \
  -framework Cocoa \
  -framework AVFoundation \
  -o Wallflow

echo "Build succeeded → ./Wallflow"
