package com.fractalforge.vulkan

import android.content.res.AssetManager
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.view.Choreographer
import android.view.MotionEvent
import android.view.Surface
import android.view.SurfaceHolder
import android.view.VelocityTracker
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import com.fractalforge.vulkan.databinding.ActivityMainBinding
import kotlin.math.*

class MainActivity : AppCompatActivity(), SurfaceHolder.Callback, Choreographer.FrameCallback {

    private lateinit var binding: ActivityMainBinding
    private var surfaceReady = false
    private var currentFractal = 0   // 0 = Mandelbrot, 1 = Mandelbulb
    private var surfaceW = 0
    private var surfaceH = 0

    // ── Constants ─────────────────────────────────────────────────────────────
    companion object {
        init { System.loadLibrary("fractal_engine") }

        private const val ZOOM_MIN       = 1e-10f
        private const val ZOOM_MAX       = 1e10f
        private const val PAN_FRICTION   = 0.95f
        private const val ZOOM_FRICTION  = 0.92f
        private const val PAN_STOP_PX    = 0.1f      // px/frame stop threshold
        private const val ZOOM_STOP      = 0.0001f
        private const val FLING_MIN_PX_S = 300f      // 0.3 px/ms = 300 px/s
        private const val ZOOM_FLING_MIN = 0.01f     // log-scale / frame
        private const val TILT_MAX_RAD   = (67.5 * PI / 180.0).toFloat()
        private const val TILT_SENS      = 0.01f     // rad / pixel
        private const val BOUNDARY_STR   = 0.5f
        private const val PAN_BOUND      = 8f        // world-unit fling boundary
        private const val TWO_TAP_MS     = 220L
        private const val DOUBLE_TAP_MS  = 300L
        private const val TAP_SLOP       = 20f       // pixels
        private const val ANIM_FRAMES    = 12        // ≈200 ms @ 60 fps
    }

    // ── Native declarations ───────────────────────────────────────────────────
    private external fun nativeInit(s: Surface, am: AssetManager, w: Int, h: Int): Boolean
    private external fun nativeDestroy()
    private external fun nativeResize(w: Int, h: Int)
    private external fun nativeSetFractalType(t: Int)
    private external fun nativeRender()
    private external fun nativeGetDeviceInfo(): String
    private external fun nativeSetViewParams(cx: Float, cy: Float, zoom: Float)
    private external fun nativeSetMandelbulbViewParams(
        cx: Float, cy: Float, cz: Float, zoom: Float,
        rotX: Float, rotY: Float, rotZ: Float
    )

    // ── View state ────────────────────────────────────────────────────────────
    private var cx   = -0.5f; private var cy  = 0f; private var cz = 0f
    private var zoom = 1f
    private var rotX = 0f;    private var rotY = 0f; private var rotZ = 0f

    // ── Fling (pan in px/frame; zoom in log/frame) ────────────────────────────
    private var flingActive = false
    private var flingVxPx   = 0f
    private var flingVyPx   = 0f
    private var flingVzoom  = 0f

    // ── Animation (double-tap / two-finger tap) ───────────────────────────────
    private var animActive = false
    private var animFrame  = 0
    private var animSCx = 0f; private var animTCx = 0f
    private var animSCy = 0f; private var animTCy = 0f
    private var animSZ  = 0f; private var animTZ  = 0f

    // ── Touch tracking ────────────────────────────────────────────────────────
    private val ptrs = mutableMapOf<Int, FloatArray>()   // id -> [x, y]
    private var gMode = 0   // 0=idle  1=1-finger  2=2-finger
    private var p1id  = -1  // active pointer id in 1-finger mode

    // 1-finger previous position + drag-slop flag
    private var p1x = 0f; private var p1y = 0f
    private var dragSlopHit = false
    private var vt: VelocityTracker? = null

    // 2-finger previous midpoint / distance / angle + zoom velocity
    private var p2mx = 0f; private var p2my = 0f
    private var p2d  = 0f; private var p2a  = 0f
    private var zVel = 0f   // smoothed log(scale)/frame for zoom fling

