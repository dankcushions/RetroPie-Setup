#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="duckstation"
rp_module_desc="PlayStation emulator DuckStation"
rp_module_help="ROM Extensions: .pbp .cue .bin .chd .img\n\nCopy your PlayStation roms to $romdir/psx\n\nCopy the required BIOS file to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/stenzek/duckstation/master/LICENSE"
rp_module_section="exp"
rp_module_flags=""

function depends_duckstation() {
    local depends=(cmake libsdl2-dev libsnappy-dev pkg-config libevdev-dev libgbm-dev libdrm-dev)
    getDepends "${depends[@]}"
}

function sources_duckstation() {
    gitPullOrClone "$md_build" https://github.com/stenzek/duckstation.git dev
}

function build_duckstation() {
    #cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_DISCORD_PRESENCE=OFF -DUSE_X11=OFF -DUSE_DRMKMS=ON -DBUILD_NOGUI_FRONTEND=ON -DBUILD_QT_FRONTEND=OFF
    #make clean
    #make
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_NOGUI_FRONTEND=ON -DBUILD_QT_FRONTEND=OFF -DUSE_DRMKMS=ON -GNinja .
    ninja -j4

    md_ret_require="$md_build/bin/duckstation-nogui"
}

function install_duckstation() {
    md_ret_files=(
        'LICENSE'
        'README.md'
        'bin'
    )
}

function configure_duckstation() {
    mkRomDir "psx"
    moveConfigDir "$md_inst/bin/bios" "$biosdir"
    # create config file
    local config="$md_conf_root/psx/duckstation.cfg"
    touch "$config"
    chown -R $user:$user "$config"
    # chris, needed?
    chown -R $user:$user "$md_inst/bin"

    addEmulator 0 "$md_id" "psx" "LIBGL_ALWAYS_SOFTWARE=1 PREFER_GLES_CONTEXT=1 $md_inst/bin/duckstation-nogui -portable -settings $config -- %ROM%"
    addSystem "psx"
}
