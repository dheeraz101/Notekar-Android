package app.notekar.notekar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NoteKarWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent?) {
        super.onReceive(context, intent)
        if (intent == null) return
        val action = intent.action
        if (action == ACTION_LOG_BG) {
            val logType = intent.getStringExtra(EXTRA_LOG_TYPE) ?: return
            performBackgroundLog(context, logType)
        } else if (action == ACTION_PAUSE_RESUME_BG) {
            togglePauseResume(context)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        super.onAppWidgetOptionsChanged(
            context,
            appWidgetManager,
            appWidgetId,
            newOptions
        )
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    private fun updateWidget(
        context: Context,
        manager: AppWidgetManager,
        appWidgetId: Int
    ) {
        Companion.updateWidget(context, manager, appWidgetId)
    }

    companion object {
        const val ACTION_LOG_BG = "app.notekar.notekar.ACTION_LOG_BG"
        const val ACTION_PAUSE_RESUME_BG = "app.notekar.notekar.ACTION_PAUSE_RESUME_BG"
        const val EXTRA_LOG_TYPE = "log_type"

        private const val ACTION_OPEN = "app.notekar.notekar.ACTION_OPEN"

        const val PREFS_NAME = "notekar_widget_state"
        const val KEY_TODAY_COUNT = "today_count"
        const val KEY_MODE = "mode"
        const val KEY_NEXT_ACTION = "next_action"
        const val KEY_LAST_TYPE = "last_type"
        const val KEY_LAST_TIMESTAMP = "last_timestamp"
        const val KEY_HAS_MOMENTS = "has_moments"
        const val KEY_HISTORY = "history"
        const val KEY_SOBRIETY_ENABLED = "sobriety_enabled"
        const val KEY_STREAK_DAYS = "streak_days"
        const val KEY_STREAK_MILESTONE = "streak_milestone"
        const val KEY_LAST_RELAPSE_TIME = "last_relapse_time"
        const val KEY_ACTIVE_CATEGORY = "active_category"
        const val KEY_FOCUS_RATIO = "focus_ratio"
        const val KEY_TOTAL_TRACKED = "total_tracked"
        const val KEY_TOTAL_WASTED = "total_wasted"
        const val KEY_IS_PAUSED = "is_paused"
        const val KEY_PAUSED_AT = "paused_at"

        fun launchIntent(
            context: Context,
            requestCode: Int,
            actionName: String,
            launchAction: String
        ): PendingIntent {
            val intent = Intent(
                context,
                MainActivity::class.java
            ).apply {
                action = actionName
                putExtra(
                    MainActivity.EXTRA_LAUNCH_ACTION,
                    launchAction
                )
                flags =
                    Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun launchBackgroundLogIntent(
            context: Context,
            requestCode: Int,
            logType: String
        ): PendingIntent {
            val intent = Intent(context, NoteKarWidgetProvider::class.java).apply {
                action = ACTION_LOG_BG
                putExtra(EXTRA_LOG_TYPE, logType)
            }
            return PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun launchQuickNoteActivityIntent(
            context: Context,
            requestCode: Int
        ): PendingIntent {
            val intent = Intent(context, QuickNoteActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun launchQuickSessionActivityIntent(
            context: Context,
            requestCode: Int,
            logType: String
        ): PendingIntent {
            val intent = Intent(context, QuickNoteActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                putExtra(QuickNoteActivity.EXTRA_IS_SESSION, true)
                putExtra(QuickNoteActivity.EXTRA_LOG_TYPE, logType)
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun performBackgroundLog(context: Context, type: String, note: String = "") {
            val now = System.currentTimeMillis()
            val logString = "$now|$type|$note"

            val bgPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentPendingCount = bgPrefs.getInt("flutter.pending_count", 0)

            bgPrefs.edit()
                .putString("flutter.log_$currentPendingCount", logString)
                .putInt("flutter.pending_count", currentPendingCount + 1)
                .commit()

            // Do NOT mutate local preferences anymore to avoid state de-syncs.
            // Flutter will process the queue and update the widgets via MethodChannel.
            MainActivity.notifyBackgroundLogRecorded()
            Toast.makeText(context, "Logged to queue...", Toast.LENGTH_SHORT).show()
        }

        // Keep old signature but unused
        fun oldPerformBackgroundLog(context: Context, type: String, note: String = "") {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val todayCount = prefs.getInt(KEY_TODAY_COUNT, 0)
            val mode = prefs.getString(KEY_MODE, "two-way") ?: "two-way"

            val newCount = todayCount + 1
            val now = System.currentTimeMillis()

            val currentNextAction = prefs.getString(KEY_NEXT_ACTION, "in") ?: "in"
            val newNextAction = if (mode == "two-way") {
                if (type == "in") "out"
                else if (type == "out") "in"
                else currentNextAction
            } else {
                "single"
            }

            // Update local history string instantly
            val currentHistory = prefs.getString(KEY_HISTORY, "") ?: ""
            val newEntry = "$now|$type|$note"
            val updatedHistory = if (currentHistory.isEmpty()) {
                newEntry
            } else {
                val list = currentHistory.split("\n").toMutableList()
                list.add(0, newEntry)
                val limit = if (list.size > 10) 10 else list.size
                list.subList(0, limit).joinToString("\n")
            }

            // Update widget preferences
            prefs.edit()
                .putInt(KEY_TODAY_COUNT, newCount)
                .putString(KEY_NEXT_ACTION, newNextAction)
                .putLong(KEY_LAST_TIMESTAMP, now)
                .putBoolean(KEY_HAS_MOMENTS, true)
                .putString(KEY_LAST_TYPE, type)
                .putString(KEY_HISTORY, updatedHistory)
                .apply()

            // Write to pending queue inside Flutter's default SharedPreferences file FIRST (synchronous commit)
            val bgPrefs =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentPendingCount = bgPrefs.getInt("flutter.pending_count", 0)
            val logString = "$now|$type|$note"

            val bgEditor = bgPrefs.edit()
                .putString("flutter.log_$currentPendingCount", logString)
                .putInt("flutter.pending_count", currentPendingCount + 1)

            if (mode == "two-way") {
                if (type == "in") {
                    prefs.edit()
                        .putBoolean(KEY_IS_PAUSED, false)
                        .putLong(KEY_PAUSED_AT, 0L)
                        .apply()
                    
                    
                    bgEditor.putBoolean("flutter.is_paused", false)
                    bgEditor.putBoolean("flutter.m-paused", false)
                    bgEditor.remove("flutter.paused_at")
                    bgEditor.remove("flutter.m-paused-at")
                } else if (type == "out") {
                    val wasPaused = prefs.getBoolean(KEY_IS_PAUSED, false)
                    val pausedAt = prefs.getLong(KEY_PAUSED_AT, 0L)
                    if (wasPaused && pausedAt > 0L) {
                        val pauseDuration = now - pausedAt
                        val adjustedStart = prefs.getLong(KEY_LAST_TIMESTAMP, now) + pauseDuration
                        prefs.edit().putLong(KEY_LAST_TIMESTAMP, adjustedStart).apply()
                    }
                    prefs.edit()
                        .putBoolean(KEY_IS_PAUSED, false)
                        .putLong(KEY_PAUSED_AT, 0L)
                        .apply()
                    
                    
                    bgEditor.putBoolean("flutter.is_paused", false)
                    bgEditor.putBoolean("flutter.m-paused", false)
                    bgEditor.remove("flutter.paused_at")
                    bgEditor.remove("flutter.m-paused-at")
                }
            }
            bgEditor.commit()

            // Update all widgets visually and instantly
            updateAllWidgets(context)

            // Update persistent control panel notification
            MainActivity.updatePersistentControlPanel(context)

            // Update floating overlay timer if active
            FloatingTimerService.updateState(context)

            // Notify running foreground activity
            MainActivity.notifyBackgroundLogRecorded()

            // Toast feedback
            val label = when (type) {
                "in" -> "IN"
                "out" -> "OUT"
                else -> "Moment"
            }
            Toast.makeText(context, "Logged $label successfully", Toast.LENGTH_SHORT).show()
        }

        fun togglePauseResume(context: Context) {
            val now = System.currentTimeMillis()
            val bgPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentPendingCount = bgPrefs.getInt("flutter.pending_count", 0)

            bgPrefs.edit()
                .putString("flutter.log_$currentPendingCount", "$now|toggle_pause|")
                .putInt("flutter.pending_count", currentPendingCount + 1)
                .commit()

            MainActivity.notifyBackgroundLogRecorded()
            Toast.makeText(context, "Pause/Resume queued...", Toast.LENGTH_SHORT).show()
        }

        // Keep old signature but unused
        fun oldTogglePauseResume(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val isPaused = prefs.getBoolean(KEY_IS_PAUSED, false)
            val now = System.currentTimeMillis()
            val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

            if (isPaused) {
                val pausedAt = prefs.getLong(KEY_PAUSED_AT, now)
                val pauseDuration = if (pausedAt > 0L) (now - pausedAt) else 0L
                val lastTimestamp = prefs.getLong(KEY_LAST_TIMESTAMP, now) + pauseDuration
                prefs.edit()
                    .putBoolean(KEY_IS_PAUSED, false)
                    .putLong(KEY_PAUSED_AT, 0L)
                    .putLong(KEY_LAST_TIMESTAMP, lastTimestamp)
                    .apply()

                flutterPrefs.edit()
                    .putBoolean("flutter.is_paused", false)
                    .putBoolean("flutter.m-paused", false)
                    .putLong("flutter.m-ses", lastTimestamp)
                    .remove("flutter.paused_at")
                    .remove("flutter.m-paused-at")
                    .commit()

                Toast.makeText(context, "Session Resumed", Toast.LENGTH_SHORT).show()
            } else {
                prefs.edit()
                    .putBoolean(KEY_IS_PAUSED, true)
                    .putLong(KEY_PAUSED_AT, now)
                    .apply()

                flutterPrefs.edit()
                    .putBoolean("flutter.is_paused", true)
                    .putBoolean("flutter.m-paused", true)
                    .putLong("flutter.paused_at", now)
                    .putLong("flutter.m-paused-at", now)
                    .commit()

                Toast.makeText(context, "Session Paused", Toast.LENGTH_SHORT).show()
            }

            updateAllWidgets(context)
            MainActivity.updatePersistentControlPanel(context)
            MainActivity.notifyBackgroundLogRecorded()
            FloatingTimerService.updateState(context)
        }

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            val todayCount = prefs.getInt(KEY_TODAY_COUNT, 0)
            val mode = prefs.getString(KEY_MODE, "two-way") ?: "two-way"
            val nextAction = prefs.getString(KEY_NEXT_ACTION, "in") ?: "in"
            val activeCategory = prefs.getString(KEY_ACTIVE_CATEGORY, "All") ?: "All"
            val isPaused = prefs.getBoolean(KEY_IS_PAUSED, false)
            val pausedAt = prefs.getLong(KEY_PAUSED_AT, 0L)
            val lastTimestamp = prefs.getLong(KEY_LAST_TIMESTAMP, 0L)
            val isCurrentlyIn = mode == "two-way" && nextAction == "out"

            val options = manager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
            )

            val compact = minWidth < 200

            val views = RemoteViews(context.packageName, R.layout.notekar_widget)

            // Normal Layout Binding
            views.setViewVisibility(R.id.widget_in, View.VISIBLE)
            views.setViewVisibility(R.id.widget_out, View.VISIBLE)
            views.setTextViewText(R.id.widget_single, "TAP")
            views.setTextViewText(R.id.widget_note, "NOTE")

            val modeText = if (isCurrentlyIn && isPaused) {
                "PAUSED • ${activeCategory.uppercase(Locale.ROOT)}"
            } else if (activeCategory != "All" && activeCategory.isNotEmpty()) {
                if (mode == "single") {
                    "SINGLE • ${activeCategory.uppercase(Locale.ROOT)}"
                } else {
                    "${nextAction.uppercase(Locale.ROOT)} • ${activeCategory.uppercase(Locale.ROOT)}"
                }
            } else {
                if (mode == "single") {
                    "SINGLE MODE"
                } else {
                    "NEXT: ${nextAction.uppercase(Locale.ROOT)}"
                }
            }
            views.setTextViewText(R.id.widget_mode, modeText)

            // Bind history stack
            val historyString = prefs.getString(KEY_HISTORY, "") ?: ""
            val historyLines =
                if (historyString.isEmpty()) emptyList() else historyString.split("\n")

            if (compact) {
                views.setViewVisibility(R.id.widget_clock, View.GONE)
                views.setViewVisibility(R.id.widget_chronometer, View.GONE)
                views.setViewVisibility(R.id.widget_history_card, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_history_card, View.VISIBLE)

                if (isCurrentlyIn && lastTimestamp > 0L) {
                    views.setViewVisibility(R.id.widget_clock, View.GONE)
                    views.setViewVisibility(R.id.widget_chronometer, View.VISIBLE)
                    val elapsed = if (isPaused && pausedAt > 0L) {
                        pausedAt - lastTimestamp
                    } else {
                        System.currentTimeMillis() - lastTimestamp
                    }
                    val base = SystemClock.elapsedRealtime() - elapsed
                    if (isPaused) {
                        views.setChronometer(R.id.widget_chronometer, base, null, false)
                        views.setTextColor(R.id.widget_chronometer, Color.parseColor("#FFFF9F0A"))
                    } else {
                        views.setChronometer(R.id.widget_chronometer, base, null, true)
                        views.setTextColor(R.id.widget_chronometer, Color.parseColor("#FF30D158"))
                    }
                } else {
                    views.setViewVisibility(R.id.widget_chronometer, View.GONE)
                    views.setViewVisibility(R.id.widget_clock, View.VISIBLE)
                }

                // Show total logs on the right end of the top line
                views.setTextViewText(R.id.widget_total_logs, "$todayCount Logs")

                if (historyLines.isNotEmpty()) {
                    val parts = historyLines[0].split("|")
                    if (parts.size >= 2) {
                        val timestamp = parts[0].toLongOrNull() ?: 0L
                        val type = parts[1]
                        val note = if (parts.size > 2) parts[2] else ""

                        val time = SimpleDateFormat("h:mm a", Locale.getDefault()).format(
                            Date(timestamp)
                        )

                        val typeLabel = when (type.lowercase(Locale.ROOT)) {
                            "in" -> "📥 IN"
                            "out" -> "📤 OUT"
                            "single" -> "⚡ TAP"
                            "note" -> "📝 NOTE"
                            else -> type.uppercase(Locale.ROOT)
                        }

                        views.setTextViewText(R.id.widget_last_log_info, "$typeLabel • $time")

                        if (note.isNotEmpty()) {
                            views.setTextViewText(R.id.widget_last_log_note, note)
                        } else {
                            views.setTextViewText(
                                R.id.widget_last_log_note,
                                "No note details..."
                            )
                        }
                    }
                } else {
                    views.setTextViewText(R.id.widget_last_log_info, "No logs today")
                    views.setTextViewText(
                        R.id.widget_last_log_note,
                        "Tap buttons below to start log"
                    )
                }
            }

            // Click Handlers
            views.setOnClickPendingIntent(
                R.id.widget_root,
                launchIntent(
                    context,
                    appWidgetId,
                    ACTION_OPEN,
                    "open"
                )
            )

            views.setOnClickPendingIntent(
                R.id.widget_single,
                launchBackgroundLogIntent(context, appWidgetId + 10, "single")
            )

            if (isCurrentlyIn) {
                views.setTextViewText(R.id.widget_in, if (isPaused) "▶ RESUME" else "⏸ PAUSE")
                val pauseIntent = Intent(context, NoteKarWidgetProvider::class.java).apply {
                    action = ACTION_PAUSE_RESUME_BG
                }
                views.setOnClickPendingIntent(
                    R.id.widget_in,
                    PendingIntent.getBroadcast(
                        context,
                        appWidgetId + 25,
                        pauseIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                )
            } else {
                views.setTextViewText(R.id.widget_in, "IN")
                views.setOnClickPendingIntent(
                    R.id.widget_in,
                    if (mode == "two-way") launchQuickSessionActivityIntent(context, appWidgetId + 20, "in")
                    else launchBackgroundLogIntent(context, appWidgetId + 20, "in")
                )
            }

            views.setOnClickPendingIntent(
                R.id.widget_out,
                launchBackgroundLogIntent(context, appWidgetId + 30, "out")
            )

            views.setOnClickPendingIntent(
                R.id.widget_note,
                launchQuickNoteActivityIntent(context, appWidgetId + 40)
            )

            manager.updateAppWidget(appWidgetId, views)
        }

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)

            // 1. Update Core Capture Widgets
            val mainComponent = ComponentName(
                context,
                NoteKarWidgetProvider::class.java
            )
            val mainIds = manager.getAppWidgetIds(mainComponent)
            for (id in mainIds) {
                updateWidget(context, manager, id)
            }

            // 2. Update Sobriety Widgets
            val sobrietyComponent = ComponentName(
                context,
                SobrietyWidgetProvider::class.java
            )
            val sobrietyIds = manager.getAppWidgetIds(sobrietyComponent)
            for (id in sobrietyIds) {
                SobrietyWidgetProvider.updateWidget(context, manager, id)
            }

            // 3. Update Life Audit Widgets
            val lifeAuditComponent = ComponentName(
                context,
                LifeAuditWidgetProvider::class.java
            )
            val lifeAuditIds = manager.getAppWidgetIds(lifeAuditComponent)
            for (id in lifeAuditIds) {
                LifeAuditWidgetProvider.updateWidget(context, manager, id)
            }

            // 4. Also refresh persistent control panel if enabled
            try {
                val prefs =
                    context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val showPanel = prefs.getBoolean("flutter.show_persistent_notification", false)
                if (showPanel) {
                    MainActivity.showPersistentControlPanel(context)
                }
            } catch (_: Exception) {
            }
        }
    }
}
