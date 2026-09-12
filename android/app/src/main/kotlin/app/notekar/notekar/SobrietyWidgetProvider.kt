package app.notekar.notekar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

class SobrietyWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent?) {
        super.onReceive(context, intent)
        if (intent == null) return
        val action = intent.action
        if (action == NoteKarWidgetProvider.ACTION_LOG_BG) {
            val logType = intent.getStringExtra(NoteKarWidgetProvider.EXTRA_LOG_TYPE) ?: return
            NoteKarWidgetProvider.performBackgroundLog(context, logType)
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
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        fun launchIntent(
            context: Context,
            requestCode: Int,
            actionName: String,
            launchAction: String
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = actionName
                putExtra(MainActivity.EXTRA_LAUNCH_ACTION, launchAction)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        fun launchBackgroundLogIntent(
            context: Context,
            requestCode: Int,
            logType: String
        ): PendingIntent {
            val intent = Intent(context, SobrietyWidgetProvider::class.java).apply {
                action = NoteKarWidgetProvider.ACTION_LOG_BG
                putExtra(NoteKarWidgetProvider.EXTRA_LOG_TYPE, logType)
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

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                NoteKarWidgetProvider.PREFS_NAME,
                Context.MODE_PRIVATE
            )

            val streakDays = prefs.getString(NoteKarWidgetProvider.KEY_STREAK_DAYS, "0h") ?: "0h"
            val streakMilestone =
                prefs.getString(NoteKarWidgetProvider.KEY_STREAK_MILESTONE, "") ?: ""
            val lastRelapseTime =
                prefs.getString(NoteKarWidgetProvider.KEY_LAST_RELAPSE_TIME, "") ?: ""

            val options = manager.getAppWidgetOptions(appWidgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val compact = minWidth < 200

            val views = RemoteViews(context.packageName, R.layout.notekar_sobriety_widget)

            views.setTextViewText(R.id.widget_streak_days, streakDays)

            if (compact) {
                views.setViewVisibility(R.id.widget_details_container, View.GONE)
                views.setViewVisibility(R.id.widget_spacer, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_details_container, View.VISIBLE)
                views.setViewVisibility(R.id.widget_spacer, View.VISIBLE)

                views.setTextViewText(
                    R.id.widget_streak_milestone,
                    if (streakMilestone.isNotEmpty()) streakMilestone else "Clean Streak"
                )
                views.setTextViewText(
                    R.id.widget_last_relapse_time,
                    if (lastRelapseTime.isNotEmpty()) "Last reset: $lastRelapseTime" else "No relapse recorded"
                )
            }

            views.setOnClickPendingIntent(
                R.id.widget_root,
                launchIntent(context, appWidgetId, "app.notekar.notekar.ACTION_OPEN", "open")
            )

            views.setOnClickPendingIntent(
                R.id.widget_single,
                launchBackgroundLogIntent(context, appWidgetId + 10, "single")
            )

            views.setOnClickPendingIntent(
                R.id.widget_note,
                launchQuickNoteActivityIntent(context, appWidgetId + 40)
            )

            manager.updateAppWidget(appWidgetId, views)
        }
    }
}
