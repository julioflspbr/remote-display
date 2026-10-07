package dk.cipher.remotedisplay.utils

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.colorResource
import dk.cipher.remotedisplay.R

@Composable
fun Modifier.previewBackground() =
    this
        .background(colorResource(R.color.display_background))
        .fillMaxSize()
