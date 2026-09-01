package dk.cipher.remotedisplay.models

data class Display(val lines: Array<Line> = Array(Specs.lineCount) { Line() }) {
    object Specs {
        const val lineCount = 2
        const val charCount = lineCount * Line.Specs.charCount
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Display) return false
        return lines.contentEquals(other.lines)
    }

    override fun hashCode(): Int {
        return lines.contentHashCode()
    }
}
