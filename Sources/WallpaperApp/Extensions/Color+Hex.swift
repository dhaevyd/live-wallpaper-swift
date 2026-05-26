import SwiftUI

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

extension Color {
    static let wallflowBackground = Color(hex: "0c0c0c")
    static let wallflowSurface    = Color(hex: "1a1a1a")
    static let wallflowAccent     = Color(hex: "F5A623")
    static let wallflowBorder     = Color.white.opacity(0.10)
}
