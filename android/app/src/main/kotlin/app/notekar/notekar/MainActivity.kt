package app.notekar.notekar

import android.Manifest
import android.content.ContentValues
import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.NotificationCompat
import androidx.core.content.FileProvider
import java.io.File
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.content.Context

class MainActivity : FlutterActivity() {
    private var pendingOpenResult: MethodChannel.Result? = null
    private var pendingPrivacyResult: MethodChannel.Result? = null
    private var pendingLaunchAction: String? = null
    private var pendingNotificationResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pendingLaunchAction = actionFromIntent(intent)

        try {
            ReminderReceiver.rescheduleAll(applicationContext)
        } catch (e: Exception) {
            android.util.Log.e("MainActivity", "Failed to reschedule reminders on launch", e)
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "notekar/files").setMethodCallHandler { call, result ->
            when (call.method) {
                "saveTextFile" -> {
                    val fileName = call.argument<String>("fileName") ?: "notekar-export.txt"
                    val content = call.argument<String>("content") ?: ""
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    try {
                        val savedUri = saveTextFile(fileName, content, mimeType)
                        result.success(savedUri)
                    } catch (error: Exception) {
                        result.error("EXPORT_FAILED", error.message, null)
                    }
                }
                "openTextFile" -> {
                    if (pendingOpenResult != null) {
                        try {
                            pendingOpenResult?.error("OPEN_CANCELLED", "New file picker request received", null)
                        } catch (_: Exception) { }
                        pendingOpenResult = null
                    }
                    pendingOpenResult = result
                    val mimeType = call.argument<String>("mimeType") ?: "application/json"
                    val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                        addCategory(Intent.CATEGORY_OPENABLE)
                        type = mimeType
                    }
                    try {
                        startActivityForResult(intent, OPEN_TEXT_FILE_REQUEST)
                    } catch (error: Exception) {
                        pendingOpenResult = null
                        result.error("OPEN_FAILED", error.message, null)
                    }
                }
                "appDataDir" -> result.success(applicationContext.filesDir.absolutePath)
                "canUsePrivacyLock" -> result.success(canUsePrivacyLock())
                "authenticatePrivacyLock" -> {
                    if (pendingPrivacyResult != null) {
                        try {
                            pendingPrivacyResult?.error("AUTH_CANCELLED", "New auth request received", null)
                        } catch (_: Exception) { }
                        pendingPrivacyResult = null
                    }
                    authenticatePrivacyLock(result)
                }
                "getLaunchAction" -> {
                    result.success(pendingLaunchAction)
                    pendingLaunchAction = null
                }
                "updateWidgetState" -> {
                    try {
                        val todayCount = call.argument<Int>("todayCount") ?: 0
                        val mode = call.argument<String>("mode") ?: "two-way"
                        val nextAction = call.argument<String>("nextAction") ?: "in"
                        val lastType = call.argument<String>("lastType") ?: ""
                        val lastTimestamp = call.argument<Number>("lastTimestamp")?.toLong() ?: 0L
                        val hasMoments = call.argument<Boolean>("hasMoments") ?: false

                        val prefs = getSharedPreferences(
                            NoteKarWidgetProvider.PREFS_NAME,
                            Context.MODE_PRIVATE
                        )

                        prefs.edit()
                            .putInt(NoteKarWidgetProvider.KEY_TODAY_COUNT, todayCount)
                            .putString(NoteKarWidgetProvider.KEY_MODE, mode)
                            .putString(NoteKarWidgetProvider.KEY_NEXT_ACTION, nextAction)
                            .putString(NoteKarWidgetProvider.KEY_LAST_TYPE, lastType)
                            .putLong(NoteKarWidgetProvider.KEY_LAST_TIMESTAMP, lastTimestamp)
                            .putBoolean(NoteKarWidgetProvider.KEY_HAS_MOMENTS, hasMoments)
                            .apply()

                        NoteKarWidgetProvider.updateAllWidgets(this)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("WIDGET_UPDATE_FAILED", e.message, null)
                    }
                }
                "setAppIconStyle" -> {
                    val style = call.argument<String>("style") ?: "default"
                    try {
                        setAppIconStyle(style)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("ICON_STYLE_FAILED", error.message, null)
                    }
                }
                "openUrl" -> {
                    val url = call.argument<String>("url") ?: ""
                    try {
                        openUrl(url)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("OPEN_URL_FAILED", error.message, null)
                    }
                }
                "showUpdateNotification" -> {
                    val title = call.argument<String>("title") ?: "NoteKar update available"
                    val body = call.argument<String>("body") ?: "Tap to open the latest release."
                    val url = call.argument<String>("url") ?: "https://github.com/dheeraz101/Notekar-Android/releases"
                    try {
                        showUpdateNotification(title, body, url)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("NOTIFICATION_FAILED", error.message, null)
                    }
                }
                "canPostNotifications" -> {
                    result.success(canPostNotifications())
                }
                "requestNotificationPermission" -> {
                    if (pendingNotificationResult != null) {
                        try {
                            pendingNotificationResult?.error("PERMISSION_CANCELLED", "New permission request received", null)
                        } catch (_: Exception) { }
                        pendingNotificationResult = null
                    }
                    requestNotificationPermission(result)
                }
                "canScheduleExactAlarms" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        result.success(alarmManager.canScheduleExactAlarms())
                    } else {
                        result.success(true)
                    }
                }
                "requestExactAlarmPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val intent = Intent().apply {
                                action = android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM
                                data = Uri.parse("package:${packageName}")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            try {
                                val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                    data = Uri.parse("package:${packageName}")
                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (_: Exception) {
                                result.success(false)
                            }
                        }
                    } else {
                        result.success(true)
                    }
                }
                "isIgnoringBatteryOptimizations" -> {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:${packageName}")
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:${packageName}")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            result.success(false)
                        }
                    }
                }
                "openAutoStartSettings" -> {
                    result.success(openAutoStartSettings())
                }
                "appCacheDir" -> {
                    result.success(applicationContext.externalCacheDir?.absolutePath ?: applicationContext.cacheDir.absolutePath)
                }
                "canInstallPackages" -> {
                    result.success(canInstallPackages())
                }
                "openInstallPermissionSettings" -> {
                    result.success(openInstallPermissionSettings())
                }
                "installApk" -> {
                    val filePath = call.argument<String>("filePath") ?: ""
                    result.success(installApk(filePath))
                }
                "getFileSha256" -> {
                    val filePath = call.argument<String>("filePath") ?: ""
                    result.success(getFileSha256(filePath))
                }
                "configureRemoteNotices" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    val feedUrl = call.argument<String>("feedUrl") ?: ""
                    val checkOnlyOnOpen = call.argument<Boolean>("checkOnlyOnOpen") ?: false
                    RemoteNoticeReceiver.configure(applicationContext, enabled, feedUrl, checkOnlyOnOpen)
                    result.success(null)
                }
                "checkRemoteNoticesNow" -> {
                    RemoteNoticeReceiver.checkNow(applicationContext)
                    result.success(null)
                }
                "scheduleReminder" -> {
                    val id = call.argument<String>("id") ?: ""
                    val type = call.argument<String>("type") ?: "daily"
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val daysOfWeek = call.argument<List<Int>>("daysOfWeek")
                    val dayOfMonth = call.argument<Int>("dayOfMonth")
                    val intervalMinutes = call.argument<Int>("intervalMinutes")
                    val title = call.argument<String>("title") ?: "NoteKar Reminder"
                    val body = call.argument<String>("body") ?: "Time to log a moment!"
                    if (id.isNotBlank()) {
                        ReminderReceiver.schedule(
                            applicationContext,
                            id,
                            type,
                            hour,
                            minute,
                            daysOfWeek,
                            dayOfMonth,
                            intervalMinutes,
                            title,
                            body
                        )
                    }
                    result.success(null)
                }
                "cancelReminder" -> {
                    val id = call.argument<String>("id") ?: ""
                    if (id.isNotBlank()) {
                        ReminderReceiver.cancel(applicationContext, id)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        pendingLaunchAction = actionFromIntent(intent)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )

        if (requestCode != NOTIFICATION_PERMISSION_REQUEST) return

        val result = pendingNotificationResult
        pendingNotificationResult = null

        val granted =
            grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED

        result?.success(granted)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == OPEN_TEXT_FILE_REQUEST) {
            val result = pendingOpenResult
            pendingOpenResult = null
            if (result == null) return
            if (resultCode != RESULT_OK || data?.data == null) {
                result.success(null)
                return
            }
            try {
                val text = applicationContext.contentResolver.openInputStream(data.data!!)?.use { stream ->
                    stream.bufferedReader(Charsets.UTF_8).readText()
                }
                result.success(text)
            } catch (error: Exception) {
                result.error("READ_FAILED", error.message, null)
            }
            return
        }
        if (requestCode == PRIVACY_LOCK_REQUEST) {
            val result = pendingPrivacyResult
            pendingPrivacyResult = null
            result?.success(resultCode == RESULT_OK)
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun saveTextFile(fileName: String, content: String, mimeType: String): String {
        val resolver = applicationContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }

        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Downloads.EXTERNAL_CONTENT_URI
        } else {
            MediaStore.Files.getContentUri("external")
        }

        val uri = resolver.insert(collection, values)
            ?: throw IllegalStateException("Could not create export file")

        resolver.openOutputStream(uri)?.use { stream ->
            stream.write(content.toByteArray(Charsets.UTF_8))
        } ?: throw IllegalStateException("Could not open export file")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        return uri.toString()
    }

    private fun openUrl(url: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun actionFromIntent(intent: Intent?): String? {
        if (intent == null) return null
        intent.getStringExtra(EXTRA_LAUNCH_ACTION)?.let { return normalizeAction(it) }
        return when (intent.action) {
            ACTION_NOTE -> "note"
            ACTION_MOMENT -> "single"
            ACTION_SINGLE -> "single"
            ACTION_IN -> "in"
            ACTION_OUT -> "out"
            ACTION_HISTORY -> "history"
            else -> actionFromUri(intent.data)
        }
    }

    private fun actionFromUri(uri: Uri?): String? {
        if (uri == null) return null
        uri.getQueryParameter("action")?.let { return normalizeAction(it) }
        return normalizeAction(uri.lastPathSegment ?: uri.host ?: "")
    }

    private fun normalizeAction(value: String): String? {
        return when (value.trim().lowercase()) {
            "open", "home" -> null
            "history" -> "history"
            "settings", "setting" -> "settings"
            "whats-new", "whatsnew", "what-is-new", "new" -> "whats-new"
            "changelog", "changes" -> "changelog"
            "note", "new-note" -> "note"
            "moment", "new-moment", "log", "single" -> "single"
            "in", "check-in", "clock-in" -> "in"
            "out", "check-out", "clock-out" -> "out"
            "updates", "update", "releases", "release" -> "releases"
            else -> null
        }
    }

    private fun setAppIconStyle(style: String) {
        val aliases = mapOf(
            "default" to "app.notekar.notekar.DefaultIconAlias",
            "black" to "app.notekar.notekar.IconBlackAlias",
            "blue" to "app.notekar.notekar.IconBlueAlias",
            "gold" to "app.notekar.notekar.IconGoldAlias",
            "green" to "app.notekar.notekar.IconGreenAlias",
            "orange" to "app.notekar.notekar.IconOrangeAlias",
            "red" to "app.notekar.notekar.IconRedAlias"
        )
        val selected = aliases[style] ?: aliases.getValue("default")
        aliases.values.forEach { aliasName ->
            packageManager.setComponentEnabledSetting(
                ComponentName(this, aliasName),
                if (aliasName == selected) {
                    PackageManager.COMPONENT_ENABLED_STATE_ENABLED
                } else {
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED
                },
                PackageManager.DONT_KILL_APP
            )
        }
    }

    private fun canUsePrivacyLock(): Boolean {
        val keyguard = getSystemService(KeyguardManager::class.java)
        return keyguard?.isDeviceSecure == true
    }

    private fun authenticatePrivacyLock(result: MethodChannel.Result) {
        if (!canUsePrivacyLock()) {
            result.success(false)
            return
        }
        if (pendingPrivacyResult != null) {
            result.error("AUTH_BUSY", "A privacy lock prompt is already open", null)
            return
        }
        val keyguard = getSystemService(KeyguardManager::class.java)
        val intent = keyguard?.createConfirmDeviceCredentialIntent(
            "Turn on App Lock",
            "Confirm your Android screen lock to protect NoteKar."
        )
        if (intent == null) {
            result.success(false)
            return
        }
        pendingPrivacyResult = result
        try {
            startActivityForResult(intent, PRIVACY_LOCK_REQUEST)
        } catch (error: Exception) {
            pendingPrivacyResult = null
            result.error("AUTH_FAILED", error.message, null)
        }
    }

    private fun showUpdateNotification(title: String, body: String, url: String) {
        if (!canPostNotifications()) return
        val notificationManager = getSystemService(NotificationManager::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.createNotificationChannel(
                NotificationChannel(
                    UPDATE_CHANNEL_ID,
                    "App updates",
                    NotificationManager.IMPORTANCE_DEFAULT
                )
            )
        }
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val notification = NotificationCompat.Builder(this, UPDATE_CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_notekar)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()
        notificationManager.notify(UPDATE_NOTIFICATION_ID, notification)
    }

    private fun requestNotificationPermission(
        result: MethodChannel.Result
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }

        if (canPostNotifications()) {
            result.success(true)
            return
        }

        if (pendingNotificationResult != null) {
            result.error(
                "PERMISSION_BUSY",
                "A notification permission request is already open",
                null
            )
            return
        }

        pendingNotificationResult = result

        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST
        )
    }

    private fun canPostNotifications(): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED
    }

    private fun openAutoStartSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val intents = listOf(
            // Xiaomi
            Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")),
            // Oppo
            Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")),
            Intent().setComponent(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity")),
            Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startupapp.StartupAppListActivity")),
            // Vivo
            Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")),
            Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")),
            Intent().setComponent(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")),
            // Huawei
            Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")),
            Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")),
            // OnePlus
            Intent().setComponent(ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.AppBootLaunchActivity")),
            // Asus
            Intent().setComponent(ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity"))
        )

        for (intent in intents) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return true
            } catch (_: Exception) {}
        }

        // Fallback: open App Info settings
        try {
            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:${packageName}")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            startActivity(intent)
            return true
        } catch (_: Exception) {
            return false
        }
    }

    private fun canInstallPackages(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            packageManager.canRequestPackageInstalls()
        } else {
            true
        }
    }

    private fun openInstallPermissionSettings(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES).apply {
                    data = Uri.parse("package:${packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                true
            } catch (e: Exception) {
                false
            }
        } else {
            true
        }
    }

    private fun installApk(filePath: String): Boolean {
        val file = File(filePath)
        if (!file.exists()) return false

        val intent = Intent(Intent.ACTION_VIEW).apply {
            val apkUri = FileProvider.getUriForFile(
                applicationContext,
                "${packageName}.fileprovider",
                file
            )
            setDataAndType(apkUri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        return try {
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun getFileSha256(filePath: String): String? {
        val file = File(filePath)
        if (!file.exists()) return null
        return try {
            val digest = java.security.MessageDigest.getInstance("SHA-256")
            file.inputStream().use { input ->
                val buffer = ByteArray(8192)
                var bytesRead = input.read(buffer)
                while (bytesRead != -1) {
                    digest.update(buffer, 0, bytesRead)
                    bytesRead = input.read(buffer)
                }
            }
            digest.digest().joinToString("") { "%02x".format(it) }
        } catch (e: Exception) {
            null
        }
    }

    companion object {
        private const val OPEN_TEXT_FILE_REQUEST = 4021
        private const val NOTIFICATION_PERMISSION_REQUEST = 4022
        private const val PRIVACY_LOCK_REQUEST = 4023
        private const val UPDATE_NOTIFICATION_ID = 3100
        private const val UPDATE_CHANNEL_ID = "notekar_updates"
        const val EXTRA_LAUNCH_ACTION = "app.notekar.notekar.extra.LAUNCH_ACTION"
        const val ACTION_NOTE = "app.notekar.notekar.ACTION_NOTE"
        const val ACTION_MOMENT = "app.notekar.notekar.ACTION_MOMENT"
        const val ACTION_SINGLE = "app.notekar.notekar.ACTION_SINGLE"
        const val ACTION_IN = "app.notekar.notekar.ACTION_IN"
        const val ACTION_OUT = "app.notekar.notekar.ACTION_OUT"
        const val ACTION_HISTORY = "app.notekar.notekar.ACTION_HISTORY"
    }
}
