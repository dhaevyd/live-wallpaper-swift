import SwiftUI

struct ContentView: View {
    @StateObject private var vm = WallpaperViewModel()
    @State private var selectedTab: NavTab = .home
    @State private var selectedWallpaper: Wallpaper? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.wallflowBackground.ignoresSafeArea()

            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            NavBarView(selectedTab: $selectedTab)
                .padding(.top, 16)

            if let wallpaper = selectedWallpaper {
                VideoDetailView(wallpaper: wallpaper) {
                    selectedWallpaper = nil
                }
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .preferredColorScheme(.dark)
        .task { vm.fetchHome() }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(Color.wallflowAccent)
                    Text("Wallflow")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Button {
                    selectedTab = .settings
                } label: {
                    Image(systemName: "gear")
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Tab routing

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:  homeTab
        case .explore: exploreTab
        case .library: tabPlaceholder("Library", icon: "folder.fill")
        case .settings: tabPlaceholder("Settings", icon: "gear")
        }
    }

    // MARK: - Home

    private var homeTab: some View {
        Group {
            if let error = vm.homeError {
                apiErrorView(message: error) { vm.fetchHome() }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HeroView(
                            featured: vm.featured,
                            thumbnails: vm.featuredThumbnails,
                            isLoading: vm.isLoadingHome
                        )

                        if !vm.curatedPicks.isEmpty {
                            GalleryRowView(
                                title: "Wallflow Picks",
                                subtitle: "Curated selection of the finest wallpapers",
                                wallpapers: vm.curatedPicks,
                                onCardTap: { selectedWallpaper = $0 }
                            )
                        }

                        Spacer(minLength: 40)
                    }
                }
                .scrollIndicators(.never)
            }
        }
    }

    // MARK: - Explore

    private var exploreTab: some View {
        Group {
            if let error = vm.exploreError {
                apiErrorView(message: error) {
                    if let cat = vm.selectedCategory {
                        vm.fetchCategory(cat)
                    } else {
                        vm.fetchCategory(Category.all[0])
                    }
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        categoryChips

                        if vm.isLoadingExplore {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(Color.wallflowAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                        } else if !vm.exploreResults.isEmpty {
                            GalleryRowView(
                                title: vm.selectedCategory?.name ?? "Search Results",
                                subtitle: "\(vm.exploreResults.count) wallpapers",
                                wallpapers: vm.exploreResults,
                                onCardTap: { selectedWallpaper = $0 }
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
                .scrollIndicators(.never)
                .task {
                    if vm.exploreResults.isEmpty {
                        vm.fetchCategory(Category.all[0])
                    }
                }
            }
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Category.all, id: \.name) { cat in
                    let isActive = vm.selectedCategory?.name == cat.name
                    Button {
                        vm.fetchCategory(cat)
                    } label: {
                        Text("\(cat.emoji) \(cat.name)")
                            .font(.system(size: 12, weight: isActive ? .semibold : .regular))
                            .foregroundStyle(isActive ? .black : .white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                isActive ? Color.wallflowAccent : Color.wallflowSurface,
                                in: Capsule()
                            )
                            .overlay(
                                Capsule().strokeBorder(
                                    isActive ? Color.clear : Color.wallflowBorder,
                                    lineWidth: 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isActive)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Shared helpers

    private func apiErrorView(message: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.wallflowAccent)
            Text("FETCH FAILED")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.white)
                .tracking(2)
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 48)
            Button("Retry") { retry() }
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(Color.wallflowAccent, in: Capsule())
                .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
