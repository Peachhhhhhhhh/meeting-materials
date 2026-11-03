#!/usr/bin/env bash
# 导出 Supabase 全库为 JSON（用于备份/迁移）
set -euo pipefail
cd "$(dirname "$0")/.."

SUPABASE_URL="${SUPABASE_URL:-https://kcothoexsnhvrlzkzttl.supabase.co}"
SUPABASE_KEY="${SUPABASE_KEY:-sb_publishable_35ODEWDAb0cNftVByeIxKg_o-4W9rq7}"

OUT="backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

for t in materials leader_notes meeting_types departments uploaders tags; do
  printf "导出 %-15s" "$t"
  curl -sS "${SUPABASE_URL}/rest/v1/${t}?select=*" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -o "${OUT}/${t}.json"
  printf " -> %s.json\n" "$t"
done

echo "完成：${OUT}"
