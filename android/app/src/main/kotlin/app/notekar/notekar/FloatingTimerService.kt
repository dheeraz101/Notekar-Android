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
            setPadding((10 * density).toInt(), (6 * density).toInt(), (10 * density).toInt(), (6 * density).toInt())
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E6181B22"))
                cornerRadius = 20 * density
                setStroke((1 * density).toInt(), Color.parseColor("#33FFFFFF"))
            }
            elevation = 12 * density
        }

        // Top Row: Status Dot + Chronometer + Category
        val mainRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        statusDot = View(this).apply {
            val size = (8 * density).toInt()
            layoutParams = LinearLayout.LayoutParams(size, size).apply {
                marginEnd = (8 * density).toInt()
            }
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#FF30D158"))
            }
        }
        mainRow.addView(statusDot)

        chronometer = Chronometer(this).apply {
            setTextColor(Color.WHITE)
            textSize = 14f
            typeface = android.graphics.Typeface.MONOSPACE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (8 * density).toInt()
            }
        }
        mainRow.addView(chronometer)

        categoryText = TextView(this).apply {
            textSize = 10.5f
            setTextColor(Color.parseColor("#FF64D2FF"))
            typeface = android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
        }
        mainRow.addView(categoryText)

        root.addView(mainRow)

        // Bottom Expandable Actions Bar (Pause/Resume, OUT, Close)
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
            textSize = 13f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val pad = (6 * density).toInt()
            setPadding(pad * 2, pad, pad * 2, pad)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#33FFFFFF"))
                cornerRadius = 10 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (6 * density).toInt()
            }
            setOnClickListener {
                NoteKarWidgetProvider.togglePauseResume(this@FloatingTimerService)
            }
        }
        actionsContainer?.addView(btnPauseResume)

        val btnOut = TextView(this).apply {
            text = "OUT"
            textSize = 11.5f
            typeface = android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val pad = (6 * density).toInt()
            setPadding(pad * 2, pad, pad * 2, pad)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FF0A84FF"))
                cornerRadius = 10 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (6 * density).toInt()
            }
            setOnClickListener {
                NoteKarWidgetProvider.performBackgroundLog(this@FloatingTimerService, "out", "")
                stopSelf()
            }
        }
        actionsContainer?.addView(btnOut)

        val btnClose = TextView(this).apply {
            text = "✕"
            textSize = 12f
            setTextColor(Color.parseColor("#99FFFFFF"))
            gravity = Gravity.CENTER
            val pad = (6 * density).toInt()
            setPadding(pad * 2, pad, pad * 2, pad)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#22FFFFFF"))
                cornerRadius = 10 * density
            }
            setOnClickListener {
                stopSelf()
            }
        }
        actionsContainer?.addView(btnClose)

        root.addView(actionsContainer)

        // Touch Listener for dragging and click detection
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f

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
                        isExpanded = !isExpanded
                        actionsContainer?.visibility = if (isExpanded) View.VISIBLE else View.GONE
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
        val mode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
        val nextAction = prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
        val lastTimestamp = prefs.getLong(NoteKarWidgetProvider.KEY_LAST_TIMESTAMP, 0L)
        val activeCategory = prefs.getString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, "Work") ?: "Work"
        val isPaused = prefs.getBoolean(NoteKarWidgetProvider.KEY_IS_PAUSED, false)
        val pausedAt = prefs.getLong(NoteKarWidgetProvider.KEY_PAUSED_AT, 0L)

        val isCurrentlyIn = mode == "two-way" && nextAction == "out"
        if (!isCurrentlyIn || lastTimestamp <= 0L) {
            stopSelf()
            return
        }

        categoryText?.text = activeCategory.uppercase(Locale.ROOT)
        btnPauseResume?.text = if (isPaused) "▶" else "⏸"

        (statusDot?.background as? GradientDrawable)?.setColor(
            if (isPaused) Color.parseColor("#FFFF9F0A") else Color.parseColor("#FF30D158")
        )

        val elapsed = if (isPaused && pausedAt > 0L) {
            pausedAt - lastTimestamp
        } else {
            System.currentTimeMillis() - lastTimestamp
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
