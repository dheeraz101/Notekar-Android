package app.notekar.notekar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings

class FloatingBubbleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.floating_timer_enabled", false)
        val newEnabled = !isEnabled

        if (newEnabled) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }
            flutterPrefs.edit()
                .putBoolean("flutter.floating_timer_enabled", true)
                .putBoolean("flutter.floating_timer_docked", false)
                .apply()
            FloatingTimerService.start(context)
            FloatingTimerService.instance?.undockToCircle(animate = true)
        } else {
            flutterPrefs.edit()
                .putBoolean("flutter.floating_timer_enabled", false)
                .apply()
            FloatingTimerService.stop(context)
        }

        MainActivity.updatePersistentControlPanel(context)
        FloatingBubbleTileService.requestTileUpdate(context)
    }

    companion object {
        const val ACTION_TOGGLE_BUBBLE = "app.notekar.notekar.ACTION_TOGGLE_BUBBLE"
    }
}
