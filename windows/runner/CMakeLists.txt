cmake_minimum_required(VERSION 3.14)
project(POSXpert LANGUAGES CXX)

# Use Flutter's expected target name
set(BINARY_NAME "flutter_application_1")

# Set the Flutter SDK path
set(FLUTTER_ROOT "C:/path/to/flutter")  # Update to your actual path

# Disable unsafe function warnings for Firebase
add_compile_options(
    "$<$<C_COMPILER_ID:MSVC>:/wd4996>"
    "$<$<CXX_COMPILER_ID:MSVC>:/wd4996>"
    "$<$<C_COMPILER_ID:MSVC>:/D_CRT_SECURE_NO_WARNINGS>"
    "$<$<CXX_COMPILER_ID:MSVC>:/D_CRT_SECURE_NO_WARNINGS>"
)

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Set output name to POSXpert.exe
set_target_properties(${BINARY_NAME} PROPERTIES OUTPUT_NAME "POSXpert")

apply_standard_settings(${BINARY_NAME})

# Version definitions
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable problematic Windows macros
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Link required libraries
target_link_libraries(${BINARY_NAME} PRIVATE 
    flutter 
    flutter_wrapper_app
    dwmapi.lib
    winmm.lib
    icuuc.lib
    icuin.lib
    version.lib
    shlwapi.lib
    firebase_app
    firebase_auth
    firebase_storage
    cloud_firestore
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Flutter build dependency
add_dependencies(${BINARY_NAME} flutter_assemble)

# Include generated plugins (CRITICAL FIX)
include(flutter/generated_plugins.cmake)