#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

function onstart_duckstation_joystick() {
    # write temp file header
    echo "; ${DEVICE_NAME}_START " > /tmp/dstempconfig.cfg
    echo "[${DEVICE_NAME}]" >> /tmp/dstempconfig.cfg
}

function map_duckstation_joystick() {
    local input_name="$1"
    local input_type="$2"
    local input_id="$3"
    local input_value="$4"

    local keys
    local dir
    case "$input_name" in
        up)
            keys=("ButtonUp")
            dir=("Up")
            ;;
        down)
            keys=("ButtonDown")
            dir=("Down")
            ;;
        left)
            keys=("ButtonLeft")
            dir=("Left")
            ;;
        right)
            keys=("ButtonRight")
            dir=("Right")
            ;;
        b)
            keys=("ButtonCross")
            ;;
        y)
            keys=("ButtonSquare")
            ;;
        a)
            keys=("ButtonCircle")
            ;;
        x)
            keys=("ButtonTriangle")
            ;;
        leftbottom|leftshoulder)
            keys=("ButtonL1")
            ;;
        rightbottom|rightshoulder)
            keys=("ButtonR1")
            ;;
        lefttop|lefttrigger)
            keys=("ButtonL2")
            ;;
        righttop|righttrigger)
            keys=("ButtonR2")
            ;;
        start)
            keys=("ButtonStart")
            ;;
        leftanalogleft)
            keys=("AxisXLeft")
            dir=("Left")
            ;;
        leftanalogright)
            keys=("AxisXLeft")
            dir=("Right")
            ;;
        leftanalogup)
            keys=("AxisYLeft")
            dir=("Up")
            ;;
        leftanalogdown)
            keys=("AxisYLeft")
            dir=("Down")
            ;;
        rightanalogleft)
            keys=("AxisXRight")
            dir=("Left")
            ;;
        rightanalogright)
            keys=("AxisXRight")
            dir=("Right")
            ;;
        rightanalogup)
            keys=("AxisYRight")
            dir=("Up")
            ;;
        rightanalogdown)
            keys=("AxisYRight")
            dir=("Down")
            ;;
        leftthumb)
            keys=("ButtonL3")
            ;;
        rightthumb)
            keys=("ButtonR3")
            ;;
        *)
            return
            ;;
    esac

    local key
    local value
    #iniConfig " = " "" "/tmp/dskeys.cfg"
    for key in "${keys[@]}"; do
        # read key value. Axis takes two key/axis values.
        iniGet "$key"
        case "$input_type" in
            axis)
                # key "X/Y Axis" needs different button naming
                if [[ "$key" == *Axis* ]]; then
                    # if there is already a "-" axis add "+" axis value
                    if   [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}${input_id}+)"
                    # if there is already a "+" axis add "-" axis value
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="axis(${input_id}-,${ini_value}"
                    # if there is no ini_value add "+" axis value
                    elif [[ "$input_value" == "1" ]]; then
                        value="${input_id}+)"
                    else
                        value="axis(${input_id}-,"
                    fi
                elif [[ "$input_value" == "1" ]]; then
                    value="axis(${input_id}+) ${ini_value}"
                else
                    value="axis(${input_id}-) ${ini_value}"
                fi
                ;;
            hat)
                if [[ "$key" == *Axis* ]]; then
                    if   [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}${dir})"
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="hat(${input_id} ${dir} ${ini_value}"
                    elif [[ "$dir" == "Up" || "$dir" == "Left" ]]; then
                        value="hat(${input_id} ${dir} "
                    elif [[ "$dir" == "Right" || "$dir" == "Down" ]]; then
                        value="${dir})"
                    fi
                else
                    if [[ -n "$dir" ]]; then
                        value="hat(${input_id} ${dir}) ${ini_value}"
                    fi
                fi
                ;;
            *)
                if [[ "$key" == *Axis* ]]; then
                    if   [[ "$ini_value" == *\(* ]]; then
                        value="${ini_value}${input_id})"
                    elif [[ "$ini_value" == *\)* ]]; then
                        value="button(${input_id},${ini_value}"
                    elif [[ "$dir" == "Up" || "$dir" == "Left" ]]; then
                        value="button(${input_id},"
                    elif [[ "$dir" == "Right" || "$dir" == "Down" ]]; then
                        value="${input_id})"
                    fi
                else
                    value="button(${input_id}) ${ini_value}"
                fi
                ;;
        esac

        iniSet "$key" "$value"
    done
}

function onend_duckstation_joystick() {
    echo "; ${DEVICE_NAME}_END " >> /tmp/dstempconfig.cfg
    echo "" >> /tmp/dstempconfig.cfg

    # abort if old device config cannot be deleted.
    local file="$configdir/psx/InputAutoCfg.ini"
    if [[ -f "$file" ]]; then
        # backup current config file
        cp "$file" "${file}.bak"
        sed -i /"${DEVICE_NAME}_START"/,/"${DEVICE_NAME}_END"/d "$file"
        if grep -q "$DEVICE_NAME" "$file" ; then
            rm /tmp/dstempconfig.cfg
            return
        fi
    fi

    # append temp device configuration to InputAutoCfg.ini
    cat /tmp/dstempconfig.cfg >> "$file"
    rm /tmp/dstempconfig.cfg
}
