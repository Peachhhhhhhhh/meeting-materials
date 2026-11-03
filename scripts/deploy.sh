#!/usr/bin/env bash
# 一键发布到 Cloudflare Pages（生产域名不变）
set -euo pipefail
cd "$(dirname "$0")/.."

: "${CLOUDFLARE_API_TOKEN:?请先执行 export CLOUDFLARE_API_TOKEN=<你的 Pages:Edit Token>}"
export CLOUDFLARE_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-88ccccf2373e93f64b1378c41511b91f}"

if ! command -v wrangler >/dev/null 2>&1; then
  echo "未检测到 wrangler，正在安装（需要 Node.js 18+）..."
  npm install -g wrangler@3.75.0
fi

cd public
wrangler pages deploy . --project-name=meeting-materials --branch=main
