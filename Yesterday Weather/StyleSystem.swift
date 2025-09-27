//
//  StyleSystem.swift
//  Yesterday Weather
//
//  Created by Claude AI on 9/26/25.
//

import SwiftUI

// MARK: - Reusable View Modifiers

struct CardStyle: ViewModifier {
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    init(backgroundColor: Color = Color.warmBackground.opacity(0.6),
         cornerRadius: CGFloat = 12,
         shadowRadius: CGFloat = 2) {
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 1)
    }
}

struct GradientBackground: ViewModifier {
    let gradient: LinearGradient

    init(colors: [Color] = [Color.warmBackground.opacity(0.8), Color.white],
         startPoint: UnitPoint = .top,
         endPoint: UnitPoint = .bottom) {
        self.gradient = LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    func body(content: Content) -> some View {
        content
            .background(gradient)
    }
}

struct ResponsivePadding: ViewModifier {
    let horizontal: CGFloat
    let vertical: CGFloat

    init(horizontal: CGFloat = 16, vertical: CGFloat = 12) {
        self.horizontal = horizontal
        self.vertical = vertical
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }
}

// MARK: - Typography System

struct TextStyles {
    static let headline = Font.system(.headline, design: .default, weight: .semibold)
    static let body = Font.system(.body, design: .default, weight: .medium)
    static let caption = Font.system(.caption, design: .default, weight: .regular)
    static let poetry = Font.system(.body, design: .serif, weight: .medium)
}

// MARK: - Animation Constants

struct AnimationConstants {
    static let defaultSpring = Animation.spring(response: 0.6, dampingFraction: 0.8)
    static let quickFade = Animation.easeInOut(duration: 0.3)
    static let slowFade = Animation.easeInOut(duration: 0.8)
}

// MARK: - Layout Constants

struct LayoutConstants {
    static let defaultCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12
}

// MARK: - View Extensions

extension View {
    func cardStyle(backgroundColor: Color = Color.warmBackground.opacity(0.6),
                  cornerRadius: CGFloat = LayoutConstants.defaultCornerRadius,
                  shadowRadius: CGFloat = 2) -> some View {
        modifier(CardStyle(backgroundColor: backgroundColor,
                          cornerRadius: cornerRadius,
                          shadowRadius: shadowRadius))
    }

    func gradientBackground(colors: [Color] = [Color.warmBackground.opacity(0.8), Color.white],
                           startPoint: UnitPoint = .top,
                           endPoint: UnitPoint = .bottom) -> some View {
        modifier(GradientBackground(colors: colors, startPoint: startPoint, endPoint: endPoint))
    }

    func responsivePadding(horizontal: CGFloat = LayoutConstants.cardPadding,
                          vertical: CGFloat = LayoutConstants.itemSpacing) -> some View {
        modifier(ResponsivePadding(horizontal: horizontal, vertical: vertical))
    }
}

// MARK: - Color Accessibility

extension Color {
    /// Returns appropriate text color for accessibility on this background
    var accessibleTextColor: Color {
        // Simple heuristic - in production, would use proper contrast calculation
        if self == .black || self == .blue || self == .warmAccent {
            return .white
        }
        return .primary
    }
}

// MARK: - Performance Optimized Views

struct LazyText: View {
    let text: String
    let font: Font
    let color: Color

    init(_ text: String, font: Font = .body, color: Color = .primary) {
        self.text = text
        self.font = font
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
    }
}