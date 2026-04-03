#!/usr/bin/env bash
set -euo pipefail

# update-claude-manifest.sh — Produce a structured manifest comparing golden set vs project
#
# Usage:
#   bash update-claude-manifest.sh <golden-repo-path> <project-path>
#
# Output: structured text listing files in each category for both golden and project,
# plus items that are new (in golden but not in project).

GOLDEN_REPO="${1:-}"
PROJECT="${2:-}"

if [ -z "$GOLDEN_REPO" ] || [ -z "$PROJECT" ]; then
  echo "Usage: bash update-claude-manifest.sh <golden-repo-path> <project-path>"
  exit 1
fi

GOLDEN="$GOLDEN_REPO/golden"

if [ ! -d "$GOLDEN" ]; then
  echo "Error: golden/ directory not found at $GOLDEN"
  exit 1
fi

# Helper: list *.md filenames (basename only) in a directory, one per line, sorted
list_md() {
  local dir="$1"
  if [ -d "$dir" ]; then
    ls -1 "$dir"/*.md 2>/dev/null | xargs -I{} basename {} | sort
  fi
}

# Helper: list subdirectory names in a directory, excluding hidden files and .DS_Store
list_subdirs() {
  local dir="$1"
  if [ -d "$dir" ]; then
    ls -1 "$dir" 2>/dev/null | grep -v '^\.' | grep -v '.DS_Store' | sort
  fi
}

# Helper: join lines into a space-separated string
join_line() {
  paste -sd' ' - 2>/dev/null
}

# Helper: compute items in list A but not in list B (both newline-separated)
new_items() {
  local a="$1"
  local b="$2"
  if [ -z "$a" ]; then return; fi
  if [ -z "$b" ]; then echo "$a" | join_line; return; fi
  comm -23 <(echo "$a") <(echo "$b") 2>/dev/null | join_line
}

# --- CLAUDE.md ---
echo "=== CLAUDE.md ==="
echo -n "golden: "; [ -f "$GOLDEN/CLAUDE.md" ] && echo "exists" || echo "missing"
echo -n "project: "; [ -f "$PROJECT/CLAUDE.md" ] && echo "exists" || echo "missing"
echo ""

# --- COMMANDS ---
echo "=== COMMANDS ==="
golden_cmds=$(list_md "$GOLDEN/.claude/commands")
project_cmds=$(list_md "$PROJECT/.claude/commands")
echo "golden: $(echo "$golden_cmds" | join_line)"
echo "project: $(echo "$project_cmds" | join_line)"
echo "new: $(new_items "$golden_cmds" "$project_cmds")"
echo ""

# --- AGENTS ---
echo "=== AGENTS ==="
golden_agents=$(list_md "$GOLDEN/.claude/agents")
project_agents=$(list_md "$PROJECT/.claude/agents")
echo "golden: $(echo "$golden_agents" | join_line)"
echo "project: $(echo "$project_agents" | join_line)"
echo "new: $(new_items "$golden_agents" "$project_agents")"
echo ""

# --- SKILLS ---
echo "=== SKILLS ==="
golden_skills=$(list_subdirs "$GOLDEN/.claude/skills")
project_skills=$(list_subdirs "$PROJECT/.claude/skills")
echo "golden: $(echo "$golden_skills" | join_line)"
echo "project: $(echo "$project_skills" | join_line)"
echo "new: $(new_items "$golden_skills" "$project_skills")"
echo ""

# --- AGENT_DOCS ---
echo "=== AGENT_DOCS ==="
golden_docs=$(list_md "$GOLDEN/agent_docs")
project_docs=$(list_md "$PROJECT/agent_docs")
echo "golden: $(echo "$golden_docs" | join_line)"
echo "project: $(echo "$project_docs" | join_line)"
echo "new: $(new_items "$golden_docs" "$project_docs")"
echo ""

# --- SETTINGS ---
echo "=== SETTINGS ==="
echo -n "golden: "; [ -f "$GOLDEN/.claude/settings.local.json" ] && echo "exists" || echo "missing"
echo -n "project: "; [ -f "$PROJECT/.claude/settings.local.json" ] && echo "exists" || echo "missing"
echo ""

# --- MCP ---
echo "=== MCP ==="
echo -n "golden: "; [ -f "$GOLDEN/.mcp.json" ] && echo "exists" || echo "missing"
echo -n "project: "; [ -f "$PROJECT/.mcp.json" ] && echo "exists" || echo "missing"
echo ""

# --- GOVERNANCE ---
echo "=== GOVERNANCE ==="
golden_gov=""
project_gov=""
for file in BUDGETS.md CHANGELOG.md; do
  [ -f "$GOLDEN/$file" ] && golden_gov="$golden_gov $file"
  [ -f "$PROJECT/$file" ] && project_gov="$project_gov $file"
done
golden_gov=$(echo "$golden_gov" | xargs)
project_gov=$(echo "$project_gov" | xargs)
echo "golden: $golden_gov"
echo "project: $project_gov"
new_gov=""
for file in BUDGETS.md CHANGELOG.md; do
  if [ -f "$GOLDEN/$file" ] && [ ! -f "$PROJECT/$file" ]; then
    new_gov="$new_gov $file"
  fi
done
echo "new: $(echo "$new_gov" | xargs)"
echo ""
