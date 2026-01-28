#!/bin/bash
set -e

# 同步远程仓库
git pull origin main --no-edit --no-rebase

if [ -z "$1" ]; then
  echo "用法: ./publish.sh 01"
  exit 1
fi

CH=$1
SRC_DIR="../novel/正文章节"
DST_DIR="chapters"

mkdir -p "$DST_DIR"

SRC_FILE=$(ls "$SRC_DIR"/第${CH}章*.md | head -n 1)

if [ ! -f "$SRC_FILE" ]; then
  echo "找不到 第${CH}章"
  exit 1
fi

cp "$SRC_FILE" "$DST_DIR/$CH.md"

# 更新 index.md
BASENAME=$(basename "$SRC_FILE" .md)
TITLE_TEXT=${BASENAME//-/ }
LINK_LINE="- [${TITLE_TEXT}](chapters/${CH}.html)"
INDEX_FILE="index.md"

if [ -f "$INDEX_FILE" ]; then
  if ! grep -q "chapters/${CH}.html" "$INDEX_FILE"; then
    # 在 "连载中" 这一行之前插入链接
    awk -v line="$LINK_LINE" '/连载中/ { print line } { print }' "$INDEX_FILE" > index.tmp && mv index.tmp "$INDEX_FILE"
    echo "✅ 已将章节添加到目录"
  else
    echo "ℹ️ 目录中已存在该章节"
  fi
fi

git add "$DST_DIR/$CH.md" "$INDEX_FILE"
git commit -m "update ch${CH}" || echo "没有新的变更，直接推送"
git push

echo "✅ 第${CH}章已更新并发布"
