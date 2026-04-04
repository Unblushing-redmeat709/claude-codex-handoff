# claude-codex-handoff

> Seamless workflow switching between Claude Code and Codex in VS Code  
> Безшовне перемикання між Claude Code та Codex у VS Code

---

## 🇬🇧 English

> [!WARNING]
> **Start small.** This workflow is not recommended for large or complex projects right away. Each AI tool has its own way of understanding context, and switching between them on a big codebase may lead to inconsistent decisions or lost nuance. Try it first on a small or mid-sized project to get a feel for the flow before applying it to something critical.

### What is this?

A setup script that configures your project for hybrid AI development — using **Claude Code** as the primary tool and **Codex** as a fallback when Claude Code tokens run out.

The script creates:
- A single source of truth (`CLAUDE.md`) shared between both AI tools
- Claude Code slash-commands for seamless session handoff
- VS Code Tasks for quick actions

### How it works

Every session state is saved in `CLAUDE.md` under the `Handoff Context` section. Both Claude Code and Codex read this file, so switching between them requires just two commands.

### Quick Start

**Windows (PowerShell):**
```powershell
# Run once per project
D:\path\to\setup-ai-workflow.ps1
```

**Mac / Linux (Bash):**
```bash
# Run once per project
bash setup-ai-workflow.sh
```

### Switching Between Tools

**Claude Code → Codex:**
1. Type `/switch-to-codex` in Claude Code
2. Confirm when prompted (`yes`)
3. Copy the phrase it outputs → paste into Codex

**Codex → Claude Code:**
1. Type `/switch-from-codex` in Claude Code
2. Confirm when prompted (`yes`)

Both commands ask for confirmation before making any changes — nothing happens without your approval.

### Slash Commands (Claude Code)

| Command | Description |
|---|---|
| `/switch-to-codex` | Save session state and prepare for Codex |
| `/switch-from-codex` | Resume after working in Codex |
| `/handoff` | Save current session state to CLAUDE.md |
| `/resume` | Restore context from CLAUDE.md |
| `/status` | Check workflow files status |

### File Structure

```
your-project/
├── CLAUDE.md                        ← Main file (edit here)
├── AGENTS.md                        ← Copy for Codex
├── .github/
│   └── copilot-instructions.md      ← Copy for GitHub Copilot
├── .vscode/
│   ├── settings.json                ← Copilot reads CLAUDE.md
│   └── tasks.json                   ← VS Code Tasks
└── .claude/
    └── commands/                    ← Claude Code slash-commands
        ├── switch-to-codex.md
        ├── switch-from-codex.md
        ├── handoff.md
        ├── resume.md
        └── status.md
```

> **Windows note:** Windows does not support symlinks without admin rights by default. The script creates copies instead and provides an `AI: sync` task to keep them in sync.
>
> **Optional: Enable symlinks on Windows**
> If you prefer true symlinks (so `AGENTS.md` always reflects `CLAUDE.md` automatically), you can enable Developer Mode in Windows Settings:
> `Settings → System → For developers → Developer Mode → On`
>
> > [!CAUTION]
> > Enabling Developer Mode grants additional system privileges and may increase security exposure. Only do this if you understand the implications. For most users, the `AI: sync` task is the safer and simpler choice.

### Requirements

- VS Code
- Claude Code extension (`anthropic.claude-code`)
- Codex extension
- Git Bash (Mac/Linux) or PowerShell (Windows)

---

## 🇺🇦 Українська

> [!WARNING]
> **Починайте з простого.** Цей workflow не рекомендується одразу використовувати на великих або складних проектах. Кожен AI інструмент по-своєму розуміє контекст, і перемикання між ними на великій кодовій базі може призвести до непослідовних рішень або втрати важливих деталей. Спробуйте спочатку на невеликому або середньому проекті — відчуйте як це працює, перш ніж застосовувати на чомусь критичному.

### Що це таке?

Скрипт налаштування для гібридної AI розробки — використовуєш **Claude Code** як основний інструмент і **Codex** як резервний коли закінчуються токени Claude Code.

Скрипт створює:
- Єдине джерело істини (`CLAUDE.md`) спільне для обох AI інструментів
- Slash-команди Claude Code для безшовної передачі сесії
- VS Code Tasks для швидких дій

### Як це працює

Стан кожної сесії зберігається у `CLAUDE.md` в секції `Handoff Context`. Обидва інструменти читають цей файл, тому перемикання між ними потребує лише двох команд.

### Швидкий старт

**Windows (PowerShell):**
```powershell
# Запускати один раз для кожного проекту
D:\шлях\до\setup-ai-workflow.ps1
```

**Mac / Linux (Bash):**
```bash
# Запускати один раз для кожного проекту
bash setup-ai-workflow.sh
```

### Перемикання між інструментами

**Claude Code → Codex:**
1. Напиши `/switch-to-codex` у Claude Code
2. Підтвердь коли запитає (`так`)
3. Скопіюй фразу яку вона виведе → встав у Codex

**Codex → Claude Code:**
1. Напиши `/switch-from-codex` у Claude Code
2. Підтвердь коли запитає (`так`)

Обидві команди запитують підтвердження перед будь-якими змінами — без вашої згоди нічого не відбувається.

### Slash-команди (Claude Code)

| Команда | Опис |
|---|---|
| `/switch-to-codex` | Зберегти стан сесії і підготуватись до Codex |
| `/switch-from-codex` | Відновити роботу після Codex |
| `/handoff` | Зберегти поточний стан сесії у CLAUDE.md |
| `/resume` | Відновити контекст з CLAUDE.md |
| `/status` | Перевірити стан файлів workflow |

### Структура файлів

```
your-project/
├── CLAUDE.md                        ← Головний файл (редагуй тут)
├── AGENTS.md                        ← Копія для Codex
├── .github/
│   └── copilot-instructions.md      ← Копія для GitHub Copilot
├── .vscode/
│   ├── settings.json                ← Copilot читає CLAUDE.md
│   └── tasks.json                   ← VS Code Tasks
└── .claude/
    └── commands/                    ← Slash-команди Claude Code
        ├── switch-to-codex.md
        ├── switch-from-codex.md
        ├── handoff.md
        ├── resume.md
        └── status.md
```

> **Примітка для Windows:** Windows не підтримує симлінки без прав адміністратора за замовчуванням. Скрипт створює копії замість симлінків і надає Task `AI: sync` для синхронізації.
>
> **Додатково: увімкнути симлінки на Windows**
> Якщо ти хочеш справжні симлінки (щоб `AGENTS.md` завжди автоматично відображав зміни з `CLAUDE.md`), увімкни Developer Mode у налаштуваннях Windows:
> `Параметри → Система → Для розробників → Режим розробника → Увімкнути`
>
> > [!CAUTION]
> > Увімкнення режиму розробника надає додаткові системні привілеї та може збільшити ризики безпеки. Робіть це лише якщо розумієте наслідки. Для більшості користувачів Task `AI: sync` є безпечнішим і простішим вибором.

### Вимоги

- VS Code
- Розширення Claude Code (`anthropic.claude-code`)
- Розширення Codex
- Git Bash (Mac/Linux) або PowerShell (Windows)

---

## Author

[Олександр Мельничук](https://github.com/DoctorMOMcv)

## License

MIT
