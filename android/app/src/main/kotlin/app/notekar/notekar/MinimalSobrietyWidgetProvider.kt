package app.notekar.notekar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews

class MinimalSobrietyWidgetProvider : AppWidgetProvider() {

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
                val prefs = context.getSharedPreferences(
                    NoteKarWidgetProvider.PREFS_NAME,
                    Context.MODE_PRIVATE
                )

                val sobrietyEnabled = prefs.getBoolean(
                    NoteKarWidgetProvider.KEY_SOBRIETY_ENABLED,
                    false
                )
                val rawStreakDays =
                    prefs.getString(NoteKarWidgetProvider.KEY_STREAK_DAYS, "0h") ?: "0h"
                val streakDays = rawStreakDays.replace(" Clean", "").replace(" clean", "").trim()
                val sobrietyStartTs = prefs.getLong(
                    NoteKarWidgetProvider.KEY_SOBRIETY_START_TS,
                    0L
                )

                val views = RemoteViews(
                    context.packageName,
                    R.layout.notekar_sobriety_minimal_widget
                )

                if (!sobrietyEnabled) {
                    views.setTextViewText(R.id.widget_minimal_header, "SOBRIETY")
                    views.setTextViewText(R.id.widget_minimal_days, "--")
                    views.setViewVisibility(R.id.widget_minimal_chronometer, View.GONE)
                    views.setTextViewText(
                        R.id.widget_minimal_status,
                        "Tap to set up in NoteKar"
                    )
                } else {
                    views.setTextViewText(R.id.widget_minimal_header, "SOBRIETY ACTIVE")
                    views.setTextViewText(
                        R.id.widget_minimal_days,
                        "$streakDays Clean"
                    )

                    if (sobrietyStartTs > 0L) {
                        val elapsedMs = System.currentTimeMillis() - sobrietyStartTs
                        if (elapsedMs >= 0L) {
                            views.setViewVisibility(R.id.widget_minimal_chronometer, View.VISIBLE)
                            views.setChronometer(
                                R.id.widget_minimal_chronometer,
                                SystemClock.elapsedRealtime() - elapsedMs,
                                null,
                                true
                            )
                        } else {
                            views.setViewVisibility(R.id.widget_minimal_chronometer, View.GONE)
                        }
                    } else {
                        views.setViewVisibility(R.id.widget_minimal_chronometer, View.GONE)
                    }

                    views.setTextViewText(
                        R.id.widget_minimal_status,
                        "Live counter • Tap for details"
                    )
                }

                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    SobrietyWidgetProvider.launchIntent(
                        context,
                        appWidgetId,
                        "app.notekar.notekar.ACTION_OPEN",
                        "sobriety"
                    )
                )

                manager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                android.util.Log.e(
                    "MinimalSobrietyWidget",
                    "Failed to update Minimal Sobriety widget",
                    e
                )
            }
        }
    }
}
