import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - İzin İste
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // MARK: - İzin Durumunu Kontrol Et
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }

    // MARK: - Tüm Bildirimleri Planla
    func scheduleNotifications(nextPeriodDate: Date?, estimatedEndDate: Date?, daysBefore: Int) {
        // Önce mevcut bildirimleri temizle
        cancelAllNotifications()

        guard let nextPeriod = nextPeriodDate else { return }

        // 1) Regl yaklaşıyor bildirimi (X gün önce)
        if daysBefore > 0 {
            let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: nextPeriod)
            if let reminderDate = reminderDate, reminderDate > Date() {
                scheduleNotification(
                    id: "period_approaching",
                    title: "Regl Yaklaşıyor",
                    body: "\(daysBefore) gün sonra reglinin başlaması bekleniyor. Hazırlıklı ol!",
                    date: reminderDate,
                    hour: 9,
                    minute: 0
                )
            }
        }

        // 2) Regl başlangıç günü bildirimi
        if nextPeriod > Date() {
            scheduleNotification(
                id: "period_start",
                title: "Regl Günü",
                body: "Bugün reglinin başlaması bekleniyor. Kayıt eklemeyi unutma!",
                date: nextPeriod,
                hour: 9,
                minute: 0
            )
        }

        // 3) Tahmini bitiş günü bildirimi
        if let endDate = estimatedEndDate, endDate > Date() {
            scheduleNotification(
                id: "period_end",
                title: "Regl Bitiyor",
                body: "Bugün reglinin bitmesi bekleniyor. Bitiş tarihini kaydetmeyi unutma!",
                date: endDate,
                hour: 9,
                minute: 0
            )
        }
    }

    // MARK: - Tek Bildirim Planla
    private func scheduleNotification(id: String, title: String, body: String, date: Date, hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Tarihin saat 09:00'una ayarla
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Tüm Bildirimleri İptal Et
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
