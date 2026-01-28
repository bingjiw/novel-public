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

# 重建 index.md （全量刷新以保证顺序正确）
echo "# 智能替代（The Replacement of Intelligence）" > index.new
echo "" >> index.new
echo "## 已发布章节" >> index.new

# 按文件名排序遍历源目录
for f in $(ls "$SRC_DIR"/第*章*.md | sort); do
  # 提取文件名
  fname=$(basename "$f")
  # 提取标题文本：去掉 .md，把 - 换成空格
  title=${fname%.md}
  title=${title//-/ }
  
  # 提取章节号 (匹配第一个数字串)
  if [[ "$fname" =~ 第([0-9]+)章 ]]; then
     chnum="${BASH_REMATCH[1]}"
     echo "- [${title}](chapters/${chnum}.html)" >> index.new
  fi
done

echo "" >> index.new
echo "连载中，未完待续 ……" >> index.new

mv index.new index.md

git add "$DST_DIR/$CH.md" index.md
git commit -m "update ch${CH}" || echo "没有新的变更，直接推送"
git push

echo "✅ 第${CH}章已更新并发布"
