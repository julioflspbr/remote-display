package dk.cipher.remotedisplay.keyboard

interface KeyboardReceiver {
    suspend fun insertText(text: String)
    suspend fun deleteBackward()
}