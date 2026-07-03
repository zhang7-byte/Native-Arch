import Foundation

extension AppStore {
    func loadSettings() {
        let rows = db.query("SELECT * FROM app_settings WHERE id=0") { r -> AppSettings in
            AppSettings(
                themeMode: r.string("theme_mode"),
                accentColor: Int(r.string("accent_color")) ?? 0xFF009688,
                density: r.string("density"),
                notifyFrequency: r.string("notify_frequency"),
                holidayRegion: r.string("holiday_region"),
                scheduleNotify: r.string("schedule_notify") == "1"
            )
        }
        if let s = rows.first {
            settings = s
        } else {
            // Seed the single settings row.
            saveSettings(AppSettings())
        }
    }

    func saveSettings(_ s: AppSettings) {
        let now = Date()
        db.run("""
            INSERT INTO app_settings
                (id, theme_mode, accent_color, density, notify_frequency,
                 holiday_region, schedule_notify, updated_at)
            VALUES (0,?,?,?,?,?,?,?)
            ON CONFLICT(id) DO UPDATE SET
                theme_mode=excluded.theme_mode,
                accent_color=excluded.accent_color,
                density=excluded.density,
                notify_frequency=excluded.notify_frequency,
                holiday_region=excluded.holiday_region,
                schedule_notify=excluded.schedule_notify,
                updated_at=excluded.updated_at
            """,
            [s.themeMode, s.accentColor, s.density, s.notifyFrequency,
             s.holidayRegion, s.scheduleNotify ? 1 : 0, now])
        settings = s
        refreshNotifications()
    }
}
