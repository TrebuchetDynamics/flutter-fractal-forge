#include "vulkan_engine.h"

#include <vulkan/vulkan.h>
#include <vulkan/vulkan_android.h>
#include <android/log.h>
#include <android/asset_manager.h>
#include <android/native_window.h>

#include <string>
#include <vector>
#include <cstring>
#include <cmath>
#include <algorithm>
#include <set>

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------
#define LOG_TAG "VulkanEngine"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO,  LOG_TAG, __VA_ARGS__)
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN,  LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)

// ---------------------------------------------------------------------------
// VK_CHECK — returns false on failure (use only in bool-returning methods)
// ---------------------------------------------------------------------------
#define VK_CHECK(result)                                                      \
    do {                                                                      \
        VkResult _r = (result);                                               \
        if (_r != VK_SUCCESS) {                                               \
            LOGE("Vulkan error %d at %s:%d", _r, __FILE__, __LINE__);         \
            return false;                                                     \
        }                                                                     \
    } while (0)

// ---------------------------------------------------------------------------
// Debug messenger (debug builds only)
// ---------------------------------------------------------------------------
#ifndef NDEBUG

static PFN_vkCreateDebugUtilsMessengerEXT  pfnCreateDebugUtilsMessenger  = nullptr;
static PFN_vkDestroyDebugUtilsMessengerEXT pfnDestroyDebugUtilsMessenger = nullptr;

static VKAPI_ATTR VkBool32 VKAPI_CALL debugCallback(
    VkDebugUtilsMessageSeverityFlagBitsEXT      severity,
    VkDebugUtilsMessageTypeFlagsEXT             /*types*/,
    const VkDebugUtilsMessengerCallbackDataEXT* callbackData,
    void*                                       /*userData*/)
{
    if (severity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT) {
        LOGE("Validation: %s", callbackData->pMessage);
    } else if (severity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) {
        LOGW("Validation: %s", callbackData->pMessage);
    } else if (severity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT) {
        LOGI("Validation: %s", callbackData->pMessage);
    } else {
        LOGD("Validation: %s", callbackData->pMessage);
    }
    return VK_FALSE;
}

#endif // !NDEBUG

// ===========================================================================
// init / cleanup
// ===========================================================================

bool VulkanEngine::init(ANativeWindow* window, AAssetManager* assets,
                        uint32_t width, uint32_t height)
{
    window_       = window;
    assetManager_ = assets;
    width_        = width;
    height_       = height;

    if (!createInstance())            return false;
    if (!createSurface())             return false;
    if (!selectPhysicalDevice())      return false;
    if (!createDevice())              return false;
    if (!createSwapchain())           return false;
    if (!createStorageImage())        return false;
    if (!createDescriptorResources()) return false;
    if (!createComputePipelines())    return false;
    if (!createCommandResources())    return false;
    if (!createSyncObjects())         return false;

    initialized_ = true;
    LOGI("VulkanEngine initialized successfully (%ux%u)", width_, height_);
    return true;
}

void VulkanEngine::cleanup()
{
    if (!initialized_) return;

    if (device_ != VK_NULL_HANDLE) {
        vkDeviceWaitIdle(device_);
    }

    destroySwapchain();
    destroyStorageImage();
    destroyComputeResources();

    if (commandPool_ != VK_NULL_HANDLE) {
        vkDestroyCommandPool(device_, commandPool_, nullptr);
        commandPool_ = VK_NULL_HANDLE;
        commandBuffer_ = VK_NULL_HANDLE;
    }

    if (fence_ != VK_NULL_HANDLE) {
        vkDestroyFence(device_, fence_, nullptr);
        fence_ = VK_NULL_HANDLE;
    }
    if (imageAvailableSemaphore_ != VK_NULL_HANDLE) {
        vkDestroySemaphore(device_, imageAvailableSemaphore_, nullptr);
        imageAvailableSemaphore_ = VK_NULL_HANDLE;
    }
    if (renderFinishedSemaphore_ != VK_NULL_HANDLE) {
        vkDestroySemaphore(device_, renderFinishedSemaphore_, nullptr);
        renderFinishedSemaphore_ = VK_NULL_HANDLE;
    }

    if (device_ != VK_NULL_HANDLE) {
        vkDestroyDevice(device_, nullptr);
        device_ = VK_NULL_HANDLE;
    }

    if (surface_ != VK_NULL_HANDLE) {
        vkDestroySurfaceKHR(instance_, surface_, nullptr);
        surface_ = VK_NULL_HANDLE;
    }

#ifndef NDEBUG
    if (debugMessenger_ != VK_NULL_HANDLE && pfnDestroyDebugUtilsMessenger) {
        pfnDestroyDebugUtilsMessenger(instance_, debugMessenger_, nullptr);
        debugMessenger_ = VK_NULL_HANDLE;
    }
#endif

    if (instance_ != VK_NULL_HANDLE) {
        vkDestroyInstance(instance_, nullptr);
        instance_ = VK_NULL_HANDLE;
    }

    if (window_ != nullptr) {
        ANativeWindow_release(window_);
        window_ = nullptr;
    }

    computeQueue_   = VK_NULL_HANDLE;
    graphicsQueue_  = VK_NULL_HANDLE;
    physicalDevice_ = VK_NULL_HANDLE;
    assetManager_   = nullptr;
    initialized_    = false;

    LOGI("VulkanEngine cleaned up");
}

// ===========================================================================
// createInstance
// ===========================================================================

bool VulkanEngine::createInstance()
{
    // ---- enumerate available layers ----
    uint32_t layerCount = 0;
    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);
    std::vector<VkLayerProperties> availableLayers(layerCount);
    if (layerCount > 0) {
        vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());
    }

    // ---- enumerate available extensions ----
    uint32_t extCount = 0;
    vkEnumerateInstanceExtensionProperties(nullptr, &extCount, nullptr);
    std::vector<VkExtensionProperties> availableExts(extCount);
    if (extCount > 0) {
        vkEnumerateInstanceExtensionProperties(nullptr, &extCount, availableExts.data());
    }

    // ---- build extension list ----
    std::vector<const char*> extensions = {
        VK_KHR_SURFACE_EXTENSION_NAME,
        VK_KHR_ANDROID_SURFACE_EXTENSION_NAME,
    };

    // ---- layers (debug only) ----
    std::vector<const char*> layers;

