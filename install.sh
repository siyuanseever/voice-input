#!/usr/bin/env bash
# 安装 voice-input：检查依赖、准备常用词表、在 ~/.hammerspoon/init.lua 里加载本仓库。
# 重复运行没有副作用。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/voice-input"
HS_INIT="$HOME/.hammerspoon/init.lua"

# 提示文字跟系统首选语言走：中文用中文，其它用英文（和 hammerspoon/voice_i18n.lua 一样）
if defaults read -g AppleLanguages 2>/dev/null | sed -n 2p | grep -q '"zh'; then ZH=1; else ZH=; fi
t() { if [ -n "$ZH" ]; then printf '%s' "$1"; else printf '%s' "$2"; fi; }

echo "==> $(t 检查依赖 'Checking dependencies')"
missing=()
for bin in ffmpeg jq; do command -v "$bin" >/dev/null 2>&1 || missing+=("$bin"); done
[ -d /Applications/Hammerspoon.app ] || missing+=("--cask hammerspoon")
if [ "${#missing[@]}" -gt 0 ]; then
  echo "$(t '缺少依赖，先装上：' 'Missing dependencies. Install them first:')" >&2
  for m in "${missing[@]}"; do echo "  brew install $m" >&2; done
  exit 1
fi

echo "==> $(t 常用词表 Vocabulary)"
mkdir -p "$CONFIG_DIR"
if [ -e "$CONFIG_DIR/vocab.txt" ]; then
  echo "    $(t "已有 $CONFIG_DIR/vocab.txt，不覆盖" "$CONFIG_DIR/vocab.txt already exists; left as is")"
else
  example="$REPO/vocab.example.txt"
  [ -n "$ZH" ] || example="$REPO/vocab.example.en.txt"
  cp "$example" "$CONFIG_DIR/vocab.txt"
  echo "    $(t "复制示例到 $CONFIG_DIR/vocab.txt" "Copied the example to $CONFIG_DIR/vocab.txt")"
fi

echo "==> $(t '在 Hammerspoon 里加载' 'Loading in Hammerspoon')"
mkdir -p "$HOME/.hammerspoon"
touch "$HS_INIT"
if grep -q 'require("voice")' "$HS_INIT"; then
  echo "    $(t "$HS_INIT 里已经加载过了" "Already loaded in $HS_INIT")"
else
  cat >>"$HS_INIT" <<LUA

-- voice-input：按键说话，转写后粘贴到光标处（${REPO}）
package.path = "$REPO/hammerspoon/?.lua;" .. package.path
require("voice")
LUA
  echo "    $(t "已追加到 $HS_INIT" "Added to $HS_INIT")"
fi

if [ -z "$ZH" ]; then
  cat <<'MSG'

Done. Next:
  1. Open Hammerspoon (if it is already running: menu bar icon → Reload Config)
  2. System Settings → Privacy & Security: allow Hammerspoon under Accessibility and Microphone
  3. Menu bar microphone → Open Panel → Settings: enter a Gemini key (or an Alibaba Cloud Model Studio key), click Test
  4. Tap Right Command, speak, tap it again; the text is pasted at the cursor
MSG
  exit 0
fi
cat <<'MSG'

装好了。接下来：
  1. 打开 Hammerspoon（已开着就点菜单栏图标 → Reload Config）
  2. 系统设置 → 隐私与安全性：给 Hammerspoon 打开「辅助功能」和「麦克风」
  3. 菜单栏麦克风图标 → 打开面板 → 设置：填阿里云百炼 Key（或 Gemini Key），点「测试」
  4. 按一下右 Command 开始说话，再按一下结束，文字会粘贴到光标处
MSG
