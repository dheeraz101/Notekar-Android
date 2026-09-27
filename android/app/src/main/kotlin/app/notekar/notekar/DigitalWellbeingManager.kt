package app.notekar.notekar

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.net.Uri
import android.os.Build
import android.provider.Settings
import java.util.Calendar
import java.util.Locale

object DigitalWellbeingManager {

    fun hasUsagePermission(context: Context): Boolean {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    context.packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    fun openUsageAccessSettings(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    data = Uri.parse("package:${context.packageName}")
                }
            }
            context.startActivity(intent)
        } catch (e: Exception) {
            try {
                val fallbackIntent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(fallbackIntent)
            } catch (_: Exception) {}
        }
    }

    fun getDailyUsageStats(
        context: Context,
        startTimeMs: Long?,
        endTimeMs: Long?
    ): Map<String, Any> {
        if (!hasUsagePermission(context)) {
            return mapOf(
                "hasPermission" to false,
                "totalScreenTimeMs" to 0L,
                "unlockCount" to 0,
                "categories" to emptyMap<String, Long>(),
                "topApps" to emptyList<Map<String, Any>>()
            )
        }

        val usageStatsManager = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return mapOf(
                "hasPermission" to false,
                "totalScreenTimeMs" to 0L,
                "unlockCount" to 0,
                "categories" to emptyMap<String, Long>(),
                "topApps" to emptyList<Map<String, Any>>()
            )

        val pm = context.packageManager
        val now = System.currentTimeMillis()
        val end = if (endTimeMs != null && endTimeMs > 0 && endTimeMs <= now) endTimeMs else now
        val start = if (startTimeMs != null && startTimeMs > 0 && startTimeMs < end) {
            startTimeMs
        } else {
            val cal = Calendar.getInstance().apply {
                set(Calendar.HOUR_OF_DAY, 0)
                set(Calendar.MINUTE, 0)
                set(Calendar.SECOND, 0)
                set(Calendar.MILLISECOND, 0)
            }
            cal.timeInMillis
        }

        // 1. Device unlocks via UsageEvents
        var unlockCount = 0
        try {
            val events = usageStatsManager.queryEvents(start, end)
            val event = UsageEvents.Event()
            while (events.hasNextEvent()) {
                events.getNextEvent(event)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    if (event.eventType == UsageEvents.Event.KEYGUARD_HIDDEN) {
                        unlockCount++
                    }
                } else {
                    if (event.eventType == UsageEvents.Event.SCREEN_INTERACTIVE) {
                        unlockCount++
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("DigitalWellbeing", "Failed to query usage events", e)
        }

        // 2. Query usage stats by package
        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            start,
            end
        )

        var totalScreenTimeMs = 0L
        val categoryBuckets = mutableMapOf(
            "Productivity" to 0L,
            "Social" to 0L,
            "Entertainment" to 0L,
            "System" to 0L
        )

        val aggregatedByPackage = mutableMapOf<String, Long>()
        for (stat in stats) {
            val fgTime = stat.totalTimeInForeground
            if (fgTime > 0) {
                aggregatedByPackage[stat.packageName] =
                    (aggregatedByPackage[stat.packageName] ?: 0L) + fgTime
            }
        }

        val topApps = mutableListOf<Map<String, Any>>()

        for ((pkg, duration) in aggregatedByPackage) {
            // Ignore system launcher idle loops or self if negligible
            if (pkg == "android" && duration < 60000L) continue

            totalScreenTimeMs += duration

            val categoryBucket = try {
                val appInfo = pm.getApplicationInfo(pkg, 0)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    when (appInfo.category) {
                        ApplicationInfo.CATEGORY_PRODUCTIVITY,
                        ApplicationInfo.CATEGORY_MAPS,
                        ApplicationInfo.CATEGORY_ACCESSIBILITY -> "Productivity"

                        ApplicationInfo.CATEGORY_SOCIAL,
                        ApplicationInfo.CATEGORY_NEWS -> "Social"

                        ApplicationInfo.CATEGORY_GAME,
                        ApplicationInfo.CATEGORY_AUDIO,
                        ApplicationInfo.CATEGORY_VIDEO,
                        ApplicationInfo.CATEGORY_IMAGE -> "Entertainment"

                        else -> {
                            if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) {
                                "System"
                            } else {
                                guessCategoryFromPackage(pkg)
                            }
                        }
                    }
                } else {
                    if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) "System" else guessCategoryFromPackage(pkg)
                }
            } catch (_: Exception) {
                "System"
            }

            categoryBuckets[categoryBucket] = (categoryBuckets[categoryBucket] ?: 0L) + duration

            val appName = try {
                pm.getApplicationLabel(pm.getApplicationInfo(pkg, 0)).toString()
            } catch (_: Exception) {
                pkg.substringAfterLast('.')
            }

            topApps.add(
                mapOf(
                    "packageName" to pkg,
                    "name" to appName,
                    "category" to categoryBucket,
                    "durationMs" to duration
                )
            )
        }

        topApps.sortByDescending { (it["durationMs"] as? Long) ?: 0L }

        return mapOf(
            "hasPermission" to true,
            "totalScreenTimeMs" to totalScreenTimeMs,
            "unlockCount" to unlockCount,
            "categories" to categoryBuckets,
            "topApps" to topApps.take(10)
        )
    }

    private fun guessCategoryFromPackage(pkg: String): String {
        val p = pkg.lowercase(Locale.ROOT)
        return when {
            p.contains("whatsapp") || p.contains("telegram") || p.contains("twitter") ||
            p.contains("instagram") || p.contains("facebook") || p.contains("discord") ||
            p.contains("reddit") || p.contains("messenger") || p.contains("snapchat") ||
            p.contains("threads") || p.contains("linkedin") || p.contains("signal") -> "Social"

            p.contains("youtube") || p.contains("netflix") || p.contains("spotify") ||
            p.contains("twitch") || p.contains("music") || p.contains("video") ||
            p.contains("game") || p.contains("primevideo") || p.contains("hotstar") ||
            p.contains("disney") || p.contains("tiktok") || p.contains("play") -> "Entertainment"

            p.contains("gmail") || p.contains("docs") || p.contains("sheets") ||
            p.contains("notion") || p.contains("obsidian") || p.contains("slack") ||
            p.contains("code") || p.contains("term") || p.contains("calculator") ||
            p.contains("calendar") || p.contains("notes") || p.contains("task") ||
            p.contains("notekar") || p.contains("keep") -> "Productivity"

            else -> "System"
        }
    }
}
