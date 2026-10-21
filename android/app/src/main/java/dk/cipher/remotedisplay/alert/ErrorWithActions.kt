package dk.cipher.remotedisplay.alert

import androidx.annotation.StringRes

data class Action(
    @StringRes val title: Int,
    val style: Style = Style.DEFAULT,
    val action: () -> Unit = {}
) {
    enum class Style {
        HIGHLIGHTED, DEFAULT
    }
}

interface ErrorWithActions {
    val actions: List<Action>
}
