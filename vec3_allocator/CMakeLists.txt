cmake_minimum_required(VERSION 3.15)

project(Vec3Allocator CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(WITH_ASAN "build with address sanitizer" OFF)
if (WITH_ASAN)
    if (MSVC)
        add_compile_options(/fsanitize=address)
    else()
        add_compile_options(-fsanitize=address,undefined -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address,undefined)
    endif()
endif()

enable_testing()

include(FetchContent)
FetchContent_Declare(
    googletest
    URL https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

add_library(vec3-allocator STATIC src/vec3_allocator.cpp)
target_include_directories(vec3-allocator PUBLIC include)

add_executable(allocator-test src/allocator_test.cpp)
target_link_libraries(allocator-test PRIVATE vec3-allocator GTest::gtest_main)

add_test(NAME allocator_tests COMMAND allocator-test)
