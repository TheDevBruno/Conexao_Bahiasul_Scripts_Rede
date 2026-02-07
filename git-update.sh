#!/bin/bash

# git-update.sh - Atualiza repo Git + sync_scripts com Git config automático
# Configura user.name/email globalmente se não definido

REPO_DIR="${1:-$(pwd)}"
MSG_COMMIT="Atualização automática $(date '+%Y-%m-%d %H:%M')"
SYNC_SCRIPT="$HOME/sync_scripts.sh"

# === CONFIGURAÇÃO AUTOMÁTICA GIT IDENTITY ===
check_git_config() {
  if ! git config --global user.name >/dev/null 2>&1 || ! git config --global user.email >/dev/null 2>&1; then
    echo "Configurando identidade Git globalmente..."
    git config --global user.name "TheDevBruno"
    git config --global user.email "brunosilvacontato2018@gmail.com"
    echo "✓ Identidade Git configurada: TheDevBruno <brunosilvacontato2018@gmail.com>"
  fi
}

cd "$REPO_DIR" || { echo "Erro: Diretório $REPO_DIR não encontrado."; exit 1; }

# Verifica se é repo Git
if [ ! -d .git ]; then
  echo "Erro: $REPO_DIR não é repositório Git válido."
  exit 1
fi

echo "=== Git Update - Conexao_Bahiasul_Scripts_Rede ==="
echo "Repositório: $REPO_DIR"

# Configura Git identity antes de qualquer operação
check_git_config

# Verifica status atual
if git diff --quiet && git diff --staged --quiet && git ls-files --others --exclude-standard | grep . > /dev/null 2>&1; then
  echo "Nenhuma mudança detectada. Repo atualizado."
  exit 0
fi

echo "Mudanças detectadas. Processando..."

# Git add all
git add . > /dev/null 2>&1

# Commit se há mudanças staged
if ! git diff --staged --quiet; then
  git commit -m "$MSG_COMMIT" || { echo "Erro no commit."; exit 1; }
  echo "✓ Commit: $MSG_COMMIT"
else
  echo "Nenhum arquivo para commit."
fi

# Pull com rebase seguro
echo "Sincronizando com remoto..."
if git pull origin main --rebase > /dev/null 2>&1; then
  echo "✓ Pull concluído"
else
  echo "Aviso: Pull pode ter conflitos (continue manualmente)"
fi

# Push
if git push origin main > /dev/null 2>&1; then
  echo "✓ Push concluído!"
  
  # Sync scripts para Desktop/$HOME
  if [ -x "$SYNC_SCRIPT" ]; then
    echo ""
    echo "=== Sincronizando scripts para Desktop ==="
    "$SYNC_SCRIPT"
    echo "✓ Scripts atualizados no Desktop!"
  else
    echo "Aviso: sync_scripts.sh não encontrado em $SYNC_SCRIPT"
  fi
else
  echo "✗ Erro no push. Verifique conexão/autenticação."
  exit 1
fi

echo ""
echo "✅ Processo completo! Repo atualizado + scripts sincronizados."
echo "Status final: $(git status --short)"

