package dk.cipher.remotedisplay.models

sealed interface Cell {
    data class Character(val char: Char): Cell
    data object Cursor: Cell
    data object Blank: Cell
}