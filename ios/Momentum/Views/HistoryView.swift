import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query private var allHabits: [Habit]

    @State private var selectedMonth: Date = Date()

    private var overallStreak: (current: Int, best: Int, totalCompletions: Int) {
        StreakCalculator.calculateOverallStreak(habits: allHabits, relativeTo: Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Streaks Trophy Stats Grid
                    statsSummaryGrid

                    // Calendar Month Matrix
                    calendarSection

                    // Per-habit breakdown
                    habitBreakdownSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Streaks & History")
        }
    }

    private var statsSummaryGrid: some View {
        HStack(spacing: 12) {
            // Current Streak
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: "FF9600"))
                    Spacer()
                }

                Text("\(overallStreak.current)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Current Streak")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Best Streak
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: "FFC800"))
                    Spacer()
                }

                Text("\(overallStreak.best)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Best Streak")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            // Total Logs
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(hex: "58CC02"))
                    Spacer()
                }

                Text("\(overallStreak.totalCompletions)")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Total Logs")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var calendarSection: some View {
        VStack(spacing: 16) {
            // Month Switcher Header
            HStack {
                Text(monthHeaderString(for: selectedMonth))
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        if let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
                            selectedMonth = prevMonth
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Circle())
                    }

                    Button {
                        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
                            selectedMonth = nextMonth
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .frame(width: 32, height: 32)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(Circle())
                    }
                }
            }

            // Weekday symbols
            let symbols = ["S", "M", "T", "W", "T", "F", "S"]
            HStack {
                ForEach(0..<7, id: \.self) { idx in
                    Text(symbols[idx])
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Month Days Grid
            let days = daysInMonth(for: selectedMonth)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        let completionStatus = dayCompletionStatus(for: date)
                        let isToday = Calendar.current.isDateInToday(date)
                        let dayNum = Calendar.current.component(.day, from: date)

                        ZStack {
                            if completionStatus == .allComplete {
                                Circle()
                                    .fill(Color(hex: "58CC02"))
                            } else if completionStatus == .partialComplete {
                                Circle()
                                    .fill(Color(hex: "FF9600").opacity(0.3))
                            } else if isToday {
                                Circle()
                                    .stroke(Color(hex: "58CC02"), lineWidth: 2)
                            }

                            Text("\(dayNum)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(completionStatus == .allComplete ? .white : .primary)
                        }
                        .frame(height: 38)
                    } else {
                        Color.clear
                            .frame(height: 38)
                    }
                }
            }

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "58CC02"))
                        .frame(width: 10, height: 10)
                    Text("All completed")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: "FF9600").opacity(0.4))
                        .frame(width: 10, height: 10)
                    Text("Partial")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var habitBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HABIT CONSISTENCY")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.6)
                .padding(.horizontal, 4)

            ForEach(allHabits) { habit in
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: habit.colorHex))
                            .frame(width: 40, height: 40)

                        Image(systemName: habit.iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(habit.title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text("\(habit.totalCompletions) total completions")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    let streak = habit.currentStreak()
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: "FF9600"))
                        Text("\(streak)d")
                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "FF9600"))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "FF9600").opacity(0.12))
                    .clipShape(Capsule())
                }
                .padding(14)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    // MARK: - Helpers

    private enum DayStatus {
        case none, partialComplete, allComplete
    }

    private func dayCompletionStatus(for date: Date) -> DayStatus {
        let scheduled = allHabits.filter { $0.isScheduled(for: date) }
        guard !scheduled.isEmpty else { return .none }

        let completed = scheduled.filter { $0.isCompleted(on: date) }
        if completed.count == scheduled.count {
            return .allComplete
        } else if completed.count > 0 {
            return .partialComplete
        }
        return .none
    }

    private func monthHeaderString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func daysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        var currentDate = monthFirstWeek.start

        // Leading padding
        while currentDate < monthInterval.start {
            days.append(nil)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        // Days in month
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }
}
