package com.trebuchetdynamics.fractal.forge

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class FractalMusicAndroidSupportTest {
    @Test
    fun parsesCanonicalStereoPcm() {
        val wav = canonicalWav(channels = 2, sampleRate = 22_050, frames = 4)

        val parsed = FractalMusicWavParser.parse(wav)

        assertEquals(2, parsed.channelCount)
        assertEquals(22_050, parsed.sampleRate)
        assertEquals(4, parsed.frameCount)
        assertEquals(16, parsed.pcm.size)
    }

    @Test
    fun rejectsMalformedPcmMetadata() {
        val notWave = canonicalWav().also { writeAscii(it, 8, "NOPE") }
        val invalidChannels = canonicalWav().also { writeLeShort(it, 22, 3) }
        val wrongPayloadSize = canonicalWav().also { writeLeInt(it, 40, 1) }

        assertThrows(IllegalArgumentException::class.java) {
            FractalMusicWavParser.parse(notWave)
        }
        assertThrows(IllegalArgumentException::class.java) {
            FractalMusicWavParser.parse(invalidChannels)
        }
        assertThrows(IllegalArgumentException::class.java) {
            FractalMusicWavParser.parse(wrongPayloadSize)
        }
    }

    @Test
    fun stopInvalidatesPendingPlayback() {
        val generation = FractalMusicPlaybackGeneration()
        val pending = generation.begin()

        generation.cancel()

        assertFalse(generation.isCurrent(pending))
    }

    @Test
    fun newestPlaybackInvalidatesOlderRequest() {
        val generation = FractalMusicPlaybackGeneration()
        val older = generation.begin()
        val newer = generation.begin()

        assertFalse(generation.isCurrent(older))
        assertTrue(generation.isCurrent(newer))
    }

    private fun canonicalWav(
        channels: Int = 2,
        sampleRate: Int = 22_050,
        frames: Int = 2,
    ): ByteArray {
        val blockAlign = channels * 2
        val dataBytes = frames * blockAlign
        return ByteArray(44 + dataBytes).also { bytes ->
            writeAscii(bytes, 0, "RIFF")
            writeLeInt(bytes, 4, 36 + dataBytes)
            writeAscii(bytes, 8, "WAVE")
            writeAscii(bytes, 12, "fmt ")
            writeLeInt(bytes, 16, 16)
            writeLeShort(bytes, 20, 1)
            writeLeShort(bytes, 22, channels)
            writeLeInt(bytes, 24, sampleRate)
            writeLeInt(bytes, 28, sampleRate * blockAlign)
            writeLeShort(bytes, 32, blockAlign)
            writeLeShort(bytes, 34, 16)
            writeAscii(bytes, 36, "data")
            writeLeInt(bytes, 40, dataBytes)
        }
    }

    private fun writeAscii(bytes: ByteArray, offset: Int, value: String) {
        value.forEachIndexed { index, char -> bytes[offset + index] = char.code.toByte() }
    }

    private fun writeLeInt(bytes: ByteArray, offset: Int, value: Int) {
        repeat(4) { index -> bytes[offset + index] = (value ushr (index * 8)).toByte() }
    }

    private fun writeLeShort(bytes: ByteArray, offset: Int, value: Int) {
        repeat(2) { index -> bytes[offset + index] = (value ushr (index * 8)).toByte() }
    }
}
