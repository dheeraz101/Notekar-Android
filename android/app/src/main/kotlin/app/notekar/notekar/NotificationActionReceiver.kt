package app.notekar.notekar

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val action = intent.action

        if (action == ACTION_TOGGLE_MODE) {
            val prefs =
                context.getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
            val currentMode =
                prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
            val newMode = if (currentMode == "two-way") "single" else "two-way"
            prefs.edit().putString(NoteKarWidgetProvider.KEY_MODE, newMode).apply()

            val flutterPrefs =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            flutterPrefs.edit().putString("flutter.m-mode", newMode).apply()

            NoteKarWidgetProvider.updateAllWidgets(context)
            MainActivity.updatePersistentControlPanel(context)
            MainActivity.notifyModeChanged(newMode)
            return
        }

        val noticeId = intent.getStringExtra(EXTRA_NOTICE_ID) ?: return
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 3200)

        // Cancel the notification immediately
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.cancel(notificationId)

        if (action == ACTION_DISMISS) {
            // Only mark as dismissed permanently if it's not a user-configured reminder
            if (!noticeId.startsWith("reminder_")) {
                val prefs =
                    context.getSharedPreferences("notekar_remote_notices", Context.MODE_PRIVATE)
                val countKey = "remote_notice_count_$noticeId"
                prefs.edit()
                    .putInt(countKey, 9999)
                    .apply()
            }
        }
    }

    companion object {
        const val ACTION_DISMISS = "app.notekar.notekar.DISMISS_NOTICE"
        const val ACTION_TOGGLE_MODE = "app.notekar.notekar.ACTION_TOGGLE_MODE"
        const val EXTRA_NOTICE_ID = "notice_id"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
    }
}
