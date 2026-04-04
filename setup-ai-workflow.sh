#!/bin/bash

# ============================================================
#  setup-ai-workflow.sh
#  Hybrid workflow setup: Claude Code + Codex
#  Usage: bash setup-ai-workflow.sh
# ============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "=================================================="
echo "  Claude Code + Codex — Hybrid Workflow Setup"
echo "=================================================="
echo -e "${NC}"

# ----------------------------------------------------------
# 1. CLAUDE.md — створити якщо не існує
# ----------------------------------------------------------
echo -e "${YELLOW}[1/5] Checking CLAUDE.md...${NC}"

if [ ! -f "CLAUDE.md" ]; then
  cat > CLAUDE.md << 'EOF'
# Project Instructions

## Overview
<!-- Describe the project briefly -->

## Tech Stack
<!-- List of technologies -->

## Architecture
<!-- Key architectural decisions -->

## Coding Standards
- Comment language: English
- Style: follow project conventions

## Important Decisions
<!-- Why this approach was chosen -->

## Handoff Context
<!-- Автоматично оновлюється перед завершенням сесії -->
- **Current state:** not defined
- **Next step:** not defined
- **Key decisions:** not defined
- **Last updated:** —
EOF
  echo -e "  ${GREEN}✓ CLAUDE.md created${NC}"
else
  # Додати секцію Handoff якщо її немає
  if ! grep -q "Handoff Context" CLAUDE.md; then
    cat >> CLAUDE.md << 'EOF'

## Handoff Context
<!-- Автоматично оновлюється перед завершенням сесії -->
- **Current state:** not defined
- **Next step:** not defined
- **Key decisions:** not defined
- **Last updated:** —
EOF
    echo -e "  ${GREEN}✓ Section 'Handoff Context' added to CLAUDE.md${NC}"
  else
    echo -e "  ${GREEN}✓ CLAUDE.md already exists and contains Handoff Context${NC}"
  fi
fi

# ----------------------------------------------------------
# 2. AGENTS.md — симлінк для Codex
# ----------------------------------------------------------
echo -e "${YELLOW}[2/5] Creating AGENTS.md (symlink for Codex)...${NC}"

if [ -L "AGENTS.md" ]; then
  echo -e "  ${GREEN}✓ AGENTS.md already exists (symlink)${NC}"
elif [ -f "AGENTS.md" ]; then
  echo -e "  ${YELLOW}⚠ AGENTS.md exists as a file — skipping (delete manually if you want to replace it)${NC}"
else
  ln -s CLAUDE.md AGENTS.md
  echo -e "  ${GREEN}✓ AGENTS.md → CLAUDE.md (symlink created)${NC}"
fi

# ----------------------------------------------------------
# 3. .github/copilot-instructions.md — для GitHub Copilot
# ----------------------------------------------------------
echo -e "${YELLOW}[3/5] Setting up GitHub Copilot instructions...${NC}"

mkdir -p .github

COPILOT_FILE=".github/copilot-instructions.md"
if [ -L "$COPILOT_FILE" ]; then
  echo -e "  ${GREEN}✓ $COPILOT_FILE already exists (symlink)${NC}"
elif [ -f "$COPILOT_FILE" ]; then
  echo -e "  ${YELLOW}⚠ $COPILOT_FILE exists as a file — skipping${NC}"
else
  ln -s ../CLAUDE.md "$COPILOT_FILE"
  echo -e "  ${GREEN}✓ $COPILOT_FILE → CLAUDE.md (symlink created)${NC}"
fi

# ----------------------------------------------------------
# 4. VS Code settings.json
# ----------------------------------------------------------
echo -e "${YELLOW}[4/5] Setting up VS Code settings.json...${NC}"

mkdir -p .vscode
SETTINGS_FILE=".vscode/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
  cat > "$SETTINGS_FILE" << 'EOF'
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "CLAUDE.md" }
  ]
}
EOF
  echo -e "  ${GREEN}✓ $SETTINGS_FILE created${NC}"
else
  # Перевірити чи вже є налаштування
  if grep -q "copilot.chat.codeGeneration.instructions" "$SETTINGS_FILE"; then
    echo -e "  ${GREEN}✓ Copilot instructions already configured in settings.json${NC}"
  else
    echo -e "  ${YELLOW}⚠ settings.json exists — add manually:${NC}"
    echo -e '    "github.copilot.chat.codeGeneration.instructions": [{ "file": "CLAUDE.md" }]'
  fi
fi

# ----------------------------------------------------------
# 5. VS Code Tasks — швидкі команди через Ctrl+Shift+P
# ----------------------------------------------------------
echo -e "${YELLOW}[5/7] Creating VS Code Tasks...${NC}"

