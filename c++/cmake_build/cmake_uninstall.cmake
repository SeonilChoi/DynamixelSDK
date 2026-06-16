# Uninstall files listed in install_manifest.txt (created by cmake --install).
# Configured from cmake_uninstall.cmake.in via configure_file(... IMMEDIATE @ONLY).

if(NOT EXISTS "/home/mini0/DynamixelSDK/c++/cmake_build/install_manifest.txt")
  message(FATAL_ERROR
    "Cannot find /home/mini0/DynamixelSDK/c++/cmake_build/install_manifest.txt\n"
    "Run: cmake --install <build-dir> (or make install) at least once so the manifest exists."
  )
endif()

file(STRINGS "/home/mini0/DynamixelSDK/c++/cmake_build/install_manifest.txt" _dxl_installed_files)

foreach(_dxl_file IN LISTS _dxl_installed_files)
  string(STRIP "${_dxl_file}" _dxl_file)
  if(_dxl_file STREQUAL "")
    continue()
  endif()
  message(STATUS "Uninstalling: ${_dxl_file}")
  # EXISTS is false for broken symlinks, so also check IS_SYMLINK.
  if(EXISTS "${_dxl_file}" OR IS_SYMLINK "${_dxl_file}")
    file(REMOVE "${_dxl_file}")
  endif()
endforeach()

# Remove installed directories (manifest only removes files).
# Derive prefix from install_manifest.txt paths so --prefix overrides work.
set(_dxl_prefix "")
foreach(_dxl_file IN LISTS _dxl_installed_files)
  string(STRIP "${_dxl_file}" _dxl_file_stripped)
  if(_dxl_file_stripped STREQUAL "")
    continue()
  endif()

  # Example:
  #   ${prefix}/include/dynamixel_sdk/dynamixel_sdk.h
  if(_dxl_file_stripped MATCHES "^(.*)/include/dynamixel_sdk/.*$")
    set(_dxl_prefix "${CMAKE_MATCH_1}")
    break()
  endif()
endforeach()

if(NOT _dxl_prefix STREQUAL "")
  file(REMOVE_RECURSE "${_dxl_prefix}/include/dynamixel_sdk")
  file(REMOVE_RECURSE "${_dxl_prefix}/lib/cmake/dynamixel_sdk")
endif()
