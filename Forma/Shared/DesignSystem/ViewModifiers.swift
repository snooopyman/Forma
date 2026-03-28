import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
    }
}

struct PrimaryButtonLabel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(Color.textOnAccent)
            .frame(maxWidth: .infinity, minHeight: DS.Sizing.minTapTarget)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }

    func primaryButtonLabel() -> some View {
        modifier(PrimaryButtonLabel())
    }
}
