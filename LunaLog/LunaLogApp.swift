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
                    Label(S.tabHome, systemImage: "heart.fill")
                }

            CycleCalendarView()
                .tabItem {
                    Label(S.tabCalendar, systemImage: "calendar")
                }

            ChatView()
                .tabItem {
                    Label(S.tabLuna, systemImage: "sparkle")
                }

            JournalView()
                .tabItem {
                    Label(S.tabJournal, systemImage: "book.fill")
                }

            SettingsView()
                .tabItem {
                    Label(S.tabSettings, systemImage: "gearshape.fill")
                }
        }
        .tint(cycleManager.accentColor)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(CycleManager())
}
