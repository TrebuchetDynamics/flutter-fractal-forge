#include <jni.h>
#include <android/native_window.h>
#include <android/native_window_jni.h>
#include <android/asset_manager.h>
#include <android/asset_manager_jni.h>
#include <android/log.h>
#include <mutex>
#include <string>

#include "vulkan_engine.h"

#define LOG_TAG "FractalJNI"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// H3: Mutex protecting g_engine against concurrent JNI calls from different threads
static std::mutex       g_engineMutex;
static VulkanEngine*    g_engine = nullptr;

// Maximum sane surface dimension (16K display)
static constexpr jint kMaxDim = 16384;

extern "C" {

JNIEXPORT jboolean JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeInit(
    JNIEnv* env, jobject /*thiz*/,
    jobject surface, jobject assetManager,
    jint width, jint height)
{
    // M1: Validate dimensions before casting to uint32_t
    if (width <= 0 || height <= 0 || width > kMaxDim || height > kMaxDim) {
        LOGE("Invalid surface dimensions: %dx%d", width, height);
        return JNI_FALSE;
    }

    ANativeWindow* window = ANativeWindow_fromSurface(env, surface);
    if (!window) {
        LOGE("Failed to get ANativeWindow from Surface");
        return JNI_FALSE;
    }

    AAssetManager* mgr = AAssetManager_fromJava(env, assetManager);
    if (!mgr) {
        LOGE("Failed to get AAssetManager from Java");
        ANativeWindow_release(window);
        return JNI_FALSE;
    }

    std::lock_guard<std::mutex> lock(g_engineMutex);

    if (g_engine) {
        g_engine->cleanup();
        delete g_engine;
        g_engine = nullptr;
    }

    g_engine = new VulkanEngine();
    if (!g_engine->init(window, mgr,
                        static_cast<uint32_t>(width),
                        static_cast<uint32_t>(height))) {
        LOGE("VulkanEngine::init() failed");
        delete g_engine;
        g_engine = nullptr;
        ANativeWindow_release(window);
        return JNI_FALSE;
    }

    LOGI("VulkanEngine initialized: %dx%d", width, height);
    return JNI_TRUE;
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeDestroy(
    JNIEnv* /*env*/, jobject /*thiz*/)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->cleanup();
        delete g_engine;
        g_engine = nullptr;
        LOGI("VulkanEngine destroyed");
    }
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeResize(
    JNIEnv* /*env*/, jobject /*thiz*/, jint width, jint height)
{
    // M1: Validate before casting
    if (width <= 0 || height <= 0 || width > kMaxDim || height > kMaxDim) {
        LOGE("Invalid resize dimensions: %dx%d", width, height);
        return;
    }
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->resize(static_cast<uint32_t>(width),
                         static_cast<uint32_t>(height));
    }
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeSetFractalType(
    JNIEnv* /*env*/, jobject /*thiz*/, jint type)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->setFractalType(static_cast<uint32_t>(type));
    }
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeRender(
    JNIEnv* /*env*/, jobject /*thiz*/)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->render();
    }
}

JNIEXPORT jstring JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeGetDeviceInfo(
    JNIEnv* env, jobject /*thiz*/)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        std::string info = g_engine->getDeviceInfo();
        return env->NewStringUTF(info.c_str());
    }
    return env->NewStringUTF("{}");
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeSetViewParams(
    JNIEnv* /*env*/, jobject /*thiz*/,
    jfloat cx, jfloat cy, jfloat zoom)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->setViewParams(cx, cy, zoom);
    }
}

JNIEXPORT void JNICALL
Java_com_fractalforge_vulkan_MainActivity_nativeSetMandelbulbViewParams(
    JNIEnv* /*env*/, jobject /*thiz*/,
    jfloat cx, jfloat cy, jfloat cz, jfloat zoom,
    jfloat rotX, jfloat rotY, jfloat rotZ)
{
    std::lock_guard<std::mutex> lock(g_engineMutex);
    if (g_engine) {
        g_engine->setMandelbulbViewParams(cx, cy, cz, zoom, rotX, rotY, rotZ);
    }
}

} // extern "C"
