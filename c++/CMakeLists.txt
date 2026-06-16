cmake_minimum_required(VERSION 3.10)

# Standalone C++ SDK: configure/build from the c++/ directory (paths below are relative to c++/).
project(dynamixel_sdk VERSION 4.0.5 LANGUAGES CXX)

set(_dxl_pkg "dynamixel_sdk")

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(FATAL_ERROR "This trimmed SDK tree only supports Linux.")
endif()

if(NOT CMAKE_SIZEOF_VOID_P EQUAL 8)
  message(FATAL_ERROR "This trimmed SDK tree only supports 64-bit Linux.")
endif()

# --------------------------------------------------------
# 1. Build Environment Configuration
# --------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(DYNAMIXEL_SDK_RUN_LDCONFIG
  "Run ldconfig after install (usually requires root). Recommended OFF."
  OFF
)

# --------------------------------------------------------
# 2. Build C++ Library
# --------------------------------------------------------
set(_dxl_sources
  src/dynamixel_sdk/group_bulk_read.cpp
  src/dynamixel_sdk/group_bulk_write.cpp
  src/dynamixel_sdk/group_sync_read.cpp
  src/dynamixel_sdk/group_sync_write.cpp
  src/dynamixel_sdk/group_fast_bulk_read.cpp
  src/dynamixel_sdk/group_fast_sync_read.cpp
  src/dynamixel_sdk/group_handler.cpp
  src/dynamixel_sdk/packet_handler.cpp
  src/dynamixel_sdk/port_handler.cpp
  src/dynamixel_sdk/port_handler_linux.cpp
  src/dynamixel_sdk/protocol2_packet_handler.cpp
)

add_library(dynamixel_sdk SHARED ${_dxl_sources})

target_include_directories(dynamixel_sdk PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<INSTALL_INTERFACE:include>
  $<INSTALL_INTERFACE:include/dynamixel_sdk>
)
target_include_directories(dynamixel_sdk PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/include/dynamixel_sdk
)

set_target_properties(dynamixel_sdk PROPERTIES
  VERSION ${PROJECT_VERSION}
  SOVERSION 2
  CXX_STANDARD 17
  CXX_STANDARD_REQUIRED ON
  OUTPUT_NAME "dxl_cpp"
)

target_link_libraries(dynamixel_sdk PRIVATE rt)

# --------------------------------------------------------
# 3. Installation
# --------------------------------------------------------
include(GNUInstallDirs)

install(
  DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/dynamixel_sdk/
  DESTINATION include/${_dxl_pkg}
)

set(_dxl_cmake_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/${_dxl_pkg}")

install(
  TARGETS dynamixel_sdk
  EXPORT dynamixel_sdkTargets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES DESTINATION include
)

install(
  EXPORT dynamixel_sdkTargets
  FILE dynamixel_sdkTargets.cmake
  NAMESPACE dynamixel_sdk::
  DESTINATION ${_dxl_cmake_package_dir}
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/dynamixel_sdkConfig.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/dynamixel_sdkConfig.cmake"
  INSTALL_DESTINATION ${_dxl_cmake_package_dir}
)

write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/dynamixel_sdkConfigVersion.cmake"
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion
)

install(
  FILES
    "${CMAKE_CURRENT_BINARY_DIR}/dynamixel_sdkConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/dynamixel_sdkConfigVersion.cmake"
  DESTINATION ${_dxl_cmake_package_dir}
)

if(DYNAMIXEL_SDK_RUN_LDCONFIG)
  install(CODE "execute_process(COMMAND ldconfig)")
endif()

# --------------------------------------------------------
# 4. Uninstall / Reinstall Targets
# --------------------------------------------------------
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
  IMMEDIATE @ONLY
)

if(NOT TARGET uninstall)
  add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    COMMENT "Uninstalling DynamixelSDK (C++)..."
  )
endif()

if(NOT TARGET reinstall)
  add_custom_target(reinstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
    COMMAND ${CMAKE_COMMAND} --build ${CMAKE_CURRENT_BINARY_DIR} --target install
    COMMENT "Reinstalling DynamixelSDK (C++)..."
  )
endif()