#ifndef NDEBUG
    // Check whether debug_utils extension is available
    bool hasDebugUtils = false;
    for (const auto& ext : availableExts) {
        if (strcmp(ext.extensionName, VK_EXT_DEBUG_UTILS_EXTENSION_NAME) == 0) {
            hasDebugUtils = true;
            break;
        }
    }
    if (hasDebugUtils) {
        extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    }

    // Check whether validation layer is available
    bool hasValidation = false;
    for (const auto& layer : availableLayers) {
        if (strcmp(layer.layerName, "VK_LAYER_KHRONOS_validation") == 0) {
            hasValidation = true;
            break;
        }
    }
    if (hasValidation) {
        layers.push_back("VK_LAYER_KHRONOS_validation");
        LOGI("Validation layer enabled");
    } else {
        LOGW("Validation layer not available");
    }
#endif

    // ---- application info ----
    VkApplicationInfo appInfo = {};
    appInfo.sType              = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName   = "FractalForge";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName        = "FractalEngine";
    appInfo.engineVersion      = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion         = VK_API_VERSION_1_1;

    // ---- create instance ----
    VkInstanceCreateInfo createInfo = {};
    createInfo.sType                   = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo        = &appInfo;
    createInfo.enabledExtensionCount   = static_cast<uint32_t>(extensions.size());
    createInfo.ppEnabledExtensionNames = extensions.data();
    createInfo.enabledLayerCount       = static_cast<uint32_t>(layers.size());
    createInfo.ppEnabledLayerNames     = layers.empty() ? nullptr : layers.data();

    VK_CHECK(vkCreateInstance(&createInfo, nullptr, &instance_));
    LOGI("Vulkan instance created");

    // ---- load debug messenger function pointers & create messenger ----
#ifndef NDEBUG
    pfnCreateDebugUtilsMessenger = reinterpret_cast<PFN_vkCreateDebugUtilsMessengerEXT>(
        vkGetInstanceProcAddr(instance_, "vkCreateDebugUtilsMessengerEXT"));
    pfnDestroyDebugUtilsMessenger = reinterpret_cast<PFN_vkDestroyDebugUtilsMessengerEXT>(
        vkGetInstanceProcAddr(instance_, "vkDestroyDebugUtilsMessengerEXT"));

    if (pfnCreateDebugUtilsMessenger && hasDebugUtils) {
        VkDebugUtilsMessengerCreateInfoEXT dbgInfo = {};
        dbgInfo.sType           = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
        dbgInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT
                                | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT
                                | VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT;
        dbgInfo.messageType     = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT
                                | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT
                                | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
        dbgInfo.pfnUserCallback = debugCallback;

        VkResult dbgResult = pfnCreateDebugUtilsMessenger(instance_, &dbgInfo, nullptr,
                                                          &debugMessenger_);
        if (dbgResult == VK_SUCCESS) {
            LOGI("Debug messenger created");
        } else {
            LOGW("Failed to create debug messenger: %d", dbgResult);
        }
    }
#endif

    return true;
}

// ===========================================================================
// createSurface
// ===========================================================================

bool VulkanEngine::createSurface()
{
    VkAndroidSurfaceCreateInfoKHR surfaceInfo = {};
    surfaceInfo.sType  = VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR;
    surfaceInfo.window = window_;

    VK_CHECK(vkCreateAndroidSurfaceKHR(instance_, &surfaceInfo, nullptr, &surface_));
    LOGI("Android surface created");
    return true;
}

// ===========================================================================
// selectPhysicalDevice
// ===========================================================================

bool VulkanEngine::selectPhysicalDevice()
{
    uint32_t deviceCount = 0;
    VK_CHECK(vkEnumeratePhysicalDevices(instance_, &deviceCount, nullptr));

    if (deviceCount == 0) {
        LOGE("No Vulkan physical devices found");
        return false;
    }

    std::vector<VkPhysicalDevice> devices(deviceCount);
    VK_CHECK(vkEnumeratePhysicalDevices(instance_, &deviceCount, devices.data()));

    // Score devices: DISCRETE=4, INTEGRATED=3, VIRTUAL=2, CPU=1, OTHER=0
    auto deviceScore = [](VkPhysicalDeviceType type) -> int {
        switch (type) {
            case VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU:   return 4;
            case VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU: return 3;
            case VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU:    return 2;
            case VK_PHYSICAL_DEVICE_TYPE_CPU:            return 1;
            default:                                     return 0;
        }
    };

    int bestScore = -1;

    for (const auto& dev : devices) {
        // Check queue families
        uint32_t queueFamilyCount = 0;
        vkGetPhysicalDeviceQueueFamilyProperties(dev, &queueFamilyCount, nullptr);
        std::vector<VkQueueFamilyProperties> queueFamilies(queueFamilyCount);
        vkGetPhysicalDeviceQueueFamilyProperties(dev, &queueFamilyCount, queueFamilies.data());

        uint32_t computeFamily  = UINT32_MAX;
        uint32_t graphicsFamily = UINT32_MAX;

        for (uint32_t i = 0; i < queueFamilyCount; i++) {
            if ((queueFamilies[i].queueFlags & VK_QUEUE_COMPUTE_BIT) && computeFamily == UINT32_MAX) {
                computeFamily = i;
            }
            if ((queueFamilies[i].queueFlags & VK_QUEUE_GRAPHICS_BIT) && graphicsFamily == UINT32_MAX) {
                graphicsFamily = i;
            }
        }

        if (computeFamily == UINT32_MAX || graphicsFamily == UINT32_MAX) {
            continue; // skip devices lacking compute or graphics
        }

        VkPhysicalDeviceProperties props;
        vkGetPhysicalDeviceProperties(dev, &props);

        int score = deviceScore(props.deviceType);
        if (score > bestScore) {
            bestScore            = score;
            physicalDevice_      = dev;
            computeQueueFamily_  = computeFamily;
            graphicsQueueFamily_ = graphicsFamily;
            deviceProperties_    = props;
        }
    }

    if (physicalDevice_ == VK_NULL_HANDLE) {
        LOGE("No suitable physical device found");
        return false;
    }

    // Check fp64 support
    VkPhysicalDeviceFeatures features;
    vkGetPhysicalDeviceFeatures(physicalDevice_, &features);
    fp64Supported_ = (features.shaderFloat64 == VK_TRUE);

    LOGI("Selected device: %s", deviceProperties_.deviceName);
    LOGI("  Vulkan API: %u.%u.%u",
         VK_VERSION_MAJOR(deviceProperties_.apiVersion),
         VK_VERSION_MINOR(deviceProperties_.apiVersion),
         VK_VERSION_PATCH(deviceProperties_.apiVersion));
    LOGI("  FP64: %s", fp64Supported_ ? "supported" : "not supported");
    LOGI("  Compute queue family: %u, Graphics queue family: %u",
         computeQueueFamily_, graphicsQueueFamily_);

    return true;
}

