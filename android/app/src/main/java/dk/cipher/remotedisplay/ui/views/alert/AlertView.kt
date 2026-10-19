package dk.cipher.remotedisplay.ui.views.alert

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.alert.Action
import dk.cipher.remotedisplay.alert.Action.Style
import dk.cipher.remotedisplay.alert.AlertController
import dk.cipher.remotedisplay.alert.ErrorWithActions
import dk.cipher.remotedisplay.utils.LocalisedError
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun AlertView(alertController: AlertController, modifier: Modifier = Modifier) {
    val viewModel: AlertViewModel = viewModel { AlertViewModel() }

    SideEffect(Unit) {
        viewModel.startListeningToErrors(alertController)
    }

    DisposableEffect(Unit) {
        onDispose {
            viewModel.stopListeningToErrors()
        }
    }

    AlertTextView(viewModel, modifier)
}

@Composable
fun AlertTextView(viewModel: AlertViewModel, modifier: Modifier = Modifier) {
    if (viewModel.isAlerting) {
        Column(
            verticalArrangement = Arrangement.spacedBy(20.dp, Alignment.CenterVertically),
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = modifier
        ) {
            BasicText(
                text = viewModel.message(),
                style = TextStyle(
                    fontSize = 17.sp,
                    color = colorResource(R.color.character)
                )
            )

            Row(
                horizontalArrangement = Arrangement.spacedBy(8.dp, Alignment.CenterHorizontally)
            ) {
                for (action in viewModel.actions()) {
                    AlertActionButton(action)
                }
            }
        }
    }
}

@Composable @Preview(widthDp = 600, heightDp = 160)
fun AlertPreview() {
    class PreviewError: LocalisedError(), ErrorWithActions {
        override val errorDescription = R.string.error_description_preview
        override val failureReason = R.string.error_failure_reason_preview
        override val recoverySuggestion = R.string.error_recover_preview

        override val actions = listOf(
            Action(R.string.action_button_preview_lalalones, Style.HIGHLIGHTED),
            Action(R.string.action_button_preview_cancel, Style.DEFAULT),
            Action(R.string.action_button_preview_try_again, Style.DEFAULT)
        )
    }

    val alertViewModel = viewModel { AlertViewModel() }
    alertViewModel.setCurrentError(PreviewError())
    AlertTextView(alertViewModel, Modifier.previewBackground())
}