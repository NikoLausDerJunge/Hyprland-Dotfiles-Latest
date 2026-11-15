#!/bin/bash

wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

if wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q '\[MUTED\]'; then
    notify-send 'Microphone' 'Microphone muted'

else
    notify-send 'Microphone' 'Microphone unmuted'
fi
