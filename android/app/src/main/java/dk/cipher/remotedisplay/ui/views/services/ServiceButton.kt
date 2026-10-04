package dk.cipher.remotedisplay.ui.views.services

import androidx.compose.animation.animateColor
import androidx.compose.animation.core.EaseInOut
import androidx.compose.animation.core.InfiniteRepeatableSpec
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.ExperimentalGridApi
import androidx.compose.foundation.layout.Grid
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.colorResource
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import dk.cipher.remotedisplay.R
import dk.cipher.remotedisplay.utils.previewBackground

@Composable
fun ServiceButton(image: Painter, color: Color, isTransient: Boolean, modifier: Modifier = Modifier) {
    var previousColor by remember { mutableStateOf(color) }

    if (isTransient) {
        ServiceButtonTransientContent(image, color, previousColor, modifier)
    } else {
        ServiceButtonSteadyContent(image, color, modifier)
    }
}

@Composable
fun ServiceButtonSteadyContent(image: Painter, color: Color, modifier: Modifier) {
    ServiceButtonContent(image, color, modifier)
}

@Composable
fun ServiceButtonTransientContent(image: Painter, color: Color, previousColor: Color, modifier: Modifier) {
    val infiniteTransition = rememberInfiniteTransition("service button's transient state infinite transition for colour")
    val colourAnimation by infiniteTransition.animateColor(
        initialValue = previousColor,
        targetValue = color,
        animationSpec = InfiniteRepeatableSpec(
            animation = tween(350, easing = EaseInOut),
           repeatMode = RepeatMode.Reverse
        ),
        label = "service button colour animation"
    )

    ServiceButtonContent(image, colourAnimation, modifier)
}

@Composable
private fun ServiceButtonContent(image: Painter, color: Color, modifier: Modifier) {
    Box(
        modifier = modifier
            .padding(2.dp)
            .clip(RoundedCornerShape(2.dp))
            .border(1.dp, color)
    ) {
        Image(
            painter = image,
            contentDescription = null,
            colorFilter = ColorFilter.tint(color),
            modifier = Modifier
                .aspectRatio(1f)
                .padding(5.dp)
        )
    }
}

@OptIn(ExperimentalGridApi::class)
@Preview(widthDp = 60, heightDp = 90)
@Composable
fun ServiceButtonPreview() {
    @Composable
    fun ServiceButtonSteadyPreview(image: Painter, color: Color, modifier: Modifier = Modifier) {
        ServiceButton(
            image = image,
            color = color,
            isTransient = false,
            modifier = modifier
        )
    }

    @Composable
    fun ServiceButtonTransientPreview(image: Painter, initialColor: Color, finalColor: Color, modifier: Modifier = Modifier) {
        var colour by remember { mutableStateOf(initialColor) }

        SideEffect {
            colour = finalColor
        }

        ServiceButton(
            image = image,
            color = colour,
            isTransient = true,
            modifier = modifier
        )
    }

    val size = 30.dp

    Grid(
        modifier = Modifier.previewBackground(),
        config = {
            column(size)
            column(size)

            row(size)
            row(size)
            row(size)
        }
    ) {
        ServiceButtonSteadyPreview(
            image = painterResource(R.drawable.smoke),
            color = colorResource(R.color.service_unavailable),
            modifier = Modifier.gridItem(1, 1)
        )

        ServiceButtonTransientPreview(
            image = painterResource(R.drawable.smoke),
            initialColor = colorResource(R.color.service_unavailable),
            finalColor = colorResource(R.color.service_available),
            modifier = Modifier.gridItem(1,2)
        )

        ServiceButtonSteadyPreview(
            image = painterResource(R.drawable.wifi),
            color = colorResource(R.color.service_failed),
            modifier = Modifier.gridItem(2, 1)
        )

        ServiceButtonTransientPreview(
            image = painterResource(R.drawable.wifi),
            initialColor = colorResource(R.color.service_available),
            finalColor = colorResource(R.color.service_connected),
            modifier = Modifier.gridItem(2,2)
        )

        ServiceButtonSteadyPreview(
            image = painterResource(R.drawable.bluetooth),
            color = colorResource(R.color.service_connected),
            modifier = Modifier.gridItem(3, 1)
        )

        ServiceButtonSteadyPreview(
            image = painterResource(R.drawable.cloud),
            color = colorResource(R.color.service_failed),
            modifier = Modifier.gridItem(3, 2)
        )
    }
}