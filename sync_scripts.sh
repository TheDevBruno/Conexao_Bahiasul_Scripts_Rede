#!/bin/bash
# Sincroniza SOMENTE scripts .sh a partir do diretório oficial
REPO_DIR="$HOME/Downloads/Conexao_Bahiasul_Scripts_Rede"

echo "🔄 Sincronizando scripts a partir de: $REPO_DIR"

# Aqui você lista todos os lugares onde eventualmente usou cópias diretas de .sh
DESTINOS=(
  "$HOME"                       # se já rodou .sh daqui
)

for DEST in "${DESTINOS[@]}"; do
  if [ -d "$DEST" ]; then
    echo "➡ Atualizando: $DEST"
    cp "$REPO_DIR"/*.sh "$DEST"/ 2>/dev/null
    chmod +x "$DEST"/*.sh 2>/dev/null
  fi
done

echo "✅ Scripts .sh sincronizados (Desktop NÃO recebe mais scripts)."

