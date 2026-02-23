import Foundation

// MARK: - In-App Localization
struct S {
    /// Aktif dili UserDefaults'tan okur
    static var lang: AppLanguage {
        if let raw = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = AppLanguage(rawValue: raw) {
            return language
        }
        return .turkish
    }

    static var locale: Locale { lang.locale }

    // MARK: - Tab Bar
    static var tabHome: String { lang == .turkish ? "Ana Sayfa" : "Home" }
    static var tabCalendar: String { lang == .turkish ? "Takvim" : "Calendar" }
    static var tabLuna: String { "Luna" }
    static var tabJournal: String { lang == .turkish ? "Günlük" : "Journal" }
    static var tabSettings: String { lang == .turkish ? "Ayarlar" : "Settings" }

    // MARK: - Common
    static var save: String { lang == .turkish ? "Kaydet" : "Save" }
    static var cancel: String { lang == .turkish ? "İptal" : "Cancel" }
    static var delete: String { lang == .turkish ? "Sil" : "Delete" }
    static var edit: String { lang == .turkish ? "Düzenle" : "Edit" }
    static var close: String { lang == .turkish ? "Kapat" : "Close" }
    static var update: String { lang == .turkish ? "Güncelle" : "Update" }
    static var giveUp: String { lang == .turkish ? "Vazgeç" : "Cancel" }
    static var day: String { lang == .turkish ? "gün" : "days" }
    static var ongoing: String { lang == .turkish ? "Devam ediyor" : "Ongoing" }

    // MARK: - Dashboard
    static var dashboardTitle: String { "LunaLog" }
    static var addFirstRecord: String { lang == .turkish ? "İlk Kaydını\nEkle" : "Add Your\nFirst Record" }
    static var emptyHello: String { lang == .turkish ? "Merhaba!" : "Hello!" }
    static var emptyDescription: String { lang == .turkish ? "Döngünü takip etmeye başlamak için\nyukarıdaki butona dokun" : "Tap the button above to\nstart tracking your cycle" }
    static var currentlyOnPeriod: String { lang == .turkish ? "Şu anda regl döneminde" : "Currently on period" }
    static func daysUntilPeriod(_ days: Int) -> String { lang == .turkish ? "Sonraki regle \(days) gün" : "\(days) days until next period" }
    static var periodDay: String { lang == .turkish ? "Regl Günü" : "Period Day" }
    static var daysLeft: String { lang == .turkish ? "Kalan Gün" : "Days Left" }
    static var cycleLength: String { lang == .turkish ? "Döngü Süresi" : "Cycle Length" }
    static var periodLength: String { lang == .turkish ? "Regl Süresi" : "Period Length" }
    static var totalRecords: String { lang == .turkish ? "Toplam Kayıt" : "Total Records" }
    static var predictions: String { lang == .turkish ? "Tahminler" : "Predictions" }
    static var estimatedPeriodEnd: String { lang == .turkish ? "Tahmini Regl Bitişi" : "Estimated Period End" }
    static var nextPeriod: String { lang == .turkish ? "Sonraki Regl" : "Next Period" }
    static var ovulation: String { lang == .turkish ? "Ovülasyon" : "Ovulation" }
    static var fertileWindow: String { lang == .turkish ? "Verimli Pencere" : "Fertile Window" }
    static var lastPeriod: String { lang == .turkish ? "Son Regl" : "Last Period" }
    static var start: String { lang == .turkish ? "Başlangıç" : "Start" }
    static var end: String { lang == .turkish ? "Bitiş" : "End" }
    static var duration: String { lang == .turkish ? "Süre" : "Duration" }
    static var estimatedEnd: String { lang == .turkish ? "Tahmini Bitiş" : "Estimated End" }
    static var periodEnded: String { lang == .turkish ? "Reglim Bitti" : "My Period Ended" }

