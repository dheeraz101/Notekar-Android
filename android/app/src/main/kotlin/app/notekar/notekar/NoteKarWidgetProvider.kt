package app.notekar.notekar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class NoteKarWidgetProvider : AppWidgetProvider() {

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
        val lastType = prefs.getString(KEY_LAST_TYPE, "") ?: ""
        val lastTimestamp = prefs.getLong(KEY_LAST_TIMESTAMP, 0L)
        val hasMoments = prefs.getBoolean(KEY_HAS_MOMENTS, false)

        val options = manager.getAppWidgetOptions(appWidgetId)
        val minWidth = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH
        )
        val minHeight = options.getInt(
            AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT
        )

        val compact = minWidth < 250
        val tall = minHeight >= 160

        views.setTextViewText(
            R.id.widget_count,
            "$todayCount today"
        )

        views.setTextViewText(
            R.id.widget_mode,
            if (mode == "single") {
                "Single"
            } else {
                "Next: ${nextAction.uppercase()}"
            }
        )

        val lastText = if (!hasMoments || lastTimestamp <= 0L) {
            "No moments yet"
        } else {
            val time = SimpleDateFormat(
                "h:mm a",
                Locale.getDefault()
            ).format(Date(lastTimestamp))

            "${lastType.uppercase()} • $time"
        }

        views.setTextViewText(
            R.id.widget_last,
            lastText
        )

        views.setViewVisibility(
            R.id.widget_single,
            if (compact) View.GONE else View.VISIBLE
        )

        views.setViewVisibility(
            R.id.widget_history,
            if (tall) View.VISIBLE else View.GONE
        )

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
            launchIntent(
                context,
                appWidgetId + 10,
                MainActivity.ACTION_SINGLE,
                "single"
            )
        )

        views.setOnClickPendingIntent(
            R.id.widget_in,
            launchIntent(
                context,
                appWidgetId + 20,
                MainActivity.ACTION_IN,
                "in"
            )
        )

        views.setOnClickPendingIntent(
            R.id.widget_out,
            launchIntent(
                context,
                appWidgetId + 30,
                MainActivity.ACTION_OUT,
                "out"
            )
        )

        views.setOnClickPendingIntent(
            R.id.widget_note,
            launchIntent(
                context,
                appWidgetId + 40,
                MainActivity.ACTION_NOTE,
                "note"
            )
        )

        views.setOnClickPendingIntent(
            R.id.widget_history,
            launchIntent(
                context,
                appWidgetId + 50,
                MainActivity.ACTION_HISTORY,
                "history"
            )
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

    companion object {
        private const val ACTION_OPEN =
            "app.notekar.notekar.ACTION_OPEN"

        const val PREFS_NAME = "notekar_widget_state"
        const val KEY_TODAY_COUNT = "today_count"
        const val KEY_MODE = "mode"
        const val KEY_NEXT_ACTION = "next_action"
        const val KEY_LAST_TYPE = "last_type"
        const val KEY_LAST_TIMESTAMP = "last_timestamp"
        const val KEY_HAS_MOMENTS = "has_moments"

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