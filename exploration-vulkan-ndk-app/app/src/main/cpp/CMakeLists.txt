cmake_minimum_required(VERSION 3.22.1)
project(fractal_engine LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(ENGINE_SOURCES
    jni_bridge.cpp
    vulkan_engine.cpp
)

add_library(fractal_engine SHARED ${ENGINE_SOURCES})

target_include_directories(fractal_engine PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Link Vulkan: try find_package first, fallback to find_library
find_package(Vulkan QUIET)
if(Vulkan_FOUND)
    target_link_libraries(fractal_engine PRIVATE Vulkan::Vulkan)
else()
    find_library(vulkan-lib vulkan)
    if(vulkan-lib)
        target_link_libraries(fractal_engine PRIVATE ${vulkan-lib})
        target_include_directories(fractal_engine PRIVATE
            ${ANDROID_NDK}/sources/third_party/vulkan/src/include
        )
    else()
        message(FATAL_ERROR "Vulkan not found. NDK: ${ANDROID_NDK}")
    endif()
endif()

target_link_libraries(fractal_engine PRIVATE
    android
    log
)

target_compile_options(fractal_engine PRIVATE
    -Wall -Wextra -Wno-unused-parameter -fvisibility=hidden
)

# Offline SPIR-V shader compilation
find_program(GLSLC glslc HINTS
    "${ANDROID_NDK}/shader-tools/${ANDROID_HOST_TAG}"
    "${ANDROID_NDK}/shader-tools/linux-x86_64"
    "$ENV{VULKAN_SDK}/bin"
    "/usr/bin"
)

if(GLSLC)
    set(SHADER_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/shaders")
    set(SHADER_OUTPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../assets/shaders")
    file(MAKE_DIRECTORY ${SHADER_OUTPUT_DIR})

    set(SHADER_SOURCES
        ${SHADER_SOURCE_DIR}/mandelbrot.comp
        ${SHADER_SOURCE_DIR}/mandelbulb.comp
    )

    set(SHADER_SPVS "")
    foreach(SHADER_SRC ${SHADER_SOURCES})
        get_filename_component(SHADER_NAME ${SHADER_SRC} NAME)
        set(SHADER_SPV "${SHADER_OUTPUT_DIR}/${SHADER_NAME}.spv")
        add_custom_command(
            OUTPUT ${SHADER_SPV}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${SHADER_OUTPUT_DIR}
            COMMAND ${GLSLC}
                -fshader-stage=compute
                --target-env=vulkan1.1
                --target-spv=spv1.3
                -O
                ${SHADER_SRC}
                -o ${SHADER_SPV}
            DEPENDS ${SHADER_SRC}
            COMMENT "Compiling ${SHADER_NAME} -> SPIR-V"
        )
        list(APPEND SHADER_SPVS ${SHADER_SPV})
    endforeach()

    add_custom_target(compile_shaders ALL DEPENDS ${SHADER_SPVS})
    add_dependencies(fractal_engine compile_shaders)
    message(STATUS "glslc found: ${GLSLC}")
else()
    message(WARNING "glslc not found; place pre-compiled .spv files in assets/shaders/")
endif()
