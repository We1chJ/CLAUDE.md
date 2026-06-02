# Claude Configuration

Configuration files for Claude Code.

## Statusline Preview

```
📂 my-app | ★ Claude Haiku | Context: ▓▓▓░░░░░░░ 35% | Session: ▓▓░░░░░░░░ 22% | Weekly: ▓░░░░░░░░░ 9%
```

Custom statusline showing folder, model, context usage, and plan limits with color-coded progress bars.

## Files

- **CLAUDE.md** - Global instructions and coding guidelines for Claude Code sessions
- **settings.json** - Claude Code settings including permissions, statusline configuration, and preferences
- **statusline.sh** - Script that renders the status bar
- **fetch-usage.sh** - Script that fetches session and weekly usage from the Anthropic API

---

## Setup Instructions

### 1. Copy the scripts

Place `statusline.sh` and `fetch-usage.sh` in your `~/.claude/` directory and make them executable:

**macOS / Linux:**
```sh
chmod +x ~/.claude/statusline.sh
chmod +x ~/.claude/fetch-usage.sh
```

**Windows (WSL or Git Bash):**
```sh
chmod +x ~/.claude/statusline.sh
chmod +x ~/.claude/fetch-usage.sh
```

**Windows (plain PowerShell / cmd):** The scripts are shell scripts and require WSL or Git Bash. Native PowerShell is not supported.

---

### 2. Update settings.json

Open `~/.claude/settings.json` and add the following block (or merge it into the existing file):

```json
"statusLine": {
  "type": "command",
  "command": "sh /FULL/PATH/TO/.claude/statusline.sh"
}
```

> **Important:** `settings.json` does NOT support `~` or `$HOME` — Claude Code reads this file before any shell expansion, so you must use the **full absolute path** to `statusline.sh`.

Replace the path depending on your OS:

| OS | Example path |
|---|---|
| macOS | `sh /Users/yourname/.claude/statusline.sh` |
| Linux | `sh /home/yourname/.claude/statusline.sh` |
| Windows (WSL) | `sh /home/yourname/.claude/statusline.sh` |
| Windows (Git Bash) | `sh C:/Users/yourname/.claude/statusline.sh` |

---

### 3. Install dependencies

Both scripts require `jq` and `curl`:

**macOS:**
```sh
brew install jq curl
```

**Linux (Debian/Ubuntu):**
```sh
sudo apt install jq curl
```

**Windows (WSL):**
```sh
sudo apt install jq curl
```

---

### 4. Platform notes

| Feature | macOS | Linux | Windows (WSL) | Windows (native) |
|---|---|---|---|---|
| Directory, model, context % | Yes | Yes | Yes | No |
| Session % and Weekly % | Yes | No | No | No |

The Session and Weekly usage segments rely on the macOS `security` keychain CLI to read your Claude OAuth token. On Linux and WSL, those segments are silently skipped — the rest of the bar still works.
