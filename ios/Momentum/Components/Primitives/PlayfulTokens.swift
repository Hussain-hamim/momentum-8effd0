// 10x primitive: duolingo/design-tokens v2
import SwiftUI

/// Central design tokens for the playful dimensional language. The app's whole
/// theme lives here: retheme by editing these values, add new tokens here, and
/// never hardcode colors or fonts in views.
///
/// Values are the set's observed reference palette (see REFERENCE.md): a white
/// ground with hairline-bordered cards, saturated signature green on every
/// primary action, selection blue, streak orange, reward gold, and rounded
/// heavy type throughout. Neutrals stay adaptive system grays so dark mode
/// keeps working.
@available(iOS 17.0, *)
enum PlayfulTokens {
    // MARK: Grounds & surfaces
    /// Screen background. Observed: plain white (#FFFFFF); adaptive stand-in.
    static let ground: Color = Color(.systemBackground)
    /// Card fill. Observed: white cards distinguished by hairline borders.
    static let surface: Color = Color(.systemBackground)
    /// Raised list-card fill (quest/challenge cards, stat tiles).
    static let surfaceRaised: Color = Color(.secondarySystemBackground)

    // MARK: Ink
    /// Primary text. Observed: soft near-black ~#4B4B4B; adaptive stand-in.
    static let ink: Color = Color(.label)
    /// Secondary text. Observed: ~#AFAFAF; adaptive stand-in.
    static let inkSecondary: Color = Color(.secondaryLabel)
    /// Text and glyphs on saturated accent fills.
    static let inkOnAccent: Color = Color.white
    /// Inactive/zero-state tint (empty streak, locked chest).
    static let inkDisabled: Color = Color(.systemGray3)

    // MARK: Accent & semantics
    /// Signature action green ~#58CC02: CTAs, progress fills, active path nodes.
    static let accent: Color = Color(red: 0.35, green: 0.80, blue: 0.01)
    /// Pale green fill ~#D7FFB8 (assembled-answer chips, correct surfaces).
    static let accentSoft: Color = Color(red: 0.84, green: 1.00, blue: 0.72)
    /// Selection/audio blue ~#1CB0F6: selected options, points glyphs.
    static let accentSecondary: Color = Color(red: 0.11, green: 0.69, blue: 0.96)
    /// Pale selection fill ~#DDF4FF behind selected option cards.
    static let accentSecondarySoft: Color = Color(red: 0.87, green: 0.96, blue: 1.00)
    /// Light selection border ~#84D8FF around selected option cards/chips.
    static let accentSecondaryLight: Color = Color(red: 0.52, green: 0.85, blue: 1.00)
    /// Dark selection blue ~#1899D6 (selected-state text).
    static let accentSecondaryDeep: Color = Color(red: 0.09, green: 0.60, blue: 0.84)
    /// Correct-verdict green ~#58A700 (dark text over `accentSoft` fills).
    static let positive: Color = Color(red: 0.35, green: 0.65, blue: 0.00)
    /// Error red ~#FF4B4B (wrong answers, demotion, loss flashes).
    static let negative: Color = Color(red: 1.00, green: 0.29, blue: 0.29)
    /// Deep verdict red ~#EA2B2B (incorrect-banner ink).
    static let negativeDeep: Color = Color(red: 0.92, green: 0.17, blue: 0.17)
    /// Pale red fill ~#FFDFE0 (incorrect-banner surface).
    static let negativeSoft: Color = Color(red: 1.00, green: 0.87, blue: 0.87)
    /// Streak/energy orange ~#FF9600 — the set's warning-register hue.
    static let warning: Color = Color(red: 1.00, green: 0.59, blue: 0.00)
    /// Reward gold ~#FFC800 (legendary nodes, bursts, ready chests).
    static let gold: Color = Color(red: 1.00, green: 0.78, blue: 0.00)
    /// Highlight purple ~#CE82FF (tutor highlights, partner fills).
    static let purple: Color = Color(red: 0.81, green: 0.51, blue: 1.00)
    /// Premium upsell gradient: blue ~#1CB0F6 into purple ~#8549BA.
    static let premiumGradient: [Color] = [
        Color(red: 0.11, green: 0.69, blue: 0.96),
        Color(red: 0.52, green: 0.29, blue: 0.73),
    ]
    /// Deep premium purple ~#8549BA (gradient tail, promo CTA text).
    static let premiumPurple: Color = Color(red: 0.52, green: 0.29, blue: 0.73)
    /// Hairline card/chip borders. Observed: ~#E5E5E5; adaptive stand-in.
    static let border: Color = Color(.systemGray4)
    /// Progress tracks, ghost slots, locked fills. Observed ~#E5E5E5 family.
    static let track: Color = Color(.systemGray5)

    // MARK: Radii
    static let radiusCard: CGFloat = 16
    static let radiusControl: CGFloat = 12
    static let radiusSheet: CGFloat = 28
    /// Signature depth rim: press travel on buttons, offset rims on chips (2pt).
    static let rimHeight: CGFloat = 4

    // MARK: Type
    /// Hero numerals/display (streak counts, level numbers): rounded heavy.
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static let titleFont: Font = .system(.title2, design: .rounded, weight: .heavy)
    static let headlineFont: Font = .system(.headline, design: .rounded, weight: .heavy)
    /// Body/answer text: rounded semibold — the lightest weight in the set.
    static let bodyFont: Font = .system(.body, design: .rounded, weight: .semibold)
    static let captionFont: Font = .system(.caption, design: .rounded, weight: .bold)
    /// Button labels: rounded bold body.
    static let buttonFont: Font = .system(.body, design: .rounded, weight: .bold)
}

#Preview("Playful tokens") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            Text("Playful design tokens")
                .font(PlayfulTokens.titleFont)
                .foregroundStyle(PlayfulTokens.ink)
            ForEach([
                ("accent", PlayfulTokens.accent),
                ("accentSoft", PlayfulTokens.accentSoft),
                ("accentSecondary", PlayfulTokens.accentSecondary),
                ("accentSecondarySoft", PlayfulTokens.accentSecondarySoft),
                ("positive", PlayfulTokens.positive),
                ("negative", PlayfulTokens.negative),
                ("negativeSoft", PlayfulTokens.negativeSoft),
                ("warning", PlayfulTokens.warning),
                ("gold", PlayfulTokens.gold),
                ("purple", PlayfulTokens.purple),
                ("border", PlayfulTokens.border),
                ("track", PlayfulTokens.track),
            ], id: \.0) { name, color in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                        .fill(color)
                        .frame(width: 56, height: 32)
                        .overlay {
                            RoundedRectangle(cornerRadius: PlayfulTokens.radiusControl, style: .continuous)
                                .strokeBorder(PlayfulTokens.border, lineWidth: 1)
                        }
                    Text(name)
                        .font(PlayfulTokens.bodyFont)
                        .foregroundStyle(PlayfulTokens.ink)
                }
            }
            Text("Display 42")
                .font(PlayfulTokens.display(42))
                .foregroundStyle(PlayfulTokens.warning)
            Text("Headline / body / caption")
                .font(PlayfulTokens.headlineFont)
            Text("Chips and answers use rounded semibold.")
                .font(PlayfulTokens.bodyFont)
            Text("HUD captions are bold and letterspaced.")
                .font(PlayfulTokens.captionFont)
                .foregroundStyle(PlayfulTokens.inkSecondary)
        }
        .padding(24)
    }
    .background(PlayfulTokens.ground)
}
