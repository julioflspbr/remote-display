package dk.cipher.remotedisplay.models

import androidx.compose.runtime.MutableState
import androidx.compose.runtime.mutableStateOf

data class Line(
    val cells: Array<MutableState<Cell>> = Array(Specs.charCount) { mutableStateOf<Cell>(Cell.Blank) }
) {
    object Specs {
        const val charCount = 16
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Line) return false
        return cells.contentEquals(other.cells)
    }

    override fun hashCode(): Int {
        return cells.contentHashCode()
    }
}
