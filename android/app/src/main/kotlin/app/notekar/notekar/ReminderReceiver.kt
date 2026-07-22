package app.notekar.notekar

import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.util.Calendar

class ReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        if (action == Intent.ACTION_BOOT_COMPLETED) {
            rescheduleAll(context)
            return
        }

        val id = intent.getStringExtra(EXTRA_ID) ?: return
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "NoteKar Reminder"
        val body = intent.getStringExtra(EXTRA_BODY) ?: "Time to log a moment!"
        val type = intent.getStringExtra(EXTRA_TYPE) ?: "daily"

        showNotification(context, id, title, body)

        // Reschedule next occurrence for repeating alarms
        if (type == "daily" || type == "weekly" || type == "monthly") {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val jsonStr = prefs.getString(id, null)
            if (jsonStr != null) {
                try {
                    val json = JSONObject(jsonStr)
                    scheduleAlarm(context, id, json)
                } catch (_: Exception) {}
            }
        }
    }

    companion object {
        const val PREFS_NAME = "notekar_reminders_prefs"
        const val CHANNEL_ID = "notekar_reminders"
        const val NOTIFICATION_ID_BASE = 4000

        const val EXTRA_ID = "reminder_id"
        const val EXTRA_TITLE = "reminder_title"
        const val EXTRA_BODY = "reminder_body"
        const val EXTRA_TYPE = "reminder_type"

        fun schedule(
            context: Context,
            id: String,
            type: String,
            hour: Int,
            minute: Int,
            daysOfWeek: List<Int>?,
            dayOfMonth: Int?,
            intervalMinutes: Int?,
            title: String,
            body: String
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val json = JSONObject().apply {
                put("id", id)
                put("type", type)
                put("hour", hour)
                put("minute", minute)
                if (daysOfWeek != null) {
                    put("daysOfWeek", org.json.JSONArray(daysOfWeek))
                }
                if (dayOfMonth != null) {
                    put("dayOfMonth", dayOfMonth)
                }
                if (intervalMinutes != null) {
                    put("intervalMinutes", intervalMinutes)
                }
                put("title", title)
                put("body", body)
            }
            prefs.edit().putString(id, json.toString()).apply()

            scheduleAlarm(context, id, json)
        }

        fun cancel(context: Context, id: String) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().remove(id).apply()

            val alarmManager = context.getSystemService(AlarmManager::class.java)
            val intent = Intent(context, ReminderReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            alarmManager.cancel(pendingIntent)
        }

        private fun rescheduleAll(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val keys = prefs.all.keys
            for (key in keys) {
                val jsonStr = prefs.getString(key, null) ?: continue
                try {
                    val json = JSONObject(jsonStr)
                    scheduleAlarm(context, key, json)
                } catch (_: Exception) {}
            }
        }

        private fun scheduleAlarm(context: Context, id: String, json: JSONObject) {
            val type = json.optString("type")
            val hour = json.optInt("hour")
            val minute = json.optInt("minute")
            val title = json.optString("title")
            val body = json.optString("body")

            val alarmManager = context.getSystemService(AlarmManager::class.java) ?: return
            val intent = Intent(context, ReminderReceiver::class.java).apply {
                putExtra(EXTRA_ID, id)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
                putExtra(EXTRA_TYPE, type)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id.hashCode(),
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val calendar = Calendar.getInstance()
            val now = Calendar.getInstance()

            when (type) {
                "inactivity" -> {
                    val intervalMinutes = json.optInt("intervalMinutes", 60)
                    calendar.timeInMillis = System.currentTimeMillis() + (intervalMinutes * 60L * 1000L)
                }
                "daily" -> {
                    calendar.set(Calendar.HOUR_OF_DAY, hour)
                    calendar.set(Calendar.MINUTE, minute)
                    calendar.set(Calendar.SECOND, 0)
                    calendar.set(Calendar.MILLISECOND, 0)
                    if (calendar.before(now)) {
                        calendar.add(Calendar.DAY_OF_YEAR, 1)
                    }
                }
                "weekly" -> {
                    val daysArr = json.optJSONArray("daysOfWeek")
                    val days = mutableListOf<Int>()
                    if (daysArr != null) {
                        for (i in 0 until daysArr.length()) {
                            days.add(daysArr.getInt(i))
                        }
                    }
                    if (days.isEmpty()) {
                        days.add(calendar.get(Calendar.DAY_OF_WEEK))
                    }

                    var targetCalendar: Calendar? = null
                    for (day in days) {
                        val tempCal = Calendar.getInstance().apply {
                            set(Calendar.HOUR_OF_DAY, hour)
                            set(Calendar.MINUTE, minute)
                            set(Calendar.SECOND, 0)
                            set(Calendar.MILLISECOND, 0)
                            set(Calendar.DAY_OF_WEEK, day)
                        }
                        if (tempCal.before(now)) {
                            tempCal.add(Calendar.WEEK_OF_YEAR, 1)
                        }
                        if (targetCalendar == null || tempCal.before(targetCalendar)) {
                            targetCalendar = tempCal
                        }
                    }
                    calendar.timeInMillis = targetCalendar?.timeInMillis ?: System.currentTimeMillis()
                }
                "monthly" -> {
                    val dayOfMonth = json.optInt("dayOfMonth", 1)
                    calendar.set(Calendar.DAY_OF_MONTH, dayOfMonth)
                    calendar.set(Calendar.HOUR_OF_DAY, hour)
                    calendar.set(Calendar.MINUTE, minute)
                    calendar.set(Calendar.SECOND, 0)
                    calendar.set(Calendar.MILLISECOND, 0)
                    if (calendar.before(now)) {
                        calendar.add(Calendar.MONTH, 1)
                    }
                }
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            } else {
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    calendar.timeInMillis,
                    pendingIntent
                )
            }
        }

        private fun showNotification(context: Context, reminderId: String, title: String, body: String) {
            val notificationManager = context.getSystemService(NotificationManager::class.java) ?: return
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Reminders",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "NoteKar logging reminders"
                    enableLights(true)
                    enableVibration(true)
                }
                notificationManager.createNotificationChannel(channel)
            }

            val notificationId = NOTIFICATION_ID_BASE + Math.abs(reminderId.hashCode() % 1000)

            val openIntent = Intent(context, MainActivity::class.java).apply {
                putExtra(MainActivity.EXTRA_LAUNCH_ACTION, "moment")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPending = PendingIntent.getActivity(
                context,
                reminderId.hashCode(),
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val dismissIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                action = NotificationActionReceiver.ACTION_DISMISS
                putExtra(NotificationActionReceiver.EXTRA_NOTICE_ID, reminderId)
                putExtra(NotificationActionReceiver.EXTRA_NOTIFICATION_ID, notificationId)
            }
            val dismissPending = PendingIntent.getBroadcast(
                context,
                reminderId.hashCode() + 1,
                dismissIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_notekar)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setContentIntent(openPending)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setDefaults(NotificationCompat.DEFAULT_ALL)
                .addAction(
                    android.R.drawable.ic_menu_edit,
                    "Log Now",
                    openPending
                )
                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Dismiss",
                    dismissPending
                )
                .build()

            notificationManager.notify(notificationId, notification)
        }
    }
}
