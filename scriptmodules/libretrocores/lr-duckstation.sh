#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-duckstation"
rp_module_desc="PlayStation emulator - Duckstation for libretro"
rp_module_help="ROM Extensions: .exe .cue .bin .chd .psf .m3u\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy the required BIOS files\n\nscph5500.bin and\nscph5501.bin and\nscph5502.bin to\n\n$biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!arm"

function depends_lr-duckstation() {
    local depends=(cmake)
    getDepends "${depends[@]}"
}

function sources_lr-duckstation() {
    gitPullOrClone "$md_build" https://github.com/stenzek/duckstation.git
}

function build_lr-duckstation() {
    make clean
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_LIBRETRO_CORE=ON
    make
    md_ret_require=(
        'duckstation_libretro.so'
    )
}

function install_lr-duckstation() {
    md_ret_files=(
        'duckstation_libretro.so'
    )
}

function configure_lr-duckstation() {
    mkRomDir "psx"
    ensureSystemretroconfig "psx"

    addEmulator 0 "$md_id" "psx" "$md_inst/duckstation_libretro.so"
    addSystem "psx"
}
