package app.notekar.notekar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
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
        const val EXTRA_LOG_TYPE = "log_type"

        private const val ACTION_OPEN =
            "app.notekar.notekar.ACTION_OPEN"

        const val PREFS_NAME = "notekar_widget_state"
        const val KEY_TODAY_COUNT = "today_count"
        const val KEY_MODE = "mode"
        const val KEY_NEXT_ACTION = "next_action"
        const val KEY_LAST_TYPE = "last_type"
        const val KEY_LAST_TIMESTAMP = "last_timestamp"
        const val KEY_HAS_MOMENTS = "has_moments"
        const val KEY_HISTORY = "history"

        private fun launchIntent(
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

        private fun launchBackgroundLogIntent(
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

        private fun launchQuickNoteActivityIntent(
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

        fun performBackgroundLog(context: Context, type: String, note: String = "") {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val todayCount = prefs.getInt(KEY_TODAY_COUNT, 0)
            val mode = prefs.getString(KEY_MODE, "two-way") ?: "two-way"

            val newCount = todayCount + 1
            val now = System.currentTimeMillis()

            val newNextAction = if (mode == "two-way") {
                if (type == "in") "out" else "in"
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

            // Update all widgets visually and instantly
            updateAllWidgets(context)

            // Write to pending queue inside Flutter's default SharedPreferences file
            val bgPrefs =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val currentCount = bgPrefs.getInt("flutter.pending_count", 0)
            val logString = "$now|$type|$note"

            bgPrefs.edit()
                .putString("flutter.log_$currentCount", logString)
                .putInt("flutter.pending_count", currentCount + 1)
                .apply()

            // Toast feedback
            val label = when (type) {
                "in" -> "IN"
                "out" -> "OUT"
                else -> "Moment"
            }
            Toast.makeText(context, "Logged $label successfully", Toast.LENGTH_SHORT).show()
        }

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(
                context.packageName,
                R.layout.notekar_widget
            )

            val prefs = context.getSharedPreferences(
                PREFS_NAME,
                Context.MODE_PRIVATE
            )

            val todayCount = prefs.getInt(KEY_TODAY_COUNT, 0)
            val mode = prefs.getString(KEY_MODE, "two-way") ?: "two-way"
            val nextAction = prefs.getString(KEY_NEXT_ACTION, "in") ?: "in"

            val options = manager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(
                AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
            )

            val compact = minWidth < 200

            views.setTextViewText(
                R.id.widget_count,
                todayCount.toString()
            )

            views.setTextViewText(
                R.id.widget_mode,
                if (mode == "single") {
                    "SINGLE MODE"
                } else {
                    "NEXT: ${nextAction.uppercase(Locale.ROOT)}"
                }
            )

            // Count color refinement
            views.setTextColor(
                R.id.widget_count,
                android.graphics.Color.parseColor("#FF0A84FF")
            )

            // Bind history stack
            val historyString = prefs.getString(KEY_HISTORY, "") ?: ""
            val historyLines =
                if (historyString.isEmpty()) emptyList() else historyString.split("\n")

            val historyTextViewIds = intArrayOf(
                R.id.widget_history_0,
                R.id.widget_history_1,
                R.id.widget_history_2,
                R.id.widget_history_3
            )

            if (compact) {
                views.setViewVisibility(R.id.widget_clock, View.GONE)
                for (viewId in historyTextViewIds) {
                    views.setViewVisibility(viewId, View.GONE)
                }
            } else {
                views.setViewVisibility(R.id.widget_clock, View.VISIBLE)
                for (i in historyTextViewIds.indices) {
                    val viewId = historyTextViewIds[i]
                    if (i < historyLines.size) {
                        val parts = historyLines[i].split("|")
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
                                "single" -> "⚡ Tap"
                                "note" -> "📝 " + (if (note.isNotEmpty()) note else "Note")
                                else -> type.uppercase(Locale.ROOT)
                            }

                            val noteSuffix =
                                if (type.lowercase(Locale.ROOT) != "note" && note.isNotEmpty()) {
                                    " ($note)"
                                } else {
                                    ""
                                }

                            views.setTextViewText(viewId, "$time - $typeLabel$noteSuffix")
                            views.setViewVisibility(viewId, View.VISIBLE)
                        } else {
                            views.setViewVisibility(viewId, View.GONE)
                        }
                    } else {
                        if (i == 0 && historyLines.isEmpty()) {
                            views.setTextViewText(viewId, "No history")
                            views.setViewVisibility(viewId, View.VISIBLE)
                        } else {
                            views.setViewVisibility(viewId, View.GONE)
                        }
                    }
                }
            }

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

            views.setOnClickPendingIntent(
                R.id.widget_in,
                launchBackgroundLogIntent(context, appWidgetId + 20, "in")
            )

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

            val component = ComponentName(
                context,
                NoteKarWidgetProvider::class.java
            )

            val ids = manager.getAppWidgetIds(component)

            if (ids.isEmpty()) return

            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }
    }
}