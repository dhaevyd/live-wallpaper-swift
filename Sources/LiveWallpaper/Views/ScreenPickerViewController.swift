import Cocoa
import UniformTypeIdentifiers

final class ScreenPickerViewController: NSViewController {
    private let stack = NSStackView()

    override func loadView() {
        let v = NSView()
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor(white: 0.09, alpha: 1).cgColor
        view = v
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stack.orientation = .vertical
        stack.spacing = 0
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        reload()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screensChanged() { reload() }

    func reload() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, screen) in NSScreen.screens.enumerated() {
            stack.addArrangedSubview(makeRow(screen: screen, index: i))
        }
        let h = CGFloat(NSScreen.screens.count) * 68
        preferredContentSize = NSSize(width: 520, height: h)
        view.window?.setContentSize(NSSize(width: 520, height: h))
    }

    // MARK: - Row

    private func makeRow(screen: NSScreen, index: Int) -> NSView {
        let bg = NSView()
        bg.wantsLayer = true
        bg.layer?.backgroundColor = (index % 2 == 0)
            ? NSColor(white: 0.11, alpha: 1).cgColor
            : NSColor(white: 0.14, alpha: 1).cgColor

        // Left: name + subtitle
        let nameLabel = label(screen.localizedName.isEmpty ? "Display \(index + 1)" : screen.localizedName,
                              size: 13, weight: .semibold, color: .white)
        let activeURL = WallpaperController.shared.currentURL(for: screen)
        let subText = activeURL?.lastPathComponent
            ?? "\(Int(screen.frame.width)) × \(Int(screen.frame.height))"
        let subColor: NSColor = activeURL != nil
            ? NSColor(red: 0.95, green: 0.76, blue: 0.12, alpha: 1)
            : .secondaryLabelColor
        let subLabel = label(subText, size: 11, weight: .regular, color: subColor)
        subLabel.lineBreakMode = .byTruncatingMiddle
        subLabel.maximumNumberOfLines = 1

        let textStack = NSStackView(views: [nameLabel, subLabel])
        textStack.orientation = .vertical
        textStack.spacing = 3
        textStack.alignment = .leading
        textStack.setContentHuggingPriority(.defaultLow, for: .horizontal)

        // Right: buttons
        var buttons: [NSView] = []
        if activeURL != nil {
            let stop = button("Stop", tag: index, action: #selector(stopTapped(_:)))
            buttons.append(stop)
        }
        let choose = button("Choose Video…", tag: index, action: #selector(chooseTapped(_:)))
        buttons.append(choose)

        let btnStack = NSStackView(views: buttons)
        btnStack.spacing = 8
        btnStack.setContentHuggingPriority(.required, for: .horizontal)

        // Full row
        let row = NSStackView(views: [textStack, btnStack])
        row.orientation = .horizontal
        row.distribution = .fill
        row.spacing = 16
        row.edgeInsets = NSEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        row.translatesAutoresizingMaskIntoConstraints = false

        bg.addSubview(row)
        NSLayoutConstraint.activate([
            row.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            row.leadingAnchor.constraint(equalTo: bg.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: bg.trailingAnchor),
            bg.heightAnchor.constraint(equalToConstant: 68),
            bg.widthAnchor.constraint(equalToConstant: 520),
        ])

        return bg
    }

    // MARK: - Actions

    @objc private func chooseTapped(_ sender: NSButton) {
        let i = sender.tag
        guard i < NSScreen.screens.count else { return }
        let screen = NSScreen.screens[i]

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .mpeg4Movie, .quickTimeMovie]
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Choose a video wallpaper"

        panel.beginSheetModal(for: view.window!) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            WallpaperController.shared.play(url: url, on: screen)
            self?.reload()
        }
    }

    @objc private func stopTapped(_ sender: NSButton) {
        let i = sender.tag
        guard i < NSScreen.screens.count else { return }
        WallpaperController.shared.stop(screen: NSScreen.screens[i])
        reload()
    }

    // MARK: - Helpers

    private func label(_ text: String, size: CGFloat, weight: NSFont.Weight, color: NSColor) -> NSTextField {
        let f = NSTextField(labelWithString: text)
        f.font = .systemFont(ofSize: size, weight: weight)
        f.textColor = color
        return f
    }

    private func button(_ title: String, tag: Int, action: Selector) -> NSButton {
        let b = NSButton(title: title, target: self, action: action)
        b.tag = tag
        b.bezelStyle = .rounded
        b.font = .systemFont(ofSize: 12)
        return b
    }
}
