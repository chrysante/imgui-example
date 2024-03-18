cmake_minimum_required(VERSION 3.23)

set(CMAKE_CXX_STANDARD 20)

# download CPM.cmake
file(
  DOWNLOAD
  https://github.com/cpm-cmake/CPM.cmake/releases/download/v0.38.3/CPM.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake
  EXPECTED_HASH SHA256=cc155ce02e7945e7b8967ddfaff0b050e958a723ef7aad3766d368940cb15494
)
include(${CMAKE_CURRENT_BINARY_DIR}/cmake/CPM.cmake)

set(GLFW_BUILD_DOCS OFF)
set(GLFW_INSTALL OFF)
CPMAddPackage("gh:glfw/glfw#master")
set(IMGUI_BACKEND_METAL ON)
set(IMGUI_BACKEND_OSX ON)
CPMAddPackage("gh:chrysante/imgui#docking")

project(imgui-example)
add_executable(imgui-example src/foo.mm)
target_compile_options(imgui-example PRIVATE "-fobjc-arc")

target_include_directories(imgui-example
  PRIVATE
    ${CMAKE_PROJECT_DIR}/src
)

target_link_libraries(imgui-example 
    glfw 
    ImGui 
    "-framework AppKit"
    "-framework Metal"
    "-framework IOKit"
    "-framework QuartzCore"
    "-framework AppKit"
    "-framework Metal"
    "-framework GameController"
    "-framework CoreImage"
    "-framework MetalKit"
)
