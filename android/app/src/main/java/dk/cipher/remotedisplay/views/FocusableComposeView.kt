package dk.cipher.remotedisplay.views

import android.content.Context
import android.text.InputType
import android.view.KeyEvent
import android.view.inputmethod.BaseInputConnection
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.view.inputmethod.TextAttribute
import android.widget.FrameLayout
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.ComposeView
import dk.cipher.remotedisplay.views.display.KeyboardManager

class FocusableComposeView(context: Context): KeyboardManager, FrameLayout(context) {
    private val compose = ComposeView(context)
    private var insertTextHandler: ((CharSequence) -> Boolean)? = null
    private var deleteBackwardHandler: (() -> Boolean)? = null
    private var isShowingKeyboard = false


    init {
        isFocusable = true
        isFocusableInTouchMode = true
        addView(compose)
    }

    fun setContent(content: @Composable () -> Unit) {
        compose.setContent(content)
    }

    override fun onCheckIsTextEditor(): Boolean = true

    override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection {
        outAttrs.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS
        outAttrs.imeOptions = EditorInfo.IME_ACTION_DONE or EditorInfo.IME_FLAG_NO_EXTRACT_UI
        return object: BaseInputConnection(this, false) {
            override fun sendKeyEvent(event: KeyEvent): Boolean {
                if (event.action == KeyEvent.ACTION_DOWN) {
                    if (event.keyCode == KeyEvent.KEYCODE_DEL) {
                        deleteBackwardHandler?.invoke() ?: super.sendKeyEvent(event)
                    }
                    if (event.keyCode == KeyEvent.KEYCODE_ENTER) {
                        hideKeyboard()
                        return true
                    }
                    val unicode = event.getUnicodeChar(event.metaState)
                    if (unicode != 0) {
                        val char = unicode.toChar()
                        return insertTextHandler?.invoke("$char") ?: super.sendKeyEvent(event)
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
        isShowingKeyboard = true
    }

    override fun hideKeyboard() {
        val input = context.getSystemService(InputMethodManager::class.java)
        input.hideSoftInputFromWindow(windowToken, 0)
        isShowingKeyboard = false
    }

    override fun isShowingKeyboard(): Boolean = isShowingKeyboard

    override fun insertText(handler: (CharSequence) -> Boolean) {
        insertTextHandler = handler
    }

    override fun deleteBackward(handler: () -> Boolean) {
        deleteBackwardHandler = handler
    }
}