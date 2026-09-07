import Foundation
import SwiftData

struct StreakCalculator {
    /// Overall app streak: consecutive active days where all scheduled habits were completed.
    /// If no habits exist or are scheduled, returns 0.
    static func calculateOverallStreak(habits: [Habit], relativeTo date: Date = Date()) -> (current: Int, best: Int, totalCompletions: Int) {
        let activeHabits = habits.filter { !$0.isArchived }
        guard !activeHabits.isEmpty else { return (0, 0, 0) }

        let calendar = Calendar.current
        var currentStreak = 0
        var checkDate = date

        // Total completions across all habits
        let totalCompletions = activeHabits.reduce(0) { $0 + $1.logs.count }

        // Check today
        let scheduledToday = activeHabits.filter { $0.isScheduled(for: checkDate) }
        let allCompletedToday = !scheduledToday.isEmpty && scheduledToday.allSatisfy { $0.isCompleted(on: checkDate) }

        if allCompletedToday {
            currentStreak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return (currentStreak, currentStreak, totalCompletions)
            }
            checkDate = previous
        } else {
            // If today is not yet fully completed, check if yesterday was fully completed
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                return (0, 0, totalCompletions)
            }
            checkDate = yesterday
        }

        // Walk backwards
        var searchDays = 0
        while searchDays < 365 { // Cap search at 1 year for performance
            searchDays += 1
            let scheduled = activeHabits.filter { $0.isScheduled(for: checkDate) }
            if scheduled.isEmpty {
                // If nothing was scheduled, pass through
                guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previous
                continue
            }

            if scheduled.allSatisfy({ $0.isCompleted(on: checkDate) }) {
                currentStreak += 1
                guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previous
            } else {
                break
            }
        }

        // Calculate best streak (approximate from logs)
        let bestStreak = max(currentStreak, computeHistoricalBest(habits: activeHabits, calendar: calendar))

        return (currentStreak, bestStreak, totalCompletions)
    }

    private static func computeHistoricalBest(habits: [Habit], calendar: Calendar) -> Int {
        // Collect all distinct completion days
        var dayCompletions: [Date: Bool] = [:]
        for habit in habits {
            for log in habit.logs {
                let day = calendar.startOfDay(for: log.completedAt)
                dayCompletions[day] = true
            }
        }

        let sortedDays = dayCompletions.keys.sorted()
        guard !sortedDays.isEmpty else { return 0 }

        var maxStreak = 1
        var tempStreak = 1
        for i in 1..<sortedDays.count {
            let prev = sortedDays[i - 1]
            let curr = sortedDays[i]
            if let diff = calendar.dateComponents([.day], from: prev, to: curr).day, diff == 1 {
                tempStreak += 1
                maxStreak = max(maxStreak, tempStreak)
            } else {
                tempStreak = 1
            }
        }
        return maxStreak
    }

    /// Seeds default habits if the database is empty
    static func seedDefaultHabits(in context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Habit>()
        if let count = try? context.fetchCount(fetchDescriptor), count == 0 {
            let sample1 = Habit(
                title: "Drink 2L Water",
                iconName: "drop.fill",
                colorHex: "1CB0F6",
                targetCountPerDay: 1,
                scheduleTypeRaw: "daily",
                orderIndex: 0
            )
            let sample2 = Habit(
                title: "Daily Workout",
                iconName: "figure.run",
                colorHex: "58CC02",
                targetCountPerDay: 1,
                scheduleTypeRaw: "daily",
                orderIndex: 1
            )
            let sample3 = Habit(
                title: "Read 15 Pages",
                iconName: "book.fill",
                colorHex: "FF9600",
                targetCountPerDay: 1,
                scheduleTypeRaw: "daily",
                orderIndex: 2
            )

            context.insert(sample1)
            context.insert(sample2)
            context.insert(sample3)

            // Seed a log for yesterday for sample1 & sample2 to show initial streak
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                let log1 = HabitCompletionLog(completedAt: yesterday, habit: sample1)
                let log2 = HabitCompletionLog(completedAt: yesterday, habit: sample2)
                let log3 = HabitCompletionLog(completedAt: yesterday, habit: sample3)
                context.insert(log1)
                context.insert(log2)
                context.insert(log3)
            }

            try? context.save()
        }
    }
}
