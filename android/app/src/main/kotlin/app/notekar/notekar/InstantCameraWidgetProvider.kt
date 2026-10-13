package app.notekar.notekar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.view.View
import android.widget.RemoteViews
import java.io.File

class InstantCameraWidgetProvider : AppWidgetProvider() {

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
        fun launchCameraCaptureIntent(context: Context, requestCode: Int): PendingIntent {
            val intent = Intent(context, InstantCameraCaptureActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
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
            try {
                val prefs = context.getSharedPreferences(
                    NoteKarWidgetProvider.PREFS_NAME,
                    Context.MODE_PRIVATE
                )

                val lastPhotoPath = prefs.getString(
                    NoteKarWidgetProvider.KEY_LAST_PHOTO_PATH,
                    ""
                ) ?: ""

                val views = RemoteViews(
                    context.packageName,
                    R.layout.notekar_instant_camera_widget
                )

                var thumbnailLoaded = false
                if (lastPhotoPath.isNotEmpty()) {
                    val file = File(lastPhotoPath)
                    if (file.exists() && file.length() > 0) {
                        try {
                            val options = BitmapFactory.Options().apply {
                                inJustDecodeBounds = true
                            }
                            BitmapFactory.decodeFile(file.absolutePath, options)
                            options.inSampleSize = calculateInSampleSize(options, 280, 280)
                            options.inJustDecodeBounds = false
                            val bitmap = BitmapFactory.decodeFile(file.absolutePath, options)
                            if (bitmap != null) {
                                views.setImageViewBitmap(R.id.widget_camera_preview, bitmap)
                                views.setViewVisibility(R.id.widget_camera_preview, View.VISIBLE)
                                views.setViewVisibility(R.id.widget_camera_placeholder, View.GONE)
                                thumbnailLoaded = true
                            }
                        } catch (e: Exception) {
                            android.util.Log.e(
                                "InstantCameraWidget",
                                "Failed to decode photo thumbnail",
                                e
                            )
                        }
                    }
                }

                if (!thumbnailLoaded) {
                    views.setViewVisibility(R.id.widget_camera_preview, View.GONE)
                    views.setViewVisibility(R.id.widget_camera_placeholder, View.VISIBLE)
                }

                // Tap capture button opens camera immediately
                views.setOnClickPendingIntent(
                    R.id.widget_camera_btn_capture,
                    launchCameraCaptureIntent(context, appWidgetId + 60)
                )

                // Tap preview or root opens NoteKar
                views.setOnClickPendingIntent(
                    R.id.widget_preview_container,
                    SobrietyWidgetProvider.launchIntent(
                        context,
                        appWidgetId + 61,
                        "app.notekar.notekar.ACTION_OPEN",
                        "home"
                    )
                )

                manager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                android.util.Log.e(
                    "InstantCameraWidget",
                    "Failed to update Instant Camera widget",
                    e
                )
            }
        }

        private fun calculateInSampleSize(
            options: BitmapFactory.Options,
            reqWidth: Int,
            reqHeight: Int
        ): Int {
            val (height: Int, width: Int) = options.run { outHeight to outWidth }
            var inSampleSize = 1
            if (height > reqHeight || width > reqWidth) {
                val halfHeight: Int = height / 2
                val halfWidth: Int = width / 2
                while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                    inSampleSize *= 2
                }
            }
            return inSampleSize.coerceAtLeast(1)
        }
    }
}
