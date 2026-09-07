// 10x primitive: duolingo/streak-indicator v2
import SwiftUI

@available(iOS 17.0, *)
struct StreakCalendarConfig {
    var filledTint: Color = PlayfulTokens.warning
    var todayRing: Color = PlayfulTokens.warning
    /// Fill behind unfilled days. The reference month grid renders empty days
    /// as plain numerals on the surface, so this defaults to clear.
    var emptyFill: Color = .clear
    var weekdayFont: Font = .system(.caption2, design: .rounded, weight: .bold)
    var dayFont: Font = .system(.footnote, design: .rounded, weight: .semibold)
    var headerFont: Font = PlayfulTokens.headlineFont
    /// Glyph inside filled days. `nil` (default) renders the day numeral in
    /// white, matching the reference calendar; pass a checkmark for the
    /// celebration-style week strip.
    var filledGlyph: Image? = nil
    /// Localized single-letter weekday headers, Sunday first.
    var weekdaySymbols: [String] = ["S", "M", "T", "W", "T", "F", "S"]
}

/// Streak detail calendar: a month grid whose completed days are filled
/// glyph dots, with today ringed. Present in a sheet from `StreakIndicator`.
@available(iOS 17.0, *)
struct StreakCalendar: View {
    var monthTitle: String
    /// Day numbers (1-based) completed this month.
    var filledDays: Set<Int>
    var daysInMonth: Int = 30
    /// Weekday column (0 = first column) the month starts on.
    var firstWeekday: Int = 0
    var today: Int? = nil
    var config: StreakCalendarConfig = StreakCalendarConfig()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        VStack(spacing: 14) {
            Text(monthTitle)
                .font(config.headerFont)
                .accessibilityAddTraits(.isHeader)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    Text(config.weekdaySymbols[index % config.weekdaySymbols.count])
                        .font(config.weekdayFont)
                        .foregroundStyle(.secondary)
                }
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    Color.clear.frame(height: 34)
                }
                ForEach(1...max(daysInMonth, 1), id: \.self) { day in
                    dayCell(day)
                }
            }
        }
        .padding(20)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Streak calendar for \(monthTitle)")
    }

    private func dayCell(_ day: Int) -> some View {
        let filled = filledDays.contains(day)
        return ZStack {
            Circle()
                .fill(filled ? config.filledTint : config.emptyFill)
            if filled {
                if let glyph = config.filledGlyph {
                    glyph
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(.white)
                } else {
                    Text("\(day)")
                        .font(config.dayFont.weight(.bold))
                        .foregroundStyle(.white)
                }
            } else {
                Text("\(day)")
                    .font(config.dayFont)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 34)
        .overlay {
            if today == day {
                Circle().strokeBorder(config.todayRing, lineWidth: 2.5)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Day \(day)")
        .accessibilityValue(filled ? "Streak kept" : "No activity")
    }
}

#Preview("Streak calendar") {
    StreakCalendar(monthTitle: "July",
                   filledDays: [1, 2, 3, 4, 7, 8, 9, 10, 11, 14, 15],
                   daysInMonth: 31,
                   firstWeekday: 2,
                   today: 16)
}
