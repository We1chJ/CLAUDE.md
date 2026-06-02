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
- **fetch-usage.sh** - Helper script that fetches session and weekly usage from the Anthropic API

## Statusline

The statusline displays:
- Current folder
- Active model
- Context window usage
- Session and weekly plan usage limits

All with color-coded progress bars (green → yellow → red as usage increases).

---

## Setup Instructions

### 1. Copy the scripts

Place `statusline.sh` and `fetch-usage.sh` in your `~/.claude/` directory and make them executable:

```sh
chmod +x ~/.claude/statusline.sh
chmod +x ~/.claude/fetch-usage.sh
```

On **Windows (WSL or Git Bash)**, `~/.claude/` resolves to your home directory the same way.

### 2. Update `settings.json` — required manual step

`settings.json` is the one file that **cannot use `$HOME` or relative paths**. Claude Code reads it before any shell expansion, so you must hardcode your full path.

Open `~/.claude/settings.json` and update the `statusLine` command to your actual username:

**macOS / Linux:**
```json
"statusLine": {
  "type": "command",
  "command": "sh /home/YOUR_USERNAME/.claude/statusline.sh"
}
```

**macOS specifically:**
```json
"statusLine": {
  "type": "command",
  "command": "sh /Users/YOUR_USERNAME/.claude/statusline.sh"
}
```

**Windows (WSL):**
```json
"statusLine": {
  "type": "command",
  "command": "sh /home/YOUR_USERNAME/.claude/statusline.sh"
}
```

**Windows (Git Bash):**
```json
"statusLine": {
  "type": "command",
  "command": "sh C:/Users/YOUR_USERNAME/.claude/statusline.sh"
}
```

Replace `YOUR_USERNAME` with your actual system username in all cases.

### 3. Dependencies

Make sure these are installed:

| Tool | macOS | Linux | Windows (WSL) |
|------|-------|-------|---------------|
| `jq` | `brew install jq` | `apt install jq` | `apt install jq` |
| `curl` | built-in | `apt install curl` | `apt install curl` |

### 4. Platform notes

| Feature | macOS | Linux | Windows (WSL) |
|---------|-------|-------|---------------|
| Directory, model, context % | ✅ | ✅ | ✅ |
| Session % and Weekly % | ✅ | ❌ | ❌ |

Session and weekly usage require the macOS `security` keychain CLI to read your Claude OAuth token. On Linux/WSL these segments are silently skipped — the rest of the bar still works.
