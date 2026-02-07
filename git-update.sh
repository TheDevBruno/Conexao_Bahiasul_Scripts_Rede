#!/bin/bash
# git-update.sh - SEM TOKEN + Push Protection compatível

REPO_DIR="${1:-$(pwd)}"
MSG_COMMIT="Atualização automática $(date '+%Y-%m-%d %H:%M')"
SYNC_SCRIPT="$HOME/sync_scripts.sh"

cd "$REPO_DIR" || exit 1
[ ! -d .git ] && { echo "Erro: Não é repo Git."; exit 1; }

echo "🚀 Git Update - SEM TOKEN"

# Verifica mudanças
if git diff --quiet && ! git ls-files --others --exclude-standard | grep .; then
  echo "✅ Nenhuma mudança."
  exit 0
fi

echo "📝 Mudanças detectadas..."
git add . >/dev/null 2>&1

if ! git diff --staged --quiet; then
  git commit -m "$MSG_COMMIT"
  echo "✅ Commit OK"
fi

echo "🔄 Pull + Push..."
if git pull origin main --rebase && git push origin main; then
  echo "✅ PUSH OK!"
  
  [ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" && echo "✅ Sync OK!"
else
  echo "❌ Falhou. Veja erro."
  exit 1
fi

echo "🎉 $(git rev-parse --short HEAD)"

