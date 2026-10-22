package app.notekar.notekar

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.os.SystemClock
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.Chronometer
import android.widget.LinearLayout
import android.widget.TextView
import java.util.Locale

class FloatingTimerService : Service() {

    private var windowManager: WindowManager? = null
    private var floatingView: View? = null
    private var chronometer: Chronometer? = null
    private var statusDot: View? = null
    private var categoryText: TextView? = null
    private var actionsContainer: LinearLayout? = null
    private var btnPauseResume: TextView? = null

    private var isExpanded = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            stopSelf()
            return
        }
        createFloatingView()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val action = intent?.action
        if (action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        refreshView()
        return START_NOT_STICKY
    }

    private fun createFloatingView() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val density = resources.displayMetrics.density

        val layoutType = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutType,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (20 * density).toInt()
            y = (140 * density).toInt()
        }

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding((14 * density).toInt(), (8 * density).toInt(), (14 * density).toInt(), (8 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#F20B0C0E"))
                cornerRadius = 19 * density
                setStroke((0.8 * density).toInt(), Color.parseColor("#26FFFFFF"))
            }
            elevation = 12 * density
        }

        // Top Row: Status Dot + Chronometer + Category Badge
        val mainRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        statusDot = View(this).apply {
            val size = (8 * density).toInt()
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                marginEnd = (9 * density).toInt()
                gravity = Gravity.CENTER_VERTICAL
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FF30D158"))
            }
        }
        mainRow.addView(statusDot)

        chronometer = Chronometer(this).apply {
            setTextColor(Color.WHITE)
            textSize = 13.5f
            typeface = android.graphics.Typeface.MONOSPACE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (9 * density).toInt()
                gravity = Gravity.CENTER_VERTICAL
            }
        }
        mainRow.addView(chronometer)

        categoryText = TextView(this).apply {
            textSize = 10f
            setTextColor(Color.parseColor("#FF64D2FF"))
            typeface = android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
            val padH = (6 * density).toInt()
            val padV = (2 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2664D2FF"))
                cornerRadius = 6 * density
            }
        }
        mainRow.addView(categoryText)

        root.addView(mainRow)

        // Bottom Expandable Actions Bar (Pause/Resume, Note, OUT, Close)
        actionsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (8 * density).toInt()
            }
        }

        btnPauseResume = TextView(this).apply {
            text = "⏸"
            textSize = 12.5f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (11 * density).toInt()
            val padV = (5 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#26FFFFFF"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                NoteKarWidgetProvider.togglePauseResume(this@FloatingTimerService)
            }
        }
        actionsContainer?.addView(btnPauseResume)

        val btnQuickNote = TextView(this).apply {
            text = "✎ Note"
            textSize = 11f
            typeface = android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (10 * density).toInt()
            val padV = (5 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#26FFFFFF"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                val intent = Intent(this@FloatingTimerService, QuickNoteActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(intent)
            }
        }
        actionsContainer?.addView(btnQuickNote)

        val btnOut = TextView(this).apply {
            text = "OUT"
            textSize = 11f
            typeface = android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (11 * density).toInt()
            val padV = (5 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFFF3B30"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                NoteKarWidgetProvider.performBackgroundLog(this@FloatingTimerService, "out", "")
                stopSelf()
            }
        }
        actionsContainer?.addView(btnOut)

        val btnClose = TextView(this).apply {
            text = "✕"
            textSize = 11.5f
            setTextColor(Color.parseColor("#B3FFFFFF"))
            gravity = Gravity.CENTER
            val padH = (9 * density).toInt()
            val padV = (5 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1AFFFFFF"))
                cornerRadius = 14 * density
            }
            setOnClickListener {
                stopSelf()
            }
        }
        actionsContainer?.addView(btnClose)

        root.addView(actionsContainer)

        // Touch Listener for dragging and magnetic edge snapping
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var lastTapTime = 0L
        val tapHandler = android.os.Handler(android.os.Looper.getMainLooper())
        var pendingSingleTap: Runnable? = null

        root.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager?.updateViewLayout(floatingView, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val dx = Math.abs(event.rawX - initialTouchX)
                    val dy = Math.abs(event.rawY - initialTouchY)
                    if (dx < 10 && dy < 10) {
                        val now = System.currentTimeMillis()
                        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

                        if (now - lastTapTime < 300) {
                            // Double tap detected
                            pendingSingleTap?.let { tapHandler.removeCallbacks(it) }
                            lastTapTime = 0L
                            root.performHapticFeedback(android.view.HapticFeedbackConstants.KEYBOARD_TAP)

                            val doubleTapAction = flutterPrefs.getString("flutter.floating_double_tap_action", "quick_menu") ?: "quick_menu"
                            if (doubleTapAction == "quick_menu") {
                                val intent = Intent(this@FloatingTimerService, QuickNoteActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                                }
                                startActivity(intent)
                            } else {
                                isExpanded = !isExpanded
                                actionsContainer?.visibility = if (isExpanded) View.VISIBLE else View.GONE
                            }
                        } else {
                            // Possible single tap
                            lastTapTime = now
                            val singleTapAction = flutterPrefs.getString("flutter.floating_single_tap_action", "toggle_expand") ?: "toggle_expand"

                            pendingSingleTap = Runnable {
                                root.performHapticFeedback(android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                                if (singleTapAction == "quick_log") {
                                    NoteKarWidgetProvider.performBackgroundLog(this@FloatingTimerService, "single", "")
                                } else {
                                    isExpanded = !isExpanded
                                    actionsContainer?.visibility = if (isExpanded) View.VISIBLE else View.GONE
                                }
                            }
                            tapHandler.postDelayed(pendingSingleTap!!, 260)
                        }
                    } else {
                        // Magnetic edge snapping
                        val screenWidth = resources.displayMetrics.widthPixels
                        val viewWidth = floatingView?.width ?: (130 * density).toInt()
                        val targetX = if (params.x + viewWidth / 2 < screenWidth / 2) {
                            (12 * density).toInt()
                        } else {
                            screenWidth - viewWidth - (12 * density).toInt()
                        }
                        android.animation.ValueAnimator.ofInt(params.x, targetX).apply {
                            duration = 220
                            interpolator = android.view.animation.DecelerateInterpolator()
                            addUpdateListener { va ->
                                params.x = va.animatedValue as Int
                                windowManager?.updateViewLayout(floatingView, params)
                            }
                            start()
                        }
                    }
                    true
                }
                else -> false
            }
        }

        floatingView = root
        try {
            windowManager?.addView(floatingView, params)
        } catch (_: Exception) {
            stopSelf()
        }
    }

    fun refreshView() {
        val prefs = getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val mode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, null)
            ?: flutterPrefs.getString("flutter.m-mode", "two-way") ?: "two-way"
        val nextAction = prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, null)
            ?: flutterPrefs.getString("flutter.m-inout", "in") ?: "in"
        var lastTimestamp = prefs.getLong(NoteKarWidgetProvider.KEY_LAST_TIMESTAMP, 0L)
        if (lastTimestamp <= 0L) {
            lastTimestamp = flutterPrefs.getLong("flutter.m-ses", 0L)
        }
        val activeCategory = prefs.getString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, null)
            ?: flutterPrefs.getString("flutter.active_category", "Work") ?: "Work"
        val isPaused = prefs.getBoolean(NoteKarWidgetProvider.KEY_IS_PAUSED, false) ||
                flutterPrefs.getBoolean("flutter.m-paused", false) ||
                flutterPrefs.getBoolean("flutter.is_paused", false)
        var pausedAt = prefs.getLong(NoteKarWidgetProvider.KEY_PAUSED_AT, 0L)
        if (pausedAt <= 0L) {
            pausedAt = flutterPrefs.getLong("flutter.m-paused-at", flutterPrefs.getLong("flutter.paused_at", 0L))
        }

        val isCurrentlyIn = mode == "two-way" && nextAction == "out"
        if (!isCurrentlyIn || lastTimestamp <= 0L) {
            stopSelf()
            return
        }

        categoryText?.text = activeCategory.uppercase(Locale.ROOT)
        btnPauseResume?.text = if (isPaused) "▶" else "⏸"

        if (isPaused) {
            statusDot?.clearAnimation()
            (statusDot?.background as? GradientDrawable)?.setColor(Color.parseColor("#FFFF9F0A"))
        } else {
            (statusDot?.background as? GradientDrawable)?.setColor(Color.parseColor("#FF30D158"))
            if (statusDot?.animation == null) {
                val pulseAnim = android.view.animation.AlphaAnimation(1.0f, 0.45f).apply {
                    duration = 850
                    repeatMode = android.view.animation.Animation.REVERSE
                    repeatCount = android.view.animation.Animation.INFINITE
                }
                statusDot?.startAnimation(pulseAnim)
            }
        }

        val elapsed = if (isPaused && pausedAt > 0L && pausedAt >= lastTimestamp) {
            pausedAt - lastTimestamp
        } else if (lastTimestamp > 0L) {
            Math.max(0L, System.currentTimeMillis() - lastTimestamp)
        } else {
            0L
        }
        val base = SystemClock.elapsedRealtime() - elapsed
        chronometer?.base = base
        if (isPaused) {
            chronometer?.stop()
            chronometer?.setTextColor(Color.parseColor("#FFFF9F0A"))
        } else {
            chronometer?.start()
            chronometer?.setTextColor(Color.WHITE)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        chronometer?.stop()
        if (floatingView != null) {
            try {
                windowManager?.removeView(floatingView)
            } catch (_: Exception) {}
            floatingView = null
        }
    }

    companion object {
        const val ACTION_STOP = "app.notekar.notekar.STOP_FLOATING_TIMER"
        var instance: FloatingTimerService? = null

        fun start(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(context)) {
                return
            }
            try {
                val intent = Intent(context, FloatingTimerService::class.java)
                context.startService(intent)
            } catch (_: Exception) {}
        }

        fun stop(context: Context) {
            try {
                val intent = Intent(context, FloatingTimerService::class.java).apply {
                    action = ACTION_STOP
                }
                context.startService(intent)
            } catch (_: Exception) {}
        }

        fun updateState(context: Context) {
            if (instance != null) {
                instance?.refreshView()
            } else {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val enabled = prefs.getBoolean("flutter.floating_timer_enabled", false)
                if (enabled) {
                    val widgetPrefs = context.getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    val mode = widgetPrefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
                    val nextAction = widgetPrefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                    if (mode == "two-way" && nextAction == "out") {
                        start(context)
                    }
                }
            }
        }
    }
}
