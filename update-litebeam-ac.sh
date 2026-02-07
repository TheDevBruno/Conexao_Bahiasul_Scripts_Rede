#!/bin/bash
# update-litebeam-ac.sh - Atualização AUTOMÁTICA LiteBeam AC v8.7.19 via SSH
# Repositório: /home/bahiasul/Downloads/Conexao_Bahiasul_Scripts_Rede/Atualizações Ubiquit Litebeam AC

clear
echo "=== ATUALIZAÇÃO LiteBeam AC v8.7.19 ==="
echo "Notebook Técnico - Linux Mint - Bahiasul24"
echo

# Configurações
FW_DIR="/home/bahiasul/Downloads/Conexao_Bahiasul_Scripts_Rede/Atualizações Ubiquit Litebeam AC"
FW_FILE="WA.v8.7.19.48279.250811.0636.bin"  # Nome esperado do firmware
ANTENA_IP="192.168.1.20"
USER="ubnt"
PASS="ubnt"
CON_NAME="ubnt-update"

# Detecta interface ethernet
IFACE=$(nmcli dev | grep ethernet | head -1 | awk '{print $1}')
if [ -z "$IFACE" ]; then
    echo "❌ ERRO: Interface ethernet não encontrada!"
    read -p "Pressione ENTER para sair..."
    exit 1
fi
echo "✅ Interface: $IFACE"

# Verifica arquivo firmware
if [ ! -f "$FW_DIR/$FW_FILE" ]; then
    echo "❌ ERRO: Firmware $FW_FILE não encontrado em $FW_DIR"
    echo "Verifique o diretório e nome do arquivo"
    read -p "Pressione ENTER para sair..."
    exit 1
fi
echo "✅ Firmware: $FW_DIR/$FW_FILE"

# Configura IP estático 192.168.1.10
echo "🔧 Configurando IP 192.168.1.10..."
nmcli con del $CON_NAME 2>/dev/null
nmcli con add type ethernet ifname $IFACE con-name $CON_NAME \
    ipv4.method manual ipv4.addresses 192.168.1.10/24 ipv4.gateway 192.168.1.1
nmcli con up $CON_NAME
sleep 3

# Testa conectividade
if ! ping -c 3 $ANTENA_IP >/dev/null 2>&1; then
    echo "❌ ANTENA OFFLINE em $ANTENA_IP"
    echo "- Reset físico da antena"
    echo "- Cabo e fonte OK?"
    nmcli con down $CON_NAME 2>/dev/null
    read -p "Pressione ENTER para sair..."
    exit 1
fi
echo "✅ Antena online: $ANTENA_IP"

# === VERIFICA VERSÃO ATUAL ===
echo "🔍 Verificando versão atual da antena..."
CURRENT_VER=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
    $USER@$ANTENA_IP "cat /etc/version" 2>/dev/null | grep -o 'v[0-9.]*' || echo "DESCONHECIDO")
echo "📱 Versão ATUAL da antena: $CURRENT_VER"
echo "🎯 Versão NOVA: v8.7.19"

if [[ "$CURRENT_VER" == *"8.7.19"* ]]; then
    echo "ℹ️  Antena já está na versão v8.7.19"
    read -p "Continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Cancelado."
        cleanup
        exit 0
    fi
fi

# === TRANSFERÊNCIA E ATUALIZAÇÃO ===
echo "📤 Transferindo firmware via SCP..."
scp -o StrictHostKeyChecking=no "$FW_DIR/$FW_FILE" $USER@$ANTENA_IP:/tmp/fwupdate.bin >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ ERRO na transferência SCP"
    cleanup
    exit 1
fi
echo "✅ Firmware transferido para /tmp/fwupdate.bin"

echo "🔄 Iniciando atualização AUTOMÁTICA..."
echo "⚠️  NÃO DESLIGUE a antena por 5 minutos!"
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no $USER@$ANTENA_IP << EOF
echo "Firmware em /tmp: \$(ls -lh /tmp/fwupdate.bin)"
chmod 777 /tmp/fwupdate.bin
/var/tmp/fwupdate -m /tmp/fwupdate.bin &
echo "Atualização iniciada em background..."
echo "Reboot em 60s..."
sleep 10
EOF

echo ""
echo "✅ COMANDO DE ATUALIZAÇÃO EXECUTADO!"
echo "⏳ Aguarde 3-5 minutos para reinício completo..."
echo "💡 IP 192.168.1.10 permanece ativo"

# Restaura rede (OPCIONAL - comentado para manter IP fixo)
# cleanup

read -p "Pressione ENTER após verificar a nova versão..."
cleanup
echo "✅ update-litebeam-ac.sh CONCLUÍDO!"
echo "Volte ao tecnico-master.sh"

