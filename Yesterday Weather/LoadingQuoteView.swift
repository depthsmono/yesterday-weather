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
                        QuoteTextView(
                            text: quote.text,
                            maxWidth: geometry.size.width * 0.8
                        )

                        // Attribution below quote - right aligned with author on top, work on bottom
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(quote.author)
                                .font(.caption)
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // Dark charcoal
                                .multilineTextAlignment(.trailing)

                            Text(quote.work)
                                .font(.caption)
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // Dark charcoal
                                .multilineTextAlignment(.trailing)
                        }
                        .frame(maxWidth: geometry.size.width * 0.8, alignment: .trailing)
                    }

                    Spacer()

                    // Tap to proceed text at bottom
                    Text("tap to proceed")
                        .font(.caption)
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3)) // Darker charcoal grey
                        .padding(.bottom, 50)
                }
            }
        }
        .ignoresSafeArea(.all)
        .onTapGesture {
            onDismiss()
        }
    }

}

// MARK: - Quote Text View with Dynamic Scaling

struct QuoteTextView: View {
    let text: String
    let maxWidth: CGFloat

    private var lines: [String] {
        text.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    private var hasLineBreaks: Bool {
        text.contains("\n")
    }

    private var uniformFontSize: CGFloat {
        // Calculate the maximum font size that will fit ALL lines within the target width
        // without any individual line needing to scale down

        if hasLineBreaks {
            // For poetry: find the longest line and calculate font size based on that
            let longestLineLength = lines.map { $0.count }.max() ?? 1

            // Estimate character width more accurately for different font sizes
            // We'll iteratively find the largest size that fits
            let targetWidth = maxWidth

            // Start with a reasonable font size and work backwards
            var fontSize: CGFloat = 28 // Start with max desired size
            let minFontSize: CGFloat = 12 // Minimum readable size

            while fontSize >= minFontSize {
                // Estimate width needed for longest line at this font size
                // Character width varies with font size - roughly 0.6 * fontSize for typical text
                let estimatedCharWidth = fontSize * 0.55
                let estimatedWidth = CGFloat(longestLineLength) * estimatedCharWidth

                if estimatedWidth <= targetWidth {
                    // This size fits - use it
                    return fontSize
                }

                fontSize -= 1
            }

            return minFontSize
        } else {
            // For prose: simpler calculation
            let charCount = text.count
            let estimatedCharWidth: CGFloat = 14
            let calculatedSize = maxWidth / (CGFloat(charCount) * estimatedCharWidth / 20)
            return max(14, min(24, calculatedSize))
        }
    }

    var body: some View {
        if hasLineBreaks {
            // Poetry: Display each line separately to prevent auto-wrapping
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                    Text(line)
                        .font(.system(size: uniformFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .minimumScaleFactor(1.0) // No scaling - use calculated uniform size
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: maxWidth, alignment: .leading)
        } else {
            // Prose: Normal text display
            Text(text)
                .font(.system(size: uniformFontSize))
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: maxWidth)
        }
    }
}

#Preview {
    LoadingQuoteView(quote: WeatherQuoteBank.randomQuote()) {
        // Preview dismiss action
    }
}