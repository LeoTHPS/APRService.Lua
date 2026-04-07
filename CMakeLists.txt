cmake_minimum_required(VERSION 3.25)

set(CMAKE_C_STANDARD               17)
set(CMAKE_CXX_STANDARD             20)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

set(LUACPP_LUA_VERSION             550)

add_subdirectory($ENV{LUACPP_PATH}     luacpp)
add_subdirectory($ENV{APRSERVICE_PATH} APRService)

project(APRService.Lua)
add_executable(APRService.Lua main.cpp)
target_link_libraries(APRService.Lua APRService luacpp)

if(WIN32)
	target_compile_definitions(APRService.Lua PRIVATE -DPLATFORM_WIN32=1)
elseif(LINUX)
	target_compile_definitions(APRService.Lua PRIVATE -DPLATFORM_LINUX=1)
elseif(UNIX)
	target_compile_definitions(APRService.Lua PRIVATE -DPLATFORM_UNIX=1)
endif()
