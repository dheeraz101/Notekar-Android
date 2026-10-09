package app.notekar.notekar

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build

object NotificationConsistencyManager {

    const val CHANNEL_HIGH_ONGOING = "notekar_high_ongoing"
    const val CHANNEL_DEFAULT_REMINDERS = "notekar_default_reminders"
    const val CHANNEL_LOW_WISDOM = "notekar_low_wisdom"

    fun setupChannels(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)

            // Channel 1 (High): Ongoing Session (Un-dismissible while active)
            val highChannel = NotificationChannel(
                CHANNEL_HIGH_ONGOING,
                "Ongoing Session",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Active session tracking"
            }

            // Channel 2 (Default): Reminders & Backups
            val defaultChannel = NotificationChannel(
                CHANNEL_DEFAULT_REMINDERS,
                "Reminders & Backups",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Daily reminders and background syncs"
            }

            // Channel 3 (Low): App Notices & Bulletins
            val lowChannel = NotificationChannel(
                CHANNEL_LOW_WISDOM,
                "App Notices & Bulletins",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Official updates, advisories, and bulletin notices"
            }

            notificationManager?.createNotificationChannel(highChannel)
            notificationManager?.createNotificationChannel(defaultChannel)
            notificationManager?.createNotificationChannel(lowChannel)
        }
    }
}
