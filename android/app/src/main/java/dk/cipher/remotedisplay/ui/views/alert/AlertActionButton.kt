package dk.cipher.remotedisplay.ui.views.alert

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.alert.Action
import dk.cipher.remotedisplay.alert.Action.Style
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun AlertActionButton(action: Action, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .clickable(onClick = action.action)
    ) {
        BasicText(
            text = stringResource(action.title),
            style = TextStyle(
                color = action.style.textColor(),
                fontSize = 20.sp
            ),
            modifier = Modifier
                .background(style = action.style)
                .padding(horizontal = 15.dp, vertical = 5.dp)
        )
    }
}

@Composable
private fun Style.textColor(): Color =
    when (this) {
        Style.DEFAULT -> colorResource(R.color.accent)
        Style.HIGHLIGHTED -> colorResource(R.color.display_background)
    }

@Composable
private fun Modifier.background(style: Style): Modifier =
    when (style) {
        Style.DEFAULT ->
            border(
                width = 1.dp,
                color = colorResource(R.color.accent),
                shape = RoundedCornerShape(8.dp)
            )
        Style.HIGHLIGHTED ->
            background(
                color = colorResource(R.color.accent),
                shape = RoundedCornerShape(8.dp)
            )
    }

@Composable @Preview(widthDp = 200, heightDp = 40)
private fun AlertActionButtonPreview() {
    Row(
        modifier = Modifier.previewBackground(),
        horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AlertActionButton(Action(R.string.action_button_ok, Style.DEFAULT))
        AlertActionButton(Action(R.string.action_button_preview_cancel, Style.HIGHLIGHTED))
    }
}