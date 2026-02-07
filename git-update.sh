#!/bin/bash

# git-update.sh - Push SILENCIOSO com token embutido + sync_scripts
REPO_DIR="${1:-$(pwd)}"
MSG_COMMIT="Atualização automática $(date '+%Y-%m-%d %H:%M')"
SYNC_SCRIPT="$HOME/sync_scripts.sh"
GITHUB_USER="TheDevBruno"
GITHUB_TOKEN="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"
REPO_NAME="Conexao_Bahiasul_Scripts_Rede"

# === CONFIG GIT IDENTITY ===
check_git_config() {
  if ! git config --global user.name >/dev/null 2>&1; then
    git config --global user.name "$GITHUB_USER"
    git config --global user.email "brunosilvacontato2018@gmail.com"
    echo "✓ Git identity configurada"
  fi
}

# === SETUP AUTENTICAÇÃO TOKEN ===
setup_auth() {
  REMOTE_URL=$(git remote get-url origin)
  TOKEN_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
  
  if [[ "$REMOTE_URL" != *"$GITHUB_TOKEN"* ]]; then
    echo "Configurando token no remote..."
    git remote set-url origin "$TOKEN_URL"
    git config credential.helper store
    echo "✓ Token configurado - push silencioso ativado"
  fi
}

cd "$REPO_DIR" || { echo "Erro: $REPO_DIR não encontrado."; exit 1; }

[ ! -d .git ] && { echo "Erro: Não é repo Git."; exit 1; }

echo "🚀 Git Update - $REPO_NAME"

check_git_config
setup_auth

# Verifica mudanças
if git diff --quiet HEAD && ! git ls-files --others --exclude-standard | grep .; then
  echo "✅ Nenhuma mudança. Repo atualizado."
  exit 0
fi

echo "📝 Mudanças detectadas..."

# Workflow silencioso
git add . >/dev/null 2>&1

if ! git diff --staged --quiet; then
  git commit -m "$MSG_COMMIT"
  echo "✅ Commit: $MSG_COMMIT"
fi

echo "🔄 Pull + Push silencioso..."
git pull origin main --rebase >/dev/null 2>&1

# PUSH DEFINITIVO SEM PROMPT
if GIT_TERMINAL_PROMPTS=0 git push origin main >/dev/null 2>&1; then
  echo "✅ PUSH CONCLUÍDO!"
  
  # Sync automático Desktop
  if [ -x "$SYNC_SCRIPT" ]; then
    echo "📱 Sincronizando scripts Desktop..."
    "$SYNC_SCRIPT"
    echo "✅ Scripts atualizados no Desktop!"
  fi
else
  echo "❌ Push falhou. Token inválido?"
  exit 1
fi

echo "🎉 FINALIZADO! $(git rev-parse --short HEAD)"

