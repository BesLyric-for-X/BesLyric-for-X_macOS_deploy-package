#!/bin/bash
#
# Perform the application packaging with create-dmg.


set -e
set -o pipefail
set -u


# ====== Input variables testing ======
# "set -u" takes effect.
echo "IMAGEMAGICK_PATH = '${IMAGEMAGICK_PATH}'"
echo "CREATE_DMG_PATH = '${CREATE_DMG_PATH}'"
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"
echo "OUTPUT_DMG_PATH = '${OUTPUT_DMG_PATH}'"


# ====== Variables preparation ======
echo

# Remove the trailing slash from the app path
APP_FILE_NAME="$( basename "${APP_FILE_PATH}" )"
echo "APP_FILE_NAME = '${APP_FILE_NAME}'"

APP_FILE_PATH="$( dirname "${APP_FILE_PATH}" )/${APP_FILE_NAME}"
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"

# Get app name
APP_FILE_BASENAME="$( basename "${APP_FILE_NAME}" '.app' )"
echo "APP_FILE_BASENAME = '${APP_FILE_BASENAME}'"

# DMG volume name
OUTPUT_DMG_FILE_BASENAME="$( basename "${OUTPUT_DMG_PATH}" '.dmg' )"
echo "OUTPUT_DMG_FILE_BASENAME = '${OUTPUT_DMG_FILE_BASENAME}'"

# DMG output dir path
OUTPUT_DIR_PATH="$( cd "$( dirname "${OUTPUT_DMG_PATH}")"; pwd -P )"
echo "OUTPUT_DIR_PATH = '${OUTPUT_DIR_PATH}'"


# ====== Make DMG ======
dmg_background_pic_file_path="${TMPDIR}/dmg_background.jpg"


# Generate the background image with ImageMagick
#   https://legacy.imagemagick.org/Usage/text/
echo
echo '====== Calling magick ======'

"${IMAGEMAGICK_PATH}" convert \
    -background '#C8C8C8' \
    -fill 'white' \
    -font 'Helvetica' \
    -size 5120x2880 \
    -pointsize 52 \
    label:"\n ${OUTPUT_DMG_FILE_BASENAME}" \
    "${dmg_background_pic_file_path}"


# Create DMG image file with create-dmg
#   https://github.com/create-dmg/create-dmg
echo
echo '====== Calling create-dmg ======'

"${CREATE_DMG_PATH}" \
    --hdiutil-verbose \
    --volname "${OUTPUT_DMG_FILE_BASENAME}" \
    --background "${dmg_background_pic_file_path}" \
    --window-size 500 352 \
    --icon-size 100 \
    --icon "${APP_FILE_NAME}" 90 162 \
    --hide-extension "${APP_FILE_NAME}" \
    --app-drop-link 370 162 \
    "${OUTPUT_DMG_PATH}" \
    "${APP_FILE_PATH}"
