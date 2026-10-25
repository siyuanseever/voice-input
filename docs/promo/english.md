# English drafts (not posted, waiting for review)

Numbers (counted 2026-10-25 from `~/.local/state/voice-input/`): 1872 clips over 23 days of use,
about 12.8 hours of audio; list-price cost ¥11.26 (about $1.6), actual bill ¥0 thanks to new-account free quota.
English speech tested with macOS `say` clips on qwen3-asr-flash, fun-asr-flash and gemini-2.5-flash (2026-10-25).

Post only after `feat/english-ui` is merged and pushed, so the README the link opens is the English one.

---

## Hacker News (Show HN)

**Title** (80 chars max)

Show HN: Push-to-talk dictation for Mac that won't rewrite or answer what you say

**URL**: https://github.com/siyuanseever/voice-input

**Text**

I spend most of my day talking to coding agents (Claude Code mostly), so I built a dictation tool for that.
Tap right Command, speak, tap again; about a second later the text is pasted at the cursor.

Two things pushed me to write my own:

1. LLM-based dictation likes to be helpful. Dictate "explain what this event tap does" and some tools
   explain it instead of writing it down. Others smooth your wording. When the text is a prompt for an agent,
   that is wrong.
2. Technical terms. "Claude Code" kept coming out as "Cloud Code".

How it works: a speech model (Alibaba's qwen3-asr-flash, or Gemini on its free tier) transcribes,
then qwen-plus proofreads under a brief that allows only three edits: remove fillers and stutters,
fix punctuation, fix the spelling of terms. If the proofread text is much longer or shorter than the input,
it is thrown away and the raw transcript is used. A plain-text vocabulary file adds terms to the prompt
and `wrong => right` rules for what still slips through.

If one model is rate-limited or down it falls through to the next, and finally (optionally) to an on-device
Qwen3-ASR-1.7B (MLX) so it works offline. Recordings are kept, so a failed clip can be re-transcribed.
Audio goes only to the providers you configure; with just the on-device model it never leaves the machine.

I've used it for a month: 1872 clips, about 13 hours of audio. At list price that is under $2; my actual bill
was zero because of new-account free quota. It's Hammerspoon plus a zsh script, about 2,600 lines, MIT.
I speak mostly Chinese mixed with English, so mixed-language speech is the case I tested hardest;
the UI now follows your macOS language and the English prompts never translate.

Happy to answer questions about the prompt rules. The failure modes of the cheaper proofreading model
(swapping synonyms, finishing your sentence for you) were the most interesting part.

---

## Reddit — r/macapps

**Title**

I made a free, open-source push-to-talk dictation tool for Mac (Hammerspoon), built for talking to AI agents

**Body**

Tap right Command, talk, tap again, and the text appears at your cursor. Hold-to-talk works too.

What's different from built-in dictation and most paid apps:

- It writes down exactly what you said. A proofreading pass may only remove "um"s, fix punctuation and fix term spelling. It never rewrites your sentence, and it never answers a question you were dictating to ChatGPT or Claude.
- Vocabulary file for names and jargon, plus `wrong => right` fix-up rules.
- Fallback chain: Alibaba Cloud qwen3-asr → Gemini (free tier) → on-device model, so it keeps working when a service is down or you're offline.
- Small overlay with a live level meter; you can start the next clip while the last one is still transcribing.
- Optional mouse buttons: back = talk, forward = Return, middle = paste.
- Cost: about $0.13 per hour of audio at list price, or free with a Gemini key.

Mac only (needs Hammerspoon, ffmpeg, jq). MIT licensed: https://github.com/siyuanseever/voice-input

Feedback welcome, especially from people who dictate in more than one language.

---

## Reddit — r/ClaudeAI

**Title**

Voice input for Claude Code that doesn't "answer" your prompt: open-source Mac tool

**Body**

I talk to Claude Code most of the day, so I built a dictation tool around it:

- Your words are transcribed and pasted at the cursor as you said them. The model is told never to answer or carry out what you're saying. That matters when what you're saying is a prompt.
- Newlines are stripped before pasting, so Claude Code doesn't collapse it into `[Pasted text]`.
- Saying just "compact" gives `/compact`; saying just "continue" gives `continue`.
- With the mouse option on: back button to talk, forward button for Return. You can lean back and run a whole session without the keyboard.

A month in: 1872 clips, about 13 hours of audio, under $2 at list price.
Mac + Hammerspoon, MIT: https://github.com/siyuanseever/voice-input