// ===========================================================================
// createDevice
// ===========================================================================

bool VulkanEngine::createDevice()
{
    float queuePriority = 1.0f;

    // Build unique queue create infos (deduplicate if same family)
    std::set<uint32_t> uniqueFamilies = { computeQueueFamily_, graphicsQueueFamily_ };
    std::vector<VkDeviceQueueCreateInfo> queueCreateInfos;

    for (uint32_t family : uniqueFamilies) {
        VkDeviceQueueCreateInfo queueInfo = {};
        queueInfo.sType            = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queueInfo.queueFamilyIndex = family;
        queueInfo.queueCount       = 1;
        queueInfo.pQueuePriorities = &queuePriority;
        queueCreateInfos.push_back(queueInfo);
    }

    // Device extensions
    const char* deviceExtensions[] = {
        VK_KHR_SWAPCHAIN_EXTENSION_NAME,
    };

    VkPhysicalDeviceFeatures enabledFeatures = {};

    VkDeviceCreateInfo deviceInfo = {};
    deviceInfo.sType                   = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    deviceInfo.queueCreateInfoCount    = static_cast<uint32_t>(queueCreateInfos.size());
    deviceInfo.pQueueCreateInfos       = queueCreateInfos.data();
    deviceInfo.enabledExtensionCount   = 1;
    deviceInfo.ppEnabledExtensionNames = deviceExtensions;
    deviceInfo.pEnabledFeatures        = &enabledFeatures;

    VK_CHECK(vkCreateDevice(physicalDevice_, &deviceInfo, nullptr, &device_));

    vkGetDeviceQueue(device_, computeQueueFamily_,  0, &computeQueue_);
    vkGetDeviceQueue(device_, graphicsQueueFamily_, 0, &graphicsQueue_);

    LOGI("Logical device created");
    return true;
}

// ===========================================================================
// createSwapchain
// ===========================================================================

bool VulkanEngine::createSwapchain(VkSwapchainKHR oldSwapchain)
{
    // Surface capabilities
    VkSurfaceCapabilitiesKHR caps;
    VK_CHECK(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice_, surface_, &caps));

    // Surface formats — prefer R8G8B8A8_UNORM or B8G8R8A8_UNORM
    uint32_t formatCount = 0;
    VK_CHECK(vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice_, surface_, &formatCount, nullptr));
    std::vector<VkSurfaceFormatKHR> formats(formatCount);
    VK_CHECK(vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice_, surface_, &formatCount, formats.data()));

    VkSurfaceFormatKHR chosenFormat = formats[0]; // fallback
    for (const auto& fmt : formats) {
        if (fmt.format == VK_FORMAT_R8G8B8A8_UNORM || fmt.format == VK_FORMAT_B8G8R8A8_UNORM) {
            chosenFormat = fmt;
            break;
        }
    }
    swapchainFormat_ = chosenFormat.format;

    // Present mode — use FIFO (always available, v-synced)
    VkPresentModeKHR presentMode = VK_PRESENT_MODE_FIFO_KHR;

    // Extent
    if (caps.currentExtent.width != UINT32_MAX) {
        swapchainExtent_ = caps.currentExtent;
    } else {
        swapchainExtent_.width  = std::clamp(width_,  caps.minImageExtent.width,  caps.maxImageExtent.width);
        swapchainExtent_.height = std::clamp(height_, caps.minImageExtent.height, caps.maxImageExtent.height);
    }

    // Image count
    uint32_t imageCount = caps.minImageCount + 1;
    if (caps.maxImageCount > 0 && imageCount > caps.maxImageCount) {
        imageCount = caps.maxImageCount;
    }

    // Sharing mode
    VkSharingMode sharingMode;
    uint32_t queueFamilyIndices[2] = { computeQueueFamily_, graphicsQueueFamily_ };
    uint32_t queueFamilyIndexCount;

    if (computeQueueFamily_ == graphicsQueueFamily_) {
        sharingMode         = VK_SHARING_MODE_EXCLUSIVE;
        queueFamilyIndexCount = 0;
    } else {
        sharingMode         = VK_SHARING_MODE_CONCURRENT;
        queueFamilyIndexCount = 2;
    }

    // Pre-transform
    VkSurfaceTransformFlagBitsKHR preTransform = caps.currentTransform;

    VkSwapchainCreateInfoKHR swapInfo = {};
    swapInfo.sType                 = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
    swapInfo.surface               = surface_;
    swapInfo.minImageCount         = imageCount;
    swapInfo.imageFormat           = chosenFormat.format;
    swapInfo.imageColorSpace       = chosenFormat.colorSpace;
    swapInfo.imageExtent           = swapchainExtent_;
    swapInfo.imageArrayLayers      = 1;
    swapInfo.imageUsage            = VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;
    swapInfo.imageSharingMode      = sharingMode;
    swapInfo.queueFamilyIndexCount = queueFamilyIndexCount;
    swapInfo.pQueueFamilyIndices   = (queueFamilyIndexCount > 0) ? queueFamilyIndices : nullptr;
    swapInfo.preTransform          = preTransform;
    swapInfo.compositeAlpha        = VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR;
    swapInfo.presentMode           = presentMode;
    swapInfo.clipped               = VK_TRUE;
    swapInfo.oldSwapchain          = oldSwapchain;

    VK_CHECK(vkCreateSwapchainKHR(device_, &swapInfo, nullptr, &swapchain_));

    // Destroy old swapchain if provided
    if (oldSwapchain != VK_NULL_HANDLE) {
        vkDestroySwapchainKHR(device_, oldSwapchain, nullptr);
    }

    // Get swapchain images
    uint32_t swapImageCount = 0;
    VK_CHECK(vkGetSwapchainImagesKHR(device_, swapchain_, &swapImageCount, nullptr));
    swapchainImages_.resize(swapImageCount);
    VK_CHECK(vkGetSwapchainImagesKHR(device_, swapchain_, &swapImageCount, swapchainImages_.data()));

    // Create image views
    swapchainImageViews_.resize(swapImageCount);
    for (uint32_t i = 0; i < swapImageCount; i++) {
        VkImageViewCreateInfo viewInfo = {};
        viewInfo.sType                           = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
        viewInfo.image                           = swapchainImages_[i];
        viewInfo.viewType                        = VK_IMAGE_VIEW_TYPE_2D;
        viewInfo.format                          = swapchainFormat_;
        viewInfo.components.r                    = VK_COMPONENT_SWIZZLE_IDENTITY;
        viewInfo.components.g                    = VK_COMPONENT_SWIZZLE_IDENTITY;
        viewInfo.components.b                    = VK_COMPONENT_SWIZZLE_IDENTITY;
        viewInfo.components.a                    = VK_COMPONENT_SWIZZLE_IDENTITY;
        viewInfo.subresourceRange.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
        viewInfo.subresourceRange.baseMipLevel   = 0;
        viewInfo.subresourceRange.levelCount     = 1;
        viewInfo.subresourceRange.baseArrayLayer = 0;
        viewInfo.subresourceRange.layerCount     = 1;

        VK_CHECK(vkCreateImageView(device_, &viewInfo, nullptr, &swapchainImageViews_[i]));
    }

    LOGI("Swapchain created: %ux%u, %u images, format %d",
         swapchainExtent_.width, swapchainExtent_.height, swapImageCount, swapchainFormat_);
    return true;
}

