package app.notekar.notekar

import android.Manifest
import android.app.AlarmManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale
import java.net.HttpURLConnection
import java.net.URL

class RemoteNoticeReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs = prefs(context)
            if (prefs.getBoolean(KEY_ENABLED, false)) {
                schedule(context)
            }
            return
        }

        val pendingResult = goAsync()

        Thread {
            try {
                checkFeed(context)
            } catch (_: Exception) {
                // Network notice checks are optional.
                // Offline, DNS, timeout, and malformed feed errors must not crash NoteKar.
            } finally {
                pendingResult.finish()
            }
        }.start()
    }

    companion object {
        private const val ACTION_CHECK = "app.notekar.notekar.CHECK_REMOTE_NOTICES"
        private const val CHANNEL_ID = "notekar_remote_notices"
        private const val KEY_ENABLED = "remote_notices_enabled"
        private const val KEY_CHECK_ON_OPEN = "remote_notices_check_on_open"
        private const val KEY_FEED_URL = "remote_notice_feed_url"
        private const val KEY_LAST_ID = "remote_notice_last_id"
        private const val KEY_PREFIX_COUNT = "remote_notice_count_"
        private const val KEY_PREFIX_LAST_SHOWN = "remote_notice_last_shown_"
        private const val NOTIFICATION_ID = 3200
        private const val REQUEST_CODE = 3201
        private const val INTERVAL_MS = 6L * 60L * 60L * 1000L

        fun configure(context: Context, enabled: Boolean, feedUrl: String, checkOnlyOnOpen: Boolean = false) {
            prefs(context).edit()
                .putBoolean(KEY_ENABLED, enabled)
                .putBoolean(KEY_CHECK_ON_OPEN, checkOnlyOnOpen)
                .putString(KEY_FEED_URL, feedUrl)
                .apply()
            if (enabled) schedule(context) else cancel(context)
        }

        fun checkNow(context: Context) {
            context.sendBroadcast(Intent(context, RemoteNoticeReceiver::class.java).apply {
                action = ACTION_CHECK
            })
        }

        private fun schedule(context: Context) {
            val alarmManager = context.getSystemService(AlarmManager::class.java)
            alarmManager.setInexactRepeating(
                AlarmManager.RTC_WAKEUP,
                System.currentTimeMillis() + INTERVAL_MS,
                INTERVAL_MS,
                pendingIntent(context)
            )
        }

        private fun cancel(context: Context) {
            context.getSystemService(AlarmManager::class.java).cancel(pendingIntent(context))
        }

        private fun pendingIntent(context: Context): PendingIntent {
            val intent = Intent(context, RemoteNoticeReceiver::class.java).apply {
                action = ACTION_CHECK
            }
            return PendingIntent.getBroadcast(
                context,
                REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun checkFeed(context: Context) {
            val prefs = prefs(context)
            if (!prefs.getBoolean(KEY_ENABLED, false) && !prefs.getBoolean(KEY_CHECK_ON_OPEN, false)) return
            if (!canPostNotifications(context)) return
            val feedUrl = prefs.getString(KEY_FEED_URL, "") ?: ""
            if (feedUrl.isBlank()) return

            val connection = (URL(feedUrl).openConnection() as HttpURLConnection).apply {
                connectTimeout = 7000
                readTimeout = 7000
                requestMethod = "GET"
                setRequestProperty("User-Agent", "NoteKar-Android")
                useCaches = false
            }
            try {
                if (connection.responseCode !in 200..299) return
                val bodyText = connection.inputStream.bufferedReader(Charsets.UTF_8).use { it.readText() }
                
                // Parse either list of notices or single notice object
                val notices = try {
                    org.json.JSONArray(bodyText)
                } catch (_: Exception) {
                    org.json.JSONArray().apply {
                        put(JSONObject(bodyText))
                    }
                }

                val now = System.currentTimeMillis()
                var candidateNotice: JSONObject? = null
                var candidatePriorityValue = -1 // low = 0, normal = 1, high = 2

                for (i in 0 until notices.length()) {
                    val data = notices.optJSONObject(i) ?: continue
                    if (data.optBoolean("enabled", true).not()) continue
                    if (!isAllowedForStable(data)) continue
                    if (!isInsideSchedule(data)) continue
                    if (!isVersionInRange(context, data)) continue

                    val id = data.optString("id", "")
                    if (id.isBlank()) continue

                    // Dismissed permanently check
                    val countKey = KEY_PREFIX_COUNT + id
                    val shownCount = prefs.getInt(countKey, 0)
                    if (shownCount >= 9999) continue

                    val maxShows = data.optInt("maxShows", 1).coerceAtLeast(1)
                    if (shownCount >= maxShows) continue

                    val priority = data.optString("priority", "normal").trim().lowercase()
                    val isHighPriority = priority == "high"

                    // Cooldown check (bypassed if high priority)
                    if (!isHighPriority) {
                        val cooldownMs = data.optLong("cooldownHours", 24L).coerceAtLeast(0L) * 60L * 60L * 1000L
                        val lastShownKey = KEY_PREFIX_LAST_SHOWN + id
                        val lastShownAt = prefs.getLong(lastShownKey, 0L)
                        if (lastShownAt > 0L && now - lastShownAt < cooldownMs) continue
                        if (id == prefs.getString(KEY_LAST_ID, "") && maxShows <= 1) continue
                    }

                    val priorityValue = when (priority) {
                        "high" -> 2
                        "normal" -> 1
                        "low" -> 0
                        else -> 1
                    }

                    // Choose candidate: highest priority takes precedence
                    if (priorityValue > candidatePriorityValue) {
                        candidateNotice = data
                        candidatePriorityValue = priorityValue
                    }
                }

                val data = candidateNotice ?: return
                val title = getLocalizedField(data, "title", "NoteKar notice")
                val message = getLocalizedField(data, "body", getLocalizedField(data, "message", "Open NoteKar to see the latest notice."))
                val id = data.optString("id", "")

                val countKey = KEY_PREFIX_COUNT + id
                val lastShownKey = KEY_PREFIX_LAST_SHOWN + id
                val shownCount = prefs.getInt(countKey, 0)

                prefs.edit()
                    .putString(KEY_LAST_ID, id)
                    .putInt(countKey, shownCount + 1)
                    .putLong(lastShownKey, now)
                    .apply()

                showNotification(
                    context,
                    id,
                    title,
                    message,
                    data.optString("url", ""),
                    data.optString("action", "")
                )
            } finally {
                connection.disconnect()
            }
        }

        private fun showNotification(
            context: Context,
            noticeId: String,
            title: String,
            body: String,
            url: String,
            action: String
        ) {
            val notificationManager = context.getSystemService(NotificationManager::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                notificationManager.createNotificationChannel(
                    NotificationChannel(
                        CHANNEL_ID,
                        "App notices",
                        NotificationManager.IMPORTANCE_DEFAULT
                    )
                )
            }
            val appAction = normalizeAction(action).ifBlank { actionFromUrl(url) }
            val openIntent = if (appAction.isNotBlank()) {
                Intent(context, MainActivity::class.java).apply {
                    putExtra(MainActivity.EXTRA_LAUNCH_ACTION, appAction)
                }
            } else if (url.startsWith("https://")) {
                Intent(Intent.ACTION_VIEW, android.net.Uri.parse(url))
            } else {
                Intent(context, MainActivity::class.java)
            }.apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openApp = PendingIntent.getActivity(
                context,
                0,
                openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Build Dismiss Action Button Intent
            val dismissIntent = Intent(context, NotificationActionReceiver::class.java).apply {
                this.action = NotificationActionReceiver.ACTION_DISMISS
                putExtra(NotificationActionReceiver.EXTRA_NOTICE_ID, noticeId)
                putExtra(NotificationActionReceiver.EXTRA_NOTIFICATION_ID, NOTIFICATION_ID)
            }
            val dismissPending = PendingIntent.getBroadcast(
                context,
                1,
                dismissIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val notification = NotificationCompat.Builder(context, CHANNEL_ID)
                .setSmallIcon(R.drawable.ic_stat_notekar)
                .setContentTitle(title)
                .setContentText(body)
                .setStyle(NotificationCompat.BigTextStyle().bigText(body))
                .setContentIntent(openApp)
                .setAutoCancel(true)
                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Dismiss",
                    dismissPending
                )
                .build()
            notificationManager.notify(NOTIFICATION_ID, notification)
        }

        private fun canPostNotifications(context: Context): Boolean {
            return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
                context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
        }

        private fun actionFromUrl(url: String): String {
            val value = url.trim().lowercase()
            if (value.isBlank() || value == "./" || value == "/") return ""
            if ("action=history" in value || value.endsWith("/history")) return "history"
            if ("action=settings" in value || value.endsWith("/settings")) return "settings"
            if ("action=whats-new" in value || "action=whatsnew" in value || value.endsWith("/whats-new")) {
                return "whats-new"
            }
            if ("action=changelog" in value || value.endsWith("/changelog")) return "changelog"
            if ("action=note" in value || value.endsWith("/note")) return "note"
            if ("action=moment" in value || value.endsWith("/moment")) return "moment"
            if ("action=updates" in value || "action=releases" in value || value.endsWith("/updates")) {
                return "releases"
            }
            return ""
        }

        private fun normalizeAction(value: String): String {
            return when (value.trim().lowercase()) {
                "history" -> "history"
                "settings", "setting" -> "settings"
                "whats-new", "whatsnew", "what-is-new", "new" -> "whats-new"
                "changelog", "changes" -> "changelog"
                "note", "new-note" -> "note"
                "moment", "new-moment", "log" -> "moment"
                "updates", "update", "releases", "release" -> "releases"
                else -> ""
            }
        }

        private fun isAllowedForStable(data: JSONObject): Boolean {
            val channels = data.optJSONArray("channels") ?: return true
            for (i in 0 until channels.length()) {
                if (channels.optString(i) == "stable") return true
            }
            return false
        }

        private fun isInsideSchedule(data: JSONObject): Boolean {
            val now = System.currentTimeMillis()
            val showAfter = parseTime(data.optString("showAfter", ""))
            val showUntil = parseTime(data.optString("showUntil", ""))
            if (showAfter != null && now < showAfter) return false
            if (showUntil != null && now > showUntil) return false
            return true
        }

        private fun isVersionInRange(context: Context, data: JSONObject): Boolean {
            val minVer = data.optString("minVersion", "").trim()
            val maxVer = data.optString("maxVersion", "").trim()
            if (minVer.isBlank() && maxVer.isBlank()) return true

            val currentVer = try {
                context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: ""
            } catch (e: Exception) {
                ""
            }
            if (currentVer.isBlank()) return true

            if (minVer.isNotBlank() && compareVersions(currentVer, minVer) < 0) return false
            if (maxVer.isNotBlank() && compareVersions(currentVer, maxVer) > 0) return false
            return true
        }

        private fun compareVersions(v1: String, v2: String): Int {
            val parts1 = v1.split(".").mapNotNull { it.toIntOrNull() }
            val parts2 = v2.split(".").mapNotNull { it.toIntOrNull() }
            val length = maxOf(parts1.size, parts2.size)
            for (i in 0 until length) {
                val p1 = parts1.getOrElse(i) { 0 }
                val p2 = parts2.getOrElse(i) { 0 }
                if (p1 != p2) return p1.compareTo(p2)
            }
            return 0
        }

        private fun getLocalizedField(data: JSONObject, field: String, defaultVal: String): String {
            val locale = Locale.getDefault().language
            val localizedKey = "${field}_$locale"
            val value = data.optString(localizedKey, "").trim()
            if (value.isNotBlank()) return value
            return data.optString(field, defaultVal)
        }

        private fun parseTime(value: String): Long? {
            if (value.isBlank()) return null
            val patterns = arrayOf(
                "yyyy-MM-dd'T'HH:mm:ssXXX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
                "yyyy-MM-dd'T'HH:mm:ss'Z'"
            )
            for (pattern in patterns) {
                try {
                    return SimpleDateFormat(pattern, Locale.US).parse(value)?.time
                } catch (_: Exception) {
                }
            }
            return null
        }

        private fun prefs(context: Context) =
            context.getSharedPreferences("notekar_remote_notices", Context.MODE_PRIVATE)
    }
}
