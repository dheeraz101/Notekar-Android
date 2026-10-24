package app.notekar.notekar

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
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
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.TextView
import org.json.JSONArray
import java.util.Locale

class FloatingTimerService : Service() {

    private var windowManager: WindowManager? = null
    private var floatingView: View? = null

    // Medium Circle components
    private var circleContainer: LinearLayout? = null
    private var circleBg: GradientDrawable? = null
    private var circleChronometer: Chronometer? = null
    private var circleTimeText: TextView? = null
    private var circleSubText: TextView? = null

    // Apple HIG Card components
    private var cardContainer: LinearLayout? = null
    private var cardCategoryBadge: TextView? = null
    private var cardGoalBadge: TextView? = null
    private var cardChronometer: Chronometer? = null
    private var cardStaticTime: TextView? = null
    private var cardStatusLabel: TextView? = null
    private var cardModeToggle: TextView? = null
    private var cardGoalsRow: LinearLayout? = null
    private var cardGoalsScroll: HorizontalScrollView? = null
    private var cardPrimaryAction: TextView? = null
    private var cardPauseResumeAction: TextView? = null
    private var cardOutAction: TextView? = null
    private var cardActiveActionRow: LinearLayout? = null

    private var isExpanded = false
    private var selectedGoalId: String? = null
    private var selectedGoalTitle: String? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        try {
            UnlockReceiver.updateUnlockReceiver(this)
        } catch (_: Exception) {}
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