// ===========================================================================
// createStorageImage
// ===========================================================================

bool VulkanEngine::createStorageImage()
{
    VkImageCreateInfo imageInfo = {};
    imageInfo.sType         = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO;
    imageInfo.imageType     = VK_IMAGE_TYPE_2D;
    imageInfo.format        = VK_FORMAT_R8G8B8A8_UNORM;
    imageInfo.extent.width  = width_;
    imageInfo.extent.height = height_;
    imageInfo.extent.depth  = 1;
    imageInfo.mipLevels     = 1;
    imageInfo.arrayLayers   = 1;
    imageInfo.samples       = VK_SAMPLE_COUNT_1_BIT;
    imageInfo.tiling        = VK_IMAGE_TILING_OPTIMAL;
    imageInfo.usage         = VK_IMAGE_USAGE_STORAGE_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT;
    imageInfo.sharingMode   = VK_SHARING_MODE_EXCLUSIVE;
    imageInfo.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;

    VK_CHECK(vkCreateImage(device_, &imageInfo, nullptr, &storageImage_));

    // Allocate memory
    VkMemoryRequirements memReqs;
    vkGetImageMemoryRequirements(device_, storageImage_, &memReqs);

    uint32_t memTypeIndex = findMemoryType(memReqs.memoryTypeBits,
                                           VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    if (memTypeIndex == UINT32_MAX) {
        LOGE("Failed to find suitable memory type for storage image");
        return false;
    }

    VkMemoryAllocateInfo allocInfo = {};
    allocInfo.sType           = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO;
    allocInfo.allocationSize  = memReqs.size;
    allocInfo.memoryTypeIndex = memTypeIndex;

    VK_CHECK(vkAllocateMemory(device_, &allocInfo, nullptr, &storageImageMemory_));
    VK_CHECK(vkBindImageMemory(device_, storageImage_, storageImageMemory_, 0));

    // Create image view
    VkImageViewCreateInfo viewInfo = {};
    viewInfo.sType                           = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
    viewInfo.image                           = storageImage_;
    viewInfo.viewType                        = VK_IMAGE_VIEW_TYPE_2D;
    viewInfo.format                          = VK_FORMAT_R8G8B8A8_UNORM;
    viewInfo.subresourceRange.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
    viewInfo.subresourceRange.baseMipLevel   = 0;
    viewInfo.subresourceRange.levelCount     = 1;
    viewInfo.subresourceRange.baseArrayLayer = 0;
    viewInfo.subresourceRange.layerCount     = 1;

    VK_CHECK(vkCreateImageView(device_, &viewInfo, nullptr, &storageImageView_));

    LOGI("Storage image created: %ux%u", width_, height_);
    return true;
}

// ===========================================================================
// createDescriptorResources
// ===========================================================================

bool VulkanEngine::createDescriptorResources()
{
    // Descriptor set layout
    VkDescriptorSetLayoutBinding binding = {};
    binding.binding            = 0;
    binding.descriptorType     = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    binding.descriptorCount    = 1;
    binding.stageFlags         = VK_SHADER_STAGE_COMPUTE_BIT;
    binding.pImmutableSamplers = nullptr;

    VkDescriptorSetLayoutCreateInfo layoutInfo = {};
    layoutInfo.sType        = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO;
    layoutInfo.bindingCount = 1;
    layoutInfo.pBindings    = &binding;

    VK_CHECK(vkCreateDescriptorSetLayout(device_, &layoutInfo, nullptr, &descriptorSetLayout_));

    // Descriptor pool
    VkDescriptorPoolSize poolSize = {};
    poolSize.type            = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    poolSize.descriptorCount = 1;

    VkDescriptorPoolCreateInfo poolInfo = {};
    poolInfo.sType         = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO;
    poolInfo.maxSets       = 1;
    poolInfo.poolSizeCount = 1;
    poolInfo.pPoolSizes    = &poolSize;

    VK_CHECK(vkCreateDescriptorPool(device_, &poolInfo, nullptr, &descriptorPool_));

    // Allocate descriptor set
    VkDescriptorSetAllocateInfo allocInfo = {};
    allocInfo.sType              = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO;
    allocInfo.descriptorPool     = descriptorPool_;
    allocInfo.descriptorSetCount = 1;
    allocInfo.pSetLayouts        = &descriptorSetLayout_;

    VK_CHECK(vkAllocateDescriptorSets(device_, &allocInfo, &descriptorSet_));

    // Update descriptor set with storage image
    VkDescriptorImageInfo imgInfo = {};
    imgInfo.sampler     = VK_NULL_HANDLE;
    imgInfo.imageView   = storageImageView_;
    imgInfo.imageLayout = VK_IMAGE_LAYOUT_GENERAL;

    VkWriteDescriptorSet write = {};
    write.sType           = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    write.dstSet          = descriptorSet_;
    write.dstBinding      = 0;
    write.dstArrayElement = 0;
    write.descriptorCount = 1;
    write.descriptorType  = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    write.pImageInfo      = &imgInfo;

    vkUpdateDescriptorSets(device_, 1, &write, 0, nullptr);

    LOGI("Descriptor resources created");
    return true;
}

// ===========================================================================
// loadShaderFromAsset
// ===========================================================================

VkShaderModule VulkanEngine::loadShaderFromAsset(const char* filename)
{
    AAsset* asset = AAssetManager_open(assetManager_, filename, AASSET_MODE_BUFFER);
    if (!asset) {
        LOGE("Failed to open shader asset: %s", filename);
        return VK_NULL_HANDLE;
    }

    size_t size = static_cast<size_t>(AAsset_getLength(asset));
    const void* data = AAsset_getBuffer(asset);

    if (!data || size == 0) {
        LOGE("Shader asset is empty: %s", filename);
        AAsset_close(asset);
        return VK_NULL_HANDLE;
    }

    // H1: SPIR-V size must be a non-zero multiple of 4 bytes (Vulkan spec)
    if ((size % 4) != 0) {
        LOGE("Shader %s has invalid SPIR-V size %zu (must be multiple of 4)", filename, size);
        AAsset_close(asset);
        return VK_NULL_HANDLE;
    }

    // Copy into an aligned buffer (uint32_t guarantees 4-byte alignment)
    std::vector<uint32_t> spirvCode(size / 4);
    std::memcpy(spirvCode.data(), data, size);
    AAsset_close(asset);

    VkShaderModuleCreateInfo moduleInfo = {};
    moduleInfo.sType    = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
    moduleInfo.codeSize = size;
    moduleInfo.pCode    = spirvCode.data();

    VkShaderModule module = VK_NULL_HANDLE;
    VkResult result = vkCreateShaderModule(device_, &moduleInfo, nullptr, &module);

    if (result != VK_SUCCESS) {
        LOGE("Failed to create shader module from %s: %d", filename, result);
        return VK_NULL_HANDLE;
    }

    LOGI("Loaded shader: %s (%zu bytes)", filename, size);
    return module;
}

// ===========================================================================
// createComputePipelines
// ===========================================================================

bool VulkanEngine::createComputePipelines()
{
    // Push constant range — size = max of both param structs = 64
    VkPushConstantRange pushRange = {};
    pushRange.stageFlags = VK_SHADER_STAGE_COMPUTE_BIT;
    pushRange.offset     = 0;
    pushRange.size       = static_cast<uint32_t>(
        std::max(sizeof(MandelbrotParams), sizeof(MandelbulbParams)));

    // Pipeline layout
    VkPipelineLayoutCreateInfo layoutInfo = {};
    layoutInfo.sType                  = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
    layoutInfo.setLayoutCount         = 1;
    layoutInfo.pSetLayouts            = &descriptorSetLayout_;
    layoutInfo.pushConstantRangeCount = 1;
    layoutInfo.pPushConstantRanges    = &pushRange;

    VK_CHECK(vkCreatePipelineLayout(device_, &layoutInfo, nullptr, &pipelineLayout_));

    // --- Mandelbrot pipeline ---
    {
        VkShaderModule module = loadShaderFromAsset("shaders/mandelbrot.comp.spv");
        if (module == VK_NULL_HANDLE) {
            LOGE("Failed to load mandelbrot shader");
            return false;
        }

        VkPipelineShaderStageCreateInfo stageInfo = {};
        stageInfo.sType  = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        stageInfo.stage  = VK_SHADER_STAGE_COMPUTE_BIT;
        stageInfo.module = module;
        stageInfo.pName  = "main";

        VkComputePipelineCreateInfo pipelineInfo = {};
        pipelineInfo.sType  = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;
        pipelineInfo.stage  = stageInfo;
        pipelineInfo.layout = pipelineLayout_;

        VkResult result = vkCreateComputePipelines(device_, VK_NULL_HANDLE, 1, &pipelineInfo,
                                                   nullptr, &mandelbrotPipeline_);
        vkDestroyShaderModule(device_, module, nullptr);

        if (result != VK_SUCCESS) {
            LOGE("Failed to create mandelbrot compute pipeline: %d", result);
            return false;
        }
    }

    // --- Mandelbulb pipeline ---
    {
        VkShaderModule module = loadShaderFromAsset("shaders/mandelbulb.comp.spv");
        if (module == VK_NULL_HANDLE) {
            LOGE("Failed to load mandelbulb shader");
            return false;
        }

        VkPipelineShaderStageCreateInfo stageInfo = {};
        stageInfo.sType  = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        stageInfo.stage  = VK_SHADER_STAGE_COMPUTE_BIT;
        stageInfo.module = module;
        stageInfo.pName  = "main";

        VkComputePipelineCreateInfo pipelineInfo = {};
        pipelineInfo.sType  = VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO;
        pipelineInfo.stage  = stageInfo;
        pipelineInfo.layout = pipelineLayout_;

        VkResult result = vkCreateComputePipelines(device_, VK_NULL_HANDLE, 1, &pipelineInfo,
                                                   nullptr, &mandelbulbPipeline_);
        vkDestroyShaderModule(device_, module, nullptr);

        if (result != VK_SUCCESS) {
            LOGE("Failed to create mandelbulb compute pipeline: %d", result);
            return false;
        }
    }

    LOGI("Compute pipelines created (push constant size: %u bytes)", pushRange.size);
    return true;
}

// ===========================================================================
// createCommandResources
// ===========================================================================

bool VulkanEngine::createCommandResources()
{
    VkCommandPoolCreateInfo poolInfo = {};
    poolInfo.sType            = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
    poolInfo.queueFamilyIndex = computeQueueFamily_;
    poolInfo.flags            = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT;

    VK_CHECK(vkCreateCommandPool(device_, &poolInfo, nullptr, &commandPool_));

    VkCommandBufferAllocateInfo allocInfo = {};
    allocInfo.sType              = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
    allocInfo.commandPool        = commandPool_;
    allocInfo.level              = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
    allocInfo.commandBufferCount = 1;

    VK_CHECK(vkAllocateCommandBuffers(device_, &allocInfo, &commandBuffer_));

    LOGI("Command resources created");
    return true;
}

// ===========================================================================
// createSyncObjects
// ===========================================================================

bool VulkanEngine::createSyncObjects()
{
    VkFenceCreateInfo fenceInfo = {};
    fenceInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
    fenceInfo.flags = VK_FENCE_CREATE_SIGNALED_BIT;

    VK_CHECK(vkCreateFence(device_, &fenceInfo, nullptr, &fence_));

    VkSemaphoreCreateInfo semInfo = {};
    semInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;

    VK_CHECK(vkCreateSemaphore(device_, &semInfo, nullptr, &imageAvailableSemaphore_));
    VK_CHECK(vkCreateSemaphore(device_, &semInfo, nullptr, &renderFinishedSemaphore_));

    LOGI("Sync objects created");
    return true;
}

// ===========================================================================
// cmdTransitionImage
// ===========================================================================

void VulkanEngine::cmdTransitionImage(VkCommandBuffer cmd, VkImage image,
                                      VkImageLayout oldLayout, VkImageLayout newLayout,
                                      VkAccessFlags srcAccess, VkAccessFlags dstAccess,
                                      VkPipelineStageFlags srcStage,
                                      VkPipelineStageFlags dstStage)
{
    VkImageMemoryBarrier barrier = {};
    barrier.sType                           = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER;
    barrier.oldLayout                       = oldLayout;
    barrier.newLayout                       = newLayout;
    barrier.srcAccessMask                   = srcAccess;
    barrier.dstAccessMask                   = dstAccess;
    barrier.srcQueueFamilyIndex             = VK_QUEUE_FAMILY_IGNORED;
    barrier.dstQueueFamilyIndex             = VK_QUEUE_FAMILY_IGNORED;
    barrier.image                           = image;
    barrier.subresourceRange.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
    barrier.subresourceRange.baseMipLevel   = 0;
    barrier.subresourceRange.levelCount     = 1;
    barrier.subresourceRange.baseArrayLayer = 0;
    barrier.subresourceRange.layerCount     = 1;

    vkCmdPipelineBarrier(cmd,
                         srcStage, dstStage,
                         0,
                         0, nullptr,
                         0, nullptr,
                         1, &barrier);
}

// ===========================================================================
// render
// ===========================================================================

void VulkanEngine::render()
{
    if (!initialized_) return;

    // 1. Wait for previous frame
    vkWaitForFences(device_, 1, &fence_, VK_TRUE, UINT64_MAX);
    vkResetFences(device_, 1, &fence_);

    // 2. Acquire next swapchain image
    uint32_t imageIndex = 0;
    VkResult acquireResult = vkAcquireNextImageKHR(device_, swapchain_, UINT64_MAX,
                                                   imageAvailableSemaphore_, VK_NULL_HANDLE,
                                                   &imageIndex);
    if (acquireResult == VK_ERROR_OUT_OF_DATE_KHR) {
        recreateSwapchain();
        return;
    }
    if (acquireResult != VK_SUCCESS && acquireResult != VK_SUBOPTIMAL_KHR) {
        LOGE("Failed to acquire swapchain image: %d", acquireResult);
        return;
    }

    // 3. Record command buffer
    vkResetCommandBuffer(commandBuffer_, 0);

    VkCommandBufferBeginInfo beginInfo = {};
    beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
    beginInfo.flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT;

    if (vkBeginCommandBuffer(commandBuffer_, &beginInfo) != VK_SUCCESS) {
        LOGE("Failed to begin command buffer");
        return;
    }

    // 4. Transition storage image: UNDEFINED -> GENERAL
    cmdTransitionImage(commandBuffer_, storageImage_,
                       VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_GENERAL,
                       0, VK_ACCESS_SHADER_WRITE_BIT,
                       VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT);

    // 5. Bind compute pipeline
    VkPipeline currentPipeline = (currentFractal_ == 0) ? mandelbrotPipeline_ : mandelbulbPipeline_;
    vkCmdBindPipeline(commandBuffer_, VK_PIPELINE_BIND_POINT_COMPUTE, currentPipeline);

    // 6. Bind descriptor set
    vkCmdBindDescriptorSets(commandBuffer_, VK_PIPELINE_BIND_POINT_COMPUTE,
                            pipelineLayout_, 0, 1, &descriptorSet_, 0, nullptr);

    // 7. Push constants
    float aspectRatio = static_cast<float>(width_) / static_cast<float>(height_);

    if (currentFractal_ == 0) {
        MandelbrotParams params = {};
        params.centerX     = viewCenterX_;
        params.centerY     = viewCenterY_;
        params.zoom        = viewZoom_;
        params.aspectRatio = aspectRatio;
        params.width       = width_;
        params.height      = height_;
        params.maxIter     = 256;
        params.bailout     = 4.0f;
        params.colorScheme = 0.0f;
        params.time        = time_;

        vkCmdPushConstants(commandBuffer_, pipelineLayout_,
                           VK_SHADER_STAGE_COMPUTE_BIT, 0,
                           sizeof(MandelbrotParams), &params);
    } else {
        MandelbulbParams params = {};
        params.centerX     = viewCenterX_;
        params.centerY     = viewCenterY_;
        params.centerZ     = viewCenterZ_;
        params.zoom        = viewZoom_;
        params.rotationX   = viewRotX_;
        params.rotationY   = viewRotY_;
        params.rotationZ   = viewRotZ_;
        params.power       = 8.0f;
        params.width       = width_;
        params.height      = height_;
        params.maxIter     = 20;
        params.maxSteps    = 100;
        params.bailout     = 2.0f;
        params.colorScheme = 0.0f;
        params.minDist     = 0.001f;
        params.time        = time_;

        vkCmdPushConstants(commandBuffer_, pipelineLayout_,
                           VK_SHADER_STAGE_COMPUTE_BIT, 0,
                           sizeof(MandelbulbParams), &params);
    }

    // 8. Dispatch compute
    uint32_t groupsX = (width_  + 15) / 16;
    uint32_t groupsY = (height_ + 15) / 16;
    vkCmdDispatch(commandBuffer_, groupsX, groupsY, 1);

    // 9. Transition storage image: GENERAL -> TRANSFER_SRC_OPTIMAL
    cmdTransitionImage(commandBuffer_, storageImage_,
                       VK_IMAGE_LAYOUT_GENERAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                       VK_ACCESS_SHADER_WRITE_BIT, VK_ACCESS_TRANSFER_READ_BIT,
                       VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);

    // 10. Transition swapchain image: UNDEFINED -> TRANSFER_DST_OPTIMAL
    cmdTransitionImage(commandBuffer_, swapchainImages_[imageIndex],
                       VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                       0, VK_ACCESS_TRANSFER_WRITE_BIT,
                       VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT);

    // 11. Blit storage image -> swapchain image
    VkImageBlit blitRegion = {};
    blitRegion.srcSubresource.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
    blitRegion.srcSubresource.mipLevel       = 0;
    blitRegion.srcSubresource.baseArrayLayer = 0;
    blitRegion.srcSubresource.layerCount     = 1;
    blitRegion.srcOffsets[0]                 = {0, 0, 0};
    blitRegion.srcOffsets[1]                 = {static_cast<int32_t>(width_),
                                                static_cast<int32_t>(height_), 1};

    blitRegion.dstSubresource.aspectMask     = VK_IMAGE_ASPECT_COLOR_BIT;
    blitRegion.dstSubresource.mipLevel       = 0;
    blitRegion.dstSubresource.baseArrayLayer = 0;
    blitRegion.dstSubresource.layerCount     = 1;
    blitRegion.dstOffsets[0]                 = {0, 0, 0};
    blitRegion.dstOffsets[1]                 = {static_cast<int32_t>(swapchainExtent_.width),
                                                static_cast<int32_t>(swapchainExtent_.height), 1};

    vkCmdBlitImage(commandBuffer_,
                   storageImage_,                    VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
                   swapchainImages_[imageIndex],     VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
                   1, &blitRegion,
                   VK_FILTER_NEAREST);

    // 12. Transition swapchain image: TRANSFER_DST -> PRESENT_SRC
    cmdTransitionImage(commandBuffer_, swapchainImages_[imageIndex],
                       VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
                       VK_ACCESS_TRANSFER_WRITE_BIT, 0,
                       VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT);

    // 13. End command buffer
    if (vkEndCommandBuffer(commandBuffer_) != VK_SUCCESS) {
        LOGE("Failed to end command buffer");
        return;
    }

    // 14. Submit
    VkPipelineStageFlags waitStage = VK_PIPELINE_STAGE_TRANSFER_BIT;

    VkSubmitInfo submitInfo = {};
    submitInfo.sType                = VK_STRUCTURE_TYPE_SUBMIT_INFO;
    submitInfo.waitSemaphoreCount   = 1;
    submitInfo.pWaitSemaphores      = &imageAvailableSemaphore_;
    submitInfo.pWaitDstStageMask    = &waitStage;
    submitInfo.commandBufferCount   = 1;
    submitInfo.pCommandBuffers      = &commandBuffer_;
    submitInfo.signalSemaphoreCount = 1;
    submitInfo.pSignalSemaphores    = &renderFinishedSemaphore_;

    if (vkQueueSubmit(computeQueue_, 1, &submitInfo, fence_) != VK_SUCCESS) {
        LOGE("Failed to submit command buffer");
        return;
    }

    // 15. Present
    VkPresentInfoKHR presentInfo = {};
    presentInfo.sType              = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;
    presentInfo.waitSemaphoreCount = 1;
    presentInfo.pWaitSemaphores    = &renderFinishedSemaphore_;
    presentInfo.swapchainCount     = 1;
    presentInfo.pSwapchains        = &swapchain_;
    presentInfo.pImageIndices      = &imageIndex;

    VkResult presentResult = vkQueuePresentKHR(graphicsQueue_, &presentInfo);
    if (presentResult == VK_ERROR_OUT_OF_DATE_KHR || presentResult == VK_SUBOPTIMAL_KHR) {
        recreateSwapchain();
    } else if (presentResult != VK_SUCCESS) {
        LOGE("Failed to present: %d", presentResult);
    }

    // 16. Advance time
    time_ += 1.0f;
}

// ===========================================================================
// recreateSwapchain
// ===========================================================================

bool VulkanEngine::recreateSwapchain()
{
    vkDeviceWaitIdle(device_);

    // Save old swapchain for retirement
    VkSwapchainKHR oldSwapchain = swapchain_;
    swapchain_ = VK_NULL_HANDLE;

    // Destroy image views only (images owned by swapchain, old swapchain destroyed in createSwapchain)
    for (auto view : swapchainImageViews_) {
        vkDestroyImageView(device_, view, nullptr);
    }
    swapchainImageViews_.clear();
    swapchainImages_.clear();

    destroyStorageImage();

    if (!createSwapchain(oldSwapchain)) {
        LOGE("Failed to recreate swapchain");
        return false;
    }

    if (!createStorageImage()) {
        LOGE("Failed to recreate storage image");
        return false;
    }

    // Re-update descriptor set to point at new storage image view
    VkDescriptorImageInfo imgInfo = {};
    imgInfo.sampler     = VK_NULL_HANDLE;
    imgInfo.imageView   = storageImageView_;
    imgInfo.imageLayout = VK_IMAGE_LAYOUT_GENERAL;

    VkWriteDescriptorSet write = {};
    write.sType           = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET;
    write.dstSet          = descriptorSet_;
    write.dstBinding      = 0;
    write.dstArrayElement = 0;
    write.descriptorCount = 1;
    write.descriptorType  = VK_DESCRIPTOR_TYPE_STORAGE_IMAGE;
    write.pImageInfo      = &imgInfo;

    vkUpdateDescriptorSets(device_, 1, &write, 0, nullptr);

    LOGI("Swapchain recreated: %ux%u", swapchainExtent_.width, swapchainExtent_.height);
    return true;
}

// ===========================================================================
// resize
// ===========================================================================

void VulkanEngine::resize(uint32_t width, uint32_t height)
{
    if (!initialized_) return;
    if (width == 0 || height == 0) return;

    width_  = width;
    height_ = height;
    recreateSwapchain();
}

// ===========================================================================
// setFractalType
// ===========================================================================

void VulkanEngine::setFractalType(uint32_t type)
{
    currentFractal_ = type;
}

void VulkanEngine::setViewParams(float cx, float cy, float zoom)
{
    viewCenterX_ = cx;
    viewCenterY_ = cy;
    viewZoom_    = zoom;
}

void VulkanEngine::setMandelbulbViewParams(float cx, float cy, float cz, float zoom,
                                            float rotX, float rotY, float rotZ)
{
    viewCenterX_ = cx;
    viewCenterY_ = cy;
    viewCenterZ_ = cz;
    viewZoom_    = zoom;
    viewRotX_    = rotX;
    viewRotY_    = rotY;
    viewRotZ_    = rotZ;
}

// ===========================================================================
// destroySwapchain
// ===========================================================================

void VulkanEngine::destroySwapchain()
{
    for (auto view : swapchainImageViews_) {
        if (view != VK_NULL_HANDLE) {
            vkDestroyImageView(device_, view, nullptr);
        }
    }
    swapchainImageViews_.clear();
    swapchainImages_.clear();

    if (swapchain_ != VK_NULL_HANDLE) {
        vkDestroySwapchainKHR(device_, swapchain_, nullptr);
        swapchain_ = VK_NULL_HANDLE;
    }
}

// ===========================================================================
// destroyStorageImage
// ===========================================================================

void VulkanEngine::destroyStorageImage()
{
    if (storageImageView_ != VK_NULL_HANDLE) {
        vkDestroyImageView(device_, storageImageView_, nullptr);
        storageImageView_ = VK_NULL_HANDLE;
    }
    if (storageImage_ != VK_NULL_HANDLE) {
        vkDestroyImage(device_, storageImage_, nullptr);
        storageImage_ = VK_NULL_HANDLE;
    }
    if (storageImageMemory_ != VK_NULL_HANDLE) {
        vkFreeMemory(device_, storageImageMemory_, nullptr);
        storageImageMemory_ = VK_NULL_HANDLE;
    }
}

// ===========================================================================
// destroyComputeResources
// ===========================================================================

void VulkanEngine::destroyComputeResources()
{
    if (mandelbrotPipeline_ != VK_NULL_HANDLE) {
        vkDestroyPipeline(device_, mandelbrotPipeline_, nullptr);
        mandelbrotPipeline_ = VK_NULL_HANDLE;
    }
    if (mandelbulbPipeline_ != VK_NULL_HANDLE) {
        vkDestroyPipeline(device_, mandelbulbPipeline_, nullptr);
        mandelbulbPipeline_ = VK_NULL_HANDLE;
    }
    if (pipelineLayout_ != VK_NULL_HANDLE) {
        vkDestroyPipelineLayout(device_, pipelineLayout_, nullptr);
        pipelineLayout_ = VK_NULL_HANDLE;
    }
    if (descriptorPool_ != VK_NULL_HANDLE) {
        vkDestroyDescriptorPool(device_, descriptorPool_, nullptr);
        descriptorPool_  = VK_NULL_HANDLE;
        descriptorSet_   = VK_NULL_HANDLE; // implicitly freed with pool
    }
    if (descriptorSetLayout_ != VK_NULL_HANDLE) {
        vkDestroyDescriptorSetLayout(device_, descriptorSetLayout_, nullptr);
        descriptorSetLayout_ = VK_NULL_HANDLE;
    }
}

// ===========================================================================
// findMemoryType
// ===========================================================================

uint32_t VulkanEngine::findMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags props)
{
    VkPhysicalDeviceMemoryProperties memProperties;
    vkGetPhysicalDeviceMemoryProperties(physicalDevice_, &memProperties);

    for (uint32_t i = 0; i < memProperties.memoryTypeCount; i++) {
        if ((typeFilter & (1u << i)) &&
            (memProperties.memoryTypes[i].propertyFlags & props) == props) {
            return i;
        }
    }

    return UINT32_MAX;
}

// ===========================================================================
// getDeviceInfo
// ===========================================================================

std::string VulkanEngine::getDeviceInfo() const
{
    if (physicalDevice_ == VK_NULL_HANDLE) {
        return "{}";
    }

    uint32_t major = VK_VERSION_MAJOR(deviceProperties_.apiVersion);
    uint32_t minor = VK_VERSION_MINOR(deviceProperties_.apiVersion);
    uint32_t patch = VK_VERSION_PATCH(deviceProperties_.apiVersion);

    // H2: Escape backslashes and double-quotes from driver-supplied deviceName
    auto jsonEscape = [](const char* s) -> std::string {
        std::string out;
        for (; *s; ++s) {
            if (*s == '"')       out += "\\\"";
            else if (*s == '\\') out += "\\\\";
            else                 out += *s;
        }
        return out;
    };

    // Build JSON manually to avoid extra dependencies
    std::string json = "{";
    json += "\"device\":\"";
    json += jsonEscape(deviceProperties_.deviceName);
    json += "\",\"vulkanVersion\":\"";
    json += std::to_string(major) + "." + std::to_string(minor) + "." + std::to_string(patch);
    json += "\",\"fp64\":";
    json += fp64Supported_ ? "true" : "false";
    json += "}";

    return json;
}
