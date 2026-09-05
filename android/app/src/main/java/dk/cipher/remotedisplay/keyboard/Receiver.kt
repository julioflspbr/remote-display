package dk.cipher.remotedisplay.keyboard

interface Receiver {
    suspend fun insertText(text: String)
    suspend fun deleteBackward()
}