    private fun formatElapsed(elapsedMs: Long): String {
        val totalSeconds = (elapsedMs / 1000).toInt()
        val minutes = (totalSeconds % 3600) / 60
        val seconds = totalSeconds % 60
        val hours = totalSeconds / 3600
        return if (hours > 0) {
            String.format(Locale.ROOT, "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format(Locale.ROOT, "%02d:%02d", minutes, seconds)
        }
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

        // Root container holds both the Medium Circle and the expandable Apple HIG Card
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.START
        }

        // -------------------------------------------------------------
        // 1. Medium Circle (Compact Floating Orb)
        // -------------------------------------------------------------
        val circleSize = (62 * density).toInt()
        circleBg = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.parseColor("#F2101114"))
            setStroke((2.2 * density).toInt(), Color.parseColor("#FF30D158"))
        }

        circleContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(circleSize, circleSize)
            background = circleBg
            elevation = 14 * density
            isClickable = true
            isFocusable = true
        }

        // Live chronometer readout inside circle
        circleChronometer = Chronometer(this).apply {
            setTextColor(Color.WHITE)
            textSize = 12.5f
            typeface = Typeface.MONOSPACE
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        circleContainer?.addView(circleChronometer)

        // Static time / idle glyph readout inside circle (shown when paused or idle)
        circleTimeText = TextView(this).apply {
            setTextColor(Color.parseColor("#FFFF9F0A"))
            textSize = 12f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            visibility = View.GONE
        }
        circleContainer?.addView(circleTimeText)

        // Subtitle / category tag inside circle
        circleSubText = TextView(this).apply {
            setTextColor(Color.parseColor("#99FFFFFF"))
            textSize = 8.5f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (1 * density).toInt()
            }
        }
        circleContainer?.addView(circleSubText)

        root.addView(circleContainer)

        // -------------------------------------------------------------
        // 2. Separate Elegant Apple HIG Floating Card
        // -------------------------------------------------------------
        val cardWidth = (270 * density).toInt()
        cardContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                cardWidth,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (10 * density).toInt()
            }
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#F516171A"))
                cornerRadius = 22 * density
                setStroke((1 * density).toInt(), Color.parseColor("#26FFFFFF"))
            }
            elevation = 18 * density
            val pad = (16 * density).toInt()
            setPadding(pad, pad, pad, pad)
        }

        // Header: Category Pill Badge + Target/Goal Pill + Close Button
        val cardHeader = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        cardCategoryBadge = TextView(this).apply {
            textSize = 10f
            setTextColor(Color.parseColor("#FF64D2FF"))
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            val padH = (8 * density).toInt()
            val padV = (3 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#2664D2FF"))
                cornerRadius = 7 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (6 * density).toInt()
            }
        }
        cardHeader.addView(cardCategoryBadge)

        cardGoalBadge = TextView(this).apply {
            textSize = 9.5f
            setTextColor(Color.parseColor("#B3FFFFFF"))
            typeface = Typeface.create("sans-serif", Typeface.NORMAL)
            val padH = (7 * density).toInt()
            val padV = (3 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1FFFFFFF"))
                cornerRadius = 7 * density
            }
            text = "🎯 Sovereign"
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        cardHeader.addView(cardGoalBadge)

        val headerSpacer = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, 1, 1f)
        }
        cardHeader.addView(headerSpacer)

        val btnCloseCard = TextView(this).apply {
            text = "✕"
            textSize = 11.5f
            setTextColor(Color.parseColor("#99FFFFFF"))
            gravity = Gravity.CENTER
            val closeSize = (24 * density).toInt()
            layoutParams = LinearLayout.LayoutParams(closeSize, closeSize)
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.parseColor("#1FFFFFFF"))
            }
            setOnClickListener {
                isExpanded = false
                cardContainer?.visibility = View.GONE
                val screenWidth = resources.displayMetrics.widthPixels
                if (params.x + cardWidth / 2 >= screenWidth / 2) {
                    params.x = screenWidth - circleSize - (12 * density).toInt()
                }
                windowManager?.updateViewLayout(floatingView, params)
            }
        }
        cardHeader.addView(btnCloseCard)

        cardContainer?.addView(cardHeader)

        // Large Timer Readout Hero
        val heroTimerContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (14 * density).toInt()
                bottomMargin = (12 * density).toInt()
            }
        }

        cardChronometer = Chronometer(this).apply {
            setTextColor(Color.WHITE)
            textSize = 25f
            typeface = Typeface.MONOSPACE
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }
        heroTimerContainer.addView(cardChronometer)

        cardStaticTime = TextView(this).apply {
            setTextColor(Color.WHITE)
            textSize = 24f
            typeface = Typeface.MONOSPACE
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
            visibility = View.GONE
        }
        heroTimerContainer.addView(cardStaticTime)

        cardStatusLabel = TextView(this).apply {
            textSize = 10.5f
            typeface = Typeface.create("sans-serif-medium", Typeface.BOLD)
            setTextColor(Color.parseColor("#FF30D158"))
            gravity = Gravity.CENTER
            text = "ACTIVE SESSION"
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = (3 * density).toInt()
            }
        }
        heroTimerContainer.addView(cardStatusLabel)

        cardContainer?.addView(heroTimerContainer)

        // Apple HIG Hairline Divider
        val divider1 = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                (0.8 * density).toInt()
            ).apply {
                bottomMargin = (10 * density).toInt()
            }
            setBackgroundColor(Color.parseColor("#1FFFFFFF"))
        }
        cardContainer?.addView(divider1)

        // Mode Switcher (Single / Two-Way Pill)
        cardModeToggle = TextView(this).apply {
            textSize = 11f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (12 * density).toInt()
            val padV = (7 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1FFFFFFF"))
                cornerRadius = 14 * density
                setStroke((0.8 * density).toInt(), Color.parseColor("#26FFFFFF"))
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (10 * density).toInt()
            }
            setOnClickListener {
                val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val widgetPrefs = getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                val currentMode = widgetPrefs.getString(NoteKarWidgetProvider.KEY_MODE, null)
                    ?: flutterPrefs.getString("flutter.m-mode", "two-way") ?: "two-way"
                val newMode = if (currentMode == "two-way") "single" else "two-way"
                flutterPrefs.edit().putString("flutter.m-mode", newMode).apply()
                widgetPrefs.edit().putString(NoteKarWidgetProvider.KEY_MODE, newMode).apply()
                NoteKarWidgetProvider.updateAllWidgets(this@FloatingTimerService)
                refreshView()
            }
        }
        cardContainer?.addView(cardModeToggle)

        // Goals / Target Selector Strip
        cardGoalsScroll = HorizontalScrollView(this).apply {
            isHorizontalScrollBarEnabled = false
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (12 * density).toInt()
            }
        }
        cardGoalsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }
        cardGoalsScroll?.addView(cardGoalsRow)
        cardContainer?.addView(cardGoalsScroll)

        // Primary Action Button (Idle: Start / Quick Log)
        cardPrimaryAction = TextView(this).apply {
            textSize = 12.5f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (14 * density).toInt()
            val padV = (10 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FF30D158"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (10 * density).toInt()
            }
            setOnClickListener {
                val prefs = getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val currentMode = prefs.getString(NoteKarWidgetProvider.KEY_MODE, null)
                    ?: flutterPrefs.getString("flutter.m-mode", "two-way") ?: "two-way"
                val actionType = if (currentMode == "two-way") "in" else "single"
                NoteKarWidgetProvider.performBackgroundLog(
                    this@FloatingTimerService,
                    actionType,
                    note = "",
                    goalId = selectedGoalId
                )
                refreshView()
            }
        }
        cardContainer?.addView(cardPrimaryAction)

        // Active Session Actions: Row of [Pause/Resume] and [Stop & Save (OUT)]
        cardActiveActionRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            visibility = View.GONE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (10 * density).toInt()
            }
        }

        cardPauseResumeAction = TextView(this).apply {
            textSize = 12f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (12 * density).toInt()
            val padV = (9 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#26FFFFFF"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginEnd = (6 * density).toInt()
            }
            setOnClickListener {
                NoteKarWidgetProvider.togglePauseResume(this@FloatingTimerService)
                refreshView()
            }
        }
        cardActiveActionRow?.addView(cardPauseResumeAction)

        cardOutAction = TextView(this).apply {
            text = "■ Stop & Save (OUT)"
            textSize = 12f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (12 * density).toInt()
            val padV = (9 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#FFFF3B30"))
                cornerRadius = 14 * density
            }
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1.4f)
            setOnClickListener {
                NoteKarWidgetProvider.performBackgroundLog(
                    this@FloatingTimerService,
                    "out",
                    note = "",
                    goalId = selectedGoalId
                )
                refreshView()
            }
        }
        cardActiveActionRow?.addView(cardOutAction)

        cardContainer?.addView(cardActiveActionRow)

        // Footer Actions Row (✎ Note, ↗ App, ✕ Off)
        val footerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        val btnQuickNote = TextView(this).apply {
            text = "✎ Quick Note"
            textSize = 11f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (10 * density).toInt()
            val padV = (7 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1FFFFFFF"))
                cornerRadius = 12 * density
            }
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1.2f).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                val intent = Intent(this@FloatingTimerService, QuickNoteActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                startActivity(intent)
            }
        }
        footerRow.addView(btnQuickNote)

        val btnOpenApp = TextView(this).apply {
            text = "↗ App"
            textSize = 11f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
            val padH = (10 * density).toInt()
            val padV = (7 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#1FFFFFFF"))
                cornerRadius = 12 * density
            }
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 0.9f).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                val launchIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED
                }
                if (launchIntent != null) {
                    startActivity(launchIntent)
                }
            }
        }
        footerRow.addView(btnOpenApp)

        val btnCloseOverlay = TextView(this).apply {
            text = "✕ Hide"
            textSize = 11f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            setTextColor(Color.parseColor("#80FFFFFF"))
            gravity = Gravity.CENTER
            val padH = (10 * density).toInt()
            val padV = (7 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#14FFFFFF"))
                cornerRadius = 12 * density
            }
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 0.9f)
            setOnClickListener {
                val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                flutterPrefs.edit().putBoolean("flutter.floating_timer_enabled", false).apply()
                stopSelf()
            }
        }
        footerRow.addView(btnCloseOverlay)

        cardContainer?.addView(footerRow)

        root.addView(cardContainer)

        // -------------------------------------------------------------
        // Touch Listener on Medium Circle: Dragging + Tap to Expand Card
        // -------------------------------------------------------------
        var initialX = 0
        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var lastTapTime = 0L
        val tapHandler = android.os.Handler(android.os.Looper.getMainLooper())
        var pendingSingleTap: Runnable? = null

        circleContainer?.setOnTouchListener { v, event ->
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
                    if (dx < 12 && dy < 12) {
                        val now = System.currentTimeMillis()
                        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

                        if (now - lastTapTime < 300) {
                            // Double tap detected
                            pendingSingleTap?.let { tapHandler.removeCallbacks(it) }
                            lastTapTime = 0L
                            v.performHapticFeedback(android.view.HapticFeedbackConstants.KEYBOARD_TAP)

                            val doubleTapAction = flutterPrefs.getString("flutter.floating_double_tap_action", "quick_menu") ?: "quick_menu"
                            if (doubleTapAction == "quick_menu") {
                                val intent = Intent(this@FloatingTimerService, QuickNoteActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                                }
                                startActivity(intent)
                            } else {
                                isExpanded = !isExpanded
                                cardContainer?.visibility = if (isExpanded) View.VISIBLE else View.GONE
                                val screenWidth = resources.displayMetrics.widthPixels
                                val screenHeight = resources.displayMetrics.heightPixels
                                val approxCardHeight = (320 * density).toInt()
                                if (isExpanded) {
                                    if (params.x + cardWidth > screenWidth - (12 * density).toInt()) {
                                        params.x = (screenWidth - cardWidth - (12 * density).toInt()).coerceAtLeast((12 * density).toInt())
                                    }
                                    if (params.y + approxCardHeight > screenHeight - (20 * density).toInt()) {
                                        params.y = (screenHeight - approxCardHeight - (20 * density).toInt()).coerceAtLeast((40 * density).toInt())
                                    }
                                } else {
                                    if (params.x + cardWidth / 2 >= screenWidth / 2) {
                                        params.x = screenWidth - circleSize - (12 * density).toInt()
                                    }
                                }
                                windowManager?.updateViewLayout(floatingView, params)
                            }
                        } else {
                            // Possible single tap
                            lastTapTime = now
                            pendingSingleTap = Runnable {
                                v.performHapticFeedback(android.view.HapticFeedbackConstants.KEYBOARD_TAP)
                                isExpanded = !isExpanded
                                cardContainer?.visibility = if (isExpanded) View.VISIBLE else View.GONE
                                val screenWidth = resources.displayMetrics.widthPixels
                                val screenHeight = resources.displayMetrics.heightPixels
                                val approxCardHeight = (320 * density).toInt()
                                if (isExpanded) {
                                    if (params.x + cardWidth > screenWidth - (12 * density).toInt()) {
                                        params.x = (screenWidth - cardWidth - (12 * density).toInt()).coerceAtLeast((12 * density).toInt())
                                    }
                                    if (params.y + approxCardHeight > screenHeight - (20 * density).toInt()) {
                                        params.y = (screenHeight - approxCardHeight - (20 * density).toInt()).coerceAtLeast((40 * density).toInt())
                                    }
                                } else {
                                    if (params.x + cardWidth / 2 >= screenWidth / 2) {
                                        params.x = screenWidth - circleSize - (12 * density).toInt()
                                    }
                                }
                                windowManager?.updateViewLayout(floatingView, params)
                            }
                            pendingSingleTap?.let { tapHandler.postDelayed(it, 240) }
                        }
                    } else {
                        // Magnetic edge snapping
                        val screenWidth = resources.displayMetrics.widthPixels
                        val currentWidth = if (isExpanded) cardWidth else circleSize
                        val targetX = if (params.x + currentWidth / 2 < screenWidth / 2) {
                            (12 * density).toInt()
                        } else {
                            (screenWidth - currentWidth - (12 * density).toInt()).coerceAtLeast((12 * density).toInt())
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

    private fun rebuildGoalChips(density: Float) {
        val row = cardGoalsRow ?: return
        row.removeAllViews()

        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val goalsList = mutableListOf<Triple<String, String, String>>() // id, title, category
        val rawGoals = flutterPrefs.getString("flutter.notekar_goals_list_v1", null)
        if (rawGoals != null && rawGoals.startsWith("[")) {
            try {
                val arr = JSONArray(rawGoals)
                for (i in 0 until arr.length()) {
                    val g = arr.optJSONObject(i)
                    if (g != null && !g.optBoolean("isArchived", false)) {
                        val gId = g.optString("id", "")
                        val gTitle = g.optString("title", "").trim()
                        val gCat = g.optString("category", "").trim()
                        if (gTitle.isNotEmpty()) {
                            goalsList.add(Triple(gId, gTitle, gCat))
                        }
                    }
                }
            } catch (_: Exception) {}
        }

        if (goalsList.isEmpty()) {
            cardGoalsScroll?.visibility = View.GONE
            cardGoalBadge?.text = "🎯 Sovereign"
            return
        }

        cardGoalsScroll?.visibility = View.VISIBLE

        // "No Goal" chip
        val noGoalChip = TextView(this).apply {
            text = "No Target"
            textSize = 10f
            typeface = Typeface.create("sans-serif", Typeface.BOLD)
            val isSelected = selectedGoalId == null
            setTextColor(if (isSelected) Color.WHITE else Color.parseColor("#80FFFFFF"))
            val padH = (9 * density).toInt()
            val padV = (4 * density).toInt()
            setPadding(padH, padV, padH, padV)
            background = GradientDrawable().apply {
                setColor(if (isSelected) Color.parseColor("#40FFFFFF") else Color.parseColor("#14FFFFFF"))
                cornerRadius = 8 * density
            }
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                marginEnd = (5 * density).toInt()
            }
            setOnClickListener {
                selectedGoalId = null
                selectedGoalTitle = null
                cardGoalBadge?.text = "🎯 Sovereign"
                rebuildGoalChips(density)
            }
        }
        row.addView(noGoalChip)

        for (goal in goalsList) {
            val (gId, gTitle, _) = goal
            val isSelected = selectedGoalId == gId
            val chip = TextView(this).apply {
                text = "🎯 $gTitle"
                textSize = 10f
                typeface = Typeface.create("sans-serif", Typeface.BOLD)
                setTextColor(if (isSelected) Color.WHITE else Color.parseColor("#B364D2FF"))
                val padH = (9 * density).toInt()
                val padV = (4 * density).toInt()
                setPadding(padH, padV, padH, padV)
                background = GradientDrawable().apply {
                    setColor(if (isSelected) Color.parseColor("#FF007AFF") else Color.parseColor("#26007AFF"))
                    cornerRadius = 8 * density
                }
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    marginEnd = (5 * density).toInt()
                }
                setOnClickListener {
                    selectedGoalId = gId
                    selectedGoalTitle = gTitle
                    cardGoalBadge?.text = "🎯 $gTitle"
                    rebuildGoalChips(density)
                }
            }
            row.addView(chip)
        }

        if (selectedGoalTitle != null) {
            cardGoalBadge?.text = "🎯 $selectedGoalTitle"
        }
    }

    fun refreshView() {
        val density = resources.displayMetrics.density
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
        val isActive = isCurrentlyIn && lastTimestamp > 0L

        // Update Category Badges
        cardCategoryBadge?.text = activeCategory.uppercase(Locale.ROOT)
        rebuildGoalChips(density)

        // Mode switch label
        cardModeToggle?.text = if (mode == "two-way") "⇄ Two-Way Mode (IN / OUT)" else "⇄ Single Mode (Quick Log)"

        if (isActive) {
            val elapsed = if (isPaused && pausedAt > 0L && pausedAt >= lastTimestamp) {
                pausedAt - lastTimestamp
            } else if (lastTimestamp > 0L) {
                Math.max(0L, System.currentTimeMillis() - lastTimestamp)
            } else {
                0L
            }
            val base = SystemClock.elapsedRealtime() - elapsed

            if (isPaused) {
                // Circle UI - Paused State (Amber / Stopped)
                circleBg?.setColor(Color.parseColor("#F218150A"))
                circleBg?.setStroke((2.2 * density).toInt(), Color.parseColor("#FFFF9F0A"))
                circleChronometer?.stop()
                circleChronometer?.visibility = View.GONE
                circleTimeText?.visibility = View.VISIBLE
                circleTimeText?.text = formatElapsed(elapsed)
                circleTimeText?.setTextColor(Color.parseColor("#FFFF9F0A"))
                circleSubText?.text = "PAUSED"
                circleSubText?.setTextColor(Color.parseColor("#FFFF9F0A"))

                // Card UI - Paused State
                cardChronometer?.stop()
                cardChronometer?.visibility = View.GONE
                cardStaticTime?.visibility = View.VISIBLE
                cardStaticTime?.text = formatElapsed(elapsed)
                cardStaticTime?.setTextColor(Color.parseColor("#FFFF9F0A"))
                cardStatusLabel?.text = "SESSION PAUSED"
                cardStatusLabel?.setTextColor(Color.parseColor("#FFFF9F0A"))
                cardPauseResumeAction?.text = "▶ Resume"
            } else {
                // Circle UI - Active Running State (Green / Live Chronometer)
                circleBg?.setColor(Color.parseColor("#F20B130E"))
                circleBg?.setStroke((2.2 * density).toInt(), Color.parseColor("#FF30D158"))
                circleTimeText?.visibility = View.GONE
                circleChronometer?.visibility = View.VISIBLE
                circleChronometer?.base = base
                circleChronometer?.start()
                circleChronometer?.setTextColor(Color.WHITE)
                circleSubText?.text = activeCategory.uppercase(Locale.ROOT)
                circleSubText?.setTextColor(Color.parseColor("#B3FFFFFF"))

                // Card UI - Active Running State
                cardStaticTime?.visibility = View.GONE
                cardChronometer?.visibility = View.VISIBLE
                cardChronometer?.base = base
                cardChronometer?.start()
                cardChronometer?.setTextColor(Color.WHITE)
                cardStatusLabel?.text = "ACTIVE SESSION"
                cardStatusLabel?.setTextColor(Color.parseColor("#FF30D158"))
                cardPauseResumeAction?.text = "⏸ Pause"
            }

            // Actions visibility
            cardPrimaryAction?.visibility = View.GONE
            cardActiveActionRow?.visibility = View.VISIBLE
        } else {
            // Idle State (Red/Amber subtle border, mode glyph)
            circleBg?.setColor(Color.parseColor("#F2151111"))
            circleBg?.setStroke((2.2 * density).toInt(), Color.parseColor("#FFFF9F0A"))
            circleChronometer?.stop()
            circleChronometer?.visibility = View.GONE
            circleTimeText?.visibility = View.VISIBLE
            circleTimeText?.text = if (mode == "two-way") "▶ IN" else "⚡ LOG"
            circleTimeText?.setTextColor(Color.parseColor("#FFFF9F0A"))
            circleSubText?.text = "IDLE"
            circleSubText?.setTextColor(Color.parseColor("#FFFF453A"))

            // Card UI - Idle State
            cardChronometer?.stop()
            cardChronometer?.visibility = View.GONE
            cardStaticTime?.visibility = View.VISIBLE
            cardStaticTime?.text = "--:--:--"
            cardStaticTime?.setTextColor(Color.parseColor("#66FFFFFF"))
            cardStatusLabel?.text = if (mode == "two-way") "IDLE · READY TO CHECK IN" else "IDLE · READY TO QUICK LOG"
            cardStatusLabel?.setTextColor(Color.parseColor("#80FFFFFF"))

            cardActiveActionRow?.visibility = View.GONE
            cardPrimaryAction?.visibility = View.VISIBLE
            cardPrimaryAction?.text = if (mode == "two-way") "▶ START SESSION (IN)" else "⚡ INSTANT QUICK LOG"
            cardPrimaryAction?.background = GradientDrawable().apply {
                setColor(Color.parseColor("#FF30D158"))
                cornerRadius = 14 * density
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        circleChronometer?.stop()
        cardChronometer?.stop()
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
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val enabled = prefs.getBoolean("flutter.floating_timer_enabled", false)
            if (!enabled) {
                if (instance != null) {
                    stop(context)
                }
                return
            }
            if (instance != null) {
                instance?.refreshView()
            } else {
                start(context)
            }
        }
    }
}