    // MARK: - Calendar
    static var calendarTitle: String { lang == .turkish ? "Takvim" : "Calendar" }
    static var dayAbbreviations: [String] {
        lang == .turkish
            ? ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
            : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
    static var colorLegend: String { lang == .turkish ? "Renk Açıklaması" : "Color Legend" }
    static var estimatedPeriod: String { lang == .turkish ? "Tahmini Regl" : "Estimated Period" }
    static var today: String { lang == .turkish ? "Bugün" : "Today" }
    static var futurePredictions: String { lang == .turkish ? "Gelecek Tahminler" : "Future Predictions" }
    static var addPeriodForPrediction: String { lang == .turkish ? "Tahmin için regl kaydı ekleyin" : "Add a period record for predictions" }
    static func nextPeriodIndex(_ index: Int) -> String { lang == .turkish ? "\(index). Sonraki Regl" : "Next Period #\(index)" }
    static func daysCount(_ days: Int) -> String { "\(days) \(S.day)" }

    // MARK: - Journal
    static var journalTitle: String { lang == .turkish ? "Günlük" : "Journal" }
    static var journalEmpty: String { lang == .turkish ? "Günlüğün Boş" : "Journal is Empty" }
    static var journalEmptyDescription: String { lang == .turkish ? "Her gün ruh halini ve notlarını\nkaydetmeye başla" : "Start recording your mood\nand notes every day" }
    static var addFirstEntry: String { lang == .turkish ? "İlk Kaydını Ekle" : "Add First Entry" }
    static var deleteEntry: String { lang == .turkish ? "Kaydı Sil" : "Delete Entry" }
    static var deleteJournalConfirm: String { lang == .turkish ? "Bu günlük kaydını silmek istediğinizden emin misiniz?" : "Are you sure you want to delete this journal entry?" }
    static var note: String { lang == .turkish ? "Not" : "Note" }
    static var symptoms: String { lang == .turkish ? "Belirtiler" : "Symptoms" }
    static var journalDetail: String { lang == .turkish ? "Günlük Detayı" : "Journal Detail" }
    static var addJournal: String { lang == .turkish ? "Günlük Ekle" : "Add Journal" }
    static var editJournal: String { lang == .turkish ? "Günlüğü Düzenle" : "Edit Journal" }
    static var howDoYouFeel: String { lang == .turkish ? "Nasıl Hissediyorsun?" : "How Are You Feeling?" }

    // MARK: - Add Period / End Period
    static var newPeriodRecord: String { lang == .turkish ? "Yeni Regl Kaydı" : "New Period Record" }
    static var dates: String { lang == .turkish ? "Tarihler" : "Dates" }
    static var startDate: String { lang == .turkish ? "Başlangıç Tarihi" : "Start Date" }
    static var addEndDate: String { lang == .turkish ? "Bitiş Tarihi Ekle" : "Add End Date" }
    static var endDate: String { lang == .turkish ? "Bitiş Tarihi" : "End Date" }
    static var notes: String { lang == .turkish ? "Notlar" : "Notes" }
    static var editRecord: String { lang == .turkish ? "Kaydı Düzenle" : "Edit Record" }
    static var whenDidPeriodEnd: String { lang == .turkish ? "Regl Ne Zaman Bitti?" : "When Did Your Period End?" }
    static func periodStart(_ date: String) -> String { lang == .turkish ? "Başlangıç: \(date)" : "Start: \(date)" }
    static var periodEndTitle: String { lang == .turkish ? "Regl Bitişi" : "Period End" }

    // MARK: - History
    static var historyTitle: String { lang == .turkish ? "Geçmiş" : "History" }
    static var pastRecords: String { lang == .turkish ? "Geçmiş Kayıtlar" : "Past Records" }
    static var deleteRecord: String { lang == .turkish ? "Kaydı Sil" : "Delete Record" }
    static var deletePeriodConfirm: String { lang == .turkish ? "Bu regl kaydını silmek istediğinizden emin misiniz?" : "Are you sure you want to delete this period record?" }
    static var noRecordsYet: String { lang == .turkish ? "Henüz kayıt yok" : "No records yet" }
    static var noRecordsDescription: String { lang == .turkish ? "İlk regl kaydınızı eklemek için\nana sayfadaki + butonuna tıklayın" : "Tap the + button on the home page\nto add your first period record" }
    static var statistics: String { lang == .turkish ? "İstatistikler" : "Statistics" }
    static var avgCycle: String { lang == .turkish ? "Ort. Döngü" : "Avg. Cycle" }
    static var avgPeriod: String { lang == .turkish ? "Ort. Regl" : "Avg. Period" }
    static var total: String { lang == .turkish ? "Toplam" : "Total" }
    static var record: String { lang == .turkish ? "kayıt" : "records" }
    static var cycleRange: String { lang == .turkish ? "Döngü aralığı:" : "Cycle range:" }
    static func daysRange(_ shortest: Int, _ longest: Int) -> String { "\(shortest) - \(longest) \(S.day)" }

    // MARK: - Chat
    static var chatTitle: String { lang == .turkish ? "Asistan" : "Assistant" }
    static var chatPlaceholder: String { lang == .turkish ? "Mesajını yaz..." : "Type your message..." }
    static var chatWelcome: String {
        lang == .turkish
            ? "Merhaba! Ben Luna, kadın sağlığı asistanın. Regl döngün, belirtilerin veya kadın sağlığı hakkında sorularını yanıtlayabilirim. Nasıl yardımcı olabilirim?"
            : "Hi! I'm Luna, your women's health assistant. I can answer your questions about menstrual cycles, symptoms, or women's health. How can I help you?"
    }

    // MARK: - Chat Context (for AI)
    static func contextCurrentPhase(_ phase: String) -> String {
        lang == .turkish ? "Mevcut döngü fazı: \(phase)" : "Current cycle phase: \(phase)"
    }
    static func contextAvgCycle(_ days: Int) -> String {
        lang == .turkish ? "Ortalama döngü süresi: \(days) gün" : "Average cycle length: \(days) days"
    }
    static func contextAvgPeriod(_ days: Int) -> String {
        lang == .turkish ? "Ortalama regl süresi: \(days) gün" : "Average period length: \(days) days"
    }
    static func contextCycleDay(_ day: Int) -> String {
        lang == .turkish ? "Döngünün \(day). günü" : "Day \(day) of cycle"
    }
    static func contextDaysUntil(_ days: Int) -> String {
        lang == .turkish ? "Sonraki regle \(days) gün kaldı" : "\(days) days until next period"
    }
    static func contextLastStart(_ date: String) -> String {
        lang == .turkish ? "Son regl başlangıcı: \(date)" : "Last period start: \(date)"
    }
    static func contextLastEnd(_ date: String) -> String {
        lang == .turkish ? "Son regl bitişi: \(date)" : "Last period end: \(date)"
    }
    static func contextSymptoms(_ symptoms: String) -> String {
        lang == .turkish ? "Son belirtiler: \(symptoms)" : "Recent symptoms: \(symptoms)"
    }
    static func contextNextPeriod(_ date: String) -> String {
        lang == .turkish ? "Tahmini sonraki regl: \(date)" : "Estimated next period: \(date)"
    }
    static func contextOvulation(_ date: String) -> String {
        lang == .turkish ? "Tahmini yumurtlama: \(date)" : "Estimated ovulation: \(date)"
    }
    static var contextRecentJournals: String {
        lang == .turkish ? "Son günlük kayıtları:" : "Recent journal entries:"
    }
    static func contextJournalEntry(_ date: String, _ mood: String) -> String {
        lang == .turkish ? "- \(date): Ruh hali: \(mood)" : "- \(date): Mood: \(mood)"
    }
    static func contextJournalNote(_ note: String) -> String {
        lang == .turkish ? ", Not: \(note)" : ", Note: \(note)"
    }

    // MARK: - Gemini System Prompt
    static func geminiSystemPrompt(_ cycleContext: String) -> String {
        if lang == .turkish {
            return """
            Sen LunaLog uygulamasının kadın sağlığı asistanısın. Adın Luna. \
            Uzmanlık alanın yalnızca kadın sağlığı, regl döngüsü, belirtiler, hormonal değişimler, üreme sağlığı ve bunlarla ilgili konulardır. \
            \
            Kurallar: \
            - Türkçe konuş, samimi ve destekleyici ol. \
            - Kısa, net ve anlaşılır cevaplar ver. \
            - Tıbbi teşhis koyma, gerektiğinde doktora yönlendir. \
            - Regl döngüsüyle ilgili sorularda kullanıcının döngü verilerini referans al. \
            - Kadın sağlığıyla ilgisi olmayan sorulara cevap verme. Kibarca "Ben sadece kadın sağlığı konularında yardımcı olabilirim" de ve konuyu kadın sağlığına yönlendir. \
            - Zararlı, tehlikeli veya etik dışı konularda yardım etme. \
            \
            Kullanıcının döngü bilgileri şöyle:

            \(cycleContext)
            """
        } else {
            return """
            You are Luna, the women's health assistant of the LunaLog app. \
            Your expertise is limited to women's health, menstrual cycles, symptoms, hormonal changes, reproductive health, and related topics. \
            \
            Rules: \
            - Be friendly and supportive. \
            - Give short, clear, and understandable answers. \
            - Do not make medical diagnoses; refer to a doctor when necessary. \
            - Reference the user's cycle data when answering cycle-related questions. \
            - Do not answer questions unrelated to women's health. Politely say "I can only help with women's health topics" and redirect the conversation. \
            - Do not help with harmful, dangerous, or unethical topics. \
            \
            The user's cycle information:

            \(cycleContext)
            """
        }
    }
    static var geminiUserPrefix: String { lang == .turkish ? "Kullanıcı: " : "User: " }

    // MARK: - Gemini Errors
    static var errorNoApiKey: String {
        lang == .turkish
            ? "API anahtarı girilmemiş. Ayarlar'dan Gemini API anahtarını gir."
            : "No API key entered. Enter your Gemini API key in Settings."
    }
    static var errorInvalidURL: String { lang == .turkish ? "Geçersiz URL." : "Invalid URL." }
    static var errorNoData: String { lang == .turkish ? "Sunucudan yanıt alınamadı." : "No response from server." }
    static var errorParseError: String { lang == .turkish ? "Yanıt işlenemedi." : "Could not process the response." }
    static func errorApiError(_ message: String) -> String { "API Error: \(message)" }

    // MARK: - Settings
    static var settingsTitle: String { lang == .turkish ? "Ayarlar" : "Settings" }
    static var notifications: String { lang == .turkish ? "Bildirimler" : "Notifications" }
    static func remindDaysBefore(_ days: Int) -> String {
        lang == .turkish ? "Kaç gün önceden haber ver" : "Days to remind before"
    }
    static func daysUnit(_ days: Int) -> String { "\(days) \(S.day)" }
    static var notificationsYouWillGet: String { lang == .turkish ? "Alacağın bildirimler:" : "You will receive:" }
    static func notifPeriodReminder(_ days: Int) -> String {
        lang == .turkish ? "  Regl \(days) gün sonra başlayacak" : "  Period starts in \(days) days"
    }
    static var notifPeriodStart: String { lang == .turkish ? "  Tahmini regl başlangıç günü" : "  Estimated period start date" }
    static var notifPeriodEnd: String { lang == .turkish ? "  Tahmini regl bitiş günü" : "  Estimated period end date" }
    static var notifPermissionRequired: String { lang == .turkish ? "Bildirim İzni Gerekli" : "Notification Permission Required" }
    static var notifPermissionMessage: String {
        lang == .turkish
            ? "Bildirim göndermek için izin gerekli. Ayarlar > LunaLog > Bildirimler kısmından izin verebilirsin."
            : "Permission is required to send notifications. You can enable it in Settings > LunaLog > Notifications."
    }
    static var ok: String { lang == .turkish ? "Tamam" : "OK" }

    static var cycleSettings: String { lang == .turkish ? "Döngü Ayarları" : "Cycle Settings" }
    static var defaultCycleLength: String { lang == .turkish ? "Varsayılan Döngü Süresi" : "Default Cycle Length" }
    static var defaultPeriodLength: String { lang == .turkish ? "Varsayılan Regl Süresi" : "Default Period Length" }

    static var calculatedValues: String { lang == .turkish ? "Hesaplanan Değerler" : "Calculated Values" }
    static var avgCycleFull: String { lang == .turkish ? "Ortalama Döngü" : "Average Cycle" }
    static var avgPeriodFull: String { lang == .turkish ? "Ortalama Regl Süresi" : "Average Period Length" }

    static var cyclePhases: String { lang == .turkish ? "Döngü Fazları" : "Cycle Phases" }

    static var dataManagement: String { lang == .turkish ? "Veri Yönetimi" : "Data Management" }
    static var savedCycles: String { lang == .turkish ? "Kayıtlı Döngü" : "Saved Cycles" }
    static func recordCount(_ count: Int) -> String { lang == .turkish ? "\(count) kayıt" : "\(count) records" }
    static var deleteAllData: String { lang == .turkish ? "Tüm Verileri Sil" : "Delete All Data" }
    static var deleteAllTitle: String { lang == .turkish ? "Tüm Verileri Sil" : "Delete All Data" }
    static var deleteAllMessage: String {
        lang == .turkish
            ? "Tüm regl kayıtlarınız ve ayarlarınız silinecek. Bu işlem geri alınamaz."
            : "All period records and settings will be deleted. This action cannot be undone."
    }

    static var language: String { lang == .turkish ? "Dil" : "Language" }

    static var appSection: String { lang == .turkish ? "Uygulama" : "App" }
    static var version: String { lang == .turkish ? "Sürüm" : "Version" }
    static var developer: String { lang == .turkish ? "Geliştirici" : "Developer" }

    // MARK: - Chatbot Settings (hidden but kept for reference)
    static var chatbotTitle: String { lang == .turkish ? "Chatbot (Gemini AI)" : "Chatbot (Gemini AI)" }
    static var geminiApiKeyPlaceholder: String { lang == .turkish ? "Gemini API Anahtarı" : "Gemini API Key" }
    static var geminiApiKeyHint: String {
        lang == .turkish
            ? "aistudio.google.com adresinden ücretsiz API anahtarı alabilirsin"
            : "Get a free API key from aistudio.google.com"
    }
    static var geminiApiKeySet: String { lang == .turkish ? "API anahtarı ayarlandı" : "API key is set" }

    // MARK: - CyclePhase Display Names
    static func cyclePhaseDisplayName(_ phase: CyclePhase) -> String {
        switch phase {
        case .menstruation: return lang == .turkish ? "Regl Dönemi" : "Menstruation"
        case .follicular: return lang == .turkish ? "Folliküler Faz" : "Follicular Phase"
        case .ovulation: return lang == .turkish ? "Ovülasyon" : "Ovulation"
        case .luteal: return lang == .turkish ? "Luteal Faz" : "Luteal Phase"
        }
    }

    static func cyclePhaseDescription(_ phase: CyclePhase) -> String {
        switch phase {
        case .menstruation:
            return lang == .turkish ? "Rahim iç tabakasının dökülmesi" : "Shedding of the uterine lining"
        case .follicular:
            return lang == .turkish ? "Yumurtalıkların yeni yumurta hazırlaması" : "Ovaries preparing a new egg"
        case .ovulation:
            return lang == .turkish ? "Yumurtanın serbest bırakılması" : "Release of the egg"
        case .luteal:
            return lang == .turkish ? "Vücut olası gebeliğe hazırlanır" : "Body prepares for possible pregnancy"
        }
    }

    static func cyclePhaseDetailedDescription(_ phase: CyclePhase) -> String {
        switch phase {
        case .menstruation:
            if lang == .turkish {
                return """
                Regl dönemi, döngünün ilk fazıdır ve genellikle 3-7 gün sürer. Bu dönemde rahim iç tabakası (endometrium) dökülür ve kanama şeklinde vücuttan atılır.

                Bu dönemde yaşanabilecek belirtiler:
                • Karın ve bel ağrısı (kramplar)
                • Yorgunluk ve halsizlik
                • Baş ağrısı
                • Ruh hali değişimleri
                • Şişkinlik

                Öneriler:
                • Bol su için ve sağlıklı beslenin
                • Hafif egzersiz yapın (yürüyüş, yoga)
                • Sıcak uygulama krampları hafifletebilir
                • Yeterli uyku almaya özen gösterin
                """
            } else {
                return """
                The menstrual phase is the first phase of the cycle and typically lasts 3-7 days. During this period, the uterine lining (endometrium) is shed and expelled from the body as bleeding.

                Common symptoms during this phase:
                • Abdominal and lower back pain (cramps)
                • Fatigue and weakness
                • Headaches
                • Mood changes
                • Bloating

                Recommendations:
                • Drink plenty of water and eat healthy
                • Do light exercise (walking, yoga)
                • Heat application can help relieve cramps
                • Make sure to get enough sleep
                """
            }
        case .follicular:
            if lang == .turkish {
                return """
                Folliküler faz, regl döneminin bitiminden ovülasyona kadar sürer (yaklaşık 7-10 gün). Bu dönemde FSH hormonu sayesinde yumurtalıklarda foliküller gelişir ve bir yumurta olgunlaşmaya başlar.

                Bu dönemde yaşanabilecek değişimler:
                • Enerji seviyesi artar
                • Ruh hali iyileşir
                • Cilt daha parlak görünür
                • Yaratıcılık ve motivasyon artar
                • Östrojen seviyesi yükselir

                Öneriler:
                • Yüksek enerjinizi değerlendirin
                • Yoğun egzersiz yapabilirsiniz
                • Sosyal aktivitelere katılmak iyi hissettirebilir
                • Protein ağırlıklı beslenin
                """
            } else {
                return """
                The follicular phase lasts from the end of menstruation to ovulation (approximately 7-10 days). During this phase, FSH hormone stimulates follicle development in the ovaries and an egg begins to mature.

                Changes you may experience:
                • Energy levels increase
                • Mood improves
                • Skin appears brighter
                • Creativity and motivation increase
                • Estrogen levels rise

                Recommendations:
                • Take advantage of your high energy
                • You can do intense exercise
                • Participating in social activities may feel good
                • Focus on protein-rich nutrition
                """
            }
        case .ovulation:
            if lang == .turkish {
                return """
                Ovülasyon, döngünün ortasında (genellikle 14. gün civarı) gerçekleşir ve 1-2 gün sürer. Olgun yumurta yumurtalıktan serbest bırakılır ve tüp boyunca ilerler.

                Bu dönemde yaşanabilecek değişimler:
                • En yüksek doğurganlık dönemi
                • Libido artabilir
                • Hafif karın ağrısı (mittelschmerz)
                • Servikal mukus değişimi
                • Bazal vücut sıcaklığında hafif artış

                Öneriler:
                • Gebelik planınız varsa en uygun dönem
                • Korunma yöntemlerine dikkat edin
                • Vücudunuzdaki değişimleri gözlemleyin
                • Stresten uzak durmaya çalışın
                """
            } else {
                return """
                Ovulation occurs in the middle of the cycle (usually around day 14) and lasts 1-2 days. The mature egg is released from the ovary and travels through the fallopian tube.

                Changes you may experience:
                • Peak fertility period
                • Libido may increase
                • Mild abdominal pain (mittelschmerz)
                • Cervical mucus changes
                • Slight increase in basal body temperature

                Recommendations:
                • Best time if you're planning pregnancy
                • Pay attention to contraception methods
                • Observe changes in your body
                • Try to avoid stress
                """
            }
        case .luteal:
            if lang == .turkish {
                return """
                Luteal faz, ovülasyondan bir sonraki reglin başlangıcına kadar sürer (yaklaşık 10-14 gün). Yumurtanın kaldığı folikül, progesteron üreten corpus luteum'a dönüşür.

                Bu dönemde yaşanabilecek değişimler:
                • PMS belirtileri başlayabilir
                • Göğüs hassasiyeti
                • Şişkinlik ve su tutma
                • Ruh hali değişimleri
                • İştah değişimleri (özellikle tatlı isteği)
                • Akne ve cilt sorunları

                Öneriler:
                • Magnezyum ve B6 vitamini faydalı olabilir
                • Kafein ve tuz tüketimini azaltın
                • Düzenli ve hafif egzersiz yapın
                • Kendinize karşı sabırlı olun
                """
            } else {
                return """
                The luteal phase lasts from ovulation to the start of the next period (approximately 10-14 days). The follicle that contained the egg transforms into the corpus luteum, which produces progesterone.

                Changes you may experience:
                • PMS symptoms may begin
                • Breast tenderness
                • Bloating and water retention
                • Mood swings
                • Appetite changes (especially sugar cravings)
                • Acne and skin issues

                Recommendations:
                • Magnesium and vitamin B6 may be helpful
                • Reduce caffeine and salt intake
                • Do regular, light exercise
                • Be patient with yourself
                """
            }
        }
    }

    // MARK: - Symptom Display Names
    static func symptomDisplayName(_ symptom: Symptom) -> String {
        switch symptom {
        case .cramps: return lang == .turkish ? "Kramp" : "Cramps"
        case .headache: return lang == .turkish ? "Baş Ağrısı" : "Headache"
        case .bloating: return lang == .turkish ? "Şişkinlik" : "Bloating"
        case .fatigue: return lang == .turkish ? "Yorgunluk" : "Fatigue"
        case .moodSwings: return lang == .turkish ? "Ruh Hali Değişimi" : "Mood Swings"
        case .backPain: return lang == .turkish ? "Bel Ağrısı" : "Back Pain"
        case .acne: return lang == .turkish ? "Sivilce" : "Acne"
        case .breastTenderness: return lang == .turkish ? "Göğüs Hassasiyeti" : "Breast Tenderness"
        case .nausea: return lang == .turkish ? "Bulantı" : "Nausea"
        case .insomnia: return lang == .turkish ? "Uykusuzluk" : "Insomnia"
        }
    }

    // MARK: - Mood Display Names
    static func moodDisplayName(_ mood: Mood) -> String {
        switch mood {
        case .veryHappy: return lang == .turkish ? "Harika" : "Amazing"
        case .happy: return lang == .turkish ? "Mutlu" : "Happy"
        case .neutral: return lang == .turkish ? "Normal" : "Normal"
        case .sad: return lang == .turkish ? "Kötü" : "Sad"
        case .verySad: return lang == .turkish ? "Çok Kötü" : "Very Sad"
        case .anxious: return lang == .turkish ? "Kaygılı" : "Anxious"
        case .angry: return lang == .turkish ? "Sinirli" : "Angry"
        case .tired: return lang == .turkish ? "Yorgun" : "Tired"
        }
    }

    // MARK: - AppearanceMode Display Names
    static func appearanceDisplayName(_ mode: AppearanceMode) -> String {
        switch mode {
        case .system: return lang == .turkish ? "Sistem" : "System"
        case .light: return lang == .turkish ? "Açık" : "Light"
        case .dark: return lang == .turkish ? "Koyu" : "Dark"
        }
    }

    // MARK: - AccentColor Display Names
    static func accentColorDisplayName(_ color: AppAccentColor) -> String {
        switch color {
        case .pink: return lang == .turkish ? "Pembe" : "Pink"
        case .purple: return lang == .turkish ? "Mor" : "Purple"
        case .blue: return lang == .turkish ? "Mavi" : "Blue"
        case .teal: return lang == .turkish ? "Turkuaz" : "Teal"
        case .red: return lang == .turkish ? "Kırmızı" : "Red"
        case .orange: return lang == .turkish ? "Turuncu" : "Orange"
        case .green: return lang == .turkish ? "Yeşil" : "Green"
        case .indigo: return lang == .turkish ? "Lacivert" : "Indigo"
        }
    }

    // MARK: - Auth
    static var loginSubtitle: String {
        lang == .turkish
            ? "Döngünü takip etmek\niçin giriş yap"
            : "Sign in to track\nyour cycle"
    }
    static var signInWithGoogle: String {
        lang == .turkish ? "Google ile Giriş Yap" : "Sign in with Google"
    }
    static var signInWithApple: String {
        lang == .turkish ? "Apple ile Giriş Yap" : "Sign in with Apple"
    }
    static var continueAsGuest: String {
        lang == .turkish ? "Hesap oluşturmadan devam et" : "Continue without an account"
    }
    static var or: String {
        lang == .turkish ? "veya" : "or"
    }
    static var account: String {
        lang == .turkish ? "Hesap" : "Account"
    }
    static var logout: String {
        lang == .turkish ? "Çıkış Yap" : "Sign Out"
    }
    static var logoutConfirmTitle: String {
        lang == .turkish ? "Çıkış Yap" : "Sign Out"
    }
    static var logoutConfirmMessage: String {
        lang == .turkish
            ? "Hesabınızdan çıkış yapmak istediğinizden emin misiniz?"
            : "Are you sure you want to sign out?"
    }
    static var authGuest: String {
        lang == .turkish ? "Misafir" : "Guest"
    }
    static var guestDescription: String {
        lang == .turkish
            ? "Hesap oluşturmadan kullanıyorsunuz"
            : "Using without an account"
    }
    static var authErrorGeneral: String {
        lang == .turkish
            ? "Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin."
            : "An error occurred while signing in. Please try again."
    }
}
