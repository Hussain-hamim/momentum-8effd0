import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.orderIndex) private var allHabits: [Habit]

    @State private var showingAddHabitSheet = false
    @State private var editingHabit: Habit?
    @State private var showingCelebration = false
    @State private var celebratedStreakCount = 1

    private var today: Date { Date() }

    private var scheduledHabits: [Habit] {
        allHabits.filter { $0.isScheduled(for: today) }
    }

    private var completedHabits: [Habit] {
        scheduledHabits.filter { $0.isCompleted(on: today) }
    }

    private var remainingHabits: [Habit] {
        scheduledHabits.filter { !$0.isCompleted(on: today) }
    }

    private var overallStreak: (current: Int, best: Int, totalCompletions: Int) {
        StreakCalculator.calculateOverallStreak(habits: allHabits, relativeTo: today)
    }

    private var progressRatio: Double {
        guard !scheduledHabits.isEmpty else { return 0 }
        return Double(completedHabits.count) / Double(scheduledHabits.count)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Streak Card
                    heroStreakCard

                    // Progress Banner
                    dailyProgressBanner

                    // Habits List Section
                    if scheduledHabits.isEmpty {
                        emptyStateCard
                    } else {
                        habitsListSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddHabitSheet = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("New Habit")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "58CC02"))
                    }
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                HabitFormView()
            }
            .sheet(item: $editingHabit) { habit in
                HabitFormView(habitToEdit: habit)
            }
            .fullScreenCover(isPresented: $showingCelebration) {
                CompletionCelebration(
                    mode: .results(
                        stats: [
                            CompletionCelebrationStat(
                                id: "streak",
                                label: "DAY STREAK",
                                value: celebratedStreakCount,
                                suffix: " Days",
                                tint: PlayfulTokens.warning,
                                glyph: Image(systemName: "flame.fill")
                            ),
                            CompletionCelebrationStat(
                                id: "completed",
                                label: "TODAY'S HABITS",
                                value: scheduledHabits.count,
                                suffix: " Done",
                                tint: PlayfulTokens.accent,
                                glyph: Image(systemName: "checkmark.seal.fill")
                            )
                        ],
                        bonusText: "All habits completed! Streak safely locked."
                    ),
                    title: "STREAK EXTENDED!",
                    subtitle: "\(celebratedStreakCount) Day Streak Kept Alive!",
                    config: CompletionCelebrationConfig(
                        continueTitle: "KEEP GOING"
                    ),
                    onContinue: {
                        showingCelebration = false
                    },
                    centerpiece: { EmptyView() }
                )
            }
        }
    }

    // MARK: - Subviews

    private var heroStreakCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT STREAK")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color(hex: "FF9600"))
                        .tracking(1.0)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color(hex: "FF9600"))

                        Text("\(overallStreak.current)")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "FF9600"))
                            .monospacedDigit()

                        Text(overallStreak.current == 1 ? "DAY" : "DAYS")
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color(hex: "FF9600"))
                    }
                }

                Spacer()

                // Best streak badge
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color(hex: "FFC800"))
                        Text("Best: \(overallStreak.best)d")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(Capsule())

                    Text("\(overallStreak.totalCompletions) Total Logs")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.tertiary)
                }
            }

            // Streak motivating note
            HStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color(hex: "58CC02"))
                Text(streakMotivationalCopy)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color(hex: "FF9600").opacity(0.16), Color(hex: "FFC800").opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(hex: "FF9600").opacity(0.3), lineWidth: 2)
        )
    }

    private var streakMotivationalCopy: String {
        if overallStreak.current == 0 {
            return "Complete today's habits to ignite your streak!"
        } else if remainingHabits.isEmpty && !scheduledHabits.isEmpty {
            return "All set for today! Your streak is safely locked."
        } else {
            let left = remainingHabits.count
            return "\(left) habit\(left == 1 ? "" : "s") left to protect your streak today!"
        }
    }

    private var dailyProgressBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("TODAY'S COMPLETION")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .tracking(0.6)

                Spacer()

                Text("\(completedHabits.count) of \(scheduledHabits.count) done")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundStyle(completedHabits.count == scheduledHabits.count && !scheduledHabits.isEmpty ? Color(hex: "58CC02") : .secondary)
            }

            // Custom chunky progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(uiColor: .tertiarySystemFill))
                        .frame(height: 14)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "58CC02"), Color(hex: "2CE0D2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * CGFloat(progressRatio)), height: 14)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progressRatio)
                }
            }
            .frame(height: 14)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var habitsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HABITS DUE TODAY")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.secondary)
                .tracking(0.6)
                .padding(.horizontal, 4)

            ForEach(scheduledHabits) { habit in
                HabitCardView(
                    habit: habit,
                    onComplete: {
                        handleHabitCompleted(habit)
                    },
                    onEdit: {
                        editingHabit = habit
                    }
                )
            }
        }
    }

    private var emptyStateCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(Color(hex: "58CC02"))
                .padding(.top, 12)

            Text("No Habits Scheduled Today")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)

            Text("Add habits you want to build every day or on specific weekdays to start your streak!")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            DimensionalButton(
                "CREATE FIRST HABIT",
                config: DimensionalButtonConfig(
                    face: Color(hex: "58CC02"),
                    foreground: .white
                ),
                action: {
                    showingAddHabitSheet = true
                }
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .padding(24)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func handleHabitCompleted(_ habit: Habit) {
        // Check if all scheduled habits are now done
        let allDone = scheduledHabits.allSatisfy { $0.isCompleted(on: today) }
        if allDone {
            let streak = overallStreak.current
            celebratedStreakCount = max(1, streak)
            showingCelebration = true
        }
    }
}
