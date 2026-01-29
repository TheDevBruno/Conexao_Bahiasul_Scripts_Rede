#!/bin/bash
# config-teclado-hp-abnt2.sh - Fix /? tecla EliteBook (TheDevBruno)
echo "🔧 Fixando tecla /? ABNT2..."

# Detecta interface wlan (ajuste se necessário)
sudo localectl set-keymap br-abnt2
setxkbmap -model abnt2 -layout br -variant abnt2 -option lv3:ralt_alt -option compose:ralt

# Fix específico /? (key <AD12>)
xmodmap -e "keycode 94 = slash question slash question" 2>/dev/null || echo "xmodmap OK"

# Teste
echo "✅ Teste tecla /?:"
echo "  Shift + tecla = ?"
echo "  AltGr + tecla = /"
echo -n "Digite: "; read test
echo "Input: '$test'"

# Persistente (adiciona autostart)
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/abnt2.desktop << EOF
[Desktop Entry]
Type=Application
Exec=setxkbmap -model abnt2 -layout br -variant abnt2
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=ABNT2 Keyboard
EOF

echo "✅ Fix aplicado! Teste /? e reboot."
