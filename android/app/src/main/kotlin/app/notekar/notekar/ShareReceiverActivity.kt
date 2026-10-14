package app.notekar.notekar

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import java.io.File

/**
 * Headless translucent activity that intercepts incoming Android Share intents
 * (ACTION_SEND and ACTION_SEND_MULTIPLE for images, links, and text)
 * and logs them silently into NoteKar with the current timestamp in single mode
 * without launching the main application window.
 */
class ShareReceiverActivity : Activity() {

    companion object {
        private const val TAG = "ShareReceiverActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            handleIncomingShare(intent)
        } catch (e: Exception) {
            Log.e(TAG, "Error processing incoming share", e)
            Toast.makeText(this, "Failed to log shared item", Toast.LENGTH_SHORT).show()
        } finally {
            finish()
        }
    }

    private fun handleIncomingShare(intent: Intent?) {
        if (intent == null) return

        val action = intent.action
        val type = intent.type ?: ""

        var noteText = ""
        var savedImagePath: String? = null

        // 1. Extract any attached caption or text
        val rawText = intent.getStringExtra(Intent.EXTRA_TEXT)
            ?: intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
            ?: intent.getStringExtra(Intent.EXTRA_SUBJECT)
            ?: ""
        noteText = rawText.trim()

        // 2. Handle image(s) if present
        if (action == Intent.ACTION_SEND && type.startsWith("image/")) {
            val imageUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            }

            if (imageUri != null) {
                val relPath = copyStreamToPermanentStorage(imageUri, 0)
                if (relPath != null) {
                    savedImagePath = relPath
                }
            }
        } else if (action == Intent.ACTION_SEND_MULTIPLE && type.startsWith("image/")) {
            val uris = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
            }

            if (!uris.isNullOrEmpty()) {
                val paths = mutableListOf<String>()
                for ((idx, u) in uris.take(5).withIndex()) {
                    val relPath = copyStreamToPermanentStorage(u, idx)
                    if (relPath != null) {
                        paths.add(relPath)
                    }
                }
                if (paths.isNotEmpty()) {
                    savedImagePath = paths.joinToString("|")
                }
            }
        }

        // Only log if we have either note text or an image
        if (noteText.isNotEmpty() || savedImagePath != null) {
            NoteKarWidgetProvider.performBackgroundLog(
                context = applicationContext,
                type = "single",
                note = noteText,
                imagePath = savedImagePath
            )
        }
    }

    /**
     * Copies a content URI input stream to NoteKar's permanent internal storage:
     * filesDir/notekar_media/images/img_<timestamp>_<index>.<ext>
     * Returns the relative path "images/..." expected by MediaStorageService.
     */
    private fun copyStreamToPermanentStorage(uri: Uri, index: Int): String? {
        return try {
            val mediaDir = File(filesDir, "notekar_media/images").apply {
                if (!exists()) mkdirs()
            }
            val mimeType = contentResolver.getType(uri) ?: "image/jpeg"
            val ext = when {
                mimeType.contains("png") -> "png"
                mimeType.contains("webp") -> "webp"
                else -> "jpg"
            }
            val fileName = "img_${System.currentTimeMillis()}_$index.$ext"
            val targetFile = File(mediaDir, fileName)

            contentResolver.openInputStream(uri)?.use { inStream ->
                targetFile.outputStream().use { outStream ->
                    inStream.copyTo(outStream)
                }
            }

            if (targetFile.exists() && targetFile.length() > 0) {
                "images/$fileName"
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to copy stream to permanent storage: $uri", e)
            null
        }
    }
}
