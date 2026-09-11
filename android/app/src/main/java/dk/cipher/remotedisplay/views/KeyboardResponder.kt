package dk.cipher.remotedisplay.views

import android.content.Context
import android.text.InputType
import android.view.KeyEvent
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.ComposeView
import dk.cipher.remotedisplay.App
import dk.cipher.remotedisplay.keyboard.Keyboard
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class KeyboardResponder : Keyboard.Service, FrameLayout {
    constructor(context: Context) : super(context) {
        this.compose = ComposeView(context)
        this.isFocusable = true
        this.isFocusableInTouchMode = true
        this.keyboardController = App.keyboardController
        this.addView(this.compose)
    }

    private val keyboardController: Keyboard.Controller
    private val compose: ComposeView

    fun setContent(content: @Composable () -> Unit) =
        compose.setContent(content)

    override fun onCheckIsTextEditor(): Boolean = true

    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection {
        outAttrs.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        outAttrs.imeOptions = EditorInfo.IME_ACTION_DONE or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        return object: BaseInputConnection(this, false) {
            override fun sendKeyEvent(event: KeyEvent): Boolean {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    if (event.keyCode == KeyEvent.KEYCODE_DEL) {
                        CoroutineScope(Dispatchers.IO).launch {
                            keyboardController.deleteBackward()
                        }
                        return true
                    }
                    val unicode = event.getUnicodeChar(event.metaState)
                    if (unicode != 0) {
                        CoroutineScope(Dispatchers.IO).launch {
                            val char = unicode.toChar()
                            keyboardController.insertText(char.toString())
                        }
                        return true
                    }
                }
                return super.sendKeyEvent(event)
            }
        }
    }

    override fun showKeyboard() {
        requestFocus()
        val input = context.getSystemService(InputMethodManager::class.java)
        input.showSoftInput(this, 0)
    }

    override fun hideKeyboard() {
        val input = context.getSystemService(InputMethodManager::class.java)
        input.hideSoftInputFromWindow(windowToken, 0)
    }
}