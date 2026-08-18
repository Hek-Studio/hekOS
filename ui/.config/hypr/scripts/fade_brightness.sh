#!/usr/bin/env bash
brightnessctl -s

floor=10
current="$(brightnessctl -m | awk -F, '{ gsub("%","",$4); print $4 }')"

if [ -n "$current" ] && [ "$current" -gt "$floor" ]; then
    steps=15
    for i in $(seq 1 "$steps"); do
        target=$(( current - (current - floor) * i / steps ))
        brightnessctl set "${target}%" -q
        sleep 0.04
    done
fi

brightnessctl set "${floor}%" -q
