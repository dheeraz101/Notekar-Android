package app.notekar.notekar

import android.content.Intent
import android.os.Build
import android.service.quicksettings.TileService

class QuickNoteTileService : TileService() {
    override fun onClick() {
        super.onClick()
        val intent = Intent(this, QuickNoteActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pendingIntent = android.app.PendingIntent.getActivity(
                this,
                0,
                intent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
            )
            try {
                val method = TileService::class.java.getMethod(
                    "startActivityAndCollapse",
                    android.app.PendingIntent::class.java
                )
                method.invoke(this, pendingIntent)
            } catch (e: Exception) {
                @Suppress("DEPRECATION")
                startActivityAndCollapse(intent)
            }
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    override fun onStartListening() {
        super.onStartListening()
        val tile = qsTile
        if (tile != null) {
            tile.state = android.service.quicksettings.Tile.STATE_ACTIVE
            tile.updateTile()
        }
    }
}
