package app.notekar.notekar

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import android.widget.EditText
import android.widget.LinearLayout

class QuickNoteActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set the activity to be transparent
        window.setBackgroundDrawableResource(android.R.color.transparent)

        val builder = AlertDialog.Builder(this)
        builder.setTitle("Add Quick Note")

        val input = EditText(this).apply {
            hint = "Type note here..."
            setSingleLine(true)
        }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val padding = (20 * resources.displayMetrics.density).toInt()
            setPadding(padding, padding / 2, padding, padding / 2)
            addView(input)
        }
        builder.setView(container)

        builder.setPositiveButton("Add") { dialog, _ ->
            val note = input.text.toString().trim()
            if (note.isNotEmpty()) {
                val prefs =
                    getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                val mode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
                val nextAction =
                    prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                val logType = if (mode == "single") "single" else nextAction

                // Log the entry in the background SharedPreferences queue
                NoteKarWidgetProvider.performBackgroundLog(this, logType, note)
            }
            dialog.dismiss()
            finish()
        }

        builder.setNegativeButton("Cancel") { dialog, _ ->
            dialog.cancel()
            finish()
        }

        val dialog = builder.create()
        dialog.setOnCancelListener {
            finish()
        }

        // Show the keyboard automatically
        dialog.window?.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE)
        dialog.show()
    }
}
