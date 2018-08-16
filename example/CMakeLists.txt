cmake_minimum_required(VERSION 3.5)

project(example VERSION 1.0.0 LANGUAGES C CXX)

set(CMAKE_COLOR_MAKEFILE ON)
set(CMAKE_VERBOSE_MAKEFILE OFF)

add_executable(hello-world hello-world.cpp)
