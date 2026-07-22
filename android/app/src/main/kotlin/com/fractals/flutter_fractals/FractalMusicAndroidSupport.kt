package com.trebuchetdynamics.fractal.forge

internal data class FractalMusicPcmWav(
    val sampleRate: Int,
    val channelCount: Int,
    val frameCount: Int,
    val pcm: ByteArray,
)

internal object FractalMusicWavParser {
    fun parse(bytes: ByteArray): FractalMusicPcmWav {
        require(bytes.size > WAV_HEADER_BYTES) { "WAV payload is empty" }
        require(hasAscii(bytes, 0, "RIFF") && hasAscii(bytes, 8, "WAVE")) {
            "Expected RIFF/WAVE bytes"
        }
        require(hasAscii(bytes, 12, "fmt ") && readLeInt(bytes, 16) == 16) {
            "Expected canonical PCM format chunk"
        }
        require(readLeShort(bytes, 20) == 1) { "Expected PCM WAV" }

        val channelCount = readLeShort(bytes, 22)
        require(channelCount == 1 || channelCount == 2) {
            "Expected mono or stereo WAV"
        }
        val sampleRate = readLeInt(bytes, 24)
        require(sampleRate in 8_000..48_000) { "Unsupported WAV sample rate" }
        require(readLeShort(bytes, 34) == 16) { "Expected 16-bit PCM WAV" }

        val blockAlign = channelCount * 2
        require(readLeShort(bytes, 32) == blockAlign) { "Invalid WAV block alignment" }
        require(readLeInt(bytes, 28) == sampleRate * blockAlign) {
            "Invalid WAV byte rate"
        }
        require(hasAscii(bytes, 36, "data")) { "Expected WAV data chunk" }

        val dataBytes = readLeInt(bytes, 40)
        require(dataBytes == bytes.size - WAV_HEADER_BYTES) {
            "Invalid WAV payload size"
        }
        require(readLeInt(bytes, 4) == bytes.size - 8) { "Invalid RIFF size" }
        require(dataBytes > 0 && dataBytes % blockAlign == 0) {
            "Invalid WAV frame data"
        }

        return FractalMusicPcmWav(
            sampleRate = sampleRate,
            channelCount = channelCount,
            frameCount = dataBytes / blockAlign,
            pcm = bytes.copyOfRange(WAV_HEADER_BYTES, bytes.size),
        )
    }

    private fun hasAscii(bytes: ByteArray, offset: Int, expected: String): Boolean =
        expected.indices.all { bytes[offset + it].toInt() and 0xff == expected[it].code }

    private fun readLeInt(bytes: ByteArray, offset: Int): Int =
        (bytes[offset].toInt() and 0xff) or
            ((bytes[offset + 1].toInt() and 0xff) shl 8) or
            ((bytes[offset + 2].toInt() and 0xff) shl 16) or
            ((bytes[offset + 3].toInt() and 0xff) shl 24)

    private fun readLeShort(bytes: ByteArray, offset: Int): Int =
        (bytes[offset].toInt() and 0xff) or
            ((bytes[offset + 1].toInt() and 0xff) shl 8)

    private const val WAV_HEADER_BYTES = 44
}

internal class FractalMusicPlaybackGeneration {
    private var generation = 0L

    @Synchronized
    fun begin(): Long = ++generation

    @Synchronized
    fun cancel() {
        generation++
    }

    @Synchronized
    fun isCurrent(request: Long): Boolean = request == generation
}
