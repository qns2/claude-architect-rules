#!/bin/bash
# Install Claude Architect rules by symlinking into ~/.claude/rules/

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RULES_SRC="$SCRIPT_DIR/rules"
RULES_DST="$HOME/.claude/rules"

mkdir -p "$RULES_DST"

count=0
for f in "$RULES_SRC"/architect-*.md; do
    name=$(basename "$f")
    target="$RULES_DST/$name"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -f "$target" ]; then
        echo "Warning: $target exists and is not a symlink. Skipping (remove manually to link)."
        continue
    fi

    ln -s "$f" "$target"
    echo "  Linked $name"
    count=$((count + 1))
done

echo "Done. $count rule files linked to $RULES_DST"
echo ""
echo "Start a new Claude Code session for rules to take effect."
