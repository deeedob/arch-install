#!/bin/bash

source $(pwd)/packages.sh

PACKAGES+=${BASE[@]}\ ${BASE_APPS[@]}\ ${APPS[@]}\ ${GAMING_APPS[@]}

echo ${PACKAGES[@]} | tr " " "\n" > temp
comm -23 <(sort -u temp) <(sort <(wget -q -O - https://aur.archlinux.org/packages.gz | gunzip) <(pacman -Ssq))
rm temp
