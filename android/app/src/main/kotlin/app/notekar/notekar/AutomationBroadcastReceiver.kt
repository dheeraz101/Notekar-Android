package app.notekar.notekar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import java.util.Locale

/**
 * BroadcastReceiver for local automation tools (Tasker, MacroDroid, Termux, Automate).
 * Listens for "app.notekar.notekar.ACTION_LOG_MOMENT" and logs moments offline in background.
 */
class AutomationBroadcastReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent == null) return
        if (intent.action == ACTION_LOG_MOMENT) {
            val prefs =
                context.getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
            val mode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
            val nextAction = prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"

            var type = intent.getStringExtra(EXTRA_TYPE)?.trim()?.lowercase(Locale.ROOT)
            if (type.isNullOrEmpty()) {
                type = if (mode == "single") "single" else nextAction
            }

            // Normalize type
            val normalizedType = when (type) {
                "in", "checkin", "check-in", "clockin", "clock-in" -> "in"
                "out", "checkout", "check-out", "clockout", "clock-out" -> "out"
                "note", "text" -> "note"
                else -> "single"
            }

            val note = intent.getStringExtra(EXTRA_NOTE)?.trim() ?: ""
            val silent = intent.getBooleanExtra(EXTRA_SILENT, false)

            NoteKarWidgetProvider.performBackgroundLog(
                context,
                normalizedType,
                note
            )

            if (!silent) {
                val label = when (normalizedType) {
                    "in" -> "📥 IN"
                    "out" -> "📤 OUT"
                    "note" -> "📝 NOTE"
                    else -> "⚡ SINGLE"
                }
                val suffix = if (note.isNotEmpty()) " • $note" else ""
                Toast.makeText(
                    context,
                    "NoteKar: $label$suffix",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }

    companion object {
        const val ACTION_LOG_MOMENT = "app.notekar.notekar.ACTION_LOG_MOMENT"
        const val EXTRA_TYPE = "type"
        const val EXTRA_NOTE = "note"
        const val EXTRA_SILENT = "silent"
    }
}
