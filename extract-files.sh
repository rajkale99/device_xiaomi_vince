#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=vince
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/aoscp/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

# default to not sanitizing the vendor folder before extraction
clean_vendor=false

while [ "$1" != "" ]; do
    case $1 in
        -p | --path )           shift
                                SRC=$1
                                ;;
        -s | --section )        shift
                                SECTION=$1
                                clean_vendor=false
                                ;;
        -c | --clean-vendor )   clean_vendor=true
                                ;;
    esac
    shift
done

if [ -z "$SRC" ]; then
    SRC=adb
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false $clean_vendor

extract "$MY_DIR"/proprietary-files.txt "$SRC" "$SECTION"
extract "$MY_DIR"/proprietary-files-qc.txt "$SRC" "$SECTION"

DEVICE_BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

# Hax for oreo cam hal
    patchelf --replace-needed libicuuc.so libicuuc-v27.so $DEVICE_BLOB_ROOT/lib/libMiCameraHal.so
    patchelf --replace-needed libminikin.so libminikin-v27.so $DEVICE_BLOB_ROOT/lib/libMiCameraHal.so
    patchelf --replace-needed libskia.so libskia-v27.so $DEVICE_BLOB_ROOT/lib/libMiCameraHal.so
    patchelf --set-soname libicuuc-v27.so $DEVICE_BLOB_ROOT/lib/libicuuc-v27.so
    patchelf --set-soname libminikin-v27.so $DEVICE_BLOB_ROOT/lib/libminikin-v27.so

"$MY_DIR"/setup-makefiles.sh
