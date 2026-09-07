import SwiftUI
import SwiftData

struct HabitsListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.orderIndex) private var habits: [Habit]

    @State private var showingAddSheet = false
    @State private var habitToEdit: Habit?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(habits) { habit in
                        Button {
                            habitToEdit = habit
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color(hex: habit.colorHex))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: habit.iconName)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(habit.title)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.primary)

                                    Text(habit.scheduleSummary)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: deleteHabits)
                } header: {
                    Text("ALL HABITS")
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.secondary)
                        .tracking(0.6)
                } footer: {
                    Text("Tap a habit to edit its schedule, daily goal, icon, or color.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Manage Habits")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(hex: "58CC02"))
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                HabitFormView()
            }
            .sheet(item: $habitToEdit) { habit in
                HabitFormView(habitToEdit: habit)
            }
        }
    }

    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habits[index]
            context.delete(habit)
        }
        try? context.save()
    }
}
