# BesLyric-for-X Deployment and Packaging Scripts (macOS)

## Introduction

The script(s) in this repository are used to deploy and package BesLyric-for-X on macOS.

## Environment

macOS 10.14 and 10.15

## Dependent tools

These tools are required to complete the work:

- Bash 3
- macdeployqt (from Qt)

If you want to create a fancy DMG with create-dmg, ImageMagick is also required since the background image will be generated on the fly:

- create-dmg
- ImageMagick 7

## How to use

### Get

```console
$ git clone https://github.com/BesLyric-for-X/BesLyric-for-X_macOS_deploy-package.git
```

### Execute with variables

#### Deployment

`macdeployqt` cannot handle 3rd party libraries correctly, so there is some additional work needs to be done by our scripts.

```shell
MACDEPLOYQT_PATH='path/to/macdeployqt' \
   APP_FILE_PATH='path/to/app_bundle.app' \
    bash macdeployqt_enhanced.sh
```

#### Packaging

Create a normal DMG:

```shell
  APP_FILE_PATH='path/to/app_bundle.app' \
OUTPUT_DMG_PATH='path/to/generated.dmg' \
    bash package_hdiutil.sh
```

Or, a fancy one:

```shell
IMAGEMAGICK_PATH='path/to/magick' \
 CREATE_DMG_PATH='path/to/create-dmg' \
   APP_FILE_PATH='path/to/app_bundle.app' \
 OUTPUT_DMG_PATH='path/to/generated.dmg' \
    bash package_cdmg.sh
```

## Common code snippets

### Writing Safe Shell Scripts

Source: [Writing Safe Shell Scripts](https://sipb.mit.edu/doc/safe-shell/)

```shell
set -e           # Checking tons of $? is painful
set -o pipefail  # Error will not disappear in the pipeline
set -u           # Detect unbound variables
```

### Bash script absolute path with OS X

Removed.

Source: [macos - Bash script absolute path with OS X - Stack Overflow § comment64141768_3572030](https://stackoverflow.com/questions/3572030/bash-script-absolute-path-with-os-x#comment64141768_3572030)

```shell
script_dir_path="$( cd "$( dirname "$0" )"; pwd -P )"
```

### High compression level of zlib

Source: [hdiutil Man Page - macOS - SS64.com](https://ss64.com/osx/hdiutil.html)

```shell
hdiutil create \
    ... \
    -format UDZO \
    -imagekey zlib-level=9
```

## Credits

Projects:

- [create-dmg/create-dmg](https://github.com/create-dmg/create-dmg)
