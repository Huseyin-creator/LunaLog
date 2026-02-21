import SwiftUI
import UserNotifications

@main
struct LunaLogApp: App {
    @StateObject private var cycleManager = CycleManager()
    @Environment(\.scenePhase) private var scenePhase

    var colorScheme: ColorScheme? {
        switch cycleManager.settings.appearanceMode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cycleManager)
                .preferredColorScheme(colorScheme)
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        UNUserNotificationCenter.current().setBadgeCount(0)
                    }
                }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var cycleManager: CycleManager

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Ana Sayfa", systemImage: "heart.fill")
                }

            JournalView()
                .tabItem {
                    Label("Günlük", systemImage: "book.fill")
                }

            ChatView()
                .tabItem {
                    Label("Asistan", systemImage: "bubble.left.fill")
                }

            CycleCalendarView()
                .tabItem {
                    Label("Takvim", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
        .tint(.pink)
    }
}

#Preview {
    ContentView()
        .environmentObject(CycleManager())
}
