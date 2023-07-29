#! /usr/bin/env bash
set -euo pipefail


ARCHIVE_FILE="archive.txt"
EXPECTED_ARGS="1"
[[ "${#}" -gt "${EXPECTED_ARGS}" ]] && exit
source "./variables.env"

DOWNLOAD_ARCHIVE="${OUTPUT_DIRECTORY}${ARCHIVE_FILE}"


clean() {
    [[ -d "${OUTPUT_DIRECTORY}" ]] \
        && rm -rf "${OUTPUT_DIRECTORY}"
}

validate_environment() {
    devices_count=$(adb devices | wc -l)
    expected_lines="3"

    [[ ! -n "${OUTPUT_DIRECTORY}" ]] && exit
    [[ ! -n "${DEST_DIRECTORY}" ]] && exit
    [[ ! -n "${PLAYLIST}" ]] && exit
    [[ "${devices_count}" -ne "${expected_lines}" ]] && exit

    echo "Running on valid environment ..."
}

download() {
    echo "Downloading music ..."

    [[ ! -d "${OUTPUT_DIRECTORY}" ]] \
        && mkdir "${OUTPUT_DIRECTORY}"

    yt-dlp \
        -x \
        --audio-format mp3 \
        --audio-quality 0 \
        --concurrent-fragments 4 \
        --download-archive "${DOWNLOAD_ARCHIVE}" \
        -P "${OUTPUT_DIRECTORY}" \
        "${PLAYLIST}"
}

synchronize_files() {
    echo "Synchronizing files ..."

    python ./better-adb-sync/src/adbsync.py \
        --del \
        --exclude "${ARCHIVE_FILE}" \
        push "${OUTPUT_DIRECTORY}" "${DEST_DIRECTORY}"
}


case "${1:-sync}" in
    "sync")
        validate_environment
        download
        synchronize_files
        echo "Downloaded music successfully ..."
        exit
        ;;
    "clean")
        clean
        echo "Cleaned successfully ..."
        exit
        ;;
esac
echo "Couldn't recongize the argument given ..."
