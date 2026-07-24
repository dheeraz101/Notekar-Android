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
        val lastTimestamp = prefs.getLong(KEY_LAST_TIMESTAMP, 0L)
        val hasMoments = prefs.getBoolean(KEY_HAS_MOMENTS, false)

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
                "NEXT: ${nextAction.uppercase()}"
            }
        )

        // Count color refinement
        views.setTextColor(
            R.id.widget_count,
            android.graphics.Color.parseColor("#FF0A84FF")
        )

        val lastType = prefs.getString(KEY_LAST_TYPE, "") ?: ""
        val lastText = if (!hasMoments || lastTimestamp <= 0L) {
            "No moments"
        } else {
            val time = SimpleDateFormat(
                "h:mm a",
                Locale.getDefault()
            ).format(Date(lastTimestamp))

            val typeSuffix = when (lastType.lowercase(Locale.ROOT)) {
                "in" -> " (IN)"
                "out" -> " (OUT)"
                "single" -> " (Tap)"
                "note" -> " (Note)"
                else -> ""
            }

            "Last: $time$typeSuffix"
        }

        views.setTextViewText(
            R.id.widget_last,
            lastText
        )

        // Visibility handling for smaller widget sizes
        if (compact) {
            views.setViewVisibility(R.id.widget_mode, View.GONE)
            views.setViewVisibility(R.id.widget_last, View.GONE)
            views.setViewVisibility(R.id.widget_clock, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_mode, View.VISIBLE)
            views.setViewVisibility(R.id.widget_last, View.VISIBLE)
            views.setViewVisibility(R.id.widget_clock, View.VISIBLE)
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

        fun performBackgroundLog(context: Context, type: String, note: String = "") {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val todayCount = prefs.getInt(KEY_TODAY_COUNT, 0)
            val mode = prefs.getString(KEY_MODE, "two-way") ?: "two-way"

            val newCount = todayCount + 1
            val now = System.currentTimeMillis()

            // Toggle next action if two-way
            val newNextAction = if (mode == "two-way") {
                if (type == "in") "out" else "in"
            } else {
                "single"
            }

            // Update widget preferences
            prefs.edit()
                .putInt(KEY_TODAY_COUNT, newCount)
                .putString(KEY_NEXT_ACTION, newNextAction)
                .putLong(KEY_LAST_TIMESTAMP, now)
                .putBoolean(KEY_HAS_MOMENTS, true)
                .putString(KEY_LAST_TYPE, type)
                .apply()

            // Update all widgets visually
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

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)

            val component = ComponentName(
                context,
                NoteKarWidgetProvider::class.java
            )

            val ids = manager.getAppWidgetIds(component)

            if (ids.isEmpty()) return

            val intent = Intent(
                context,
                NoteKarWidgetProvider::class.java
            ).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(
                    AppWidgetManager.EXTRA_APPWIDGET_IDS,
                    ids
                )
            }

            context.sendBroadcast(intent)
        }
    }
}