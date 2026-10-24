package app.notekar.notekar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews

class SessionWidgetProvider : AppWidgetProvider() {

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
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                val widgetPrefs = context.getSharedPreferences(
                    NoteKarWidgetProvider.PREFS_NAME,
                    Context.MODE_PRIVATE
                )

                val nextAction =
                    widgetPrefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                val lastTimestamp =
                    widgetPrefs.getLong(NoteKarWidgetProvider.KEY_LAST_TIMESTAMP, 0L)
                val activeCategory =
                    widgetPrefs.getString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, "All") ?: "All"
                val isPaused =
                    widgetPrefs.getBoolean(NoteKarWidgetProvider.KEY_IS_PAUSED, false)

                val isCurrentlyIn = nextAction == "out"
                val nextLogType = if (isCurrentlyIn) "out" else "in"

                val views = RemoteViews(
                    context.packageName,
                    R.layout.notekar_session_widget
                )

                if (isCurrentlyIn) {
                    views.setTextViewText(
                        R.id.widget_session_status,
                        if (isPaused) "⏸ Paused" else "🟢 Active Session"
                    )
                    views.setTextViewText(R.id.widget_session_toggle_btn, "TAP TO FINISH (OUT)")
                    views.setViewVisibility(R.id.widget_session_chronometer, View.VISIBLE)

                    if (!isPaused && lastTimestamp > 0L) {
                        val elapsed = System.currentTimeMillis() - lastTimestamp
                        val baseTime = SystemClock.elapsedRealtime() - elapsed
                        views.setChronometer(R.id.widget_session_chronometer, baseTime, null, true)
                    } else {
                        views.setChronometer(R.id.widget_session_chronometer, SystemClock.elapsedRealtime(), null, false)
                    }
                } else {
                    views.setTextViewText(R.id.widget_session_status, "⚪ Standby")
                    views.setTextViewText(R.id.widget_session_toggle_btn, "TAP TO START (IN)")
                    views.setViewVisibility(R.id.widget_session_chronometer, View.GONE)
                    views.setChronometer(R.id.widget_session_chronometer, SystemClock.elapsedRealtime(), null, false)
                }

                if (activeCategory.isNotEmpty() && activeCategory != "All") {
                    views.setTextViewText(R.id.widget_session_category, "• $activeCategory")
                    views.setViewVisibility(R.id.widget_session_category, View.VISIBLE)
                } else {
                    views.setViewVisibility(R.id.widget_session_category, View.GONE)
                }

                // 1-Tap Toggle Pending Intent (triggers ACTION_LOG_BG directly without launching MainActivity)
                val togglePending = NoteKarWidgetProvider.launchBackgroundLogIntent(
                    context,
                    2001,
                    nextLogType
                )
                views.setOnClickPendingIntent(R.id.widget_session_toggle_btn, togglePending)

                // Root click to open NoteKar
                val openPending = NoteKarWidgetProvider.launchIntent(
                    context,
                    2000,
                    "app.notekar.notekar.ACTION_OPEN",
                    "open"
                )
                views.setOnClickPendingIntent(R.id.widget_session_root, openPending)

                manager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                android.util.Log.e("SessionWidgetProvider", "Failed to update session widget", e)
            }
        }
    }
}
