#!/usr/bin/bash

# Will exit the Bash script the moment any command will itself exit with a non-zero status, thus an error.
set -e

EXTRACT_PATH=$1
INSTALL_PATH=$2
PROJECT_VERSION=$3
ARCHIVE_URL=$4

# We print the arguments passed to the Bash script.
echo -e "\n"
echo -e "==============="
echo -e "=== INSTALL ==="
echo -e "==============="
echo -e "\n"

echo -e "[INSTALL][ARGS] EXTRACT PATH: ${EXTRACT_PATH}"
echo -e "[INSTALL][ARGS] INSTALL PATH: ${INSTALL_PATH}"
echo -e "[INSTALL][ARGS] PROJECT VERSION: ${PROJECT_VERSION}"
echo -e "[INSTALL][ARGS] ARCHIVE URL: ${ARCHIVE_URL}"

# We check if the arguments variables we need are correctly set.
# If not, we abort the process.
if [[ -z ${EXTRACT_PATH} || -z ${INSTALL_PATH} || -z ${PROJECT_VERSION} || -z ${ARCHIVE_URL} ]]; then
    echo -e "\n"
    echo -e "[INSTALL][ARGS] One or more of the argument variables are empty. Aborting..."
    echo -e "\n"

    exit 1
fi

# We install 3Delight.
echo -e "\n"
echo -e "[INSTALL] Installing 3Delight-${PROJECT_VERSION}..."
echo -e "\n"

mkdir -p ${EXTRACT_PATH}
cd ${EXTRACT_PATH}

# We extract the project archive.
tar -xf ${ARCHIVE_URL} -C ${EXTRACT_PATH} --strip 1

PLATFORM=$(uname -s)-$(uname -m)

# We copy the necessary files to the install directory.
cp -R ${EXTRACT_PATH}/3delight/${PLATFORM}/* ${INSTALL_PATH}

# Setting up the license server.
if [[ -z ${DELIGHT_LICENSE_SERVER} ]]; then
    echo -e "[INSTALL][LICENSE] Warning! The environment variable \"DELIGHT_LICENSE_SERVER\" does not seem to be set, no license server will be setup..."
    echo -e "\n"
else
    echo -e "[INSTALL][LICENSE] Setting up the license server..."
    echo -e "\nlicense.server ${DELIGHT_LICENSE_SERVER}" >> ${INSTALL_PATH}/3delight.config
    echo -e "[INSTALL][LICENSE] License server successfully setup!"
    echo -e "\n"
fi

echo -e "[INSTALL] Finished installing 3Delight-${PROJECT_VERSION}!"
echo -e "\n"
