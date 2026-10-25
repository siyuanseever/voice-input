-- 界面语言：中文 / English。
-- 用法：local t = require("voice_i18n").t;  t("已取消", "Cancelled")
-- 中英两份写在一起，不另建词条表：改一处文字时另一种语言就在旁边，不会漏改。
--
-- 选哪种：config.json 的 language（"zh" / "en"），没设或是 "auto" 就看系统首选语言，
-- 首选语言是中文（zh-Hans、zh-Hant……）用中文，其它一律英文。面板「设置」里能改，改完立即生效。
-- bin/voice-input 用同样的规则（Hammerspoon 调它时通过 VOICE_LANG 直接传过去，省得它再查一遍）。

local M = {}

local CONFIG = os.getenv("HOME") .. "/.config/voice-input/config.json"

local function configured()
  local f = io.open(CONFIG, "r")
  if not f then return nil end
  local ok, cfg = pcall(hs.json.decode, f:read("a"))
  f:close()
  local v = ok and type(cfg) == "table" and cfg.language
  return (v == "zh" or v == "en") and v or nil
end

function M.system()
  local first = (hs.host.locale.preferredLanguages() or {})[1] or ""
  return first:match("^zh") and "zh" or "en"
end

function M.reload() M.lang = configured() or M.system() end
M.reload()

function M.t(zh, en) return M.lang == "zh" and zh or en end

return M
