package dk.cipher.remotedisplay.views.display

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.models.Line
import dk.cipher.remotedisplay.views.character.CharacterView

@Composable
fun DisplayView(input: KeyboardManager, text: String) {
    val viewModel: DisplayViewModel = viewModel(factory = DisplayViewModel.build(input))
    viewModel.setText(text)
    Column(
        Modifier
            .size(805.dp, 160.dp)
            .background(colorResource(R.color.display_background))
            .focusable()
            .clickable {
                viewModel.toggleKeyboard()
            }
    ) {
        for (line in viewModel.display.lines) {
            LineView(line)
        }
    }
}

@Composable
fun LineView(line: Line) {
    Row(
        Modifier
            .size(805.dp, 80.dp)
    ) {
       for (char in line.cells) {
           CharacterView(
               cell = char.value,
               modifier = Modifier
                   .size(50.dp, 80.dp)
                   .padding(5.dp)
           )
       }
    }
}

@Preview(widthDp = 805, heightDp = 160)
@Composable
fun DisplayPreview() {
    DisplayView(EmptyKeyboardManager,"Ola\nNatalia")
}
