package com.fractals.flutter_fractals

import android.app.WallpaperManager
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fractalforge/deeplink"
    private val WALLPAPER_CHANNEL = "com.fractalforge/wallpaper"
    private var initialLink: String? = null
    private var methodChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Capture the initial link if the app was launched via deep link
        handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    result.success(initialLink)
                    // Clear it after it's been consumed
                    initialLink = null
                }
                else -> result.notImplemented()
            }
        }

        // Wallpaper channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WALLPAPER_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        try {
                            val bytes = call.argument<ByteArray>("bytes")
                            val target = call.argument<String>("target") ?: "home"
                            if (bytes == null) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            val bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                            if (bmp == null) {
                                result.success(false)
                                return@setMethodCallHandler
                            }

                            val wm = WallpaperManager.getInstance(applicationContext)
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                when (target) {
                                    "home" -> wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_SYSTEM)
                                    "lock" -> wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_LOCK)
                                    else -> {
                                        wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_SYSTEM)
                                        wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_LOCK)
                                    }
                                }
                            } else {
                                // Pre-N: only supports system wallpaper.
                                wm.setBitmap(bmp)
                            }

                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WALLPAPER_ERROR", e.message, null)
                        }
                    }
                    "saveToPhotos" -> {
                        // Not applicable on Android; return false so Dart can fallback.
                        result.success(false)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val action = intent?.action
        val data = intent?.data
        
        if (Intent.ACTION_VIEW == action && data != null) {
            val uriString = data.toString()
            
            if (methodChannel != null) {
                // App is already running, send the link immediately
                methodChannel?.invokeMethod("onDeepLink", uriString)
            } else {
                // App is starting, save for later retrieval
                initialLink = uriString
            }
        }
    }
}
