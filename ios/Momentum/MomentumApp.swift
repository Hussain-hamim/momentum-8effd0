import SwiftUI
import SwiftData

@main
struct MomentumApp: App {
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([
                Habit.self,
                HabitCompletionLog.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed default initial habits on first launch
            StreakCalculator.seedDefaultHabits(in: container.mainContext)
        } catch {
            fatalError("Could not initialize SwiftData ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(container)
    }
}