cat > .vscode/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI: handoff — save session state",
      "type": "shell",
      "command": "echo",
      "args": [
        "📋 Скопіюй і відправ у Claude Code:\n\nОнови секцію Handoff Context у CLAUDE.md — підсумуй поточний стан, наступний крок і ключові рішення прийняті в цій сесії."
      ],
      "presentation": {
        "reveal": "always",
        "panel": "shared",
        "clear": true
      },
      "problemMatcher": []
    },
    {
      "label": "AI: resume — відновити сесію",
      "type": "shell",
      "command": "echo '--- Handoff Context ---' && grep -A 10 'Handoff Context' CLAUDE.md || echo 'Handoff Context не знайдено у CLAUDE.md'",
      "presentation": {
        "reveal": "always",
        "panel": "shared",
        "clear": true
      },
      "problemMatcher": []
    },
    {
      "label": "AI: status — workflow files status",
      "type": "shell",
      "command": "bash",
      "args": [
        "-c",
        "echo '=== AI Workflow Status ===' && echo '' && echo -n 'CLAUDE.md:    ' && ([ -f CLAUDE.md ] && echo '✓ існує' || echo '✗ відсутній') && echo -n 'AGENTS.md:    ' && ([ -L AGENTS.md ] && echo '✓ симлінк' || ([ -f AGENTS.md ] && echo '⚠ файл (не симлінк)' || echo '✗ відсутній')) && echo -n 'copilot-instructions: ' && ([ -L .github/copilot-instructions.md ] && echo '✓ симлінк' || ([ -f .github/copilot-instructions.md ] && echo '⚠ файл (не симлінк)' || echo '✗ відсутній')) && echo -n 'tasks.json:   ' && ([ -f .vscode/tasks.json ] && echo '✓ існує' || echo '✗ відсутній') && echo -n 'commands/:    ' && ([ -d .claude/commands ] && echo '✓ існує' || echo '✗ відсутній') && echo '' && echo '--- Останній Handoff ---' && grep -A 5 'Handoff Context' CLAUDE.md 2>/dev/null | tail -5 || echo 'не знайдено'"
      ],
      "presentation": {
        "reveal": "always",
        "panel": "shared",
        "clear": true
      },
      "problemMatcher": []
    },
    {
      "label": "AI: switch-to-codex — prepare to switch",
      "type": "shell",
      "command": "bash",
      "args": [
        "-c",
        "echo '=== Switching to Codex ===' && echo '' && echo '1. Відправ у Claude Code:' && echo '   \"Онови секцію Handoff Context у CLAUDE.md\"' && echo '' && echo '2. Після оновлення — відкрий Codex і напиши:' && echo '   \"Прочитай CLAUDE.md і продовж з розділу Handoff Context\"' && echo '' && echo '--- Поточний Handoff ---' && grep -A 6 'Handoff Context' CLAUDE.md 2>/dev/null || echo 'Handoff Context не знайдено'"
      ],
      "presentation": {
        "reveal": "always",
        "panel": "shared",
        "clear": true
      },
      "problemMatcher": []
    }
  ]
}
EOF
echo -e "  ${GREEN}✓ .vscode/tasks.json created (4 commands)${NC}"

# ----------------------------------------------------------
# 6. Claude Code slash-команди — .claude/commands/
# ----------------------------------------------------------
echo -e "${YELLOW}[6/7] Creating Claude Code slash-commands...${NC}"

mkdir -p .claude/commands

cat > .claude/commands/handoff.md << 'EOF'
Save the current session state to CLAUDE.md.

Find the `## Handoff Context` section and replace its content with current information:

- **Current state:** [what was implemented in this session]
- **Next step:** [what needs to be done next, specifically]
- **Key decisions:** [what architectural or technical decisions were made and why]
- **Last updated:** [current date and time]

Be specific and concise. After updating — confirm that the file was saved.
EOF
echo -e "  ${GREEN}✓ /handoff — save session state${NC}"

cat > .claude/commands/resume.md << 'EOF'
Read CLAUDE.md fully.

Pay special attention to the `## Handoff Context` section.

Briefly summarize:
1. What was done in the previous session
2. What the next step is
3. What key decisions to keep in mind

Then — suggest where to start.
EOF
echo -e "  ${GREEN}✓ /resume — restore session context${NC}"

cat > .claude/commands/status.md << 'EOF'
Check the status of AI workflow files in the project and display a report:

