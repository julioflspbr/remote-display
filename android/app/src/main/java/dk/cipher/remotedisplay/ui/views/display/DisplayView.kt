package dk.cipher.remotedisplay.ui.views.display

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.keyboard.KeyboardController
import dk.cipher.remotedisplay.ui.models.Line
import dk.cipher.remotedisplay.ui.views.character.CharacterView
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun DisplayView(text: String, keyboardController: KeyboardController, modifier: Modifier = Modifier) {
    val viewModel: DisplayViewModel = viewModel(
        factory = DisplayViewModel.build(keyboardController)
    )

    viewModel.setText(text)
    Column(
        modifier
            .clickable {
                keyboardController.toggleKeyboard()
            }
    ) {
        for (line in viewModel.display.lines) {
            LineView(line)
        }
    }
}

@Composable
private fun LineView(line: Line) {
    Row(
        modifier = Modifier.padding(vertical = 2.5.dp)
    ) {
       for (char in line.cells) {
           CharacterView(
               cell = char.value,
               modifier = Modifier
                   .padding(horizontal = 2.5.dp)
           )
       }
    }
}

@Preview(widthDp = 590, heightDp = 115)
@Composable
private fun DisplayPreview() {
    DisplayView(
        text = "Ola\nNatalia", KeyboardController(),
        modifier = Modifier.previewBackground()
    )
}
