package app.notekar.notekar

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.widget.Toast

/**
 * Handles Android global text selection context menu ("Log in NoteKar").
 * Receives highlighted text from any application (Chrome, Books, WhatsApp, etc.)
 * and logs it immediately or forwards it to NoteKar.
 */
class ProcessTextActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val selectedText = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString()?.trim()
        } else {
            null
        }

        if (!selectedText.isNullOrEmpty()) {
            val isReadonly = intent.getBooleanExtra(Intent.EXTRA_PROCESS_TEXT_READONLY, false)

            // 1. Perform background log via NoteKarWidgetProvider
            val prefs = getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
            val mode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
            val nextAction = prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
            val logType = if (mode == "single") "single" else nextAction

            NoteKarWidgetProvider.performBackgroundLog(
                this,
                logType,
                selectedText
            )

            val displaySnippet = if (selectedText.length > 30) {
                selectedText.substring(0, 27) + "..."
            } else {
                selectedText
            }
            Toast.makeText(
                this,
                "⚡ Logged to NoteKar: \"$displaySnippet\"",
                Toast.LENGTH_SHORT
            ).show()
        }

        finish()
    }
}
