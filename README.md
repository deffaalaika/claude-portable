# claude-portable

Personal working preferences and Android field notes for **Claude Code**, packaged so they
can be installed on a machine that can open GitHub but cannot log in to it.

The package is attached to the [latest release](../../releases/latest) as a zip with a
`SHA256SUMS` file. No GitHub login is needed.

## Guidance, not a source of truth

The notes come from experience on a **previous** codebase. They are a list of things worth
checking and lessons that proved useful, not a standard of right and wrong for any other
project. Every codebase has its own structure, conventions and team process. When they
disagree, the current project wins, in this order:

1. The user's instructions and the team's decisions
2. Conventions visible in the current codebase (its README/CLAUDE.md, dominant code patterns, CI)
3. These notes

Platform facts (Android, Gradle, Kotlin, AGP behaviour) and verification habits travel best.
Process rules (publish flow, golden-image policy, staged gates) are the most likely not to apply.

## Requirements

- macOS or Linux with `curl`, `unzip`, `shasum`
- [Claude Code](https://docs.claude.com/en/docs/claude-code) installed

## Install (one command)

```bash
curl -fLO https://raw.githubusercontent.com/deffaalaika/claude-portable/main/get-claude-portable.sh
bash get-claude-portable.sh
```

The script downloads the package into `./claude-portable-download`, verifies its SHA-256
checksum, unzips it and copies the files into `~/.claude`. Existing files are **not**
overwritten. To replace them (the old ones are backed up as `*.bak-<timestamp>`):

```bash
bash get-claude-portable.sh --force
```

Then start a new Claude Code session. Afterwards you can delete the `claude-portable-download` folder.

## Install (manual, via browser)

1. From the [latest release](../../releases/latest), download `claude-portable.zip` and `SHA256SUMS` into one folder.
2. Download `get-claude-portable.sh` into the same folder and run it with that folder:
   ```bash
   bash get-claude-portable.sh .
   ```
   Or by hand:
   ```bash
   shasum -a 256 -c SHA256SUMS
   unzip claude-portable.zip
   bash claude-portable/install.sh
   ```

## What's in the package

| Installed to | Content |
|---|---|
| `~/.claude/CLAUDE.md` | Global working preferences: git (no auto-push, no AI attribution in commits, per-hunk merges), verification habits, workflow, zsh pitfalls |
| `~/.claude/skills/android-field-notes/` | Skill loaded during Android work. References: verification, Gradle/AAR artifacts, Kotlin↔Java ABI, View/XML UI, Roborazzi/Robolectric visual testing, git/shell |

The notes are written in Indonesian.

## Not included

Anything specific to a previous organisation: repository/module/package names, app
architecture, feature flows, ticket IDs, branch names, registry details, security
mechanisms, credentials and internal documents. Only general Android/Gradle/Kotlin
knowledge is included.

## License

Provided as-is.
