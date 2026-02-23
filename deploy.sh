#!/usr/bin/env bash
set -euo pipefail

# deploy.sh — Copy the golden set into a target project directory
#
# Usage:
#   ./deploy.sh /path/to/project
#   ./deploy.sh                    # prompts for target directory

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOLDEN_DIR="$SCRIPT_DIR/golden"

# Verify golden directory exists
if [ ! -d "$GOLDEN_DIR" ]; then
  echo "Error: golden/ directory not found at $GOLDEN_DIR"
  exit 1
fi

# Get target directory
TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  read -rp "Target project directory: " TARGET
fi

# Expand ~ and resolve path
TARGET="${TARGET/#\~/$HOME}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

# Validate or create target
if [ ! -d "$TARGET" ]; then
  read -rp "Directory '$TARGET' does not exist. Create it? (y/N) " CREATE
  if [[ "$CREATE" =~ ^[Yy]$ ]]; then
    mkdir -p "$TARGET"
    echo "Created $TARGET"
  else
    echo "Aborted."
    exit 1
  fi
fi

# Check for existing config
EXISTING=()
[ -f "$TARGET/CLAUDE.md" ] && EXISTING+=("CLAUDE.md")
[ -d "$TARGET/.claude" ] && EXISTING+=(".claude/")
[ -f "$TARGET/.mcp.json" ] && EXISTING+=(".mcp.json")

if [ ${#EXISTING[@]} -gt 0 ]; then
  echo ""
  echo "Warning: Target already has Claude configuration:"
  printf "  - %s\n" "${EXISTING[@]}"
  echo ""
  read -rp "Overwrite? (y/N) " OVERWRITE
  if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
    echo "Aborted. Existing config preserved."
    exit 0
  fi
fi

# Copy golden set to target
echo ""
echo "Deploying golden set to $TARGET..."

# Copy CLAUDE.md
cp "$GOLDEN_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"

# Copy .claude/ directory (merge, don't delete existing)
mkdir -p "$TARGET/.claude"
cp -R "$GOLDEN_DIR/.claude/" "$TARGET/.claude/"

# Copy .mcp.json
cp "$GOLDEN_DIR/.mcp.json" "$TARGET/.mcp.json"

echo ""
echo "Done! Golden set deployed to $TARGET"
echo ""
echo "Files deployed:"
echo "  - CLAUDE.md (baseline configuration)"
echo "  - .claude/commands/ (workflow commands)"
echo "  - .claude/skills/bootstrap-claude/ (project adapter)"
echo "  - .claude/agents/code-reviewer.md (review agent)"
echo "  - .claude/settings.local.json (baseline permissions)"
echo "  - .mcp.json (MCP server config)"
echo ""
echo "Next step:"
echo "  cd $TARGET"
echo "  claude"
echo "  > /bootstrap-claude"
echo ""
echo "This will scan your project and adapt the configuration to your tech stack."
