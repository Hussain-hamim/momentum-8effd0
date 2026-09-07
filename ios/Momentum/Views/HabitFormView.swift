import SwiftUI
import SwiftData

struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var habitToEdit: Habit?

    @State private var title: String = ""
    @State private var selectedIcon: String = "flame.fill"
    @State private var selectedColorHex: String = "58CC02"
    @State private var targetCount: Int = 1
    @State private var scheduleType: String = "daily" // "daily", "weekdays", "custom"
    @State private var selectedWeekdays: Set<Int> = [1, 2, 3, 4, 5, 6, 7] // 1: Sun ... 7: Sat

    private let availableIcons = [
        "flame.fill", "drop.fill", "figure.run", "book.fill",
        "dumbbell.fill", "bed.double.fill", "heart.fill", "fork.knife",
        "brain.head.profile", "pencil.and.outline", "leaf.fill", "sun.max.fill",
        "moon.stars.fill", "cup.and.saucer.fill", "cross.case.fill", "music.note"
    ]

    private let availableColors = [
        ("Green", "58CC02"),
        ("Orange", "FF9600"),
        ("Blue", "1CB0F6"),
        ("Purple", "CE82FF"),
        ("Red", "FF4B4B"),
        ("Gold", "FFC800"),
        ("Teal", "2CE0D2")
    ]

    private let weekdayLabels: [(index: Int, label: String)] = [
        (2, "M"), (3, "T"), (4, "W"), (5, "T"), (6, "F"), (7, "S"), (1, "S")
    ]

    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (scheduleType != "custom" || !selectedWeekdays.isEmpty)
    }

    init(habitToEdit: Habit? = nil) {
        self.habitToEdit = habitToEdit
        if let habit = habitToEdit {
            _title = State(initialValue: habit.title)
            _selectedIcon = State(initialValue: habit.iconName)
            _selectedColorHex = State(initialValue: habit.colorHex)
            _targetCount = State(initialValue: habit.targetCountPerDay)
            _scheduleType = State(initialValue: habit.scheduleTypeRaw)
            _selectedWeekdays = State(initialValue: Set(habit.selectedWeekdays))
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview Card
                    previewCard

                    // Name Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("HABIT NAME")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        TextField("e.g. Read 20 mins, Drink water...", text: $title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color(uiColor: .separator), lineWidth: 1.5)
                            )
                    }

                    // Schedule Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SCHEDULE")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        Picker("Schedule", selection: $scheduleType) {
                            Text("Every Day").tag("daily")
                            Text("Mon – Fri").tag("weekdays")
                            Text("Custom Days").tag("custom")
                        }
                        .pickerStyle(.segmented)

                        if scheduleType == "custom" {
                            HStack(spacing: 8) {
                                ForEach(weekdayLabels, id: \.index) { item in
                                    let isSelected = selectedWeekdays.contains(item.index)
                                    Button {
                                        if isSelected {
                                            selectedWeekdays.remove(item.index)
                                        } else {
                                            selectedWeekdays.insert(item.index)
                                        }
                                    } label: {
                                        Text(item.label)
                                            .font(.system(size: 15, weight: .heavy, design: .rounded))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 44)
                                            .background(isSelected ? Color(hex: selectedColorHex) : Color(uiColor: .secondarySystemBackground))
                                            .foregroundStyle(isSelected ? .white : .primary)
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .stroke(isSelected ? Color.clear : Color(uiColor: .separator), lineWidth: 1.5)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }

                    // Daily Target
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DAILY GOAL")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        HStack {
                            Text("Times per day")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))

                            Spacer()

                            HStack(spacing: 12) {
                                Button {
                                    if targetCount > 1 { targetCount -= 1 }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(width: 36, height: 36)
                                        .background(Color(uiColor: .secondarySystemBackground))
                                        .clipShape(Circle())
                                }
                                .disabled(targetCount <= 1)

                                Text("\(targetCount)")
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .monospacedDigit()
                                    .frame(minWidth: 28)

                                Button {
                                    if targetCount < 10 { targetCount += 1 }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .frame(width: 36, height: 36)
                                        .background(Color(uiColor: .secondarySystemBackground))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    // Icon Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CHOOSE ICON")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                            ForEach(availableIcons, id: \.self) { icon in
                                let isSelected = selectedIcon == icon
                                Button {
                                    selectedIcon = icon
                                } label: {
                                    Image(systemName: icon)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(isSelected ? Color(hex: selectedColorHex) : .secondary)
                                        .frame(height: 54)
                                        .frame(maxWidth: .infinity)
                                        .background(isSelected ? Color(hex: selectedColorHex).opacity(0.15) : Color(uiColor: .secondarySystemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .stroke(isSelected ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Color Picker
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CHOOSE THEME COLOR")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.6)

                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.1) { item in
                                let isSelected = selectedColorHex == item.1
                                Button {
                                    selectedColorHex = item.1
                                } label: {
                                    Circle()
                                        .fill(Color(hex: item.1))
                                        .frame(height: 38)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(Color(hex: item.1), lineWidth: isSelected ? 2 : 0)
                                                .scaleEffect(1.2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }

                    // Save Button
                    DimensionalButton(
                        habitToEdit == nil ? "CREATE HABIT" : "SAVE CHANGES",
                        config: DimensionalButtonConfig(
                            face: Color(hex: selectedColorHex),
                            foreground: .white
                        ),
                        action: saveHabit
                    )
                    .disabled(!isFormValid)
                    .padding(.top, 12)

                    if habitToEdit != nil {
                        Button(role: .destructive) {
                            deleteHabit()
                        } label: {
                            Text("Delete Habit")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color(hex: "FF4B4B"))
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(20)
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(hex: selectedColorHex))
                    .frame(width: 52, height: 52)

                Image(systemName: selectedIcon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title.isEmpty ? "Habit Title" : title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)

                Text(scheduleType == "daily" ? "Daily • \(targetCount)x / day" : (scheduleType == "weekdays" ? "Mon–Fri • \(targetCount)x" : "\(selectedWeekdays.count) days/wk"))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: selectedColorHex).opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 3)
    }

    private func saveHabit() {
        guard isFormValid else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let weekdays = Array(selectedWeekdays).sorted()

        if let habit = habitToEdit {
            habit.title = trimmedTitle
            habit.iconName = selectedIcon
            habit.colorHex = selectedColorHex
            habit.targetCountPerDay = targetCount
            habit.scheduleTypeRaw = scheduleType
            habit.selectedWeekdays = weekdays
        } else {
            let newHabit = Habit(
                title: trimmedTitle,
                iconName: selectedIcon,
                colorHex: selectedColorHex,
                targetCountPerDay: targetCount,
                scheduleTypeRaw: scheduleType,
                selectedWeekdays: weekdays
            )
            context.insert(newHabit)
        }

        try? context.save()
        dismiss()
    }

    private func deleteHabit() {
        if let habit = habitToEdit {
            context.delete(habit)
            try? context.save()
        }
        dismiss()
    }
}

// Color hex helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 88, 204, 2)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
