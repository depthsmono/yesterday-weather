//
//  LoadingQuoteView.swift
//  Yesterday Weather
//
//  Created by Ed Thompson on 9/22/25.
//

import SwiftUI

struct LoadingQuoteView: View {
    let quote: WeatherQuote
    let onDismiss: () -> Void

    @State private var timeRemaining: Double = 7.0
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background layer - marble with overlay (aggressive full coverage)
                Image("MarbleRoseGold")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()

                // White overlay for text readability (20% opacity)
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.15)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Content layer - quote and loading indicator
                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 32) {
                        // Quote text with dynamic scaling for poetry
                        QuoteTextView(text: quote.text)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: geometry.size.width - 64) // Ensure it fits within screen

                        // Attribution below quote
                        Text("— \(quote.attribution) —")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .frame(maxWidth: geometry.size.width - 64) // Ensure it fits within screen
                    }

                    Spacer()

                    // Loading indicator at bottom
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.warmAccent)

                        Text("Loading weather data...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Tap to skip")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            dismissQuote()
        }
        .onAppear {
            startTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                dismissQuote()
            }
        }
    }

    private func dismissQuote() {
        timer?.invalidate()
        timer = nil
        onDismiss()
    }

    private func checkDismiss() {
        if timeRemaining <= 0 {
            dismissQuote()
        }
    }
}

// MARK: - Quote Text View with Dynamic Scaling

struct QuoteTextView: View {
    let text: String

    private var lines: [String] {
        text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private var hasLineBreaks: Bool {
        text.contains("\n")
    }

    private var dynamicFont: Font {
        if hasLineBreaks {
            // Poetry - scale down to preserve line breaks and fit screen
            let lineCount = lines.count
            let longestLineLength = lines.map { $0.count }.max() ?? 0

            // Start smaller for longer lines or more lines
            switch (lineCount, longestLineLength) {
            case (1...2, 0..<50): return .title3
            case (1...2, _): return .headline
            case (3...4, 0..<40): return .headline
            case (3...4, _): return .subheadline
            case (5...6, 0..<35): return .subheadline
            case (5...6, _): return .callout
            case (7...8, _): return .callout
            default: return .footnote
            }
        } else {
            // Prose - normal flowing text
            return .title2
        }
    }

    var body: some View {
        if hasLineBreaks {
            // Poetry: Display each line separately to prevent auto-wrapping
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    Text(line)
                        .font(dynamicFont)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .minimumScaleFactor(0.5) // Allow significant scaling to fit screen
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            // Prose: Normal text display
            Text(text)
                .font(dynamicFont)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    LoadingQuoteView(quote: WeatherQuoteBank.randomQuote()) {
        // Preview dismiss action
    }
}