1. Does CLAUDE.md exist and is Handoff Context filled in?
2. Does AGENTS.md exist (symlink to CLAUDE.md)?
3. Does .github/copilot-instructions.md exist (symlink to CLAUDE.md)?
4. Does .vscode/tasks.json exist?
5. Does the .claude/commands/ directory exist and what commands are in it?

Display the result as a short checklist with statuses ✓ / ✗ / ⚠
EOF
echo -e "  ${GREEN}✓ /status — check workflow status${NC}"

cat > .claude/commands/switch-to-codex.md << 'EOF'
Before doing anything — ask the user:
"Ready to switch to Codex? I will save the current session state to CLAUDE.md and sync the files. Confirm? (yes/no)"

Proceed only after the answer "yes". If "no" — do nothing and inform that the switch was cancelled.

After confirmation:
1. Update the `## Handoff Context` section in CLAUDE.md with the current session state
2. Display the final content of the Handoff Context section
3. On Mac/Linux symlinks update automatically — confirm the file is saved
4. Display the ready phrase to paste into Codex:

---
Read CLAUDE.md and continue development from the Handoff Context section
---
EOF
echo -e "  ${GREEN}✓ /switch-to-codex — prepare to switch to Codex${NC}"

cat > .claude/commands/switch-from-codex.md << 'EOF'
Before doing anything — ask the user:
"Returning from Codex to Claude Code? I will read CLAUDE.md and restore the session context. Confirm? (yes/no)"

Proceed only after the answer "yes". If "no" — do nothing and inform that the restore was cancelled.

After confirmation:
1. Read CLAUDE.md fully
2. Check the Handoff Context section — was it updated in Codex?
3. Review recent changes: git log --oneline -5 (if git is available)
4. Summarize what changed and suggest a plan to continue

If Handoff Context was not updated — ask to explain what was done in Codex.
EOF
echo -e "  ${GREEN}✓ /switch-from-codex — resume after Codex${NC}"

# ----------------------------------------------------------
# 7. .gitignore
# ----------------------------------------------------------
echo -e "${YELLOW}[7/7] Checking .gitignore...${NC}"

if [ ! -f ".gitignore" ]; then
  touch .gitignore
fi

if ! grep -q "AGENTS.md" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# AI workflow symlinks (auto-generated)" >> .gitignore
  echo "# AGENTS.md" >> .gitignore
  echo "# .github/copilot-instructions.md" >> .gitignore
  echo -e "  ${GREEN}✓ Comment added to .gitignore${NC}"
  echo -e "  ${YELLOW}  (symlinks are commented out — uncomment if you don't want to commit them)${NC}"
else
  echo -e "  ${GREEN}✓ .gitignore already configured${NC}"
fi

# ----------------------------------------------------------
# Підсумок
# ----------------------------------------------------------
echo ""
echo -e "${BLUE}=================================================="
echo -e "  Done! File structure:"
echo -e "==================================================${NC}"
echo ""
echo -e "  📄 ${GREEN}CLAUDE.md${NC}                        <- main file (edit here)"
echo -e "  🔗 ${GREEN}AGENTS.md${NC}                        → CLAUDE.md  (для Codex)"
echo -e "  🔗 ${GREEN}.github/copilot-instructions.md${NC}  → CLAUDE.md  (для Copilot)"
echo -e "  ⚙️  ${GREEN}.vscode/settings.json${NC}            <- Copilot reads CLAUDE.md"
echo -e "  ⚙️  ${GREEN}.vscode/tasks.json${NC}               <- VS Code Tasks"
echo -e "  📁 ${GREEN}.claude/commands/${NC}                 <- Claude Code slash-commands"
echo ""
echo -e "${BLUE}VS Code Tasks  (Ctrl+Shift+P → 'Run Task'):${NC}"
echo -e "  ${GREEN}AI: handoff${NC}          — нагадування зберегти стан"
echo -e "  ${GREEN}AI: resume${NC}           — показати поточний Handoff Context"
echo -e "  ${GREEN}AI: status${NC}           — перевірити стан всіх файлів"
echo -e "  ${GREEN}AI: switch-to-codex${NC}  — інструкція переходу в Codex"
echo ""
echo -e "${BLUE}Claude Code slash-команди:${NC}"
echo -e "  ${GREEN}/handoff${NC}             — зберегти стан сесії в CLAUDE.md"
echo -e "  ${GREEN}/resume${NC}              — відновити контекст сесії"
echo -e "  ${GREEN}/status${NC}              — перевірити стан workflow"
echo -e "  ${GREEN}/switch-to-codex${NC}     — підготовка до переходу в Codex"
echo -e "  ${GREEN}/switch-from-codex${NC}   — відновлення після Codex"
echo ""
