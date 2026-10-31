package app.notekar.notekar

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

class FloatingBubbleTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()
        val context = applicationContext
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.floating_timer_enabled", false)

        if (!isEnabled) {
            // Check overlay permission first
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                val intent = Intent(
                    Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:$packageName")
                ).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    val pendingIntent = PendingIntent.getActivity(
                        this,
                        0,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    try {
                        val method = TileService::class.java.getMethod(
                            "startActivityAndCollapse",
                            PendingIntent::class.java
                        )
                        method.invoke(this, pendingIntent)
                    } catch (_: Exception) {
                        @Suppress("DEPRECATION")
                        startActivityAndCollapse(intent)
                    }
                } else {
                    @Suppress("DEPRECATION")
                    startActivityAndCollapse(intent)
                }
                return
            }

            // Turn ON: Enable, ensure not docked, and start service
            flutterPrefs.edit()
                .putBoolean("flutter.floating_timer_enabled", true)
                .putBoolean("flutter.floating_timer_docked", false)
                .apply()
            FloatingTimerService.start(this)
            FloatingTimerService.instance?.undockToCircle(animate = true)
        } else {
            // Turn OFF: Disable and stop service
            flutterPrefs.edit()
                .putBoolean("flutter.floating_timer_enabled", false)
                .apply()
            FloatingTimerService.stop(this)
        }

        updateTileState()
        MainActivity.updatePersistentControlPanel(this)
    }

    private fun updateTileState() {
        val tile = qsTile ?: return
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.floating_timer_enabled", false)

        if (isEnabled && FloatingTimerService.instance != null) {
            tile.state = Tile.STATE_ACTIVE
            tile.label = "Bubble: ON"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Tap to hide"
            }
        } else {
            tile.state = Tile.STATE_INACTIVE
            tile.label = "Bubble: OFF"
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = "Tap to show"
            }
        }
        tile.updateTile()
    }

    companion object {
        fun requestTileUpdate(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    requestListeningState(
                        context,
                        android.content.ComponentName(context, FloatingBubbleTileService::class.java)
                    )
                } catch (_: Exception) {}
            }
        }
    }
}
