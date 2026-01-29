#!/bin/bash
# fix-teclado-elitebook.sh - ABNT2 /? definitivo
sudo apt install x11-xkb-utils -y
xmodmap -e "keycode 94 = slash question slash question U2022"  # Keycode /?
xmodmap -e "clear Lock"
setxkbmap -model abnt2 -layout br -variant abnt2
echo "@ reexec" | sudo at now +1 minute  # Persistente
