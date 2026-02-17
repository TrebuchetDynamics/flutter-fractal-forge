package com.fractalforge.vulkan

import android.content.res.AssetManager
import android.os.Bundle
import android.view.Surface
import android.view.SurfaceHolder
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.fractalforge.vulkan.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity(), SurfaceHolder.Callback {

    private lateinit var binding: ActivityMainBinding
    private var surfaceReady = false
    private var currentFractal = 0

    companion object {
        init {
            System.loadLibrary("fractal_engine")
        }
    }

    private external fun nativeInit(surface: Surface, assetManager: AssetManager, width: Int, height: Int): Boolean
    private external fun nativeDestroy()
    private external fun nativeResize(width: Int, height: Int)
    private external fun nativeSetFractalType(type: Int)
    private external fun nativeRender()
    private external fun nativeGetDeviceInfo(): String

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.surfaceView.holder.addCallback(this)

        binding.btnMandelbrot.setOnClickListener {
            currentFractal = 0
            if (surfaceReady) {
                nativeSetFractalType(0)
                nativeRender()
            }
        }

        binding.btnMandelbulb.setOnClickListener {
            currentFractal = 1
            if (surfaceReady) {
                nativeSetFractalType(1)
                nativeRender()
            }
        }
    }

    override fun surfaceCreated(holder: SurfaceHolder) {
        // Wait for surfaceChanged which provides final dimensions
    }

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        if (!surfaceReady) {
            val success = nativeInit(holder.surface, assets, width, height)
            if (!success) {
                showError(getString(R.string.error_no_vulkan))
                return
            }
            surfaceReady = true
        } else {
            nativeResize(width, height)
        }
        nativeSetFractalType(currentFractal)
        nativeRender()
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        if (surfaceReady) {
            nativeDestroy()
            surfaceReady = false
        }
    }

    private fun showError(message: String) {
        binding.tvError.text = message
        binding.tvError.visibility = View.VISIBLE
        binding.surfaceView.visibility = View.GONE
        binding.controlsContainer.visibility = View.GONE
    }

    override fun onDestroy() {
        if (surfaceReady) {
            nativeDestroy()
            surfaceReady = false
        }
        super.onDestroy()
    }
}
