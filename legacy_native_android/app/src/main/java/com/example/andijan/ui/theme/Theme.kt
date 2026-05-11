package com.example.andijan.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme = darkColorScheme(
    primary = TerracottaDark,
    secondary = OliveDark,
    tertiary = EspressoLight,
    background = SandDark,
    surface = Color(0xFF2A211D),
    onPrimary = Color(0xFF31160A),
    onSecondary = Color(0xFF173223),
    onBackground = Color(0xFFF7EDE4),
    onSurface = Color(0xFFF7EDE4),
    onSurfaceVariant = Color(0xFFD8C2B5)
)

private val LightColorScheme = lightColorScheme(
    primary = Terracotta,
    secondary = Olive,
    tertiary = Espresso,
    background = Sand,
    surface = Color.White,
    onPrimary = Color.White,
    onSecondary = Color.White,
    onTertiary = Color.White,
    onBackground = Espresso,
    onSurface = Espresso,
    onSurfaceVariant = Color(0xFF7A6559)
)

@Composable
fun AndijanTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    // Dynamic color is available on Android 12+
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }

        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
