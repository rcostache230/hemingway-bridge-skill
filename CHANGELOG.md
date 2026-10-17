# Changelog

## 0.1.0 — 2026-10-17

First public release.

- `/bridge` skill: write, resume and list modes; what makes a bridge good; the note template.
- `bridge.sh`: `list`, `recall`, `slug`, `path`, `archive`, `cross`, `dir`. bash 3.2, awk, sed.
- SessionStart hook that prints open bridges to the next session and nothing when there are none.
- Bridges directory resolved from `BRIDGE_DIR`, `~/.claude/bridge.conf`, an Obsidian vault if configured, else `~/.claude/bridges`.
