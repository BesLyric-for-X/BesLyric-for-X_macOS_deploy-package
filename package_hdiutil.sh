#!/bin/bash
#
# Perform the application packaging with hdiutil.


set -e
set -o pipefail
set -u


# ====== Input variables testing ======
# "set -u" takes effect.
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"
echo "OUTPUT_DMG_PATH = '${OUTPUT_DMG_PATH}'"


# ====== Variables preparation ======
echo

# Remove the trailing slash from the app path
APP_FILE_PATH="$( dirname "${APP_FILE_PATH}" )/$( basename "${APP_FILE_PATH}" )"
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"

# DMG volume name
OUTPUT_DMG_FILE_BASENAME="$( basename "${OUTPUT_DMG_PATH}" '.dmg' )"
echo "OUTPUT_DMG_FILE_BASENAME = '${OUTPUT_DMG_FILE_BASENAME}'"

# DMG output dir path
OUTPUT_DIR_PATH="$( cd "$( dirname "${OUTPUT_DMG_PATH}")"; pwd -P )"
echo "OUTPUT_DIR_PATH = '${OUTPUT_DIR_PATH}'"


# Create DMG image file with hdiutil
#   https://code.qt.io/cgit/qt/qttools.git/tree/src/macdeployqt/shared/shared.cpp?h=5.14.1#n1545
echo
echo '====== Calling hdiutil ======'

hdiutil create \
    "${OUTPUT_DMG_PATH}" \
    -volname "${OUTPUT_DMG_FILE_BASENAME}" \
    -srcfolder "${APP_FILE_PATH}" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -fs HFS+ \
    -ov \
    -verbose
