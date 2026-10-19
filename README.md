# Hemingway Bridge for Claude Code

> Stop while you are going good and you know what will happen next. Tomorrow the next sentence is already there.

Hemingway ended each writing day that way, so the next morning never started with a blank page.
Tiago Forte called the practice the **Hemingway Bridge** in *Building a Second Brain*: before you
stop, write down the next steps, the current status, the details you will forget, and your
intention for the next session.

A Claude Code session needs this more than a novelist does. It dies at the end of its context
window, and the next one wakes up knowing nothing but what is on disk. Without a bridge it burns
its first twenty minutes re-reading, re-discovering and re-deciding things that were obvious an
hour ago.

**`/bridge`** writes a short, forward-looking note when you stop. In the next session,
**`/bridge resume`** reads it, checks it against reality, marks it crossed and does the next
sentence. No re-exploring.

## Install

Install the standalone skill from your terminal, in the project where you want to use it:

```bash
npx skills add rcostache230/hemingway-bridge-skill --skill bridge --agent claude-code
```

Add `--global` to make it available across projects.

Or copy the skill into Claude Code's personal skills directory:

```bash
git clone https://github.com/rcostache230/hemingway-bridge-skill.git
mkdir -p ~/.claude/skills
cp -R hemingway-bridge-skill/skills/bridge ~/.claude/skills/bridge
```

The helper needs only bash (3.2 or newer), awk and sed at runtime. Runs locally and sends nothing
anywhere. Use `/bridge resume` or `/bridge list` to load saved bridges in a new session.

## Use

| Say | What happens |
|---|---|
| `/bridge`, "let's stop here", "I'm done for today", "park this", "before we compact" | Writes a bridge for the project you were working on and tells you its next sentence |
| `resume`, `/bridge resume`, "where did we stop", "continue where we left off" | Reads the open bridge, verifies it, marks it crossed, does the next sentence |
| `/bridge list`, "what did I park" | Lists open bridges: project, date, next sentence |

Claude also offers a bridge on its own when a long session with unfinished work is winding down,
and writes one first if context is about to run out.

## What a bridge looks like

```markdown
## Next sentence
Open `board-deck_v7.pptx`, replace slide 12's title with the agreed line, then export the PDF as `_v7`.

## Where I stopped
Slides 1–11 of v7 reviewed and fixed. Slide 12's title was the last open edit; 13–20 are untouched from v6 and already approved.

## Status
- Done this session: v6 → v7 restructure, new table on slide 4, the reviewer's three comments addressed.
- In flight (unverified): v7 PDF not exported; slide 4 table not checked on the 4:3 export.
- Deliberately not done: speaker notes for slides 15–20 (the user writes those).

## Details that will be forgotten
- Source deck: `~/Documents/decks/board-deck_v7.pptx`; v6 stays as reference.
- Export: `python scripts/export_pdf.py --deck v7` (the PowerPoint MCP export rasterises the tables, don't use it).
- Rejected: a seventh row "file detonation" ("we don't sell that, drop it").

## Intention
A board-ready v7 PDF before the Thursday pre-read goes out.

## Open loops
- Does Legal accept the new title wording? — user to ask the PMM lead.
```

Forty to sixty lines. The test for the next sentence: executable in five minutes with zero
research. "Continue the deck" fails; "open deck_v7, fix slide 12's title, export PDF" passes.
A bridge is not a session summary. It says what to do first and what you need to know to do it
without looking anything up.

## Where bridges live

Plain Markdown files with YAML frontmatter, one open bridge per project. The directory is resolved
in this order:

1. `$BRIDGE_DIR` in the environment
2. `BRIDGE_DIR=...` in `~/.claude/bridge.conf`
3. `$OBSIDIAN_VAULT/Bridges` if you keep an Obsidian vault (env, or `~/.claude/obsidian-memory.conf`)
4. `~/.claude/bridges` (default)

Writing a new bridge for a project moves the previous one to `archive/`. A resumed bridge gets
`crossed: <date>` in its frontmatter and stops showing up in the default list. Obsidian is optional;
point `BRIDGE_DIR` into a vault and bridges get backlinks and search for free.

## How it works

```
skills/bridge/SKILL.md              the procedure: write, resume, list; what makes a bridge good
skills/bridge/scripts/bridge.sh     bookkeeping: list, slug, path, archive, cross, dir
skills/bridge/assets/bridge-template.md
```

The skill loads saved bridges when you ask to resume or list them.

## Hacking on it

```bash
bash -n skills/bridge/scripts/bridge.sh
BRIDGE_DIR=/tmp/bridges skills/bridge/scripts/bridge.sh list
```

Issues and pull requests welcome. MIT licence.

---

Hemingway's rule is from "Monologue to the Maestro", *Esquire*, October 1935. The name
"Hemingway Bridge" is Tiago Forte's, from *Building a Second Brain* (2022).
