#!/bin/bash
# config-teclado-abnt2.sh - Configura ABNT2 Mint 22 (TheDevBruno)
# Uso: ./config-teclado-abnt2.sh

echo "🔧 Configurando Teclado ABNT2 (Português Brasil)..."

# Backup layout atual
sudo cp /etc/default/keyboard /etc/default/keyboard.bak 2>/dev/null

# Configuração permanente
sudo sed -i 's/XKBDEFAULTLAYOUT=.*/XKBDEFAULTLAYOUT="br"/' /etc/default/keyboard
sudo sed -i 's/XKBVARIANT=.*/XKBVARIANT="abnt2"/' /etc/default/keyboard
sudo sed -i 's/XKBMODEL=.*/XKBMODEL="abnt2"/' /etc/default/keyboard
sudo sed -i 's/XKBOPTIONS=.*/XKBOPTIONS="lv3:ralt_switch"/' /etc/default/keyboard

# Aplicar imediato
setxkbmap -model abnt2 -layout br -variant abnt2 -option lv3:ralt_switch

# Recarregar
sudo service keyboard-setup restart 2>/dev/null || sudo systemctl restart display-manager

# Teste caracteres
echo "✅ Teste ABNT2 (copie e cole):"
echo "AltGr+Q = /    Shift+2 = \"    AltGr+1 = |    Shift+; = :"
echo -n "Digite teste: "; read input
echo "Seu input: '$input'"

echo "✅ Configurado! Reboot recomendado: sudo reboot"
