import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID = UUID()
    var title: String = ""
    var iconName: String = "flame.fill"
    var colorHex: String = "58CC02"
    var targetCountPerDay: Int = 1
    var scheduleTypeRaw: String = "daily" // "daily", "weekdays", "custom"
    var selectedWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7] // 1 = Sunday ... 7 = Saturday (Calendar standard)
    var createdAt: Date = Date()
    var isArchived: Bool = false
    var orderIndex: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletionLog.habit)
    var logs: [HabitCompletionLog] = []

    init(
        title: String,
        iconName: String = "flame.fill",
        colorHex: String = "58CC02",
        targetCountPerDay: Int = 1,
        scheduleTypeRaw: String = "daily",
        selectedWeekdays: [Int] = [1, 2, 3, 4, 5, 6, 7],
        createdAt: Date = Date(),
        orderIndex: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.iconName = iconName
        self.colorHex = colorHex
        self.targetCountPerDay = targetCountPerDay
        self.scheduleTypeRaw = scheduleTypeRaw
        self.selectedWeekdays = selectedWeekdays
        self.createdAt = createdAt
        self.isArchived = false
        self.orderIndex = orderIndex
    }

    var scheduleSummary: String {
        switch scheduleTypeRaw {
        case "daily":
            return "Every day"
        case "weekdays":
            return "Weekdays only (Mon–Fri)"
        case "custom":
            let calendar = Calendar.current
            let symbols = calendar.shortWeekdaySymbols
            if selectedWeekdays.count == 7 {
                return "Every day"
            }
            if selectedWeekdays.sorted() == [2, 3, 4, 5, 6] {
                return "Weekdays"
            }
            if selectedWeekdays.sorted() == [1, 7] {
                return "Weekends"
            }
            let dayNames = selectedWeekdays.sorted().map { symbols[$0 - 1] }
            return dayNames.joined(separator: ", ")
        default:
            return "Daily"
        }
    }

    func isScheduled(for date: Date = Date()) -> Bool {
        if isArchived { return false }
        switch scheduleTypeRaw {
        case "daily":
            return true
        case "weekdays":
            let weekday = Calendar.current.component(.weekday, from: date)
            return weekday >= 2 && weekday <= 6 // Mon to Fri
        case "custom":
            let weekday = Calendar.current.component(.weekday, from: date)
            return selectedWeekdays.contains(weekday)
        default:
            return true
        }
    }

    func completionCount(on date: Date = Date()) -> Int {
        let calendar = Calendar.current
        return logs.filter { calendar.isDate($0.completedAt, inSameDayAs: date) }.count
    }

    func isCompleted(on date: Date = Date()) -> Bool {
        return completionCount(on: date) >= targetCountPerDay
    }

    // Calculates current streak for this specific habit
    func currentStreak(relativeTo date: Date = Date()) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = date

        // Check if completed today; if not, check if it was due today or start from yesterday
        let completedToday = isCompleted(on: checkDate)
        if completedToday {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return streak }
            checkDate = previousDay
        } else {
            // If today is scheduled and not yet completed, we don't break the streak yet if yesterday was completed
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        // Walk backwards in time
        while true {
            if isScheduled(for: checkDate) {
                if isCompleted(on: checkDate) {
                    streak += 1
                    guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                    checkDate = previous
                } else {
                    break
                }
            } else {
                // Not scheduled on this day: skip without breaking streak
                guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previous
            }
        }

        return streak
    }

    // Total completions ever
    var totalCompletions: Int {
        logs.count
    }
}

@Model
final class HabitCompletionLog {
    var id: UUID = UUID()
    var completedAt: Date = Date()
    var habit: Habit?

    init(completedAt: Date = Date(), habit: Habit? = nil) {
        self.id = UUID()
        self.completedAt = completedAt
        self.habit = habit
    }
}
