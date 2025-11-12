#!/bin/bash
#
# Perform the dependecies fetching with macdeployqt and my code.


set -e
set -o pipefail
set -u


# ====== Input variables testing ======
# "set -u" takes effect.
echo "MACDEPLOYQT_PATH = '${MACDEPLOYQT_PATH}'"
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"


# ====== Variables preparation ======
echo

# Remove the trailing slash from the app path
APP_FILE_PATH="$( dirname "${APP_FILE_PATH}" )/$( basename "${APP_FILE_PATH}" )"
echo "APP_FILE_PATH = '${APP_FILE_PATH}'"

# Framework dir in app bundle (non-existing)
FRAMEWORKS_DIR_PATH="${APP_FILE_PATH}/Contents/Frameworks"
echo "FRAMEWORKS_DIR_PATH = '${FRAMEWORKS_DIR_PATH}'"


# copy libsharpyuv and wait for our own processing
#   chain:
#   - ffmpeg (libavformat.58.dylib)
#   - webp (libwebp.7.dylib)
#   - libsharpyuv (@rpath/libsharpyuv.0.dylib)
mkdir -p "$FRAMEWORKS_DIR_PATH"
cp -a \
    "$(readlink -f "$(brew --prefix --installed webp)/lib/libsharpyuv.0.dylib")" \
    "$FRAMEWORKS_DIR_PATH/libsharpyuv.0.dylib"


# Call macdeployqt
echo
echo '====== Calling macdeployqt ======'

"${MACDEPLOYQT_PATH}" "${APP_FILE_PATH}" -verbose=3


# Process 3rd party dependencies
echo
echo '====== Process 3rd party dependencies ======'

find "${FRAMEWORKS_DIR_PATH}" -type f | \
    while read -r lib_path; do
        echo 'Log: Using otool:'
        echo "Log:  inspecting \"${lib_path}\""

        otool -L "${lib_path}" | awk '{ if (NR > 1) { print $1 } }' | \
            while read -r lib_depends; do
                echo "Log: found dependency: ${lib_depends}"

                if [[ "${lib_depends}" = '/usr/local/'* ]]; then
                    lib_depends_path_old="${lib_depends}"
                    lib_depends_path_new="@executable_path/../Frameworks/$( \
                        basename "${lib_depends_path_old}" \
                    )"

                    echo 'Log: Using install_name_tool:'
                    echo "Log:  in \"${lib_path}\""
                    echo "Log:  change reference \"${lib_depends_path_old}\""
                    echo "Log:  to \"${lib_depends_path_new}\""

                    install_name_tool -change \
                        "${lib_depends_path_old}" \
                        "${lib_depends_path_new}" \
                        "${lib_path}"
                fi
            done

        echo

    done
