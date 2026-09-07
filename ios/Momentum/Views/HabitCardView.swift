import SwiftUI
import SwiftData

struct HabitCardView: View {
    @Bindable var habit: Habit
    var onComplete: () -> Void
    var onEdit: () -> Void

    @Environment(\.modelContext) private var context

    private var isCompletedToday: Bool {
        habit.isCompleted(on: Date())
    }

    private var completionCountToday: Int {
        habit.completionCount(on: Date())
    }

    private var habitColor: Color {
        Color(hex: habit.colorHex)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Habit Icon with background
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isCompletedToday ? habitColor.opacity(0.18) : habitColor)
                    .frame(width: 52, height: 52)

                Image(systemName: habit.iconName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(isCompletedToday ? habitColor : .white)
            }

            // Habit Details
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundStyle(isCompletedToday ? .secondary : .primary)
                    .strikethrough(isCompletedToday, color: .secondary.opacity(0.5))

                HStack(spacing: 6) {
                    // Habit streak pill
                    let habitStreak = habit.currentStreak()
                    if habitStreak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color(hex: "FF9600"))
                            Text("\(habitStreak)d streak")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Color(hex: "FF9600"))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: "FF9600").opacity(0.12))
                        .clipShape(Capsule())
                    }

                    if habit.targetCountPerDay > 1 {
                        Text("\(completionCountToday)/\(habit.targetCountPerDay) done")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(habit.scheduleSummary)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Completion Action Button
            Button {
                toggleCompletion()
            } label: {
                ZStack {
                    if isCompletedToday {
                        Circle()
                            .fill(Color(hex: "58CC02"))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: Color(hex: "58CC02").opacity(0.3), radius: 4, y: 2)
                    } else {
                        Circle()
                            .fill(Color(uiColor: .systemBackground))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(habitColor, lineWidth: 3)
                            )
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(habitColor)
                            )
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isCompletedToday ? Color(hex: "58CC02").opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }

    private func toggleCompletion() {
        let today = Date()
        if isCompletedToday {
            // Find logs from today and remove the most recent one
            let calendar = Calendar.current
            let todayLogs = habit.logs.filter { calendar.isDate($0.completedAt, inSameDayAs: today) }
            if let lastLog = todayLogs.last {
                context.delete(lastLog)
                try? context.save()
            }
        } else {
            // Add completion log
            let newLog = HabitCompletionLog(completedAt: today, habit: habit)
            context.insert(newLog)
            try? context.save()
            onComplete()
        }
    }
}
