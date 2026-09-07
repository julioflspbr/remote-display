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
import dk.cipher.remotedisplay.keyboard.Controller
import dk.cipher.remotedisplay.keyboard.Receiver
import dk.cipher.remotedisplay.keyboard.Toggler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class FocusableComposeView : Toggler, FrameLayout {
    val keyboardController: Receiver

    constructor(context: Context) : super(context) {
        this.keyboardController = Controller.shared
        this.compose = ComposeView(context)
        isFocusable = true
        isFocusableInTouchMode = true
        addView(compose)
    }

    constructor(context: Context, keyboardController: Receiver) : super(context) {
        this.keyboardController = keyboardController
        this.compose = ComposeView(context)
        isFocusable = true
        isFocusableInTouchMode = true
        addView(compose)
    }

    private val compose: ComposeView
    private var isShowingKeyboard = false

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

    private fun showKeyboard() {
        requestFocus()
        val input = context.getSystemService(InputMethodManager::class.java)
        input.showSoftInput(this, 0)
        isShowingKeyboard = true
    }

    private fun hideKeyboard() {
        val input = context.getSystemService(InputMethodManager::class.java)
        input.hideSoftInputFromWindow(windowToken, 0)
        isShowingKeyboard = false
    }

    override fun toggleKeyboard() {
        if (isShowingKeyboard) {
            hideKeyboard()
        } else {
            showKeyboard()
        }
    }
}