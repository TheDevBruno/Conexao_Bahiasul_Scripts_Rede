#!/bin/bash
# UPDATE-LITEBEAM-AC v8.7.19 - CORRIGIDO (SCP + cleanup)

set -e  # Para execução em erro

REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"
LITEBEAM_IP="192.168.1.20"
SSH_USER="ubnt"
SSH_PASS="ubnt"
FIRMWARE_VERSION="v8.7.19"
FIRMWARE_FILE="LiteBeam-AC-EU.bin"
FIRMWARE_URL="https://dl.ui.com/firmwares/xm/v${FIRMWARE_VERSION//\./}/LiteBeam-AC-EU.bin"

# FUNÇÃO CLEANUP (DECLARADA PRIMEIRO)
cleanup() {
    echo "🧹 Limpando configurações temporárias..."
    nmcli con down litebeam-temp 2>/dev/null
    nmcli con del litebeam-temp 2>/dev/null
    rm -f /tmp/${FIRMWARE_FILE}
    echo "✅ Cleanup concluído!"
}

# TRAP para garantir cleanup mesmo com Ctrl+C
trap cleanup EXIT INT TERM

clear
echo "🚀 LiteBeam AC Auto Update $FIRMWARE_VERSION"
echo "============================================="

# 1. DETECTA INTERFACE
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
[ -z "$IFACE" ] && { echo "❌ Interface ethernet não encontrada!"; exit 1; }
echo "📡 Interface: $IFACE"

# 2. CONFIGURA IP ESTÁTICO 192.168.1.10
echo "🔧 Configurando IP 192.168.1.10..."
nmcli con del litebeam-temp 2>/dev/null
nmcli con add type ethernet ifname "$IFACE" con-name litebeam-temp \
  ipv4.method manual ipv4.addresses "192.168.1.10/24" ipv4.gateway "192.168.1.1"
nmcli con up litebeam-temp
sleep 3

ip addr show "$IFACE" | grep 192.168.1.10 || { echo "❌ Erro IP!"; exit 1; }

# 3. TESTA CONECTIVIDADE
echo "🔍 Testando LiteBeam $LITEBEAM_IP..."
if ! ping -c 3 "$LITEBEAM_IP" > /dev/null 2>&1; then
    echo "❌ Antena OFFLINE!"
    echo "  - Cabo conectado?"
    echo "  - Antena ligada?"
    exit 1
fi
echo "✅ Antena online: $LITEBEAM_IP"

# 4. VERIFICA VERSÃO ATUAL (SSH)
echo "🔍 Verificando versão atual da antena..."
VERSION_ATUAL=$(sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  "$SSH_USER@$LITEBEAM_IP" "cat /etc/version" 2>/dev/null | head -1 || echo "DESCONHECIDO")
echo "📱 Versão ATUAL da antena: $VERSION_ATUAL"
echo "🎯 Versão NOVA: $FIRMWARE_VERSION"

# 5. BAIXA FIRMWARE LOCALMENTE (MÉTODO MAIS ESTÁVEL)
echo "📥 Baixando firmware $FIRMWARE_VERSION..."
if wget -T 30 -O "/tmp/$FIRMWARE_FILE" "$FIRMWARE_URL"; then
    echo "✅ Firmware baixado: /tmp/$FIRMWARE_FILE"
else
    echo "❌ Falha download! Usando método SSH direto..."
    # MÉTODO ALTERNATIVO: wget direto na antena
    sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$LITEBEAM_IP" \
      "wget -O /tmp/fwupdate.bin '$FIRMWARE_URL' && sync"
fi

# 6. TRANSFERE FIRMWARE VIA SCP (CORRIGIDO)
echo "📤 Transferindo firmware via SCP..."
if [ -f "/tmp/$FIRMWARE_FILE" ]; then
    scp_res=$(timeout 30 sshpass -p "$SSH_PASS" scp -o StrictHostKeyChecking=no \
      "/tmp/$FIRMWARE_FILE" "$SSH_USER@$LITEBEAM_IP:/tmp/fwupdate.bin" 2>&1)
    SCP_EXIT=$?
    
    if [ $SCP_EXIT -eq 0 ]; then
        echo "✅ Firmware transferido!"
    else
        echo "⚠️  SCP falhou, tentando wget direto na antena..."
        sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$LITEBEAM_IP" \
          "rm -f /tmp/fwupdate.bin; wget -O /tmp/fwupdate.bin '$FIRMWARE_URL'"
    fi
else
    echo "❌ Arquivo firmware não encontrado localmente!"
    exit 1
fi

# 7. APLICA UPDATE
echo "🔄 Aplicando firmware v$FIRMWARE_VERSION..."
sshpass -p "$SSH_PASS" ssh -o StrictHostKeyChecking=no "$SSH_USER@$LITEBEAM_IP" "
    if [ -f /tmp/fwupdate.bin ]; then
        chmod +x /tmp/fwupdate.bin
        echo 'Iniciando update...'
        /tmp/fwupdate.bin apply &
        echo '✅ UPDATE INICIADO! Antena reiniciará em 30-60s'
        echo 'Aguarde 3-5 minutos antes de testar novamente'
    else
        echo '❌ Arquivo fwupdate.bin não encontrado!'
        exit 1
    fi
"

RESULT=$?
cleanup

if [ $RESULT -eq 0 ]; then
    whiptail --msgbox "🎉 LiteBeam AC ATUALIZADO v$FIRMWARE_VERSION!

Aguarde 3-5min para reinício completo.

IP rede restaurado (DHCP)" 12 60 0
else
    whiptail --msgbox "⚠️  Possível falha no update!
Verifique manualmente: $LITEBEAM_IP" 12 60 0
fi

echo "✅ Script concluído!"

