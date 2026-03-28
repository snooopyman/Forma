import CoreGraphics

enum DS {

    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 10
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16

        static let card: CGFloat = xl
        static let button: CGFloat = lg
        static let setRow: CGFloat = md
        static let chip: CGFloat = sm
        static let inner: CGFloat = xs
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    enum Sizing {
        static let macroRingOuter: CGFloat = 140
        static let macroRingMiddle: CGFloat = 110
        static let macroRingInner: CGFloat = 80
        static let sparklineHeight: CGFloat = 40
        static let restTimerRing: CGFloat = 180
        static let minTapTarget: CGFloat = 44
    }
}
