package app.notekar.notekar

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val noticeId = intent.getStringExtra(EXTRA_NOTICE_ID) ?: return
        val notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 3200)

        // Cancel the notification immediately
        val manager = context.getSystemService(NotificationManager::class.java)
        manager.cancel(notificationId)

        if (action == ACTION_DISMISS) {
            // Only mark as dismissed permanently if it's not a user-configured reminder
            if (!noticeId.startsWith("reminder_")) {
                val prefs = context.getSharedPreferences("notekar_remote_notices", Context.MODE_PRIVATE)
                val countKey = "remote_notice_count_$noticeId"
                prefs.edit()
                    .putInt(countKey, 9999)
                    .apply()
            }
        }
    }

    companion object {
        const val ACTION_DISMISS = "app.notekar.notekar.DISMISS_NOTICE"
        const val EXTRA_NOTICE_ID = "notice_id"
        const val EXTRA_NOTIFICATION_ID = "notification_id"
    }
}
