# Findmgclient.cmake - Locate mgclient library and headers
# Usage: find_package(mgclient REQUIRED)

if(MGCLIENT_ROOT)
    set(_mgclient_include "${MGCLIENT_ROOT}/include")
    set(_mgclient_lib_dir "${MGCLIENT_ROOT}/lib")
    set(MGCLIENT_ROOT "${MGCLIENT_ROOT}" CACHE PATH "mgclient install root" FORCE)
else()
    # Fall back to standard system paths
    find_path(_mgclient_include_dir NAMES mgclient.h
              PATHS /usr/include /usr/local/include
              NO_DEFAULT_PATH)
    find_library(_mgclient_lib NAMES mgclient
                 PATHS /usr/lib /usr/local/lib
                 NO_DEFAULT_PATH)
    set(_mgclient_include "${_mgclient_include_dir}")
    set(_mgclient_lib_dir "")
endif()

# Pick library: prefer shared if it exists
if(MGCLIENT_ROOT)
    if(EXISTS "${_mgclient_lib_dir}/libmgclient.so")
        set(_mgclient_lib "${_mgclient_lib_dir}/libmgclient.so")
    elseif(EXISTS "${_mgclient_lib_dir}/libmgclient.a")
        set(_mgclient_lib "${_mgclient_lib_dir}/libmgclient.a")
    else()
        message(FATAL_ERROR "mgclient library not found in ${_mgclient_lib_dir}")
    endif()
endif()

# Check include directory
if(NOT EXISTS "${_mgclient_include}/mgclient.h")
    message(FATAL_ERROR "mgclient.h not found in ${_mgclient_include}")
endif()

message(STATUS "mgclient include: ${_mgclient_include}")
message(STATUS "mgclient library: ${_mgclient_lib}")

# Create imported target
add_library(mgclient SHARED IMPORTED)
set_target_properties(mgclient PROPERTIES
    IMPORTED_LOCATION "${_mgclient_lib}"
    INTERFACE_INCLUDE_DIRECTORIES "${_mgclient_include}"
)

# Variables for compatibility
set(MGCLIENT_INCLUDE_DIRS "${_mgclient_include}")
set(MGCLIENT_LIBRARIES mgclient)
set(MGCLIENT_FOUND TRUE)

