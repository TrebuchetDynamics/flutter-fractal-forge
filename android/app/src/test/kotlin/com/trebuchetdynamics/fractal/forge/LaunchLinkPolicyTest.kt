package com.trebuchetdynamics.fractal.forge

import android.content.Intent
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class LaunchLinkPolicyTest {
    private val link = "https://fractalforge.app/view?type=mandelbrot&zoom=3"

    @Test
    fun freshLaunchReturnsTheLink() {
        assertEquals(link, LaunchLinkPolicy.initialLink(link, isRecreated = false, intentFlags = 0))
    }

    @Test
    fun recreatedActivityDoesNotReplayTheLink() {
        assertNull(LaunchLinkPolicy.initialLink(link, isRecreated = true, intentFlags = 0))
    }

    @Test
    fun launchFromRecentsDoesNotReplayTheLink() {
        assertNull(
            LaunchLinkPolicy.initialLink(
                link,
                isRecreated = false,
                intentFlags = Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY or Intent.FLAG_ACTIVITY_NEW_TASK,
            ),
        )
    }

    @Test
    fun launcherStartWithoutDataHasNoLink() {
        assertNull(LaunchLinkPolicy.initialLink(null, isRecreated = false, intentFlags = 0))
    }
}
