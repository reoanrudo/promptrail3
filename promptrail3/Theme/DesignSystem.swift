//
//  DesignSystem.swift
//  promptrail3
//
//  Created by 田口怜央 on 2025/11/19.
//

import SwiftUI

// MARK: - Color System
extension Color {
    // Primary Colors (変化なし)
    static let prOrange = Color(hex: "FF6B35")
    static let prOrangeLight = Color(hex: "FF8C42")
    static let prOrangeDark = Color(hex: "E55A2B")

    // Accent Colors (変化なし)
    static let prCoral = Color(hex: "FF8A80")
    static let prPeach = Color(hex: "FFE0B2")

    // Adaptive Background Colors
    static let prBackground = Color(
        light: Color(hex: "FAFAFA"),
        dark: Color(hex: "121212")
    )

    static let prCardBackground = Color(
        light: Color.white,
        dark: Color(hex: "1E1E1E")
    )

    static let prSurfaceElevated = Color(
        light: Color.white,
        dark: Color(hex: "2C2C2C")
    )

    // Adaptive Text Colors
    static let prTextPrimary = Color(
        light: Color(hex: "212121"),
        dark: Color(hex: "F5F5F5")
    )

    static let prTextSecondary = Color(
        light: Color(hex: "757575"),
        dark: Color(hex: "B0B0B0")
    )

    static let prTextTertiary = Color(
        light: Color(hex: "9E9E9E"),
        dark: Color(hex: "808080")
    )

    // Adaptive Border Colors
    static let prBorder = Color(
        light: Color(hex: "E8E8E8"),
        dark: Color(hex: "3A3A3A")
    )

    static let prBorderHeavy = Color(
        light: Color(hex: "D0D0D0"),
        dark: Color(hex: "4A4A4A")
    )

    // Neutral Colors (後方互換用、徐々に廃止予定)
    static let prGray5 = Color(hex: "F5F5F5")
    static let prGray10 = Color(hex: "E8E8E8")
    static let prGray20 = Color(hex: "D0D0D0")
    static let prGray40 = Color(hex: "9E9E9E")
    static let prGray60 = Color(hex: "757575")
    static let prGray80 = Color(hex: "424242")
    static let prGray100 = Color(hex: "212121")

    // Semantic Colors (変化なし)
    static let prSuccess = Color(hex: "4CAF50")
    static let prWarning = Color(hex: "FF9800")
    static let prError = Color(hex: "F44336")
    static let prInfo = Color(hex: "2196F3")

    // Category Colors (変化なし)
    static let prCategoryBlue = Color(hex: "5C6BC0")
    static let prCategoryGreen = Color(hex: "66BB6A")
    static let prCategoryPurple = Color(hex: "AB47BC")
    static let prCategoryTeal = Color(hex: "26A69A")
    static let prCategoryAmber = Color(hex: "FFA726")

    // Adaptive Color Initializer
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }

    // Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography
struct PRTypography {
    // Display
    static let displayLarge = Font.system(size: 32, weight: .bold)
    static let displayMedium = Font.system(size: 28, weight: .bold)
    static let displaySmall = Font.system(size: 24, weight: .bold)

    // Headline
    static let headlineLarge = Font.system(size: 20, weight: .semibold)
    static let headlineMedium = Font.system(size: 17, weight: .semibold)
    static let headlineSmall = Font.system(size: 15, weight: .semibold)

    // Body
    static let bodyLarge = Font.system(size: 17, weight: .regular)
    static let bodyMedium = Font.system(size: 15, weight: .regular)
    static let bodySmall = Font.system(size: 14, weight: .regular)

    // Label
    static let labelLarge = Font.system(size: 14, weight: .medium)
    static let labelMedium = Font.system(size: 12, weight: .medium)
    static let labelSmall = Font.system(size: 10, weight: .medium)

    // Code
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
    static let codeSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
}

// MARK: - Spacing
struct PRSpacing {
    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

// MARK: - Radius
struct PRRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let pill: CGFloat = 100
}

// MARK: - Shadow
struct PRShadow {
    static let sm = ShadowStyle(
        lightColor: .black.opacity(0.05),
        darkColor: .black.opacity(0.3),
        radius: 4,
        x: 0,
        y: 2
    )
    static let md = ShadowStyle(
        lightColor: .black.opacity(0.08),
        darkColor: .black.opacity(0.4),
        radius: 12,
        x: 0,
        y: 4
    )
    static let lg = ShadowStyle(
        lightColor: .black.opacity(0.12),
        darkColor: .black.opacity(0.5),
        radius: 24,
        x: 0,
        y: 8
    )
    static let orange = ShadowStyle(
        lightColor: Color.prOrange.opacity(0.3),
        darkColor: Color.prOrange.opacity(0.2),
        radius: 20,
        x: 0,
        y: 4
    )
}

struct ShadowStyle {
    let lightColor: Color
    let darkColor: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    init(lightColor: Color, darkColor: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.lightColor = lightColor
        self.darkColor = darkColor
        self.radius = radius
        self.x = x
        self.y = y
    }

    // 後方互換用
    init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.lightColor = color
        self.darkColor = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    var color: Color {
        Color(light: lightColor, dark: darkColor)
    }
}

// MARK: - View Modifiers
extension View {
    func prShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    func prCardStyle() -> some View {
        self
            .background(Color.prCardBackground)
            .cornerRadius(PRRadius.lg)
            .prShadow(PRShadow.md)
    }

    func prPrimaryButton() -> some View {
        self
            .font(PRTypography.headlineSmall)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [.prOrange, .prOrangeLight],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(PRRadius.md)
            .prShadow(PRShadow.orange)
    }

    func prSecondaryButton() -> some View {
        self
            .font(PRTypography.labelLarge)
            .foregroundColor(Color.prTextPrimary)
            .padding(.horizontal, PRSpacing.md)
            .padding(.vertical, PRSpacing.sm)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: PRRadius.md)
                    .stroke(Color.prBorder, lineWidth: 1.5)
            )
    }

    func prSearchBar() -> some View {
        self
            .padding(PRSpacing.sm)
            .background(Color.prSurfaceElevated)
            .cornerRadius(PRRadius.xxl)
    }
}

// MARK: - Button Styles
struct PRPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .prPrimaryButton()
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PRSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .prSecondaryButton()
            .background(configuration.isPressed ? Color.prSurfaceElevated : Color.clear)
            .cornerRadius(PRRadius.md)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PRGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PRTypography.labelLarge)
            .foregroundColor(.prOrange)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Primary Button")
            .prPrimaryButton()

        Button("Secondary Button") {}
            .buttonStyle(PRSecondaryButtonStyle())

        Button("Ghost Button") {}
            .buttonStyle(PRGhostButtonStyle())

        HStack {
            Circle().fill(Color.prOrange).frame(width: 40, height: 40)
            Circle().fill(Color.prOrangeLight).frame(width: 40, height: 40)
            Circle().fill(Color.prCoral).frame(width: 40, height: 40)
            Circle().fill(Color.prGray40).frame(width: 40, height: 40)
        }
    }
    .padding()
}
