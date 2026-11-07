cmake_minimum_required(VERSION 3.18)
project(fractal_engine_bridge LANGUAGES NONE)

# Flutter's generated environment carries the Dart flag; off builds need no Cargo.
include("${CMAKE_SOURCE_DIR}/flutter/ephemeral/generated_config.cmake")
set(RUST_CORE_ENABLED FALSE)
foreach(entry IN LISTS FLUTTER_TOOL_ENVIRONMENT)
  if(entry MATCHES "^DART_DEFINES=(.*,)?UlVTVF9DT1JFPXRydWU=($|,)")
    set(RUST_CORE_ENABLED TRUE)
  endif()
endforeach()
set(fractal_engine_bridge_bundled_libraries "" PARENT_SCOPE)
if(NOT RUST_CORE_ENABLED)
  return()
endif()

find_program(CARGO_EXECUTABLE cargo REQUIRED)
get_filename_component(PLUGIN_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.." REALPATH)
get_filename_component(REPO_ROOT "${PLUGIN_ROOT}/../.." REALPATH)
set(RUST_TARGET_DIR "${CMAKE_CURRENT_BINARY_DIR}/rust-target")
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(RUST_PROFILE debug)
  set(RUST_PROFILE_ARG "")
else()
  set(RUST_PROFILE release)
  set(RUST_PROFILE_ARG --release)
endif()
set(RUST_LIBRARY "${RUST_TARGET_DIR}/${RUST_PROFILE}/libfractal_bridge.so")
file(GLOB_RECURSE RUST_INPUTS CONFIGURE_DEPENDS
  "${REPO_ROOT}/rust/crates/*.rs" "${REPO_ROOT}/rust/crates/*/Cargo.toml")
add_custom_command(
  OUTPUT "${RUST_LIBRARY}"
  COMMAND "${CARGO_EXECUTABLE}" build
    --manifest-path "${REPO_ROOT}/rust/crates/fractal-bridge/Cargo.toml"
    --target-dir "${RUST_TARGET_DIR}" --locked --offline ${RUST_PROFILE_ARG}
  WORKING_DIRECTORY "${REPO_ROOT}/rust"
  DEPENDS ${RUST_INPUTS} "${REPO_ROOT}/rust/Cargo.toml"
    "${REPO_ROOT}/rust/Cargo.lock" "${REPO_ROOT}/rust/rust-toolchain.toml"
  VERBATIM)
add_custom_target(fractal_engine_bridge_build ALL DEPENDS "${RUST_LIBRARY}")
set(fractal_engine_bridge_bundled_libraries "${RUST_LIBRARY}" PARENT_SCOPE)
