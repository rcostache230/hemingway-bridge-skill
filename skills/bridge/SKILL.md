---
name: bridge
description: >-
  Write, list, or resume Hemingway bridge notes for Claude Code sessions. Use when
  the user asks to leave a bridge, save their place, park unfinished work, stop for
  the day, prepare for compaction, or resume where a previous session stopped.
  Notes preserve the next concrete action, stopping point, status, details likely
  to be forgotten, intention, and open loops. Offer a bridge when a long session
  ends with unfinished work. Not for finishing the work itself or writing a
  retrospective session summary.
---

# Bridge — the Hemingway bridge for Claude sessions

Hemingway's rule for a writing day: stop when you are going good and when you know what will
happen next, never when you are stuck or empty. Tomorrow you sit down, read the last paragraph,
and the next sentence is already there. Tiago Forte named the practice the *Hemingway Bridge* in
*Building a Second Brain*: end every work session by writing down the next steps, the current
status, the details you will forget, and your intention for the next session.

A Claude session dies at the end of its context window. The next one wakes up with nothing but the
files on disk and whatever notes exist. Without a bridge it spends its first twenty minutes
re-reading, re-discovering and re-deciding things that were obvious an hour ago. A bridge turns that
into one action: read the note, do the next sentence.

A bridge is **forward-looking**. It is not a summary of what happened (if your setup already writes
session summaries, do not repeat them here). The bridge answers one question for the next session:
*what do I do first, and what do I need to know to do it without looking anything up?*

## Where bridges live

One Markdown file per project, in the bridges directory. `scripts/bridge.sh dir` prints it; the
script resolves it in this order: `$BRIDGE_DIR`, then `BRIDGE_DIR=…` in `~/.claude/bridge.conf`,
then `$OBSIDIAN_VAULT/Bridges` when an Obsidian vault is configured, then `~/.claude/bridges`.
Obsidian is optional. One **open** bridge per project; writing a new one archives the old one to
`archive/`. A bridge that has been resumed is **crossed** (`crossed: <date>` in its frontmatter)
and stops appearing in the default list, but stays on disk until the next bridge replaces it.

In a new session, use `/bridge resume` to pick up saved work or `/bridge list` to see open bridges.

The helper script does the bookkeeping so every session behaves the same way. `BRIDGE` below is
this skill's base directory (printed as "Base directory for this skill" when the skill loads):

```bash
"$BRIDGE/scripts/bridge.sh" list            # open bridges, newest first
"$BRIDGE/scripts/bridge.sh" list --all      # including crossed ones
"$BRIDGE/scripts/bridge.sh" slug "Omni concept film"   # -> omni-concept-film
"$BRIDGE/scripts/bridge.sh" path "Omni concept film"   # -> full path of that bridge
"$BRIDGE/scripts/bridge.sh" archive <slug>  # move the current bridge to archive/
"$BRIDGE/scripts/bridge.sh" cross <slug>    # mark as resumed (today's date)
"$BRIDGE/scripts/bridge.sh" dir             # where bridges live
```

## Modes

Pick the mode from what the user said. `/bridge` with no argument means **write**.
`/bridge resume [project]`, "continue where we left off", "where did we stop" mean **resume**.
`/bridge list`, "what bridges are open", "what did I park" mean **list**.

### Write

1. **Name the project.** Reuse a name an earlier bridge already used (`bridge.sh list --all`) or
   the name the user uses for the work; otherwise the repository or folder name. A consistent name
   is what lets the next session find the bridge. The folder is the deepest directory where this
   session actually changed files, not necessarily the cwd (in a workspace that holds many
   projects the cwd is the whole workspace).

2. **Find the stopping point.** If the user is stopping while things are going well, the next
   sentence is obvious: write it. If the user is stopping because they are stuck, the bridge still
   needs a next sentence, so make it the diagnostic: the one experiment, question or read that
   would unblock things. A bridge without a next sentence is a summary, not a bridge.

   If the user says "wrap up" while something is half-done and finishing it would take more than
   a few minutes, do not race to finish it. Stop cleanly, record what is half-done under *In
   flight*, and make finishing it the next sentence. That is the whole point of the technique.

