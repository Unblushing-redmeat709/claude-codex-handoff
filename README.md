# claude-codex-handoff

> Seamless workflow switching between Claude Code and Codex in VS Code  
> Безшовне перемикання між Claude Code та Codex у VS Code

---

## 🇬🇧 English

> [!WARNING]
> **Start small.** This workflow is not recommended for large or complex projects right away. Each AI tool has its own way of understanding context, and switching between them on a big codebase may lead to inconsistent decisions or lost nuance. Try it first on a small or mid-sized project to get a feel for the flow before applying it to something critical.

### The Problem

Claude Code and Codex are two different AI coding assistants. Each has its own memory — they don't know what the other has done. When you switch between them, context is lost. You have to explain the project from scratch every time.

On top of that, these tools use different instruction files:
- **Claude Code** reads `CLAUDE.md`
- **Codex** reads `AGENTS.md`
- **GitHub Copilot** reads `.github/copilot-instructions.md`

Three different files, three different tools — and they all need to stay in sync.

### The Solution

This setup script solves both problems at once.

**One source of truth.** You maintain a single file — `CLAUDE.md`. It holds your project description, architecture notes, coding standards, and most importantly, a `Handoff Context` section that captures the current state of your work before switching tools.

**Automatic sync.** `AGENTS.md` and `.github/copilot-instructions.md` are symlinks (Mac/Linux) or copies (Windows) of `CLAUDE.md`. When you update `CLAUDE.md`, all other tools see the same content.

**Two slash-commands do all the work.** Before switching to Codex, type `/switch-to-codex` in Claude Code — it saves the session state and syncs the files. When you return, type `/switch-from-codex` — it reads the saved context and picks up exactly where you left off.

### Why CLAUDE.md → AGENTS.md?

`AGENTS.md` is the native instruction file that Codex reads — just like `CLAUDE.md` is for Claude Code. Instead of maintaining two separate files, this workflow keeps `AGENTS.md` as a mirror of `CLAUDE.md`. You only ever edit one file. The rest happens automatically.

---

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

The script is safe to run multiple times — it never overwrites existing files.

---

### Switching Between Tools

**Claude Code → Codex:**
1. Type `/switch-to-codex` in Claude Code
2. Confirm when prompted (`yes`)
3. Copy the phrase it outputs → paste into Codex

**Codex → Claude Code:**
1. Type `/switch-from-codex` in Claude Code
2. Confirm when prompted (`yes`)

Both commands ask for confirmation before making any changes — nothing happens without your approval.

---

### Slash Commands (Claude Code)

| Command | Description |
|---|---|
| `/switch-to-codex` | Save session state and prepare for Codex |
| `/switch-from-codex` | Resume after working in Codex |
| `/handoff` | Save current session state to CLAUDE.md |
| `/resume` | Restore context from CLAUDE.md |
| `/status` | Check workflow files status |

---

### File Structure

