#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(CDPATH= cd -- "${SCRIPT_DIR}/../../.." && pwd)"

# shellcheck source=machine.conf
source "${SCRIPT_DIR}/machine.conf"
# shellcheck source=scripts/machine-image.sh
source "${REPO_ROOT}/scripts/machine-image.sh"

[[ -n "${QEMU_EXECUTABLE:-}" ]] || machine_image_die \
    "QEMU_EXECUTABLE must name the absolute path to qemu-system-riscv64"
[[ "${QEMU_EXECUTABLE}" = /* ]] || \
    machine_image_die "QEMU_EXECUTABLE must be an absolute path"
[[ -x "${QEMU_EXECUTABLE}" ]] || \
    machine_image_die "QEMU executable is not executable: ${QEMU_EXECUTABLE}"

machine_image_prepare \
    "${REPO_ROOT}" \
    "${ARCHITECTURE}" \
    "${QEMU_MACHINE}" \
    "${RELEASE_ASSET_PREFIX}" \
    "${REQUIRED_IMAGES[@]}"

machine_image_exec "${QEMU_EXECUTABLE}" \
    -machine "${QEMU_MACHINE}" \
    -display none \
    -monitor none \
    -serial stdio \
    -bios "${MACHINE_IMAGE_DIR}/fw_dynamic.bin" \
    -kernel "${MACHINE_IMAGE_DIR}/u-boot.bin" \
    -dtb "${MACHINE_IMAGE_DIR}/k3-pico-itx-qemu-uboot.dtb" \
    -drive \
    "file=${MACHINE_IMAGE_DIR}/k3-qemu-sd.raw,if=sd,format=raw,snapshot=on" \
    -no-reboot \
    "$@"
