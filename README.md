# Claude Configuration

**Honestly just toss this into Claude and tell it to set it up for you lol**

![Platform Support](https://camo.githubusercontent.com/f95fa034d83e7049df1402b9f0a007b39eed90274dcfb08b96ad07b92a898dfb/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f6d61634f5325323025374325323057696e646f77732532302537432532304c696e75782d3131313832373f7374796c653d666f722d7468652d6261646765)

Configuration files for Claude Code, including a custom status bar for the terminal.

> **Note:** The Session and Weekly usage bars are designed for users on a **Claude subscription plan (Pro, Max, etc.)**. If you're on API billing, those segments won't show anything — the rest of the bar (folder, model, context %) works for everyone.

## Statusline Preview

```
📂 my-app | ★ Claude Sonnet | Context: ▓▓▓░░░░░░░ 35% | Session: ▓▓░░░░░░░░ 22% | Weekly: ▓░░░░░░░░░ 9%
```

Color-coded progress bars for context window, session usage, and weekly plan usage — always visible at the bottom of your terminal.

---

## Files

| File | Platform | Purpose |
|---|---|---|
| `CLAUDE.md` | All | Global instructions and coding guidelines for Claude Code |
| `settings.json` | All | Claude Code settings — permissions, statusline config, plugins |
| `statusline.sh` | macOS / Linux / WSL | Shell script that renders the status bar |
| `fetch-usage.sh` | macOS / Linux / WSL | Helper that fetches session and weekly usage from Anthropic API |
| `statusline.js` | Windows (native) | Node.js script that renders the status bar (no shell required) |

---

## What the status bar shows

- **📂 Folder** — current working directory
- **★ Model** — which Claude model is active
- **Context bar** — how full the context window is (green → yellow → red)
- **Session bar** — 5-hour rolling usage against your plan limit
- **Weekly bar** — 7-day rolling usage against your plan limit

---

## Setup

Pick your platform:

- [macOS](#macos)
- [Linux](#linux)
- [Windows — native (Git Bash / PowerShell)](#windows--native)
- [Windows — WSL](#windows--wsl)

---

### macOS

**1. Copy files**

```sh
# Files are already here if you cloned the repo into ~/.claude
# If not, copy them manually:
cp statusline.sh ~/.claude/statusline.sh
cp fetch-usage.sh ~/.claude/fetch-usage.sh
chmod +x ~/.claude/statusline.sh ~/.claude/fetch-usage.sh
```

**2. Install dependencies**

```sh
brew install jq
# curl is built-in on macOS
```

**3. Update `settings.json`**

Open `~/.claude/settings.json` and set the `statusLine` key. Replace `YOUR_USERNAME` with your macOS username (run `whoami` if unsure):

```json
"statusLine": {
  "type": "command",
  "command": "sh /Users/YOUR_USERNAME/.claude/statusline.sh"
}
```

> **Why hardcode the path?** Claude Code reads `settings.json` before any shell is started, so `$HOME` and `~` are not expanded. The full path is required.

**4. Restart Claude Code**

```sh
exit
claude
```

**Features available on macOS:**

| Feature | Works? |
|---|---|
| Folder, model, context % | ✅ |
| Session % and Weekly % | ✅ (reads token from macOS keychain) |

---

### Linux

**1. Copy files**

```sh
cp statusline.sh ~/.claude/statusline.sh
cp fetch-usage.sh ~/.claude/fetch-usage.sh
chmod +x ~/.claude/statusline.sh ~/.claude/fetch-usage.sh
```

**2. Install dependencies**

```sh
sudo apt install jq curl   # Debian/Ubuntu
# or
sudo dnf install jq curl   # Fedora/RHEL
```

**3. Update `settings.json`**

Open `~/.claude/settings.json` and set the `statusLine` key. Replace `YOUR_USERNAME` with your Linux username (run `whoami` if unsure):

```json
"statusLine": {
  "type": "command",
  "command": "sh /home/YOUR_USERNAME/.claude/statusline.sh"
}
```

**4. Restart Claude Code**

```sh
exit
claude
```

**Features available on Linux:**

| Feature | Works? |
|---|---|
| Folder, model, context % | ✅ |
| Session % and Weekly % | ✅ (reads token from `~/.claude/.credentials.json`) |

> The credentials file is created automatically when you log in to Claude Code. If Session/Weekly bars don't appear, check that `~/.claude/.credentials.json` exists and contains `claudeAiOauth.accessToken`.

---

### Windows — native

On native Windows, inline shell commands in `settings.json` can break silently due to how Windows handles certain characters. The fix: use `statusline.js` — a Node.js script — instead of the shell script. Node.js is already installed since Claude Code requires it.

**1. Copy the file**

Open File Explorer and copy `statusline.js` to `C:\Users\YOUR_USERNAME\.claude\statusline.js`.

Or from Git Bash / PowerShell:

```sh
cp statusline.js ~/.claude/statusline.js
```

**2. No extra dependencies needed**

`statusline.js` uses only Node.js built-ins (`https`, `fs`, `path`, `os`). Nothing to install.

**3. Update `settings.json`**

Open `C:\Users\YOUR_USERNAME\.claude\settings.json`. Replace `YOUR_USERNAME` with your Windows username:

```json
"statusLine": {
  "type": "command",
  "command": "node C:/Users/YOUR_USERNAME/.claude/statusline.js"
}
```

Use forward slashes (`/`) in the path, not backslashes.

**4. Restart Claude Code**

Close and reopen the Claude Code terminal, or type `exit` then `claude`.

**Features available on Windows (native):**

| Feature | Works? |
|---|---|
| Folder, model, context % | ✅ |
| Session % and Weekly % | ✅ (reads token from `~/.claude/.credentials.json`) |

> The credentials file is created automatically when you log in to Claude Code at `C:\Users\YOUR_USERNAME\.claude\.credentials.json`.

---

### Windows — WSL

WSL runs a full Linux environment, so the Linux setup applies exactly. Follow the [Linux instructions](#linux) above, using your WSL home directory path (e.g. `/home/YOUR_USERNAME`).

**Features available on WSL:**

| Feature | Works? |
|---|---|
| Folder, model, context % | ✅ |
| Session % and Weekly % | ✅ (reads token from `~/.claude/.credentials.json`) |

---

## Feature support summary

| Feature | macOS | Linux | Windows (native) | Windows (WSL) |
|---|---|---|---|---|
| Folder, model, context % | ✅ | ✅ | ✅ | ✅ |
| Session % and Weekly % | ✅ | ✅ | ✅ | ✅ |

> Session/Weekly % require a Claude Max or Pro subscription. On API billing plans, these segments will be empty.

---

## Troubleshooting

**Status bar doesn't appear at all**
- Check that the path in `settings.json` is correct and uses your actual username
- Confirm the script file exists at that path
- Restart Claude Code after any change to `settings.json`

**Session/Weekly % not showing**
- Make sure you are logged in to Claude Code (the credentials file is created on login)
- On macOS: verify the keychain entry exists by running `security find-generic-password -s 'Claude Code-credentials' -w`
- On Linux/Windows: verify `~/.claude/.credentials.json` exists and is valid JSON

**Bar appears but looks broken (missing characters)**
- Your terminal font may not support block characters (`▓░`). Switch to a monospace font like JetBrains Mono, Fira Code, or any Nerd Font.