```
your-project/
├── CLAUDE.md                        ← Main file — edit only this one
├── AGENTS.md                        ← Mirror for Codex
├── .github/
│   └── copilot-instructions.md      ← Mirror for GitHub Copilot
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

> **Windows note:** Windows does not support symlinks without admin rights by default. The script creates copies instead and provides an `AI: sync` VS Code Task to keep them in sync after every edit to `CLAUDE.md`.
>
> **Optional: Enable symlinks on Windows**
> If you prefer true symlinks so that `AGENTS.md` always reflects `CLAUDE.md` automatically, enable Developer Mode in Windows Settings:
> `Settings → System → For developers → Developer Mode → On`
>
> > [!CAUTION]
> > Enabling Developer Mode grants additional system privileges and may increase security exposure. Only do this if you understand the implications. For most users, the `AI: sync` task is the safer and simpler choice.

---

### Requirements

- VS Code
- Claude Code extension (`anthropic.claude-code`)
- Codex extension
- Git Bash (Mac/Linux) or PowerShell (Windows)

---

## 🇺🇦 Українська

> [!WARNING]
> **Починайте з простого.** Цей workflow не рекомендується одразу використовувати на великих або складних проектах. Кожен AI інструмент по-своєму розуміє контекст, і перемикання між ними на великій кодовій базі може призвести до непослідовних рішень або втрати важливих деталей. Спробуйте спочатку на невеликому або середньому проекті — відчуйте як це працює, перш ніж застосовувати на чомусь критичному.

### Проблема

Claude Code і Codex — два різні AI-асистенти для розробки. Кожен має свою пам'ять — вони не знають що робив інший. Коли ти перемикаєшся між ними, контекст губиться. Щоразу доводиться пояснювати проект з нуля.

До того ж ці інструменти використовують різні файли для інструкцій:
- **Claude Code** читає `CLAUDE.md`
- **Codex** читає `AGENTS.md`
- **GitHub Copilot** читає `.github/copilot-instructions.md`

Три різні файли, три різні інструменти — і всі мають бути синхронізовані.

### Рішення

Цей скрипт вирішує обидві проблеми одночасно.

**Єдине джерело істини.** Ти підтримуєш один файл — `CLAUDE.md`. У ньому — опис проекту, архітектурні рішення, стандарти коду і найголовніше — секція `Handoff Context`, яка фіксує поточний стан роботи перед переключенням.

**Автоматична синхронізація.** `AGENTS.md` і `.github/copilot-instructions.md` — це симлінки (Mac/Linux) або копії (Windows) файлу `CLAUDE.md`. Коли ти оновлюєш `CLAUDE.md` — всі інші інструменти бачать той самий вміст.

**Дві slash-команди роблять всю роботу.** Перед переходом у Codex напиши `/switch-to-codex` у Claude Code — вона збереже стан сесії і синхронізує файли. Коли повертаєшся — напиши `/switch-from-codex` — вона прочитає збережений контекст і продовжить з того місця де зупинились.

### Чому CLAUDE.md → AGENTS.md?

`AGENTS.md` — це рідний файл інструкцій який читає Codex, так само як `CLAUDE.md` для Claude Code. Замість того щоб підтримувати два окремі файли, цей workflow робить `AGENTS.md` дзеркалом `CLAUDE.md`. Ти редагуєш тільки один файл. Решта відбувається автоматично.

---

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

Скрипт можна запускати повторно — він ніколи не перезаписує існуючі файли.

---

### Перемикання між інструментами

**Claude Code → Codex:**
1. Напиши `/switch-to-codex` у Claude Code
2. Підтвердь коли запитає (`так`)
3. Скопіюй фразу яку вона виведе → встав у Codex

**Codex → Claude Code:**
1. Напиши `/switch-from-codex` у Claude Code
2. Підтвердь коли запитає (`так`)

Обидві команди запитують підтвердження перед будь-якими змінами — без вашої згоди нічого не відбувається.

---

### Slash-команди (Claude Code)

| Команда | Опис |
|---|---|
| `/switch-to-codex` | Зберегти стан сесії і підготуватись до Codex |
| `/switch-from-codex` | Відновити роботу після Codex |
| `/handoff` | Зберегти поточний стан сесії у CLAUDE.md |
| `/resume` | Відновити контекст з CLAUDE.md |
| `/status` | Перевірити стан файлів |

---

### Структура файлів

```
your-project/
├── CLAUDE.md                        ← Головний файл — редагуй тільки його
├── AGENTS.md                        ← Дзеркало для Codex
├── .github/
│   └── copilot-instructions.md      ← Дзеркало для GitHub Copilot
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

> **Примітка для Windows:** Windows не підтримує симлінки без прав адміністратора за замовчуванням. Скрипт створює копії замість симлінків і надає VS Code Task `AI: sync` для синхронізації після кожного редагування `CLAUDE.md`.
>
> **Додатково: увімкнути симлінки на Windows**
> Якщо ти хочеш справжні симлінки щоб `AGENTS.md` завжди автоматично відображав зміни з `CLAUDE.md`, увімкни режим розробника у налаштуваннях Windows:
> `Параметри → Система → Для розробників → Режим розробника → Увімкнути`
>
> > [!CAUTION]
> > Увімкнення режиму розробника надає додаткові системні привілеї та може збільшити ризики безпеки. Робіть це лише якщо розумієте наслідки. Для більшості користувачів Task `AI: sync` є безпечнішим і простішим вибором.

---

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
