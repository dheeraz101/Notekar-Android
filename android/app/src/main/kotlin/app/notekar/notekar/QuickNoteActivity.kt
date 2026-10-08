package app.notekar.notekar

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Bundle
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import org.json.JSONArray

class QuickNoteActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set full transparent window & decor to eliminate rectangular box borders on older Android
        window.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        window.decorView.setBackgroundColor(Color.TRANSPARENT)
        window.setDimAmount(0.45f)

        val density = resources.displayMetrics.density

        // Root Container (Translucent dark overlay)
        val root = FrameLayout(this).apply {
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.parseColor("#70000000"))
            setOnClickListener {
                finish()
            }
        }

        // Scrollable container to ensure dialog and buttons remain accessible above keyboard
        val scrollView = ScrollView(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            isFillViewport = true
            overScrollMode = View.OVER_SCROLL_IF_CONTENT_SCROLLS
            setOnClickListener {
                finish()
            }
        }

        val scrollCenter = FrameLayout(this).apply {
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
            }
            setOnClickListener {
                finish()
            }
        }

        // Dialog Card
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val cardWidth = Math.min((340 * density).toInt(), (resources.displayMetrics.widthPixels * 0.92f).toInt())
            val lp = FrameLayout.LayoutParams(
                cardWidth,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
                topMargin = (24 * density).toInt()
                bottomMargin = (24 * density).toInt()
            }
            layoutParams = lp
            padding(20, 20, 20, 20)

            // Glassmorphic rounded background
            background = GradientDrawable().apply {
                setColor(Color.parseColor("#E61A1D24")) // slate dark
                cornerRadius = 24 * density
                setStroke((1 * density).toInt(), Color.parseColor("#26FFFFFF"))
            }
            setOnClickListener {
                // Prevent click pass-through
            }
        }

        val isSession = intent.getBooleanExtra(EXTRA_IS_SESSION, false)
        val showModes = intent.getBooleanExtra(EXTRA_SHOW_MODES, false)
        val explicitLogType = intent.getStringExtra(EXTRA_LOG_TYPE)
        val widgetPrefs =
            getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
        val flutterPrefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val mode = widgetPrefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
        val nextAction = widgetPrefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
        val resolvedType = explicitLogType ?: if (isSession) nextAction else "single"
        val isStartingSession = isSession && resolvedType == "in"
        val isEndingSession = isSession && resolvedType == "out"

        var selectedCategory =
            widgetPrefs.getString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, null)
                ?: flutterPrefs.getString("flutter.notekar.active_category", null)
                ?: flutterPrefs.getString("flutter.active_category", null)
                ?: "Work"
        if (selectedCategory == "All") selectedCategory = "Work"
        var selectedGoalTitle: String? = null

        // Title
        val title = TextView(this).apply {
            text = when {
                showModes -> "Select Mode & Action"
                isStartingSession -> "Start Session"
                isEndingSession -> "Log OUT Note"
                else -> "⚡ Quick Log"
            }
            setTextColor(Color.WHITE)
            textSize = 17f
            typeface =
                android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
            gravity = Gravity.CENTER
            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (14 * density).toInt()
            }
            layoutParams = lp
        }
        card.addView(title)

        // 1. Show Mode / Category Selector Strip
        if (isStartingSession || showModes || !isEndingSession) {
            val categories = mutableListOf<String>()
            val customCatsJson = flutterPrefs.getString("flutter.notekar.custom_categories", null)
                ?: flutterPrefs.getString("flutter.custom_categories", null)
            if (customCatsJson != null && customCatsJson.startsWith("[")) {
                try {
                    val arr = JSONArray(customCatsJson)
                    for (i in 0 until arr.length()) {
                        val c = arr.optString(i)?.trim()
                        if (!c.isNullOrEmpty() && c != "All") categories.add(c)
                    }
                } catch (_: Exception) {
                }
            }
            if (categories.isEmpty()) {
                categories.addAll(
                    listOf(
                        "Work",
                        "Study",
                        "Gym",
                        "Reading",
                        "Personal",
                        "Health",
                        "Routine"
                    )
                )
            }

            val catLabel = TextView(this).apply {
                text = "SELECT MODE"
                setTextColor(Color.parseColor("#80FFFFFF"))
                textSize = 11f
                typeface =
                    android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
                val lp = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = (6 * density).toInt()
                }
                layoutParams = lp
            }
            card.addView(catLabel)

            val catScroll = HorizontalScrollView(this).apply {
                overScrollMode = View.OVER_SCROLL_NEVER
                isHorizontalScrollBarEnabled = false
                val lp = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = (12 * density).toInt()
                }
                layoutParams = lp
            }

            val catRow = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
            }

            val catViews = mutableListOf<TextView>()
            for (cat in categories) {
                val isSelected = cat.equals(selectedCategory, ignoreCase = true)
                val catChip = TextView(this).apply {
                    text = cat
                    textSize = 12f
                    gravity = Gravity.CENTER
                    val hPad = (11 * density).toInt()
                    val vPad = (6 * density).toInt()
                    setPadding(hPad, vPad, hPad, vPad)

                    val chipLp = LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.WRAP_CONTENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    ).apply {
                        marginEnd = (6 * density).toInt()
                    }
                    layoutParams = chipLp

                    fun applyCatStyle(active: Boolean) {
                        setTextColor(if (active) Color.WHITE else Color.parseColor("#B3FFFFFF"))
                        background = GradientDrawable().apply {
                            setColor(
                                if (active) Color.parseColor("#FF0A84FF") else Color.parseColor(
                                    "#1FFFFFFF"
                                )
                            )
                            cornerRadius = 14 * density
                            if (!active) {
                                setStroke((1 * density).toInt(), Color.parseColor("#26FFFFFF"))
                            }
                        }
                    }

                    applyCatStyle(isSelected)

                    setOnClickListener {
                        selectedCategory = cat
                        for (v in catViews) {
                            (v.tag as? ((Boolean) -> Unit))?.invoke(v.text == cat)
                        }
                        widgetPrefs.edit().putString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, cat)
                            .apply()
                        flutterPrefs.edit()
                            .putString("flutter.notekar.active_category", cat)
                            .putString("flutter.active_category", cat)
                            .apply()
                        NoteKarWidgetProvider.updateAllWidgets(this@QuickNoteActivity)
                        MainActivity.updatePersistentControlPanel(this@QuickNoteActivity)
                    }
                    tag = { active: Boolean -> applyCatStyle(active) }
                }
                catViews.add(catChip)
                catRow.addView(catChip)
            }
            catScroll.addView(catRow)
            card.addView(catScroll)

            // Goals / Target Selector Strip (if user configured any goals)
            val goalsList = mutableListOf<String>()
            val rawGoals = flutterPrefs.getString("flutter.notekar_goals_list_v1", null)
            if (rawGoals != null && rawGoals.startsWith("[")) {
                try {
                    val arr = JSONArray(rawGoals)
                    for (i in 0 until arr.length()) {
                        val g = arr.optJSONObject(i)
                        if (g != null && !g.optBoolean("isArchived", false)) {
                            val gTitle = g.optString("title", "").trim()
                            if (gTitle.isNotEmpty()) {
                                goalsList.add(gTitle.take(9))
                            }
                        }
                    }
                } catch (_: Exception) {
                }
            }

            if (goalsList.isNotEmpty()) {
                val goalLabel = TextView(this).apply {
                    text = "LINK TARGET / GOAL (OPTIONAL)"
                    setTextColor(Color.parseColor("#80FFFFFF"))
                    textSize = 11f
                    typeface = android.graphics.Typeface.create(
                        "sans-serif",
                        android.graphics.Typeface.BOLD
                    )
                    val lp = LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    ).apply {
                        bottomMargin = (6 * density).toInt()
                    }
                    layoutParams = lp
                }
                card.addView(goalLabel)

                val goalScroll = HorizontalScrollView(this).apply {
                    overScrollMode = View.OVER_SCROLL_NEVER
                    isHorizontalScrollBarEnabled = false
                    val lp = LinearLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.WRAP_CONTENT
                    ).apply {
                        bottomMargin = (12 * density).toInt()
                    }
                    layoutParams = lp
                }

                val goalRow = LinearLayout(this).apply {
                    orientation = LinearLayout.HORIZONTAL
                }

                val goalViews = mutableListOf<TextView>()
                for (goal in goalsList) {
                    val goalChip = TextView(this).apply {
                        text = "🎯 $goal"
                        textSize = 11.5f
                        gravity = Gravity.CENTER
                        val hPad = (10 * density).toInt()
                        val vPad = (5 * density).toInt()
                        setPadding(hPad, vPad, hPad, vPad)

                        val chipLp = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.WRAP_CONTENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        ).apply {
                            marginEnd = (6 * density).toInt()
                        }
                        layoutParams = chipLp

                        fun applyGoalStyle(active: Boolean) {
                            setTextColor(if (active) Color.WHITE else Color.parseColor("#B3FFFFFF"))
                            background = GradientDrawable().apply {
                                setColor(
                                    if (active) Color.parseColor("#FF30D158") else Color.parseColor(
                                        "#1FFFFFFF"
                                    )
                                )
                                cornerRadius = 14 * density
                                if (!active) {
                                    setStroke((1 * density).toInt(), Color.parseColor("#26FFFFFF"))
                                }
                            }
                        }

                        applyGoalStyle(false)

                        setOnClickListener {
                            if (selectedGoalTitle == goal) {
                                selectedGoalTitle = null
                                applyGoalStyle(false)
                            } else {
                                selectedGoalTitle = goal
                                for (v in goalViews) {
                                    val isCurrent = (v.text.toString() == "🎯 $goal")
                                    (v.tag as? ((Boolean) -> Unit))?.invoke(isCurrent)
                                }
                            }
                        }
                        tag = { active: Boolean -> applyGoalStyle(active) }
                    }
                    goalViews.add(goalChip)
                    goalRow.addView(goalChip)
                }
                goalScroll.addView(goalRow)
                card.addView(goalScroll)
            }
        }

        // EditText
        val input = EditText(this).apply {
            hint = when {
                isStartingSession -> "Session focus or notes (optional)"
                isEndingSession -> "What did you accomplish?"
                else -> "What's on your mind?"
            }
            setHintTextColor(Color.parseColor("#60FFFFFF"))
            setTextColor(Color.WHITE)
            inputType = InputType.TYPE_CLASS_TEXT or
                    InputType.TYPE_TEXT_FLAG_CAP_SENTENCES or
                    InputType.TYPE_TEXT_FLAG_MULTI_LINE
            isSingleLine = false
            minLines = if (isStartingSession) 2 else 3
            maxLines = 5
            gravity = Gravity.TOP or Gravity.START
            imeOptions = android.view.inputmethod.EditorInfo.IME_FLAG_NO_ENTER_ACTION
            textSize = 14f

            background = GradientDrawable().apply {
                setColor(Color.parseColor("#15FFFFFF"))
                cornerRadius = 12 * density
                setStroke((1 * density).toInt(), Color.parseColor("#1CFFFFFF"))
            }

            val pHorizontal = (12 * density).toInt()
            val pVertical = (10 * density).toInt()
            setPadding(pHorizontal, pVertical, pHorizontal, pVertical)

            val lp = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = (12 * density).toInt()
            }
            layoutParams = lp
        }
        card.addView(input)

        // Quick Tag Chips (15 Researched Daily Activities)
        try {
            val customTags = mutableListOf<String>()
            val stringSet = flutterPrefs.getStringSet("flutter.custom_note_tags", null)
            if (stringSet != null && stringSet.isNotEmpty()) {
                customTags.addAll(stringSet)
            } else {
                val jsonString = flutterPrefs.getString("flutter.custom_note_tags", null)
                if (jsonString != null && jsonString.startsWith("[")) {
                    val jsonArray = JSONArray(jsonString)
                    for (i in 0 until jsonArray.length()) {
                        val tag = jsonArray.optString(i)?.trim()
                        if (!tag.isNullOrEmpty()) {
                            customTags.add(tag)
                        }
                    }
                }
            }

            if (customTags.isEmpty()) {
                customTags.addAll(
                    listOf(
                        "Walking",
                        "Gym",
                        "Studying",
                        "Deep Work",
                        "Bathing",
                        "Washroom",
                        "Reading",
                        "Meditation",
                        "Commute",
                        "Cooking",
                        "Chores",
                        "Gaming",
                        "Family",
                        "Dining",
                        "Sleep"
                    )
                )
            }

            val tagScroll = HorizontalScrollView(this).apply {
                overScrollMode = View.OVER_SCROLL_NEVER
                isHorizontalScrollBarEnabled = false
                val lp = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    bottomMargin = (16 * density).toInt()
                }
                layoutParams = lp
            }

            val tagRow = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
            }

            val renderTagChips = { query: String? ->
                tagRow.removeAllViews()
                val q = query?.removePrefix("#")?.lowercase()?.trim()
                val filteredTags = if (q.isNullOrEmpty()) {
                    customTags
                } else {
                    customTags.filter { it.removePrefix("#").lowercase().contains(q) }
                }

                for (tag in filteredTags) {
                    val cleanTag = if (tag.startsWith("#")) tag else "#$tag"
                    val isFiltered = !q.isNullOrEmpty()
                    val chip = TextView(this).apply {
                        text = cleanTag
                        setTextColor(if (isFiltered) Color.WHITE else Color.parseColor("#CCFFFFFF"))
                        textSize = 12f
                        gravity = Gravity.CENTER
                        background = StateListDrawable().apply {
                            addState(
                                intArrayOf(android.R.attr.state_pressed),
                                GradientDrawable().apply {
                                    setColor(Color.parseColor("#4D3B82F6"))
                                    cornerRadius = 14 * density
                                })
                            addState(intArrayOf(), GradientDrawable().apply {
                                setColor(Color.parseColor(if (isFiltered) "#4D3B82F6" else "#1FFFFFFF"))
                                cornerRadius = 14 * density
                                setStroke((1 * density).toInt(), Color.parseColor(if (isFiltered) "#803B82F6" else "#26FFFFFF"))
                            })
                        }
                        val hPad = (10 * density).toInt()
                        val vPad = (5 * density).toInt()
                        setPadding(hPad, vPad, hPad, vPad)

                        val chipLp = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.WRAP_CONTENT,
                            ViewGroup.LayoutParams.WRAP_CONTENT
                        ).apply {
                            marginEnd = (6 * density).toInt()
                        }
                        layoutParams = chipLp

                        setOnClickListener {
                            val currentText = input.text.toString()
                            val cursorPosition = input.selectionEnd
                            val safeCursor = if (cursorPosition in 0..currentText.length) cursorPosition else currentText.length
                            val prefix = currentText.substring(0, safeCursor)
                            val suffix = currentText.substring(safeCursor)
                            val hashIndex = prefix.lastIndexOf('#')
                            val newText = if (hashIndex != -1 && !prefix.substring(hashIndex).contains(" ")) {
                                prefix.substring(0, hashIndex) + cleanTag + " " + suffix
                            } else {
                                val separator =
                                    if (currentText.isEmpty() || currentText.endsWith(" ")) "" else " "
                                "$currentText$separator$cleanTag "
                            }
                            input.setText(newText)
                            input.setSelection(newText.length)
                        }
                    }
                    tagRow.addView(chip)
                }
                tagScroll.visibility = if (filteredTags.isEmpty()) View.GONE else View.VISIBLE
            }

            renderTagChips(null)

            input.addTextChangedListener(object : android.text.TextWatcher {
                override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
                    val text = s?.toString() ?: ""
                    val cursor = input.selectionEnd
                    val safeCursor = if (cursor in 0..text.length) cursor else text.length
                    val textUpToCursor = text.substring(0, safeCursor)
                    val lastWord = textUpToCursor.split("\\s+".toRegex()).lastOrNull() ?: ""
                    if (lastWord.startsWith("#")) {
                        renderTagChips(lastWord)
                    } else {
                        renderTagChips(null)
                    }
                }
                override fun afterTextChanged(s: android.text.Editable?) {}
            })

            tagScroll.addView(tagRow)
            card.addView(tagScroll)
        } catch (_: Exception) {
        }

        // Buttons Layout
        val buttonsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        // Cancel / Skip Button
        val btnCancel = TextView(this).apply {
            text = if (isEndingSession) "Skip" else "Cancel"
            setTextColor(Color.parseColor("#B3FFFFFF"))
            textSize = 14f
            gravity = Gravity.CENTER
            typeface =
                android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)

            background = StateListDrawable().apply {
                addState(intArrayOf(android.R.attr.state_pressed), GradientDrawable().apply {
                    setColor(Color.parseColor("#1AFFFFFF"))
                    cornerRadius = 20 * density
                })
            }

            val lp = LinearLayout.LayoutParams(0, (40 * density).toInt(), 1f).apply {
                marginEnd = (6 * density).toInt()
            }
            layoutParams = lp
            setOnClickListener {
                if (isEndingSession) {
                    NoteKarWidgetProvider.performBackgroundLog(
                        this@QuickNoteActivity,
                        "out",
                        ""
                    )
                }
                finish()
            }
        }
        buttonsContainer.addView(btnCancel)

        // Save / Action Button
        val btnSave = TextView(this).apply {
            text = when {
                isStartingSession -> "Start Session"
                isEndingSession -> "Complete"
                else -> "Log ⚡"
            }
            setTextColor(Color.WHITE)
            textSize = 14f
            gravity = Gravity.CENTER
            typeface =
                android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)

            val accentColor = if (isStartingSession) "#FF30D158" else "#FF0A84FF"

            background = StateListDrawable().apply {
                addState(intArrayOf(android.R.attr.state_pressed), GradientDrawable().apply {
                    setColor(Color.parseColor(if (isStartingSession) "#FF24A143" else "#FF0062CC"))
                    cornerRadius = 20 * density
                })
                addState(intArrayOf(), GradientDrawable().apply {
                    setColor(Color.parseColor(accentColor))
                    cornerRadius = 20 * density
                })
            }

            val lp = LinearLayout.LayoutParams(0, (40 * density).toInt(), 1.2f).apply {
                marginStart = (6 * density).toInt()
            }
            layoutParams = lp
            setOnClickListener {
                var noteText = input.text.toString().trim()
                if (selectedGoalTitle != null && selectedGoalTitle!!.isNotEmpty()) {
                    noteText =
                        if (noteText.isEmpty()) "[${selectedGoalTitle}]" else "[${selectedGoalTitle}] $noteText"
                }

                if (isStartingSession) {
                    widgetPrefs.edit()
                        .putString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, selectedCategory)
                        .apply()
                }

                NoteKarWidgetProvider.performBackgroundLog(
                    this@QuickNoteActivity,
                    resolvedType,
                    noteText
                )
                finish()
            }
        }
        if (showModes) {
            val btnLogNote = TextView(this).apply {
                text = "Log Note"
                setTextColor(Color.WHITE)
                textSize = 13.5f
                gravity = Gravity.CENTER
                typeface =
                    android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#FF0A84FF"))
                    cornerRadius = 20 * density
                }
                val lp = LinearLayout.LayoutParams(0, (40 * density).toInt(), 1f).apply {
                    marginStart = (4 * density).toInt()
                    marginEnd = (4 * density).toInt()
                }
                layoutParams = lp
                setOnClickListener {
                    var noteText = input.text.toString().trim()
                    if (selectedGoalTitle != null && selectedGoalTitle!!.isNotEmpty()) {
                        noteText =
                            if (noteText.isEmpty()) "[${selectedGoalTitle}]" else "[${selectedGoalTitle}] $noteText"
                    }
                    widgetPrefs.edit()
                        .putString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, selectedCategory)
                        .apply()
                    NoteKarWidgetProvider.performBackgroundLog(
                        this@QuickNoteActivity,
                        "note",
                        noteText
                    )
                    finish()
                }
            }
            buttonsContainer.addView(btnLogNote)

            val btnStart = TextView(this).apply {
                text = if (mode == "two-way") "Start Session" else "⚡ Log"
                setTextColor(Color.WHITE)
                textSize = 13.5f
                gravity = Gravity.CENTER
                typeface =
                    android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)
                background = GradientDrawable().apply {
                    setColor(Color.parseColor("#FF30D158"))
                    cornerRadius = 20 * density
                }
                val lp = LinearLayout.LayoutParams(0, (40 * density).toInt(), 1.15f).apply {
                    marginStart = (4 * density).toInt()
                }
                layoutParams = lp
                setOnClickListener {
                    var noteText = input.text.toString().trim()
                    if (selectedGoalTitle != null && selectedGoalTitle!!.isNotEmpty()) {
                        noteText =
                            if (noteText.isEmpty()) "[${selectedGoalTitle}]" else "[${selectedGoalTitle}] $noteText"
                    }
                    widgetPrefs.edit()
                        .putString(NoteKarWidgetProvider.KEY_ACTIVE_CATEGORY, selectedCategory)
                        .apply()
                    val targetType = if (mode == "two-way") "in" else "single"
                    NoteKarWidgetProvider.performBackgroundLog(
                        this@QuickNoteActivity,
                        targetType,
                        noteText
                    )
                    finish()
                }
            }
            buttonsContainer.addView(btnStart)
        } else {
            buttonsContainer.addView(btnSave)
        }

        card.addView(buttonsContainer)
        scrollCenter.addView(card)
        scrollView.addView(scrollCenter)
        root.addView(scrollView)

        setContentView(root)

        // Automatically show keyboard
        input.requestFocus()
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_ALWAYS_VISIBLE)
    }

    private fun View.padding(l: Int, t: Int, r: Int, b: Int) {
        val density = resources.displayMetrics.density
        setPadding(
            (l * density).toInt(),
            (t * density).toInt(),
            (r * density).toInt(),
            (b * density).toInt()
        )
    }

    companion object {
        const val EXTRA_LOG_TYPE = "log_type"
        const val EXTRA_IS_SESSION = "is_session"
        const val EXTRA_SHOW_MODES = "show_modes"
    }
}
