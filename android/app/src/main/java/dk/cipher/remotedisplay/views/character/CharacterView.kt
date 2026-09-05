package dk.cipher.remotedisplay.views.character

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicText
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.models.Cell

@Composable
fun CharacterView(cell: Cell, modifier: Modifier = Modifier) {
    val viewModel: CharacterViewModel = viewModel(factory = CharacterViewModel.build())

    SideEffect(cell is Cell.Cursor) {
        if (cell is Cell.Cursor) {
            viewModel.blink()
        } else {
            viewModel.steady()
        }
    }

    val char: Char = when (cell) {
        is Cell.Character -> cell.char
        is Cell.Cursor -> if (viewModel.showCursor) '_' else ' '
        is Cell.Blank -> ' '
    }

    BasicText(
        text = "$char",
        style = TextStyle(
            color = colorResource(R.color.character),
            fontSize = 70.sp,
            fontFamily = FontFamily(Font(R.font.ninepin))
        ),
        modifier = modifier
            .aspectRatio(5f/8f, matchHeightConstraintsFirst = true)
            .background(color = colorResource(R.color.character_background))
    )
}

@Preview
@Composable
fun CharacterPreview() {
    CharacterView(
        cell = Cell.Cursor,
        modifier = Modifier
            .size(50.dp, 80.dp)
            .background(color = colorResource(R.color.display_background))
            .padding(5.dp)
    )
}