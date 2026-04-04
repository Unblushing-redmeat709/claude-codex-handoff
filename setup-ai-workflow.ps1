# ============================================================
#  setup-ai-workflow.ps1
#  Hybrid workflow setup: Claude Code + Codex
#  Usage: .\setup-ai-workflow.ps1
# ============================================================

$ErrorActionPreference = "Stop"

function Write-Green  { param($msg) Write-Host "  $msg" -ForegroundColor Green }
function Write-Yellow { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Blue   { param($msg) Write-Host $msg -ForegroundColor Cyan }

Write-Blue "=================================================="
Write-Blue "  Claude Code + Codex — Hybrid Workflow Setup"
Write-Blue "=================================================="
Write-Host ""

# ----------------------------------------------------------
# 1. CLAUDE.md
# ----------------------------------------------------------
Write-Yellow "[1/6] Checking CLAUDE.md..."

if (-not (Test-Path "CLAUDE.md")) {
    @"
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
<!-- Updated automatically before ending a session -->
- **Current state:** not defined
- **Next step:** not defined
- **Key decisions:** not defined
- **Last updated:** —
"@ | Set-Content "CLAUDE.md" -Encoding UTF8
    Write-Green "✓ CLAUDE.md created"
} else {
    $content = Get-Content "CLAUDE.md" -Raw
    if ($content -notmatch "Handoff Context") {
        @"

## Handoff Context
<!-- Updated automatically before ending a session -->
- **Current state:** not defined
- **Next step:** not defined
- **Key decisions:** not defined
- **Last updated:** —
"@ | Add-Content "CLAUDE.md" -Encoding UTF8
        Write-Green "✓ Section 'Handoff Context' added to CLAUDE.md"
    } else {
        Write-Green "✓ CLAUDE.md already exists and contains Handoff Context"
    }
}

# ----------------------------------------------------------
# 2. AGENTS.md — симлінк або копія для Codex
# ----------------------------------------------------------
Write-Yellow "[2/6] Creating AGENTS.md for Codex..."

Write-Host ""
Write-Host "  Windows supports symlinks only with Developer Mode enabled." -ForegroundColor Yellow
Write-Host "  Symlinks are more convenient — AGENTS.md always stays up to date automatically." -ForegroundColor Yellow
Write-Host "  However, enabling Developer Mode grants additional system privileges." -ForegroundColor Yellow
Write-Host ""
$useSymlink = Read-Host "  Use symlinks? (yes/no, default: no)"

if ($useSymlink -eq "yes") {
    Write-Host "  ⚠ WARNING: Symlinks require admin rights or Developer Mode." -ForegroundColor Red
    Write-Host "  Enable: Settings → System → For developers → Developer Mode" -ForegroundColor Gray
    Write-Host ""
    if (-not (Test-Path "AGENTS.md")) {
        try {
            New-Item -ItemType SymbolicLink -Path "AGENTS.md" -Target "CLAUDE.md" -ErrorAction Stop | Out-Null
            Write-Green "✓ AGENTS.md → CLAUDE.md (symlink created)"
        } catch {
            Write-Host "  ✗ Failed to create symlink. Make sure Developer Mode is enabled." -ForegroundColor Red
            Write-Host "  Creating a copy instead of symlink..." -ForegroundColor Yellow
            Copy-Item "CLAUDE.md" "AGENTS.md"
            Write-Green "✓ AGENTS.md created (copy of CLAUDE.md)"
        }
    } else {
        Write-Green "✓ AGENTS.md already exists"
    }
} else {
    if (-not (Test-Path "AGENTS.md")) {
        Copy-Item "CLAUDE.md" "AGENTS.md"
        Write-Green "✓ AGENTS.md created (copy of CLAUDE.md)"
        Write-Host "  ℹ After editing CLAUDE.md run Task 'AI: sync'" -ForegroundColor Gray
    } else {
        Write-Green "✓ AGENTS.md already exists"
    }
}

# ----------------------------------------------------------
# 3. .github/copilot-instructions.md
# ----------------------------------------------------------
Write-Yellow "[3/6] Setting up GitHub Copilot instructions..."

if (-not (Test-Path ".github")) {
    New-Item -ItemType Directory -Path ".github" | Out-Null
}

if (-not (Test-Path ".github\copilot-instructions.md")) {
    Copy-Item "CLAUDE.md" ".github\copilot-instructions.md"
    Write-Green "✓ .github\copilot-instructions.md created"
} else {
    Write-Green "✓ .github\copilot-instructions.md already exists"
}

# ----------------------------------------------------------
# 4. VS Code settings.json
# ----------------------------------------------------------
Write-Yellow "[4/6] Setting up VS Code settings.json..."

if (-not (Test-Path ".vscode")) {
    New-Item -ItemType Directory -Path ".vscode" | Out-Null
}

if (-not (Test-Path ".vscode\settings.json")) {
    @"
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": "CLAUDE.md" }
  ]
}
"@ | Set-Content ".vscode\settings.json" -Encoding UTF8
    Write-Green "✓ .vscode\settings.json created"
} else {
    $settings = Get-Content ".vscode\settings.json" -Raw
    if ($settings -notmatch "copilot.chat.codeGeneration.instructions") {
        Write-Host "  ⚠ settings.json exists — add manually:" -ForegroundColor Yellow
        Write-Host '    "github.copilot.chat.codeGeneration.instructions": [{ "file": "CLAUDE.md" }]' -ForegroundColor Gray
    } else {
        Write-Green "✓ Copilot instructions already configured"
    }
}

