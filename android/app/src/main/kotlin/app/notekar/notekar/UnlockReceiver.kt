package app.notekar.notekar

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat

/**
 * BroadcastReceiver triggered on android.intent.action.USER_PRESENT (phone unlocked).
 * When "Log after unlock" is enabled in settings, either pops an interactive Heads-up
 * Notification or presents the QuickNote floating overlay with a 60-second cooldown guard.
 */
class UnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_USER_PRESENT) return

        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.m-log-after-unlock", false)
        if (!isEnabled) return

        // 60-second cooldown guard to prevent multiple prompts on rapid unlock cycles
        val now = System.currentTimeMillis()
        val lastPromptTime = flutterPrefs.getLong("flutter.last_unlock_prompt_ms", 0L)
        if (now - lastPromptTime < 60_000L) {
            return
        }
        flutterPrefs.edit().putLong("flutter.last_unlock_prompt_ms", now).apply()

        val actionStyle = flutterPrefs.getString("flutter.m-unlock-action", "notification") ?: "notification"

        if (actionStyle == "quick_note") {
            // Launch floating QuickNoteActivity directly
            val quickNoteIntent = Intent(context, QuickNoteActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            context.startActivity(quickNoteIntent)
        } else {
            // Post an elegant interactive heads-up notification
            postUnlockNotification(context)
        }
    }

    private fun postUnlockNotification(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        val channelId = "notekar_quick_log"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Quick Log on Unlock",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Interactive prompt to quickly log notes or checkpoints upon unlocking device"
                enableVibration(true)
                setShowBadge(false)
            }
            manager.createNotificationChannel(channel)
        }

        // Tap content -> Open main app
        val contentIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            UNLOCK_NOTIF_ID,
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Action 1: Quick Note Floating Overlay
        val noteIntent = Intent(context, QuickNoteActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val notePendingIntent = PendingIntent.getActivity(
            context,
            UNLOCK_NOTIF_ID + 1,
            noteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Action 2: Checkpoint Dashboard in Main App
        val checkpointIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "checkpoint")
        }
        val checkpointPendingIntent = PendingIntent.getActivity(
            context,
            UNLOCK_NOTIF_ID + 2,
            checkpointIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Action 3: Two-Way Session Start
        val sessionIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "session")
        }
        val sessionPendingIntent = PendingIntent.getActivity(
            context,
            UNLOCK_NOTIF_ID + 3,
            sessionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("NoteKar • Quick Log")
            .setContentText("Ready to log a note, habit checkpoint, or session?")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(contentPendingIntent)
            .addAction(0, "✎ Note", notePendingIntent)
            .addAction(0, "📍 Checkpoint", checkpointPendingIntent)
            .addAction(0, "⏱ Session", sessionPendingIntent)
            .build()

        manager.notify(UNLOCK_NOTIF_ID, notification)
    }

    companion object {
        private const val UNLOCK_NOTIF_ID = 4192
    }
}
