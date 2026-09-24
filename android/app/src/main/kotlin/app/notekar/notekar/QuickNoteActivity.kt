package app.notekar.notekar

import android.app.Activity
import android.content.Context
import android.graphics.Color
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
import android.widget.LinearLayout
import android.widget.TextView

class QuickNoteActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Set full screen layout translucent
        window.setBackgroundDrawableResource(android.R.color.transparent)
        window.setDimAmount(0.45f) // Dim the background for premium feel

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

        // Dialog Card
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            val lp = FrameLayout.LayoutParams(
                (300 * density).toInt(),
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.CENTER
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
        val explicitLogType = intent.getStringExtra(EXTRA_LOG_TYPE)

        // Title
        val title = TextView(this).apply {
            text = if (isSession) {
                val prefs =
                    getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                val nextAction =
                    prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                val resolvedType = explicitLogType ?: nextAction
                if (resolvedType == "out") "Log OUT Note" else "Log IN Note"
            } else {
                "Quick Note"
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
                bottomMargin = (16 * density).toInt()
            }
            layoutParams = lp
        }
        card.addView(title)

        // EditText
        val input = EditText(this).apply {
            hint = "What's on your mind?"
            setHintTextColor(Color.parseColor("#60FFFFFF"))
            setTextColor(Color.WHITE)
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
            setSingleLine(true)
            textSize = 14f

            // Styled input box background
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

        // Quick Tag Chips
        try {
            val flutterPrefs =
                getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val customTags = mutableListOf<String>()

            // Flutter StringList is stored in JSON or prefix set
            val stringSet = flutterPrefs.getStringSet("flutter.custom_note_tags", null)
            if (stringSet != null && stringSet.isNotEmpty()) {
                customTags.addAll(stringSet)
            } else {
                val jsonString = flutterPrefs.getString("flutter.custom_note_tags", null)
                if (jsonString != null && jsonString.startsWith("[")) {
                    val cleaned = jsonString.removeSurrounding("[", "]").replace("\"", "")
                    if (cleaned.isNotEmpty()) {
                        customTags.addAll(cleaned.split(",").map { it.trim() })
                    }
                }
            }

            if (customTags.isEmpty()) {
                customTags.addAll(
                    listOf(
                        "#work",
                        "#study",
                        "#play",
                        "#health",
                        "#focus",
                        "#routine"
                    )
                )
            }

            val tagScroll = android.widget.HorizontalScrollView(this).apply {
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
                layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
            }

            for (tag in customTags) {
                val cleanTag = if (tag.startsWith("#")) tag else "#$tag"
                val chip = TextView(this).apply {
                    text = cleanTag
                    setTextColor(Color.parseColor("#CCFFFFFF"))
                    textSize = 12f
                    gravity = Gravity.CENTER
                    background = StateListDrawable().apply {
                        addState(
                            intArrayOf(android.R.attr.state_pressed),
                            GradientDrawable().apply {
                                setColor(Color.parseColor("#33FFFFFF"))
                                cornerRadius = 14 * density
                            })
                        addState(intArrayOf(), GradientDrawable().apply {
                            setColor(Color.parseColor("#1FFFFFFF"))
                            cornerRadius = 14 * density
                            setStroke((1 * density).toInt(), Color.parseColor("#26FFFFFF"))
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
                        val separator =
                            if (currentText.isEmpty() || currentText.endsWith(" ")) "" else " "
                        val newText = "$currentText$separator$cleanTag "
                        input.setText(newText)
                        input.setSelection(newText.length)
                    }
                }
                tagRow.addView(chip)
            }
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
            text = if (isSession) "Skip" else "Cancel"
            setTextColor(Color.parseColor("#B3FFFFFF"))
            textSize = 14f
            gravity = Gravity.CENTER
            typeface =
                android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)

            // Hover background
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
                if (isSession) {
                    val prefs =
                        getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    val nextAction =
                        prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                    val logType = explicitLogType ?: nextAction

                    NoteKarWidgetProvider.performBackgroundLog(
                        this@QuickNoteActivity,
                        logType,
                        ""
                    )
                }
                finish()
            }
        }
        buttonsContainer.addView(btnCancel)

        // Save Button
        val btnSave = TextView(this).apply {
            text = "Add"
            setTextColor(Color.WHITE)
            textSize = 14f
            gravity = Gravity.CENTER
            typeface =
                android.graphics.Typeface.create("sans-serif", android.graphics.Typeface.BOLD)

            background = StateListDrawable().apply {
                addState(intArrayOf(android.R.attr.state_pressed), GradientDrawable().apply {
                    setColor(Color.parseColor("#FF0062CC"))
                    cornerRadius = 20 * density
                })
                addState(intArrayOf(), GradientDrawable().apply {
                    setColor(Color.parseColor("#FF0A84FF")) // iOS Accent Blue
                    cornerRadius = 20 * density
                })
            }

            val lp = LinearLayout.LayoutParams(0, (40 * density).toInt(), 1f).apply {
                marginStart = (6 * density).toInt()
            }
            layoutParams = lp
            setOnClickListener {
                val note = input.text.toString().trim()
                val prefs =
                    getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                val nextAction =
                    prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                val logType = explicitLogType ?: if (isSession) nextAction else "single"

                NoteKarWidgetProvider.performBackgroundLog(
                    this@QuickNoteActivity,
                    logType,
                    note
                )
                finish()
            }
        }
        buttonsContainer.addView(btnSave)

        card.addView(buttonsContainer)
        root.addView(card)

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
    }
}
