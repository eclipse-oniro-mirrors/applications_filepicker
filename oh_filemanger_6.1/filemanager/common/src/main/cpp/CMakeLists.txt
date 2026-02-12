# the minimum version of CMake.
cmake_minimum_required(VERSION 3.16.0)
project(SecurityApi)

set(NATIVERENDER_ROOT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")

include_directories(${NATIVERENDER_ROOT_PATH}
                    ${NATIVERENDER_ROOT_PATH}/include
                    src/main/cpp/fileoperation
                    src/main/cpp/napi
                    src/main/cpp/trash
                    src/main/cpp/common
                    src/main/cpp/filequery
                    src/main/cpp/utils)

add_library(Security SHARED
    Security.cpp
    fileoperation/listfile.cpp
    napi/n_func_arg.cpp
    napi/n_val.cpp
    napi/n_ref.cpp
    napi/n_error.cpp
    napi/n_async_work_promise.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/filequery/file_producer.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/fileoperation/file_util.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/fileoperation/napi_util.cpp)

add_library(Trash SHARED
    napi/n_func_arg.cpp
    napi/n_val.cpp
    napi/n_ref.cpp
    napi/n_error.cpp
    napi/n_async_work_promise.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/filemanager_db_manager.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/file_manager_utils.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/filemanager_rdb_instance.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/filemanager_rdb_trash.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/filemanager_rdb_utils.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/napi_module_trash.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/trash/trash_utils.cpp)


target_link_libraries(Security PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
    libohfileuri.so
    libohfileio.so)

target_link_libraries(Trash PUBLIC
    libnative_rdb_ndk.z.so
    libace_napi.z.so
    libhilog_ndk.z.so
    libohfileuri.so
    libohfileio.so)