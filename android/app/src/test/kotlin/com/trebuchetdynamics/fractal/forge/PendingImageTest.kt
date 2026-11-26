package com.trebuchetdynamics.fractal.forge

import java.io.IOException
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Assert.assertThrows
import org.junit.Test

class PendingImageTest {
    @Test
    fun writeFailureDeletesPendingEntryAndPropagatesTheError() {
        val writeFailure = IOException("disk full")
        var deletes = 0

        val thrown = assertThrows(IOException::class.java) {
            writePendingImage(delete = { deletes++ }) { throw writeFailure }
        }

        assertSame(writeFailure, thrown)
        assertEquals(1, deletes)
    }

    @Test
    fun successfulPublishDoesNotDeleteTheEntry() {
        val operations = mutableListOf<String>()
        writePendingImage(delete = { operations.add("delete") }) {
            operations.add("write and publish")
            1
        }
        assertEquals(listOf("write and publish"), operations)
    }

    @Test
    fun publishWithoutAnUpdatedRowReportsFailureAndAttemptsCleanup() {
        var deletes = 0
        assertThrows(IOException::class.java) {
            writePendingImage(delete = { deletes++ }) { 0 }
        }
        assertEquals(1, deletes)
    }

    @Test
    fun cleanupFailureDoesNotMaskTheOriginalWriteFailure() {
        val writeFailure = IOException("disk full")
        val thrown = assertThrows(IOException::class.java) {
            writePendingImage(delete = { throw SecurityException("cleanup denied") }) {
                throw writeFailure
            }
        }
        assertSame(writeFailure, thrown)
    }
}
