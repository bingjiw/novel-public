#!/bin/bash
set -e

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

git add "$DST_DIR/$CH.md"
git commit -m "update ch${CH}"
git push

echo "✅ 第${CH}章已更新并发布"
