import SwiftUI

/// A view modifier that adds a shimmer animation effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                    .blendMode(.overlay)
                    .ignoresSafeArea()
                }
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

/// A conditional shimmer modifier that only applies when loading
struct ShimmerModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        if isLoading {
            content.modifier(ShimmerEffect())
        } else {
            content
        }
    }
}

extension View {
    /// Adds a shimmer animation effect to the view
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }

    /// Conditionally adds a shimmer effect when loading
    func shimmer(isLoading: Bool) -> some View {
        modifier(ShimmerModifier(isLoading: isLoading))
    }
}
