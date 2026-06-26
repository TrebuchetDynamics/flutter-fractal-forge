package com.trebuchetdynamics.fractal.forge

import android.app.WallpaperManager
import android.content.ContentValues
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterFragmentActivity() {
    private var deepLinkChannel: MethodChannel? = null
    private var initialLink: String? = null

    companion object {
        private const val DEVICE_CHANNEL = "fractalforge/device"
        private const val DEEPLINK_CHANNEL = "com.fractalforge/deeplink"
        private const val MEDIA_STORE_CHANNEL = "fractalforge/media_store"
        private const val WALLPAPER_CHANNEL = "com.fractalforge/wallpaper"
        private const val MEDIA_STORE_SUBDIR = "FractalForge"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.auto(Color.TRANSPARENT, Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        initialLink = intent?.dataString
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.dataString?.let { link ->
            deepLinkChannel?.invokeMethod("onDeepLink", link)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isEmulator" -> result.success(isEmulator())
                    else -> result.notImplemented()
                }
            }

        deepLinkChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEEPLINK_CHANNEL
        ).also { channel ->
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialLink" -> result.success(initialLink)
                    else -> result.notImplemented()
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIA_STORE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveImage" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val filename = call.argument<String>("filename")
                        val mimeType = call.argument<String>("mimeType")
                            ?: inferImageMimeType(filename ?: "")

                        if (bytes == null || filename.isNullOrBlank()) {
                            result.error(
                                "invalid_args",
                                "bytes and filename are required",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        saveImageToMediaStore(bytes, filename, mimeType, result)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WALLPAPER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        val target = call.argument<String>("target") ?: "home"
                        if (bytes == null) {
                            result.error("invalid_args", "bytes are required", null)
                            return@setMethodCallHandler
                        }
                        setDeviceWallpaper(bytes, target, result)
                    }

                    "saveToPhotos" -> {
                        val bytes = call.argument<ByteArray>("bytes")
                        if (bytes == null) {
                            result.error("invalid_args", "bytes are required", null)
                            return@setMethodCallHandler
                        }
                        saveBytesToPhotos(bytes, result)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun setDeviceWallpaper(
        bytes: ByteArray,
        target: String,
        result: MethodChannel.Result,
    ) {
        Thread {
            try {
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                    ?: throw IOException("Failed to decode wallpaper bitmap")
                val manager = WallpaperManager.getInstance(applicationContext)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    val which = when (target) {
                        "lock" -> WallpaperManager.FLAG_LOCK
                        "both" -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                        else -> WallpaperManager.FLAG_SYSTEM // "home"
                    }
                    manager.setBitmap(bitmap, null, true, which)
                } else {
                    // Pre-N: only the system (home) wallpaper, no per-target flags.
                    manager.setBitmap(bitmap)
                }
                bitmap.recycle()
                runOnUiThread { result.success(true) }
            } catch (t: Throwable) {
                runOnUiThread {
                    result.error(
                        "set_wallpaper_failed",
                        t.message ?: "Failed to set wallpaper",
                        null
                    )
                }
            }
        }.start()
    }

    private fun saveBytesToPhotos(bytes: ByteArray, result: MethodChannel.Result) {
        Thread {
            try {
                val filename = "fractal_wallpaper_${System.currentTimeMillis()}.png"
                persistImageToMediaStore(bytes, filename, "image/png")
                runOnUiThread { result.success(true) }
            } catch (t: Throwable) {
                runOnUiThread { result.success(false) }
            }
        }.start()
    }

    private fun isEmulator(): Boolean {
        val fingerprint = Build.FINGERPRINT ?: ""
        val model = Build.MODEL ?: ""
        val manufacturer = Build.MANUFACTURER ?: ""
        val brand = Build.BRAND ?: ""
        val device = Build.DEVICE ?: ""
        val product = Build.PRODUCT ?: ""

        return fingerprint.startsWith("generic") ||
            fingerprint.contains("emulator", ignoreCase = true) ||
            fingerprint.contains("sdk_gphone", ignoreCase = true) ||
            model.contains("google_sdk", ignoreCase = true) ||
            model.contains("Emulator", ignoreCase = true) ||
            model.contains("Android SDK built for", ignoreCase = true) ||
            manufacturer.contains("Genymotion", ignoreCase = true) ||
            (brand.startsWith("generic") && device.startsWith("generic")) ||
            product.contains("sdk_gphone", ignoreCase = true) ||
            product.contains("emulator", ignoreCase = true)
    }

    private fun saveImageToMediaStore(
        bytes: ByteArray,
        filename: String,
        mimeType: String,
        result: MethodChannel.Result,
    ) {
        Thread {
            try {
                val savedRef = persistImageToMediaStore(bytes, filename, mimeType)
                runOnUiThread { result.success(savedRef) }
            } catch (t: Throwable) {
                runOnUiThread {
                    result.error(
                        "media_store_save_failed",
                        t.message ?: "Failed to save image to MediaStore",
                        null
                    )
                }
            }
        }.start()
    }

    /** Writes [bytes] into MediaStore (Pictures/FractalForge) and returns the
     *  saved reference (content URI on Q+, absolute path on legacy). Throws on
     *  failure. Must be called off the main thread. */
    private fun persistImageToMediaStore(
        bytes: ByteArray,
        filename: String,
        mimeType: String,
    ): String {
        val resolver = applicationContext.contentResolver
        val safeName = filename.replace("/", "_").replace("\\", "_")

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val relativePath = "${Environment.DIRECTORY_PICTURES}/$MEDIA_STORE_SUBDIR"
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, safeName)
                put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                put(MediaStore.Images.Media.RELATIVE_PATH, relativePath)
                put(MediaStore.Images.Media.ORIENTATION, 0)
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }

            val collection = MediaStore.Images.Media.getContentUri(
                MediaStore.VOLUME_EXTERNAL_PRIMARY
            )
            val uri = resolver.insert(collection, values)
                ?: throw IOException("Failed to create MediaStore record")

            resolver.openOutputStream(uri)?.use { stream ->
                stream.write(bytes)
                stream.flush()
            } ?: throw IOException("Failed to open output stream for MediaStore URI")

            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            uri.toString()
        } else {
            // Legacy fallback (API < 29): write to public Pictures and trigger scan.
            val picturesDir = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES
            )
            val targetDir = File(picturesDir, MEDIA_STORE_SUBDIR)
            if (!targetDir.exists() && !targetDir.mkdirs()) {
                throw IOException("Failed to create ${targetDir.absolutePath}")
            }
            val file = File(targetDir, safeName)
            FileOutputStream(file).use { out ->
                out.write(bytes)
                out.flush()
            }
            MediaScannerConnection.scanFile(
                applicationContext,
                arrayOf(file.absolutePath),
                arrayOf(mimeType),
                null
            )
            file.absolutePath
        }
    }

    private fun inferImageMimeType(filename: String): String {
        return when (filename.substringAfterLast('.', "").lowercase()) {
            "jpg", "jpeg" -> "image/jpeg"
            "webp" -> "image/webp"
            else -> "image/png"
        }
    }
}
