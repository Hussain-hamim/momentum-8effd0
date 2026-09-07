import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "checkmark.circle.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("Streaks", systemImage: "flame.fill")
                }
                .tag(1)

            HabitsListView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet.rectangle.portrait.fill")
                }
                .tag(2)
        }
        .tint(Color(hex: "58CC02"))
    }
}
