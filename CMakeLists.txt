CMAKE_MINIMUM_REQUIRED(VERSION 3.0)
PROJECT(3delight)

include(ExternalProject)

option(CLEAN_BUILD "Clean the build directory when running CMake." ON)
option(CLEAN_INSTALL "Clean the install directory when running CMake." ON)

# We check if we are using either the Rez build system, or if we are doing a pure CMake build.
# If the former, we are making use of the Rez dedicated environment variables.
# If the latter, we rely on environment or local variables that we define ourselves.
if(DEFINED ENV{REZ_BUILD_ENV})
    message("\n[CMAKE][SETUP] The project build will be done through Rez.\n")

    include(RezBuild)

    set(PROJECT_VERSION $ENV{REZ_BUILD_PROJECT_VERSION})
    set(INSTALL_PATH $ENV{REZ_BUILD_INSTALL_PATH})
    set(ARCHIVE_PATH $ENV{REZ_REPO_PAYLOAD_DIR})
    # The environment variable REZ_TMP_PATH is meant to point to a location such as "/tmp/rez".
    set(TMP_PATH $ENV{REZ_TMP_PATH})
    set(BUILD_THREADS $ENV{REZ_BUILD_THREAD_COUNT})
else()
    message("\n[CMAKE][SETUP] The project build will be done through pure CMake.\n")

    include(ProcessorCount)

    set(PROJECT_VERSION 1.6.17)
    set(INSTALL_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_PROJECT_NAME}/${PROJECT_VERSION})
    set(ARCHIVE_PATH $ENV{BUILD_ARCHIVE_PATH})
    set(TMP_PATH $ENV{BUILD_TMP_PATH})
    ProcessorCount(BUILD_THREADS)

    if(NOT EXISTS ${INSTALL_PATH})
        file(MAKE_DIRECTORY ${INSTALL_PATH})
    endif()
endif()

# We check that the minimum set of variables are properly defined. If not, we abort the process.
if(NOT DEFINED PROJECT_VERSION)
    message(FATAL_ERROR "The PROJECT_VERSION variable is not properly defined. Aborting...")
elseif(NOT DEFINED INSTALL_PATH)
    message(FATAL_ERROR "The INSTALL_PATH variable is not properly defined. Aborting...")
elseif(NOT DEFINED ARCHIVE_PATH)
    message(FATAL_ERROR "The ARCHIVE_PATH variable is not properly defined. Aborting...")
elseif(NOT DEFINED TMP_PATH)
    message(FATAL_ERROR "The TMP_PATH variable is not properly defined. Aborting...")
elseif(NOT DEFINED BUILD_THREADS)
    message(FATAL_ERROR "The BUILD_THREADS variable is not properly defined. Aborting...")
endif()

# We build the path to the archive of the project we are building.
set(ARCHIVE_URL ${ARCHIVE_PATH}/${CMAKE_PROJECT_NAME}/3DelightNSI-${PROJECT_VERSION}-Linux-x86_64.tar.xz)

# We check that the path to the archive actually exists on disk.
if(NOT EXISTS ${ARCHIVE_URL})
    message(FATAL_ERROR "Archive not found, using the following path: ${ARCHIVE_URL}. "
        "Either the path leading to it is wrong, or it does not exist. If the archive does not indeed exist, "
        "please consider using the following link to download it: "
        "https://www.3delight.com/download")
endif()

set(EXTRACT_PATH ${TMP_PATH}/${CMAKE_PROJECT_NAME}/${PROJECT_VERSION})

# We clean the previous build, if any.
if (${CLEAN_BUILD})
    if(EXISTS ${EXTRACT_PATH})
        file(GLOB EXTRACT_PATH_FILES
            LIST_DIRECTORIES true
            ${EXTRACT_PATH}/*)

        foreach(EXTRACT_PATH_CHILD ${EXTRACT_PATH_FILES})
            file(REMOVE_RECURSE ${EXTRACT_PATH_CHILD})
        endforeach()
    endif()
endif()

# We clean the previous install, if any.
if (${CLEAN_INSTALL})
    file(GLOB INSTALL_PATH_FILES
        LIST_DIRECTORIES true
        ${INSTALL_PATH}/*)

    foreach(INSTALL_PATH_CHILD ${INSTALL_PATH_FILES})
        file(REMOVE_RECURSE ${INSTALL_PATH_CHILD})
    endforeach()
endif()

# We install the project.
install(
    CODE
    "execute_process(
        COMMAND bash ${CMAKE_SOURCE_DIR}/install.sh ${EXTRACT_PATH} ${INSTALL_PATH} ${PROJECT_VERSION} ${ARCHIVE_URL}
        RESULT_VARIABLE RETURN_CODE_INSTALL
    )
    if (NOT RETURN_CODE_INSTALL EQUAL \"0\")
        message(FATAL_ERROR \"[CMAKE] Install script returned an error code. Aborting...\")
    endif()"
)
