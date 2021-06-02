#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# based on mupen64plus launch script

ROM="$1"

rootdir="/opt/retropie"
configdir="$rootdir/configs"
config="$configdir/psx/duckstation.ini"
inputconfig="$configdir/psx/InputAutoCfg.ini"
datadir="$HOME/RetroPie"
romdir="$datadir/roms"

source "$rootdir/lib/inifuncs.sh"

# arg 1: hotkey name, arg 2: device number, arg 3: retroarch auto config file
function getBind() {
    local key="$1"
    local ds_hotkey="Controller$2"
    local file="$3"

    iniConfig " = " "" "$file"

    # search hotkey enable button
    local hotkey
    local input_type
    local i=0
    for hotkey in input_enable_hotkey "$key"; do
        for input_type in "_btn" "_axis"; do
            iniGet "${hotkey}${input_type}"
            ini_value="${ini_value// /}"
            if [[ -n "$ini_value" ]]; then
                ini_value="${ini_value//\"/}"
                case "$input_type" in
                    _axis)
                        ds_hotkey+="A${ini_value:1}${ini_value:0:1}"
                    ;;
                    _btn)
                        # if ini_value contains "h" it should be a hat device
                        if [[ "$ini_value" == *h* ]]; then
                            local dir="${ini_value:2}"
                            ini_value="${ini_value:1}"
                            case $dir in
                                up)
                                    dir="1"
                                    ;;
                                right)
                                    dir="2"
                                    ;;
                                down)
                                    dir="4"
                                    ;;
                                left)
                                    dir="8"
                                    ;;
                            esac
                            ds_hotkey+="H${ini_value}V${dir}"
                        fi
                    ;;
                esac
            fi
        done
        [[ "$i" -eq 0 ]] && ds_hotkey+="/"
        ((i++))
    done
    echo "$ds_hotkey"
}

function remap() {
    local device
    local devices
    local device_num

    # get lists of all present js device numbers and device names
    # get device count
    while read -r device; do
        device_num="${device##*/js}"
        devices[$device_num]=$(</sys/class/input/js${device_num}/device/name)
    done < <(find /dev/input -name "js*")

    # read retroarch auto config file and use config
    # for duckstation.ini
    local file
    local bind
    local hotkeys_rp=( "input_exit_emulator" "input_menu_toggle" "input_reset" )
    local hotkeys_ds=( "PowerOff" "OpenQuickMenu" "Reset" )
    local i
    local j

    iniConfig " = " "" "$config"
    if ! grep -q "\[Hotkeys\]" "$config"; then
        echo "[Hotkeys]" >> "$config"
    fi

    for i in {0..2}; do
        bind=""
        for device_num in "${!devices[@]}"; do
            # get name of retroarch auto config file
            file=$(grep -lF "\"${devices[$device_num]}\"" "$configdir/all/retroarch-joypads/"*.cfg)
            if [[ -f "$file" ]]; then
                if [[ -n "$bind" && "$bind" != *, ]]; then
                    bind+=","
                fi
                bind+=$(getBind "${hotkeys_rp[$i]}" "${device_num}" "$file")
            fi
        done
        # write hotkey to duckstation.ini
        iniConfig " = " "" "$config"
        iniSet "${hotkeys_ds[$i]}" "$bind"
    done
}

getAutoConf duckstation_hotkeys && remap

"$rootdir/emulators/duckstation/bin/duckstation-nogui" -portable -settings ${config} -- "$ROM"
