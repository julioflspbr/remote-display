package dk.cipher.remotedisplay.ui.views.content

import android.content.Context
import android.text.InputType
import android.view.KeyEvent
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import androidx.compose.ui.platform.ComposeView
import dk.cipher.remotedisplay.keyboard.Keyboard
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.services.ServiceController
import dk.cipher.remotedisplay.ui.views.display.DisplayView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ContentView: Keyboard.Service, FrameLayout {
    data class Dependencies(
        val keyboardController: KeyboardController,
        val serviceController: ServiceController
    )

    private val inputManager: InputMethodManager
    private val keyboardController: KeyboardController?

    constructor(context: Context): super(context) {
        this.isFocusable = true
        this.isFocusableInTouchMode = true
        this.keyboardController = null
        this.inputManager = context.getSystemService(InputMethodManager::class.java)
    }

    constructor(context: Context, dependencies: Dependencies): super(context) {
        this.isFocusable = true
        this.isFocusableInTouchMode = true
        this.keyboardController = dependencies.keyboardController
        this.inputManager = context.getSystemService(InputMethodManager::class.java)

        dependencies.keyboardController.setService(this)
        val composeView = ComposeView(context).apply {
            setContent { DisplayView("Placeholder", dependencies.keyboardController) }
        }
        this.addView(composeView)
    }

    override fun onCheckIsTextEditor() = true

    override fun onCreateInputConnection(outAttrs: EditorInfo?): InputConnection? {
        outAttrs?.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        outAttrs?.imeOptions = EditorInfo.IME_ACTION_DONE or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        return object: BaseInputConnection(this, false) {
            override fun sendKeyEvent(event: KeyEvent): Boolean {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    if (event.keyCode == KeyEvent.KEYCODE_DEL) {
                        CoroutineScope(Dispatchers.IO).launch {
                            keyboardController?.deleteBackward()
                        }
                        return true
                    }
                    val unicode = event.getUnicodeChar(event.metaState)
                    if (unicode != 0) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val char = unicode.toChar()
                            keyboardController?.insertText(char.toString())
                        }
                        return true
                    }
                }
                return super.sendKeyEvent(event)
            }
        }
    }

    override fun showKeyboard() {
        this.requestFocus()
        this.inputManager.showSoftInput(this, 0)
    }

    override fun hideKeyboard() {
        this.inputManager.hideSoftInputFromWindow(this.windowToken, 0)
    }
}