# ----------------------------------------------------------
# 5. VS Code Tasks
# ----------------------------------------------------------
Write-Yellow "[5/6] Creating VS Code Tasks..."

@'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "AI: handoff — save session state",
      "type": "shell",
      "command": "Write-Host '📋 Send in Claude Code: /handoff' -ForegroundColor Cyan",
      "options": { "shell": { "executable": "powershell.exe" } },
      "presentation": { "reveal": "always", "panel": "shared", "clear": true },
      "problemMatcher": []
    },
    {
      "label": "AI: resume — show Handoff Context",
      "type": "shell",
      "command": "Write-Host '--- Handoff Context ---' -ForegroundColor Cyan; $lines = Get-Content CLAUDE.md; $start = $false; foreach ($line in $lines) { if ($line -match 'Handoff Context') { $start = $true }; if ($start) { Write-Host $line } }",
      "options": { "shell": { "executable": "powershell.exe" } },
      "presentation": { "reveal": "always", "panel": "shared", "clear": true },
      "problemMatcher": []
    },
    {
      "label": "AI: status — workflow files status",
      "type": "shell",
      "command": "Write-Host '=== AI Workflow Status ===' -ForegroundColor Cyan; Write-Host ('CLAUDE.md:     ' + $(if (Test-Path CLAUDE.md) {'✓'} else {'✗'})); Write-Host ('AGENTS.md:     ' + $(if (Test-Path AGENTS.md) {'✓'} else {'✗'})); Write-Host ('copilot-inst:  ' + $(if (Test-Path .github/copilot-instructions.md) {'✓'} else {'✗'})); Write-Host ('tasks.json:    ' + $(if (Test-Path .vscode/tasks.json) {'✓'} else {'✗'})); Write-Host ('commands/:     ' + $(if (Test-Path .claude/commands) {'✓'} else {'✗'}))",
      "options": { "shell": { "executable": "powershell.exe" } },
      "presentation": { "reveal": "always", "panel": "shared", "clear": true },
      "problemMatcher": []
    },
    {
      "label": "AI: switch-to-codex — prepare to switch",
      "type": "shell",
      "command": "Write-Host '=== Switching to Codex ===' -ForegroundColor Cyan; Write-Host '1. Send in Claude Code: /switch-to-codex'; Write-Host '2. Потім оновити AGENTS.md:'; Write-Host '   Copy-Item CLAUDE.md AGENTS.md -Force' -ForegroundColor Gray; Write-Host '3. У Codex напиши:'; Write-Host '   Прочитай CLAUDE.md і продовж з розділу Handoff Context' -ForegroundColor Gray",
      "options": { "shell": { "executable": "powershell.exe" } },
      "presentation": { "reveal": "always", "panel": "shared", "clear": true },
      "problemMatcher": []
    },
    {
      "label": "AI: sync — update AGENTS.md from CLAUDE.md",
      "type": "shell",
      "command": "Copy-Item CLAUDE.md AGENTS.md -Force; Copy-Item CLAUDE.md .github/copilot-instructions.md -Force; Write-Host '✓ AGENTS.md and copilot-instructions.md updated' -ForegroundColor Green",
      "options": { "shell": { "executable": "powershell.exe" } },
      "presentation": { "reveal": "always", "panel": "shared", "clear": true },
      "problemMatcher": []
    }
  ]
}
'@ | Set-Content ".vscode\tasks.json" -Encoding UTF8
Write-Green "✓ .vscode\tasks.json created (5 commands)"

# ----------------------------------------------------------
# 6. Claude Code slash-команди
# ----------------------------------------------------------
Write-Yellow "[6/6] Creating Claude Code slash-commands..."

if (-not (Test-Path ".claude\commands")) {
    New-Item -ItemType Directory -Path ".claude\commands" -Force | Out-Null
}

@"
Save the current session state to CLAUDE.md.

Find the ``## Handoff Context`` section and replace its content with current information:

- **Current state:** [what was implemented in this session]
- **Next step:** [what needs to be done next, specifically]
- **Key decisions:** [what architectural or technical decisions were made and why]
- **Last updated:** [current date and time]

