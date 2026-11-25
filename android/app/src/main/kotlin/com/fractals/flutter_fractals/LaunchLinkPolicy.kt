package com.trebuchetdynamics.fractal.forge

import android.content.Intent

/**
 * Decides whether the intent that created the activity is a fresh link launch.
 *
 * Android redelivers the original (or last `setIntent`) intent when it
 * recreates the activity after process death, and when the user reopens the
 * task from Recents. Treating that replay as a new link would replace the
 * restored viewer session with a stale view, so only a fresh launch counts.
 */
internal object LaunchLinkPolicy {
    fun initialLink(
        dataString: String?,
        isRecreated: Boolean,
        intentFlags: Int,
    ): String? {
        if (isRecreated) return null
        if (intentFlags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        return dataString
    }
}
