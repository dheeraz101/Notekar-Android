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

        // Title
        val title = TextView(this).apply {
            text = "Quick Note"
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
                bottomMargin = (20 * density).toInt()
            }
            layoutParams = lp
        }
        card.addView(input)

        // Buttons Layout
        val buttonsContainer = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        // Cancel Button
        val btnCancel = TextView(this).apply {
            text = "Cancel"
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
                if (note.isNotEmpty()) {
                    val prefs =
                        getSharedPreferences(NoteKarWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE)
                    val mode =
                        prefs.getString(NoteKarWidgetProvider.KEY_MODE, "two-way") ?: "two-way"
                    val nextAction =
                        prefs.getString(NoteKarWidgetProvider.KEY_NEXT_ACTION, "in") ?: "in"
                    val logType = if (mode == "single") "single" else nextAction

                    NoteKarWidgetProvider.performBackgroundLog(
                        this@QuickNoteActivity,
                        logType,
                        note
                    )
                }
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
}
