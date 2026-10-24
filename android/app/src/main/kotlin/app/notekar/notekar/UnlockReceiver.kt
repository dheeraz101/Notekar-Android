package app.notekar.notekar

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.provider.Settings
import androidx.core.app.NotificationCompat

/**
 * BroadcastReceiver triggered on android.intent.action.USER_PRESENT (phone unlocked).
 * When "Log after unlock" is enabled in settings, either pops an interactive Heads-up
 * Notification or presents the QuickNote floating overlay with a 12-second cooldown guard.
 */
class UnlockReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != Intent.ACTION_USER_PRESENT) return

        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.m-log-after-unlock", false) ||
                        flutterPrefs.getBoolean("m-log-after-unlock", false)
        if (!isEnabled) return

        // 12-second cooldown guard to prevent multiple prompts on rapid unlock cycles
        val now = System.currentTimeMillis()
        val lastPromptTime = flutterPrefs.getLong("flutter.last_unlock_prompt_ms", 0L)
        if (now - lastPromptTime < 12_000L) {
            return
        }
        flutterPrefs.edit().putLong("flutter.last_unlock_prompt_ms", now).apply()

        val actionStyle = flutterPrefs.getString("flutter.m-unlock-action", null)
            ?: flutterPrefs.getString("m-unlock-action", "notification")
            ?: "notification"

        if (actionStyle == "quick_note") {
            // Android 10+ restricts starting background activities without overlay permission.
            val canDraw = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                Settings.canDrawOverlays(context)
            } else {
                true
            }

            if (canDraw) {
                try {
                    val quickNoteIntent = Intent(context, QuickNoteActivity::class.java).apply {
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                                Intent.FLAG_ACTIVITY_SINGLE_TOP
                    }
                    context.startActivity(quickNoteIntent)
                    return
                } catch (e: Exception) {
                    android.util.Log.e("UnlockReceiver", "Failed to launch QuickNoteActivity directly, falling back to notification", e)
                }
            } else {
                android.util.Log.w("UnlockReceiver", "SYSTEM_ALERT_WINDOW permission not granted; falling back to heads-up notification")
            }
        }

        // Post an elegant interactive heads-up notification
        postUnlockNotification(context)
    }

    private fun postUnlockNotification(context: Context) {
        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager ?: return

        // If on Android 13+ and notifications are globally disabled by user, don't attempt to notify
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && !manager.areNotificationsEnabled()) {
            android.util.Log.w("UnlockReceiver", "Notifications are disabled, skipping unlock notification")
            return
        }

        val channelId = CHANNEL_ID
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Quick Log on Unlock",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Interactive prompt to quickly log notes or checkpoints upon unlocking device"
                enableVibration(true)
                setShowBadge(false)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
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
            putExtra(MainActivity.EXTRA_LAUNCH_ACTION, "checkpoint")
            putExtra("action", "checkpoint")
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
            putExtra(MainActivity.EXTRA_LAUNCH_ACTION, "session")
            putExtra("action", "session")
            putExtra("route", "session")
        }
        val sessionPendingIntent = PendingIntent.getActivity(
            context,
            UNLOCK_NOTIF_ID + 3,
            sessionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.drawable.ic_stat_notekar)
            .setContentTitle("NoteKar • Quick Log")
            .setContentText("Ready to log a note, habit checkpoint, or session?")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_REMINDER)
            .setAutoCancel(true)
            .setContentIntent(contentPendingIntent)
            .addAction(0, "✎ Note", notePendingIntent)
            .addAction(0, "📍 Checkpoint", checkpointPendingIntent)
            .addAction(0, "⏱ Session", sessionPendingIntent)
            .setDefaults(NotificationCompat.DEFAULT_ALL)
            .build()

        manager.notify(UNLOCK_NOTIF_ID, notification)
    }

    companion object {
        const val CHANNEL_ID = "notekar_quick_log"
        private const val UNLOCK_NOTIF_ID = 4192
        private var dynamicReceiver: UnlockReceiver? = null

        /**
         * Dynamically registers or unregisters the UnlockReceiver based on user preference.
         * Modern Android (API 26+) ignores static manifest declarations for Intent.ACTION_USER_PRESENT.
         * Dynamic context registration ensures unlock events are delivered reliably.
         */
        @Synchronized
        fun updateUnlockReceiver(context: Context) {
            val appContext = context.applicationContext ?: context
            val flutterPrefs = appContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val isEnabled = flutterPrefs.getBoolean("flutter.m-log-after-unlock", false) ||
                            flutterPrefs.getBoolean("m-log-after-unlock", false)

            if (isEnabled) {
                if (dynamicReceiver == null) {
                    try {
                        val receiver = UnlockReceiver()
                        val filter = IntentFilter(Intent.ACTION_USER_PRESENT)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            appContext.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
                        } else {
                            appContext.registerReceiver(receiver, filter)
                        }
                        dynamicReceiver = receiver
                        android.util.Log.i("UnlockReceiver", "Registered dynamic UnlockReceiver for ACTION_USER_PRESENT")
                    } catch (e: Exception) {
                        android.util.Log.e("UnlockReceiver", "Failed to register dynamic UnlockReceiver", e)
                    }
                }
            } else {
                dynamicReceiver?.let { receiver ->
                    try {
                        appContext.unregisterReceiver(receiver)
                        android.util.Log.i("UnlockReceiver", "Unregistered dynamic UnlockReceiver")
                    } catch (e: Exception) {
                        android.util.Log.e("UnlockReceiver", "Failed to unregister dynamic UnlockReceiver", e)
                    }
                    dynamicReceiver = null
                }
            }
        }
    }
}
