---
title: I dictate almost every prompt to Claude Code now. This Mac tool writes down exactly what I said
published: false
tags: claude, productivity, opensource, macos
cover_image: https://raw.githubusercontent.com/siyuanseever/voice-input/main/docs/promo/img/architecture.en.png
---

<!-- Draft for dev.to (account threedaycat, same as claude-tmux-sessions). Not posted yet.
     Paste the body with hard line breaks as written (dev.to renders Markdown). Images point at the repo's main branch.
     Numbers: counted 2026-10-25 from ~/.local/state/voice-input/ and the git log of ~/dotfiles/voice/vocab.txt.
     The English example below is a synthetic clip made with macOS `say` and run through the tool on 2026-10-25. -->

**TL;DR**: [voice-input](https://github.com/siyuanseever/voice-input) is push-to-talk dictation for macOS. Tap right
Command, speak, tap again, and a second or two later the text is pasted at your cursor. It is built for talking to
coding agents, so it has one hard rule: write down what was said. Never rewrite it, never translate it, never answer
it. MIT, Hammerspoon plus one zsh script.

![How it works: speak, record, transcribe, proofread, apply vocabulary rules, paste. Claude Code feeds misheard terms back into the vocabulary.](https://raw.githubusercontent.com/siyuanseever/voice-input/main/docs/promo/img/architecture.en.png)

## Why I wrote my own

Most of my working day is now spent talking to Claude Code: describing a change, pointing at a bug, asking why.
Typing that is slow; saying it is fast. Off-the-shelf dictation got in the way in three ways:

1. **LLM cleanup is too helpful.** Give a model "explain what this event tap does" and ask it to tidy the
   transcript, and it may explain the event tap instead. Or it smooths your wording. When the text is a prompt
   for an agent, both are wrong.
2. **Technical terms.** "Claude Code" kept coming out as "Cloud Code", "Codex" as "Codecs".
3. **Subscriptions** for something I use all day.

## How it works

1. **Record.** ffmpeg captures 16 kHz mono. A small overlay at the bottom of the screen shows elapsed time and a live
   level meter. You can start the next clip while the previous one is still being transcribed. Every clip is saved
   before anything else happens, so a failed or cancelled one can be redone from the panel.
2. **Transcribe.** Models are tried in order: Alibaba Cloud's `qwen3-asr-flash` (fast and cheap), then Gemini on its
   free tier, then an optional on-device Qwen3-ASR-1.7B (MLX) that works offline. A model that is out of quota,
   unreachable or gone is skipped automatically.
3. **Proofread.** `qwen-plus` gets a brief that allows exactly three edits: drop fillers and stutters, fix
   punctuation, fix the spelling of terms. No synonyms, no reordering, no added words, and never an answer.
4. **Vocabulary rules.** A plain-text file: one term per line goes into the prompts; `wrong => right` lines are
   applied afterwards for what still slips through.
5. **Paste.** The text goes to the clipboard and, if the cursor is still in the same field, it is pasted there.

Here is a synthetic clip I made with macOS `say` and ran through it:

```
spoken:  "Um, can you refactor the, the panel code so that it uses the new i18n helper,
          and then run the tests? Don't push yet."
pasted:  Can you refactor the panel code so that it uses the new i18n helper and then run the tests? Don't push yet.
```

The "um" and the repeated "the" are gone; the request is still a request.

## Three things I learned about the proofreading prompt

- **The cheaper model couldn't follow it.** I started with `qwen-flash`. It swapped synonyms, reordered clauses and
  once finished my sentence with half a sentence I never said. Making the rules stricter made it worse.
  `qwen-plus` follows them.
- **Guard the output, not just the prompt.** If the proofread text is much longer or shorter than the raw transcript,
  the model has probably answered or rewritten something. The tool throws it away and pastes the raw transcript.
- **Examples in the prompt leak.** I once wrote "if you hear something like 'cloud code', it is Claude Code". The model
  started inserting "Claude" into sentences where I had never said it. Now the prompt carries a list of terms and no
  examples.

## Let Claude maintain the vocabulary

The vocabulary file is the part I'm happiest with, and I don't maintain it by hand. Since I talk to Claude Code all
day, it usually understands what I meant and can tell which word was misheard. So my `CLAUDE.md` has a rule like this:

```
## Misheard words in my dictation
I dictate most messages. When you can tell a term was misheard and are sure of the right one,
add "wrong => right" to ~/.config/voice-input/vocab.txt and mention it in one line at the end of your reply.
If the wrong spelling is a common word, include surrounding words so normal speech isn't rewritten. If unsure, ask.
```

In the first month my vocabulary file got 108 edits; 86 of them were made by Claude this way. The next time I say
the word, the transcript is right. That is the loop in the bottom-right corner of the diagram.

## Fallbacks and cost

After a month: 1,872 clips over 23 days, about 13 hours of audio. At list price that is under $2 (about ¥11 on the
China region); my actual bill was zero, because on the China region each model version comes with a new-account free quota and the tool
spends those first. With "stop when used up" turned on in the console, an exhausted quota returns an error instead
of a charge, and the next model takes over.

![The panel's stats tab: transcripts per day over two weeks, coloured by model (made-up data)](https://raw.githubusercontent.com/siyuanseever/voice-input/main/docs/panel.en.png)

The tool works with either an Alibaba Cloud Model Studio key (International or China region; set Region to Auto and
it works out which one your key belongs to) or a free Gemini key. The UI follows your macOS language, English or
Chinese.

## Small things for Claude Code users

- Newlines are removed before pasting, because Claude Code collapses multi-line pastes into `[Pasted text]` and you
  can't check what was transcribed.
- Saying only "compact" pastes `/compact`; saying only "continue" pastes `continue` with no full stop.
- Optional mouse buttons: back to talk, forward for Return, middle click to paste. I can lean back and run a whole
  session without touching the keyboard.

## Try it

```bash
brew install --cask hammerspoon
brew install ffmpeg jq
git clone https://github.com/siyuanseever/voice-input ~/projects/voice-input
~/projects/voice-input/install.sh
```

Then give Hammerspoon Accessibility and Microphone permission, paste a key in the panel's Settings, and tap right
Command.

Known limits, up front: macOS only. I mostly speak Chinese mixed with English, so that is what it has been used on
most; English I tested with synthetic clips. The Gemini path has no separate proofreading step, so it occasionally
keeps a filler word. Issues and PRs welcome.