Be specific and concise. After updating — confirm that the file was saved.
"@ | Set-Content ".claude\commands\handoff.md" -Encoding UTF8
Write-Green "✓ /handoff"

@"
Read CLAUDE.md fully.

Pay special attention to the ``## Handoff Context`` section.

Briefly summarize:
1. What was done in the previous session
2. What the next step is
3. What key decisions to keep in mind

Then — suggest where to start.
"@ | Set-Content ".claude\commands\resume.md" -Encoding UTF8
Write-Green "✓ /resume"

@"
Check the status of AI workflow files in the project and display a report:

1. Does CLAUDE.md exist and is Handoff Context filled in?
2. Does AGENTS.md exist?
3. Does .github/copilot-instructions.md exist?
4. Does .vscode/tasks.json exist?
5. Does the .claude/commands/ directory exist and what commands are in it?

Display the result as a short checklist with statuses ✓ / ✗ / ⚠
"@ | Set-Content ".claude\commands\status.md" -Encoding UTF8
Write-Green "✓ /status"

$switchToCodex = @"
Before doing anything — ask the user:
"Ready to switch to Codex? I will save the current session state to CLAUDE.md and sync the files. Confirm? (yes/no)"

Proceed only after the answer "yes". If "no" — do nothing and inform that the switch was cancelled.

After confirmation:
1. Update the ## Handoff Context section in CLAUDE.md with the current session state
2. Display the final content of the Handoff Context section
3. Run this command in the terminal to sync:
   Copy-Item CLAUDE.md AGENTS.md -Force
4. Confirm that both files are updated
5. Display the ready phrase to paste into Codex:

---
Read CLAUDE.md and continue development from the Handoff Context section
---
"@
[System.IO.File]::WriteAllText((Join-Path (Resolve-Path ".").Path ".claude\commands\switch-to-codex.md"), $switchToCodex, [System.Text.UTF8Encoding]::new($true))
Write-Green "✓ /switch-to-codex"

$switchFromCodex = @"
Before doing anything — ask the user:
"Returning from Codex to Claude Code? I will read CLAUDE.md and restore the session context. Confirm? (yes/no)"

Proceed only after the answer "yes". If "no" — do nothing and inform that the restore was cancelled.

After confirmation:
1. Read CLAUDE.md fully
2. Check the Handoff Context section — was it updated in Codex?
3. Review recent changes: git log --oneline -5 (if git is available)
4. Summarize what changed and suggest a plan to continue
"@
[System.IO.File]::WriteAllText((Join-Path (Resolve-Path ".").Path ".claude\commands\switch-from-codex.md"), $switchFromCodex, [System.Text.UTF8Encoding]::new($true))
Write-Green "✓ /switch-from-codex"

# ----------------------------------------------------------
# Підсумок
# ----------------------------------------------------------
Write-Host ""
Write-Blue "=================================================="
Write-Blue "  Done! File structure:"
Write-Blue "=================================================="
Write-Host ""
Write-Host "  📄 CLAUDE.md                       <- main file (edit here)" -ForegroundColor Green
Write-Host "  📄 AGENTS.md                       <- copy for Codex" -ForegroundColor Green
Write-Host "  📄 .github\copilot-instructions.md <- copy for Copilot" -ForegroundColor Green
Write-Host "  ⚙️  .vscode\settings.json           <- Copilot reads CLAUDE.md" -ForegroundColor Green
Write-Host "  ⚙️  .vscode\tasks.json              <- VS Code Tasks" -ForegroundColor Green
Write-Host "  📁 .claude\commands\               <- Claude Code slash-commands" -ForegroundColor Green
Write-Host ""
Write-Host "VS Code Tasks (Ctrl+Shift+P -> Run Task):" -ForegroundColor Cyan
Write-Host "  AI: handoff         - reminder to save state"
Write-Host "  AI: resume          - show current Handoff Context"
Write-Host "  AI: status          - check files status"
Write-Host "  AI: switch-to-codex - prepare to switch to Codex"
Write-Host "  AI: sync            - update AGENTS.md from CLAUDE.md"
Write-Host ""
Write-Host "Claude Code slash-commands:" -ForegroundColor Cyan
Write-Host "  /handoff            - save session state"
Write-Host "  /resume             - restore context"
Write-Host "  /status             - check workflow status"
Write-Host "  /switch-to-codex    - prepare to switch to Codex"
Write-Host "  /switch-from-codex  - resume after Codex"
Write-Host ""
Write-Host "⚠ NOTE: Windows does not support symlinks without admin rights." -ForegroundColor Yellow
Write-Host "  After editing CLAUDE.md run Task 'AI: sync'" -ForegroundColor Yellow
Write-Host "  or run: Copy-Item CLAUDE.md AGENTS.md -Force" -ForegroundColor Gray
Write-Host ""
