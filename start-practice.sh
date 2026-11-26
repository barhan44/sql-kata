#!/usr/bin/env bash
#
# start-practice.sh — начало ежедневной практики.
#
# Создаёт ветку practice-<дата-время> от master и переключается на неё.
# Использование:
#   ./start-practice.sh            # ветка от локального master
#   ./start-practice.sh <base>     # ветка от другой базовой ветки
#
set -euo pipefail

BASE_BRANCH="${1:-master}"
BRANCH="practice-$(date +%Y%m%d-%H%M%S)"

# Работаем из корня репозитория, откуда бы скрипт ни запустили.
cd "$(git rev-parse --show-toplevel)"

if ! git rev-parse --verify --quiet "$BASE_BRANCH" >/dev/null; then
    echo "Ошибка: базовая ветка '$BASE_BRANCH' не найдена." >&2
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Предупреждение: в рабочем дереве есть незакоммиченные изменения —" >&2
    echo "они будут перенесены в новую ветку." >&2
fi

git switch -c "$BRANCH" "$BASE_BRANCH"

echo "Готово: создана и активна ветка '$BRANCH' (от '$BASE_BRANCH')."
