package dk.cipher.remotedisplay.ui.views.alert

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.initializer
import androidx.lifecycle.viewmodel.viewModelFactory
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.alert.Action
import dk.cipher.remotedisplay.alert.AlertController
import dk.cipher.remotedisplay.alert.ErrorWithActions
import dk.cipher.remotedisplay.utils.LocalisedError
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlin.coroutines.CoroutineContext

class AlertViewModel: ViewModel() {
    private val semaphore = Semaphore(1)
    private var currentError: Throwable? = null
    private var handlingJob: Job? = null

    val isAlerting: Boolean
        get() = this.currentError != null

    @Composable
    fun message(): String {
        val currentError = this.currentError ?: return ""
        var message = ""

        if (currentError is LocalisedError) {
            if (currentError.errorDescription != null) {
                message += stringResource(currentError.errorDescription!!)
            }
            if (currentError.failureReason != null) {
                message += "\n" + stringResource(currentError.failureReason!!)
            }
            if (currentError.recoverySuggestion != null) {
                message += "\n" + stringResource(currentError.recoverySuggestion!!)
            }
        } else {
            message += currentError.localizedMessage ?: ""
        }

        return message
    }

    @Composable
    fun actions(): List<Action> {
        val currentError = this.currentError ?: return listOf()

        if (currentError is ErrorWithActions) {
            return currentError.actions.map { action ->
                Action(
                    title = action.title,
                    style = action.style,
                    action = {
                        action.action()
                        this.currentError = null
                        this.semaphore.release()
                    }
                )
            }.sorted
        } else {
            return listOf(Action(R.string.action_button_ok, Action.Style.HIGHLIGHTED))
        }
    }

    fun startListeningToErrors(alertController: AlertController?, context: CoroutineContext = Dispatchers.Default) {
        this.stopListeningToErrors()

        val alertController = alertController ?: return
        this.handlingJob = CoroutineScope(context).launch {
            for (error in alertController.errors(context)) {
                currentError = error
                semaphore.acquire()
            }
        }
    }

    fun stopListeningToErrors() {
        this.handlingJob?.cancel()
        this.handlingJob = null
    }

    fun setCurrentError(error: Throwable?) {
        this.currentError = error
    }
}

private val List<Action>.sorted: List<Action>
    get() {
        val adjusting = this.toMutableList()
        var preselectedIndex: Int? = null

        for ((i, action) in this.withIndex().reversed()) {
            if (preselectedIndex == null && action.style == Action.Style.HIGHLIGHTED) {
                preselectedIndex = i
            } else if (action.style == Action.Style.HIGHLIGHTED) {
                adjusting[i] = Action(
                    action.title,
                    Action.Style.DEFAULT,
                    action.action
                )
            }
        }
        if (preselectedIndex != null) {
            val preselected = adjusting.removeAt(preselectedIndex)
            adjusting.add(preselected)
        }
        return adjusting
    }