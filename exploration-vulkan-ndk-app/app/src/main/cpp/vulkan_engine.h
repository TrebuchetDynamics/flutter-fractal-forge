#pragma once

#include <vulkan/vulkan.h>
#include <android/native_window.h>
#include <android/asset_manager.h>
#include <string>
#include <vector>
#include <cstdint>

struct MandelbrotParams {
    float    centerX;
    float    centerY;
    float    zoom;
    float    aspectRatio;
    uint32_t width;
    uint32_t height;
    uint32_t maxIter;
    float    bailout;
    float    colorScheme;
    float    time;
};
static_assert(sizeof(MandelbrotParams) == 40, "MandelbrotParams size mismatch");
static_assert(sizeof(MandelbrotParams) <= 128, "MandelbrotParams exceeds push constant limit");

struct MandelbulbParams {
    float    centerX;
    float    centerY;
    float    centerZ;
    float    zoom;
    float    rotationX;
    float    rotationY;
    float    rotationZ;
    float    power;
    uint32_t width;
    uint32_t height;
    uint32_t maxIter;
    uint32_t maxSteps;
    float    bailout;
    float    colorScheme;
    float    minDist;
    float    time;
};
static_assert(sizeof(MandelbulbParams) == 64, "MandelbulbParams size mismatch");
static_assert(sizeof(MandelbulbParams) <= 128, "MandelbulbParams exceeds push constant limit");

class VulkanEngine {
public:
    VulkanEngine()  = default;
    ~VulkanEngine() { cleanup(); }

    bool init(ANativeWindow* window, AAssetManager* assets,
              uint32_t width, uint32_t height);
    void cleanup();
    void resize(uint32_t width, uint32_t height);
    void setFractalType(uint32_t type);
    void render();
    std::string getDeviceInfo() const;

private:
    VkInstance               instance_              = VK_NULL_HANDLE;
    VkDebugUtilsMessengerEXT debugMessenger_         = VK_NULL_HANDLE;
    VkPhysicalDevice         physicalDevice_         = VK_NULL_HANDLE;
    VkDevice                 device_                = VK_NULL_HANDLE;
    VkQueue                  computeQueue_          = VK_NULL_HANDLE;
    VkQueue                  graphicsQueue_         = VK_NULL_HANDLE;
    uint32_t                 computeQueueFamily_    = UINT32_MAX;
    uint32_t                 graphicsQueueFamily_   = UINT32_MAX;

    VkSurfaceKHR             surface_               = VK_NULL_HANDLE;
    VkSwapchainKHR           swapchain_             = VK_NULL_HANDLE;
    std::vector<VkImage>     swapchainImages_;
    std::vector<VkImageView> swapchainImageViews_;
    VkFormat                 swapchainFormat_       = VK_FORMAT_UNDEFINED;
    VkExtent2D               swapchainExtent_       = {0, 0};

    VkImage              storageImage_              = VK_NULL_HANDLE;
    VkDeviceMemory       storageImageMemory_        = VK_NULL_HANDLE;
    VkImageView          storageImageView_          = VK_NULL_HANDLE;

    VkDescriptorSetLayout descriptorSetLayout_      = VK_NULL_HANDLE;
    VkDescriptorPool      descriptorPool_           = VK_NULL_HANDLE;
    VkDescriptorSet       descriptorSet_            = VK_NULL_HANDLE;

    VkPipelineLayout pipelineLayout_                = VK_NULL_HANDLE;
    VkPipeline       mandelbrotPipeline_            = VK_NULL_HANDLE;
    VkPipeline       mandelbulbPipeline_            = VK_NULL_HANDLE;

    VkCommandPool   commandPool_                    = VK_NULL_HANDLE;
    VkCommandBuffer commandBuffer_                  = VK_NULL_HANDLE;
    VkFence         fence_                          = VK_NULL_HANDLE;
    VkSemaphore     imageAvailableSemaphore_        = VK_NULL_HANDLE;
    VkSemaphore     renderFinishedSemaphore_        = VK_NULL_HANDLE;

    ANativeWindow*  window_        = nullptr;
    AAssetManager*  assetManager_  = nullptr;
    uint32_t        width_         = 0;
    uint32_t        height_        = 0;
    uint32_t        currentFractal_= 0;
    bool            initialized_   = false;
    float           time_          = 0.0f;

    VkPhysicalDeviceProperties deviceProperties_ = {};
    bool                       fp64Supported_    = false;

    bool createInstance();
    bool createSurface();
    bool selectPhysicalDevice();
    bool createDevice();
    bool createSwapchain(VkSwapchainKHR oldSwapchain = VK_NULL_HANDLE);
    bool createStorageImage();
    bool createDescriptorResources();
    bool createComputePipelines();
    bool createCommandResources();
    bool createSyncObjects();

    void destroySwapchain();
    void destroyStorageImage();
    void destroyComputeResources();

    VkShaderModule loadShaderFromAsset(const char* filename);
    uint32_t       findMemoryType(uint32_t typeFilter, VkMemoryPropertyFlags props);
    void           cmdTransitionImage(VkCommandBuffer cmd, VkImage image,
                                      VkImageLayout oldLayout, VkImageLayout newLayout,
                                      VkAccessFlags srcAccess, VkAccessFlags dstAccess,
                                      VkPipelineStageFlags srcStage,
                                      VkPipelineStageFlags dstStage);
    bool           recreateSwapchain();
};
