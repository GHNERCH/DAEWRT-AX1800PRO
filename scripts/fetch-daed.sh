#!/usr/bin/env bash

set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WRT_DIR="${ROOT_DIR}/wrt"

DAED_REPO="${DAED_REPO:-https://github.com/daeuniverse/daed.git}"
DAED_COMMIT="${DAED_COMMIT:-671e65d2fdcd62fe6a3ec18ecda209c5addea898}"
DAED_VERSION="${DAED_VERSION:-2026.07.31}"
DAED_SOURCE="daed-${DAED_VERSION}.tar.gz"

TMP_DIR="${WRT_DIR}/tmp/daed-source"
DL_DIR="${WRT_DIR}/dl"
CLONE_DIR="${TMP_DIR}/daed-${DAED_VERSION}"
ARCHIVE_PATH="${DL_DIR}/${DAED_SOURCE}"

rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}" "${DL_DIR}"

echo "==> Cloning daed"
git clone \
    --recurse-submodules \
    --shallow-submodules \
    "${DAED_REPO}" \
    "${CLONE_DIR}"

cd "${CLONE_DIR}"

echo "==> Checking out daed commit ${DAED_COMMIT}"
git checkout --detach "${DAED_COMMIT}"

echo "==> Initializing submodules"
git submodule sync --recursive
git submodule update --init --recursive

echo "==> Checking embedded web files"

WEB_DIR="${CLONE_DIR}/wing/webrender/web"

if [ ! -d "${WEB_DIR}" ]; then
    echo "ERROR: missing directory: ${WEB_DIR}"
    find "${CLONE_DIR}/wing" -maxdepth 4 -type d -print || true
    exit 1
fi

WEB_FILE="$(find "${WEB_DIR}" -type f \
    ! -name '.gitkeep' \
    ! -name '.keep' \
    -print -quit)"

if [ -z "${WEB_FILE}" ]; then
    echo "ERROR: ${WEB_DIR} contains no embeddable files"
    find "${WEB_DIR}" -maxdepth 5 -print || true
    exit 1
fi

echo "Found web asset: ${WEB_FILE}"

echo "==> Removing Git metadata"
find "${CLONE_DIR}" -type d -name .git -prune -exec rm -rf {} +
rm -f "${CLONE_DIR}/.gitmodules"

echo "==> Creating ${ARCHIVE_PATH}"
rm -f "${ARCHIVE_PATH}"

tar \
    --numeric-owner \
    --owner=0 \
    --group=0 \
    --mode=a-s \
    --sort=name \
    --mtime='UTC 2026-01-01' \
    -czf "${ARCHIVE_PATH}" \
    -C "${TMP_DIR}" \
    "daed-${DAED_VERSION}"

echo "==> Verifying generated archive"
rm -rf "${TMP_DIR}/verify"
mkdir -p "${TMP_DIR}/verify"

tar \
    -xzf "${ARCHIVE_PATH}" \
    -C "${TMP_DIR}/verify"

VERIFY_WEB_FILE="$(
    find "${TMP_DIR}/verify/daed-${DAED_VERSION}/wing/webrender/web" \
        -type f \
        -print -quit
)"

if [ -z "${VERIFY_WEB_FILE}" ]; then
    echo "ERROR: generated archive still does not contain web assets"
    tar -tzf "${ARCHIVE_PATH}" | grep -E 'webrender/web|wing' || true
    exit 1
fi

echo "==> Source archive is ready"
echo "    ${ARCHIVE_PATH}"
echo "==> SHA256:"
sha256sum "${ARCHIVE_PATH}"