3. **Write the note** with the template in `assets/bridge-template.md`, replacing every
   `{{PLACEHOLDER}}` and every italic guidance line with real content. Then:

   ```bash
   S=$("$BRIDGE/scripts/bridge.sh" slug "<project>")
   "$BRIDGE/scripts/bridge.sh" archive "$S"      # no-op when there is no old bridge
   cat > "$("$BRIDGE/scripts/bridge.sh" path "<project>")" <<'MD'
   ...the filled template...
   MD
   ```

4. **Confirm** in one line: the bridge's path and its next sentence, quoted. Nothing else;
   the user is leaving.

What makes a bridge good:

- **The next sentence is executable in five minutes with zero research.** A file to open, a
  command to run, a paragraph to write, a person to message. "Continue the deck" fails this test;
  "Open `deck_v4.pptx`, rewrite slide 12's title to the agreed line, then export PDF" passes.
- **Details that will be forgotten are the ones that cost the most to rediscover:** exact paths and
  version tags, commands and flags that worked, numbers and names, URLs and ticket ids, and above
  all *what was tried and rejected and why*. The next session will otherwise retry the rejected
  thing.
- **Short.** Forty to sixty lines. If it is longer, the status section is turning into a summary;
  cut it.
- **Honest about verification.** Anything unverified, uncommitted, unsent or unreviewed goes under
  *In flight*, so the next session does not trust it blindly.
- **No secrets, ever.** Tokens, passwords, card digits and keys never go into a bridge.

### Resume

1. Find the bridge: `bridge.sh list`. With a project argument, or when exactly one open bridge
   matches the current folder, take that one. With several candidates, show the list (project,
   date, next sentence) and let the user pick. With none, say so and fall back to whatever other
   memory exists (notes, docs, git log); do not invent a bridge.
2. Read the whole note. Check reality before trusting it: the files and folders it names still
   exist, uncommitted work is still there (`git status` in a repo), nothing under *In flight* has
   been finished since. Drift is normal; state it in one line if found.
3. Mark it crossed: `bridge.sh cross <slug>`.
4. Tell the user, in two lines, where the bridge says we stopped and what the next sentence is,
   then **do the next sentence**. Do not re-explore the project, re-read everything or re-plan
   from scratch: that is exactly the waste the bridge exists to prevent. Ask about today's
   direction only if the bridge's intention is unclear or the user redirects.
5. When this session ends, write a new bridge; the crossed one gets archived by that write.

### List

Run `bridge.sh list` and show the result as a short table: project, date, next sentence. Offer to
resume one. `--all` includes crossed bridges when the user asks about history.

## Offering a bridge unprompted

When a session has been long, real work is unfinished, and the user signals they are leaving
("ok thanks", "that's it for tonight", "I'll look at this tomorrow"), offer in one line: "Want me
to leave a bridge so the next session picks this up directly?" If context is visibly running out
before the work is done, write the bridge first and tell the user, rather than losing the state in
compaction. Do not offer after a finished task with nothing left to do.

## Example

User, after two hours on a deck: "ok I need to stop, let's continue tomorrow"

Bridge written to `<bridges dir>/board-deck.md`:

```markdown
## Next sentence
Open `board-deck_v7.pptx`, replace slide 12's title with "From licensing code to selling verdicts"
(agreed with the VP today), then export the PDF as `_v7`.

## Where I stopped
Slides 1–11 of v7 reviewed and fixed. Slide 12 title was the last open edit; slides 13–20 are
untouched from v6 and already approved.

## Status
- Done this session: v6 → v7 restructure, new sensor table on slide 4, the VP's three comments addressed.
- In flight (unverified): v7 PDF not exported; slide 4 table not checked on the 4:3 export.
- Deliberately not done: no speaker notes for slides 15–20 (the user writes those).

## Details that will be forgotten
- Source deck: `~/Documents/decks/board-deck_v7.pptx`; v6 stays as reference.
- Export: `python scripts/export_pdf.py --deck v7` (the PowerPoint MCP export rasterises the tables, don't use it).
- Rejected: a seventh sensor "file detonation" ("we don't sell that, drop it").

## Intention
A board-ready v7 PDF in the user's hands before the Thursday pre-read goes out.

## Open loops
- Does Legal accept "selling verdicts" in a board document? — user to ask the PMM lead.
```

Confirmation to the user: `Bridge left at <bridges dir>/board-deck.md — next sentence: open deck_v7, fix slide 12's title, export PDF.`
