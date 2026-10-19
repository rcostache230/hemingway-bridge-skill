#!/bin/bash
# Hemingway bridge bookkeeping for the /bridge skill. Written for macOS /bin/bash 3.2; runs on any bash 3.2+.
#
#   bridge.sh list [--all] [--brief]   open bridges newest first (--all: crossed too; --brief: one line each)
#   bridge.sh slug "<project>"         project name -> file slug
#   bridge.sh path "<project>"         project name -> full path of its bridge file
#   bridge.sh archive <slug>           move <dir>/<slug>.md to <dir>/archive/<slug> <stamp>.md (no-op if absent)
#   bridge.sh cross <slug> [date]      set crossed: <date> in the bridge's frontmatter (default: today)
#   bridge.sh dir                      print the bridges directory
#
# Where bridges live (first match wins):
#   1. $BRIDGE_DIR in the environment
#   2. BRIDGE_DIR=... in ~/.claude/bridge.conf (plain bash, sourced)
#   3. $OBSIDIAN_VAULT/Bridges when an Obsidian vault is configured (env, or ~/.claude/obsidian-memory.conf)
#   4. ~/.claude/bridges
# Obsidian is optional: a bridge is a plain Markdown file with YAML frontmatter.

[ -n "$BRIDGE_DIR" ] || { [ -f "$HOME/.claude/bridge.conf" ] && . "$HOME/.claude/bridge.conf"; }
if [ -z "$BRIDGE_DIR" ]; then
  [ -n "$OBSIDIAN_VAULT" ] || { [ -f "$HOME/.claude/obsidian-memory.conf" ] && . "$HOME/.claude/obsidian-memory.conf"; }
  [ -n "$OBSIDIAN_VAULT" ] && BRIDGE_DIR="$OBSIDIAN_VAULT/Bridges"
fi
: "${BRIDGE_DIR:=$HOME/.claude/bridges}"
DIR="$BRIDGE_DIR"
US=$'\037'

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# Frontmatter field, first match only.
fm() { awk -v k="$2" 'NR == 1 && $0 != "---" { exit } NR > 1 && /^---$/ { exit } index($0, k ": ") == 1 { print substr($0, length(k) + 3); exit }' "$1"; }

# First real line under "## Next sentence" (blockquote marker stripped; italic guidance skipped).
next_sentence() {
  awk '/^## Next sentence/ { on = 1; next } on && /^## / { exit }
       on && NF { sub(/^> ?/, ""); if ($0 ~ /^\*.*\*$/) next; print; exit }' "$1"
}

# Open (or all) bridges as US-separated rows, newest first: date time project folder crossed next file
rows() {
  all="$1"
  [ -d "$DIR" ] || return 0
  for f in "$DIR"/*.md; do
    [ -f "$f" ] || continue
    c=$(fm "$f" crossed)
    [ "$all" = 1 ] || [ -z "$c" ] || continue
    printf '%s%s%s%s%s%s%s%s%s%s%s%s%s\n' "$(fm "$f" date)" "$US" "$(fm "$f" time)" "$US" "$(fm "$f" project)" "$US" \
      "$(fm "$f" folder)" "$US" "$c" "$US" "$(next_sentence "$f")" "$US" "$f"
  done | sort -r
}

cmd="${1:-list}"; shift 2>/dev/null
case "$cmd" in
  dir) printf '%s\n' "$DIR" ;;
  slug) slugify "$1" ;;
  path) mkdir -p "$DIR"; printf '%s/%s.md\n' "$DIR" "$(slugify "$1")" ;;
  archive)
    s="$1"; f="$DIR/$s.md"
    [ -f "$f" ] || exit 0
    mkdir -p "$DIR/archive"
    stamp="$(fm "$f" date) $(fm "$f" time | tr ':' '.')"; stamp="${stamp% }"
    [ "$stamp" = " " ] || [ -z "$stamp" ] && stamp=$(date '+%Y-%m-%d %H.%M')
    dest="$DIR/archive/$s $stamp.md"; n=2
    while [ -e "$dest" ]; do dest="$DIR/archive/$s $stamp ($n).md"; n=$((n + 1)); done
    mv "$f" "$dest" && printf 'archived -> %s\n' "$dest" ;;
  cross)
    s="$1"; d="${2:-$(date +%F)}"; f="$DIR/$s.md"
    [ -f "$f" ] || { echo "no bridge: $f" >&2; exit 1; }
    tmp="$f.tmp.$$"
    awk -v d="$d" 'NR > 1 && /^---$/ { fmdone = 1 } !fmdone && !done && /^crossed:/ { print "crossed: " d; done = 1; next } { print }' "$f" > "$tmp" \
      && mv -f "$tmp" "$f" && printf 'crossed %s on %s\n' "$s" "$d" ;;
  list)
    all=0; brief=0
    for a in "$@"; do case "$a" in --all) all=1 ;; --brief) brief=1 ;; esac; done
    rows "$all" | while IFS="$US" read -r d t p folder c ns f; do
      if [ "$brief" = 1 ]; then
        printf -- '- %s %s · %s%s → %s\n    ↳ %s%s\n' "$d" "$t" "$p" "${c:+ (crossed $c)}" "${ns:-?}" "$f" "${folder:+  · folder: $folder}"
      else
        printf '%s %s  %s%s\n  next: %s\n  folder: %s\n  file: %s\n\n' "$d" "$t" "$p" "${c:+  [crossed $c]}" "${ns:-?}" "${folder:--}" "$f"
      fi
    done ;;
  *) echo "usage: bridge.sh list [--all] [--brief] | slug <project> | path <project> | archive <slug> | cross <slug> [date] | dir" >&2; exit 2 ;;
esac
