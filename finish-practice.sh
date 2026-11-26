#!/usr/bin/env bash
#
# finish-practice.sh — завершение ежедневной практики.
#
# Коммитит все изменения (новые, изменённые, удалённые файлы) с их перечнем
# в теле сообщения, ничего не пушит и возвращает на master.
#
# Использование:
#   ./finish-practice.sh
#
set -euo pipefail

BASE_BRANCH="master"

cd "$(git rev-parse --show-toplevel)"

BRANCH="$(git symbolic-ref --quiet --short HEAD || true)"
if [ -z "$BRANCH" ]; then
    echo "Ошибка: HEAD в состоянии detached; переключитесь на practice-ветку." >&2
    exit 1
fi

if [ "$BRANCH" = "$BASE_BRANCH" ]; then
    echo "Ошибка: вы на '$BASE_BRANCH'. Коммит практики делается из practice-ветки." >&2
    echo "Начните её через ./start-practice.sh." >&2
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    git add -A

    # Перечень всех изменений — после add, чтобы учитывались и новые файлы.
    CHANGES="$(git status --short)"

    git commit --quiet -m "practice: $BRANCH" -m "Изменения:
$CHANGES

Co-Authored-By: Claude Code <noreply@anthropic.com>"

    echo "Создан коммит $(git rev-parse --short HEAD) в ветке '$BRANCH':"
    printf '%s\n' "$CHANGES"
else
    echo "Незакоммиченных изменений нет — коммит не создан."
fi

git switch --quiet "$BASE_BRANCH"
echo "Готово: вы снова на '$BASE_BRANCH'. Ветка '$BRANCH' не запушена."
