#!/bin/bash
REPO_DIR="${1:-$(pwd)}"
MSG_COMMIT="Atualização automática $(date '+%Y-%m-%d %H:%M')"
SYNC_SCRIPT="$HOME/sync_scripts.sh"

cd "$REPO_DIR" || exit 1
[ ! -d .git ] && { echo "Erro: Não é repo Git."; exit 1; }

echo "🚀 Git Update - Bahiasul Scripts"

git add . >/dev/null 2>&1
if ! git diff --staged --quiet; then
  git commit -m "$MSG_COMMIT" && echo "✅ Commit OK"
fi

echo "🔄 Pull + Push..."
if git pull origin main --rebase && git push origin main; then
  echo "✅ PUSH CONCLUÍDO!"
  [ -x "$SYNC_SCRIPT" ] && "$SYNC_SCRIPT" && echo "✅ Scripts sincronizados Desktop!"
else
  echo "❌ Falhou"
  exit 1
fi

echo "🎉 $(git rev-parse --short HEAD)"