    // Double-tap detection
    private var lastTapT = 0L; private var lastTapX = 0f; private var lastTapY = 0f

    // Two-finger-tap detection
    private var t2DownT = 0L; private var t2Mx0 = 0f; private var t2My0 = 0f

    // ── Lifecycle ─────────────────────────────────────────────────────────────
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.surfaceView.holder.addCallback(this)
        binding.surfaceView.setOnTouchListener         { _, e -> onSurfaceTouch(e); true }
        binding.surfaceView.setOnGenericMotionListener { _, e -> onScroll(e) }

        binding.btnMandelbrot.setOnClickListener { switchFractal(0) }
        binding.btnMandelbulb.setOnClickListener { switchFractal(1) }
    }

    private fun switchFractal(t: Int) {
        currentFractal = t
        cx = if (t == 0) -0.5f else 0f
        cy = 0f; cz = 0f; zoom = 1f; rotX = 0f; rotY = 0f; rotZ = 0f
        flingActive = false; animActive = false
        if (surfaceReady) {
            nativeSetFractalType(t)
            flushView()
            nativeRender()
        }
    }

    // ── SurfaceHolder.Callback ────────────────────────────────────────────────
    override fun surfaceCreated(holder: SurfaceHolder) {}

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, w: Int, h: Int) {
        surfaceW = w; surfaceH = h
        if (!surfaceReady) {
            if (!nativeInit(holder.surface, assets, w, h)) {
                showError(getString(R.string.error_no_vulkan)); return
            }
            surfaceReady = true
        } else {
            nativeResize(w, h)
        }
        nativeSetFractalType(currentFractal)
        flushView()
        nativeRender()
    }

    override fun surfaceDestroyed(holder: SurfaceHolder) {
        flingActive = false; animActive = false
        Choreographer.getInstance().removeFrameCallback(this)
        if (surfaceReady) { nativeDestroy(); surfaceReady = false }
    }

    // ── Choreographer frame loop ──────────────────────────────────────────────
    override fun doFrame(ns: Long) {
        if (!surfaceReady) return
        var dirty = false

        if (animActive) {
            animFrame = (animFrame + 1).coerceAtMost(ANIM_FRAMES)
            val t = smoothStep(animFrame / ANIM_FRAMES.toFloat())
            cx   = lerp(animSCx, animTCx, t)
            cy   = lerp(animSCy, animTCy, t)
            zoom = lerp(animSZ,  animTZ,  t)
            if (animFrame >= ANIM_FRAMES) animActive = false
            dirty = true
        }

        if (flingActive && !animActive) {
            val ws = worldScale()
            cx -= flingVxPx * ws
            cy -= flingVyPx * ws

            if (abs(flingVzoom) > ZOOM_STOP) {
                val newZoom = (zoom * exp(flingVzoom)).coerceIn(ZOOM_MIN, ZOOM_MAX)
                if (newZoom == ZOOM_MIN || newZoom == ZOOM_MAX) flingVzoom *= -BOUNDARY_STR
                zoom = newZoom
                flingVzoom *= ZOOM_FRICTION
            } else {
                flingVzoom = 0f
            }

            // Pan boundary bounce-back
            if (abs(cx) > PAN_BOUND) { cx = cx.coerceIn(-PAN_BOUND, PAN_BOUND); flingVxPx *= -BOUNDARY_STR }
            if (abs(cy) > PAN_BOUND) { cy = cy.coerceIn(-PAN_BOUND, PAN_BOUND); flingVyPx *= -BOUNDARY_STR }

            flingVxPx *= PAN_FRICTION
            flingVyPx *= PAN_FRICTION

            if (abs(flingVxPx) < PAN_STOP_PX && abs(flingVyPx) < PAN_STOP_PX
                    && abs(flingVzoom) < ZOOM_STOP) {
                flingActive = false
            }
            dirty = true
        }

        if (dirty) { flushView(); nativeRender() }
        if (animActive || flingActive) Choreographer.getInstance().postFrameCallback(this)
    }

    // ── Touch dispatcher ──────────────────────────────────────────────────────
    private fun onSurfaceTouch(e: MotionEvent) {
        when (e.actionMasked) {

            MotionEvent.ACTION_DOWN -> {
                flingActive = false; animActive = false
                vt?.recycle()
                vt = VelocityTracker.obtain()
                vt!!.addMovement(e)
                p1id = e.getPointerId(0)
                ptrs[p1id] = floatArrayOf(e.x, e.y)
                p1x = e.x; p1y = e.y
                dragSlopHit = false
                gMode = 1
            }

            MotionEvent.ACTION_POINTER_DOWN -> {
                vt?.addMovement(e)
                val idx = e.actionIndex
                val pid = e.getPointerId(idx)
                ptrs[pid] = floatArrayOf(e.getX(idx), e.getY(idx))
                if (ptrs.size == 2) {
                    gMode = 2
                    init2Finger()
                    t2DownT = System.currentTimeMillis()
                    val (mx, my) = midXY()
                    t2Mx0 = mx; t2My0 = my
                    zVel = 0f
                }
            }

            MotionEvent.ACTION_MOVE -> {
                vt?.addMovement(e)
                for (i in 0 until e.pointerCount) {
                    ptrs[e.getPointerId(i)] = floatArrayOf(e.getX(i), e.getY(i))
                }
                when (gMode) {
                    1 -> move1()
                    2 -> move2()
                }
                flushView(); nativeRender()
            }

            MotionEvent.ACTION_POINTER_UP -> {
                vt?.addMovement(e)
                if (ptrs.size == 2 && gMode == 2) {
                    // Snapshot midpoint before removal
                    val (mx, my) = midXY()
                    val elapsed  = System.currentTimeMillis() - t2DownT
                    val moveDist = hypot(mx - t2Mx0, my - t2My0)
                    when {
                        elapsed < TWO_TAP_MS && moveDist < TAP_SLOP -> onTwoFingerTap(mx, my)
                        !animActive && abs(zVel) >= ZOOM_FLING_MIN  -> {
                            flingVzoom = zVel
                            flingActive = true
                            Choreographer.getInstance().postFrameCallback(this)
                        }
                    }
                }
                ptrs.remove(e.getPointerId(e.actionIndex))
                if (ptrs.size == 1) {
                    gMode = 1
                    p1id  = ptrs.keys.first()
                    val p = ptrs[p1id]!!
                    p1x = p[0]; p1y = p[1]
                    dragSlopHit = false
                }
            }

            MotionEvent.ACTION_UP -> {
                vt?.addMovement(e)
                if (gMode == 1) onFingerUp(e.x, e.y)
                ptrs.clear(); gMode = 0
                vt?.recycle(); vt = null
            }

            MotionEvent.ACTION_CANCEL -> {
                ptrs.clear(); gMode = 0
                vt?.recycle(); vt = null
            }
        }
    }

    // ── 1-finger pan ──────────────────────────────────────────────────────────
    private fun move1() {
        val p = ptrs[p1id] ?: return
        val dx = p[0] - p1x
        val dy = p[1] - p1y
        if (hypot(dx, dy) > TAP_SLOP) dragSlopHit = true
        val ws = worldScale()
        cx -= dx * ws
        cy -= dy * ws
        cx = cx.coerceIn(-PAN_BOUND, PAN_BOUND)
        cy = cy.coerceIn(-PAN_BOUND, PAN_BOUND)
        p1x = p[0]; p1y = p[1]
    }

    // ── 2-finger: pan + pinch-zoom + rotate + tilt ───────────────────────────
    private fun move2() {
        if (ptrs.size < 2) return
        val (a, b) = two()
        val mx  = (a[0] + b[0]) * 0.5f
        val my  = (a[1] + b[1]) * 0.5f
        val d   = hypot(a[0] - b[0], a[1] - b[1])
        val ang = atan2(b[1] - a[1], b[0] - a[0])

        val dMx = mx - p2mx
        val dMy = my - p2my
        val sc  = if (p2d > 0f) d / p2d else 1f
        val dA  = angleDiff(ang, p2a)

        val ws = worldScale()

        // Pan / tilt
        if (currentFractal == 0) {
            cx -= dMx * ws
            cy -= dMy * ws
        } else {
            cx  -= dMx * ws
            rotX = (rotX + dMy * TILT_SENS).coerceIn(0f, TILT_MAX_RAD)
        }

        // Pinch-zoom with midpoint as focal point
        if (sc > 0f && sc != 1f) {
            val fwx = cx + (mx - surfaceW * 0.5f) * ws
            val fwy = cy + (my - surfaceH * 0.5f) * ws
            zoom = (zoom * sc).coerceIn(ZOOM_MIN, ZOOM_MAX)
            val nws = worldScale()
            cx = fwx - (mx - surfaceW * 0.5f) * nws
            cy = fwy - (my - surfaceH * 0.5f) * nws
            // Accumulate zoom velocity (EWMA of log scale)
            zVel = 0.7f * zVel + 0.3f * ln(sc)
        }

        // 2-finger rotation (Z axis)
        rotZ += dA

        cx = cx.coerceIn(-PAN_BOUND, PAN_BOUND)
        cy = cy.coerceIn(-PAN_BOUND, PAN_BOUND)
        p2mx = mx; p2my = my; p2d = d; p2a = ang
    }

    // ── Finger-up: double-tap detection + pan fling ───────────────────────────
    private fun onFingerUp(ux: Float, uy: Float) {
        val v = vt ?: return
        v.computeCurrentVelocity(1000)   // → px/s
        val vxS   = v.getXVelocity(p1id)
        val vyS   = v.getYVelocity(p1id)
        val speed = hypot(vxS, vyS)

        // Double-tap (only if finger barely moved)
        val now = System.currentTimeMillis()
        if (!dragSlopHit) {
            if (now - lastTapT < DOUBLE_TAP_MS &&
                hypot(ux - lastTapX, uy - lastTapY) < TAP_SLOP) {
                onDoubleTap(ux, uy)
                lastTapT = 0L
                return
            }
            lastTapT = now; lastTapX = ux; lastTapY = uy
        }

        // Pan fling
        if (speed >= FLING_MIN_PX_S) {
            flingVxPx   = vxS / 60f    // px/s → px/frame @ 60 fps
            flingVyPx   = vyS / 60f
            flingVzoom  = 0f
            flingActive = true
            Choreographer.getInstance().postFrameCallback(this)
        }
    }

    // ── Gesture actions ───────────────────────────────────────────────────────
    private fun onDoubleTap(tx: Float, ty: Float) {
        haptic()
        val ws          = worldScale()
        val twx         = cx + (tx - surfaceW * 0.5f) * ws
        val twy         = cy + (ty - surfaceH * 0.5f) * ws
        val targetZoom  = (zoom * 2f).coerceIn(ZOOM_MIN, ZOOM_MAX)
        val nws         = 2f / (surfaceH.toFloat() * targetZoom)
        startAnim(
            twx - (tx - surfaceW * 0.5f) * nws,
            twy - (ty - surfaceH * 0.5f) * nws,
            targetZoom
        )
    }

    private fun onTwoFingerTap(mx: Float, my: Float) {
        haptic()
        val ws         = worldScale()
        val mwx        = cx + (mx - surfaceW * 0.5f) * ws
        val mwy        = cy + (my - surfaceH * 0.5f) * ws
        val targetZoom = (zoom * 0.5f).coerceIn(ZOOM_MIN, ZOOM_MAX)
        val nws        = 2f / (surfaceH.toFloat() * targetZoom)
        startAnim(
            mwx - (mx - surfaceW * 0.5f) * nws,
            mwy - (my - surfaceH * 0.5f) * nws,
            targetZoom
        )
    }

    private fun startAnim(tcx: Float, tcy: Float, tz: Float) {
        animSCx = cx;   animTCx = tcx
        animSCy = cy;   animTCy = tcy
        animSZ  = zoom; animTZ  = tz
        animFrame   = 0
        animActive  = true
        flingActive = false
        Choreographer.getInstance().postFrameCallback(this)
    }

    // ── Mouse / trackpad wheel zoom ───────────────────────────────────────────
    private fun onScroll(e: MotionEvent): Boolean {
        if (e.actionMasked != MotionEvent.ACTION_SCROLL) return false
        val deltaY = e.getAxisValue(MotionEvent.AXIS_VSCROLL)
        val ws     = worldScale()
        val fwx    = cx + (e.x - surfaceW * 0.5f) * ws
        val fwy    = cy + (e.y - surfaceH * 0.5f) * ws
        zoom = (zoom * exp(-deltaY * 0.001f)).coerceIn(ZOOM_MIN, ZOOM_MAX)
        val nws = worldScale()
        cx = fwx - (e.x - surfaceW * 0.5f) * nws
        cy = fwy - (e.y - surfaceH * 0.5f) * nws
        if (surfaceReady) { flushView(); nativeRender() }
        return true
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    /** World units per screen pixel at current zoom. */
    private fun worldScale() = 2f / ((if (surfaceH > 0) surfaceH else 1).toFloat() * zoom)

    private fun flushView() {
        if (!surfaceReady) return
        if (currentFractal == 0)
            nativeSetViewParams(cx, cy, zoom)
        else
            nativeSetMandelbulbViewParams(cx, cy, cz, zoom, rotX, rotY, rotZ)
    }

    private fun init2Finger() {
        val (a, b) = two()
        p2mx = (a[0] + b[0]) * 0.5f
        p2my = (a[1] + b[1]) * 0.5f
        p2d  = hypot(a[0] - b[0], a[1] - b[1])
        p2a  = atan2(b[1] - a[1], b[0] - a[0])
    }

    private fun two(): Pair<FloatArray, FloatArray> {
        val vs = ptrs.values.toList(); return Pair(vs[0], vs[1])
    }

    private fun midXY(): Pair<Float, Float> {
        return if (ptrs.size >= 2) {
            val (a, b) = two()
            Pair((a[0] + b[0]) * 0.5f, (a[1] + b[1]) * 0.5f)
        } else {
            val p = ptrs.values.firstOrNull()
            Pair(p?.get(0) ?: 0f, p?.get(1) ?: 0f)
        }
    }

    private fun angleDiff(new: Float, old: Float): Float {
        var d = new - old
        while (d >  PI.toFloat()) d -= (2 * PI).toFloat()
        while (d < -PI.toFloat()) d += (2 * PI).toFloat()
        return d
    }

    private fun lerp(a: Float, b: Float, t: Float) = a + (b - a) * t

    private fun smoothStep(t: Float): Float {
        val c = t.coerceIn(0f, 1f)
        return c * c * (3f - 2f * c)
    }

    private fun haptic() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                getSystemService(VibratorManager::class.java)
                    ?.defaultVibrator
                    ?.vibrate(VibrationEffect.createOneShot(20, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Vibrator::class.java)?.vibrate(20)
            }
        } catch (_: Exception) {}
    }

    private fun showError(msg: String) {
        binding.tvError.text = msg
        binding.tvError.visibility = View.VISIBLE
        binding.surfaceView.visibility = View.GONE
        binding.controlsContainer.visibility = View.GONE
    }

    override fun onDestroy() {
        flingActive = false; animActive = false
        Choreographer.getInstance().removeFrameCallback(this)
        if (surfaceReady) { nativeDestroy(); surfaceReady = false }
        super.onDestroy()
    }
}
