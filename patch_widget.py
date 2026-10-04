import os
import re

path = "android/app/src/main/kotlin/app/notekar/notekar/NoteKarWidgetProvider.kt"
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace performBackgroundLog
old_perform = """        fun performBackgroundLog(context: Context, type: String, note: String = "") {"""

new_perform = """        fun performBackgroundLog(context: Context, type: String, note: String = "") {
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
        fun oldPerformBackgroundLog(context: Context, type: String, note: String = "") {"""

content = content.replace(old_perform, new_perform)

# Replace togglePauseResume
old_toggle = """        fun togglePauseResume(context: Context) {"""

new_toggle = """        fun togglePauseResume(context: Context) {
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
        fun oldTogglePauseResume(context: Context) {"""

content = content.replace(old_toggle, new_toggle)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Widget logic refactored!")
