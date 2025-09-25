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
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                // Quote text with dynamic scaling for poetry
                QuoteTextView(text: quote.text)
                    .padding(.horizontal, 32)

                // Attribution below quote
                Text("— \(quote.attribution) —")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Loading indicator at bottom
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.blue)

                Text("Loading weather data...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Tap to skip")
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
        )
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

    private var hasLineBreaks: Bool {
        text.contains("\n")
    }

    private var dynamicFont: Font {
        if hasLineBreaks {
            // Poetry - scale down to preserve line breaks
            let lineCount = text.components(separatedBy: .newlines).count
            switch lineCount {
            case 1...2: return .title2
            case 3...4: return .title3
            case 5...6: return .headline
            default: return .subheadline
            }
        } else {
            // Prose - normal flowing text
            return .title2
        }
    }

    var body: some View {
        Text(text)
            .font(dynamicFont)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(hasLineBreaks ? 6 : 4)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    LoadingQuoteView(quote: WeatherQuoteBank.randomQuote()) {
        // Preview dismiss action
    }
}