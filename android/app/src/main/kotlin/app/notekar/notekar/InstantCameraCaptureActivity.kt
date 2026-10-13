package app.notekar.notekar

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.provider.MediaStore
import android.widget.Toast
import androidx.core.content.FileProvider
import java.io.File

class InstantCameraCaptureActivity : Activity() {

    private var currentPhotoPath: String? = null

    companion object {
        private const val REQUEST_CAMERA_PERMISSION = 1001
        private const val REQUEST_IMAGE_CAPTURE = 1002
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(
                arrayOf(Manifest.permission.CAMERA),
                REQUEST_CAMERA_PERMISSION
            )
        } else {
            launchCamera()
        }
    }

    private fun launchCamera() {
        try {
            val dir = File(cacheDir, "camera_logs").apply {
                if (!exists()) mkdirs()
            }
            val photoFile = File(dir, "instant_${System.currentTimeMillis()}.jpg")
            currentPhotoPath = photoFile.absolutePath

            val photoUri: Uri = FileProvider.getUriForFile(
                this,
                "${packageName}.fileprovider",
                photoFile
            )

            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION or Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }

            if (intent.resolveActivity(packageManager) != null) {
                startActivityForResult(intent, REQUEST_IMAGE_CAPTURE)
            } else {
                Toast.makeText(this, "No camera application found", Toast.LENGTH_SHORT).show()
                finish()
            }
        } catch (e: Exception) {
            android.util.Log.e("InstantCamera", "Failed to launch camera", e)
            Toast.makeText(this, "Failed to launch camera", Toast.LENGTH_SHORT).show()
            finish()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_CAMERA_PERMISSION) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                launchCamera()
            } else {
                Toast.makeText(
                    this,
                    "Camera permission required to capture moments",
                    Toast.LENGTH_SHORT
                ).show()
                finish()
            }
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_IMAGE_CAPTURE) {
            if (resultCode == RESULT_OK && currentPhotoPath != null) {
                val file = File(currentPhotoPath!!)
                if (file.exists() && file.length() > 0) {
                    try {
                        NoteKarWidgetProvider.performBackgroundLog(
                            applicationContext,
                            type = "single",
                            note = "",
                            imagePath = file.absolutePath
                        )

                        val prefs = getSharedPreferences(
                            NoteKarWidgetProvider.PREFS_NAME,
                            Context.MODE_PRIVATE
                        )
                        prefs.edit()
                            .putString(NoteKarWidgetProvider.KEY_LAST_PHOTO_PATH, file.absolutePath)
                            .apply()

                        NoteKarWidgetProvider.updateAllWidgets(applicationContext)
                        Toast.makeText(this, "Photo moment logged!", Toast.LENGTH_SHORT).show()
                    } catch (e: Exception) {
                        android.util.Log.e("InstantCamera", "Failed to log photo moment", e)
                    }
                }
            }
            finish()
        }
    }
}
