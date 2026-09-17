# sk-skills

Personal [Agent Skills](https://agentskills.io) — one canonical copy, installed into every
runtime that reads `SKILL.md`.

## Install

```bash
git clone git@github.com:<user>/sk-skills.git ~/Admin/personal/sk-skills
cd ~/Admin/personal/sk-skills

./install.sh --global        # available in every project
./install.sh ~/work/myrepo   # available in one project only
```

`--global` links into `~/.claude/skills`, `~/.codex/skills` and `~/.gemini/config/skills`.
A project install links into `<project>/.claude/skills` and `<project>/.agents/skills`.

## Which runtime sees what

| Runtime | Project scope | Per-user scope |
|---|---|---|
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Codex | `.agents/skills/` | `~/.codex/skills/` |
| Antigravity | `.agents/skills/` | `~/.gemini/config/skills/` |
| omp | `.claude/skills/`, `.agents/skills/`, `.omp/skills/` | — |
| Cursor, VS Code, Gemini CLI, opencode, Kiro, … | read the same format | |

Codex and Antigravity share `.agents/skills/`, and omp reads both directories, so a project
install needs only the two symlink targets.

## Other commands

```bash
./install.sh --list              # show what is linked where
./install.sh --uninstall --global
./install.sh --uninstall ~/work/myrepo
```

Uninstall only removes symlinks that point into this repo; anything else in those directories is
left alone.

## Skills

| Skill | Purpose |
|---|---|
| `sk-scout` | Find the files and call paths behind a task, read-only |
| `sk-code-review` | Review a diff for correctness defects with reproducible triggers |
| `sk-go-service` | Handler, service and repository work in a Go backend |

## Adding a skill

Create `skills/<name>/SKILL.md` with `name` (matching the directory) and `description`, then
re-run `install.sh`. See [AGENTS.md](AGENTS.md) for the conventions and the portability rules.
