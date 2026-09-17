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
| `sk-plan` | Fix the outcome and acceptance criteria, then split into verifiable phases |
| `sk-implement` | Write code for settled scope, matching local conventions, verified before done |
| `sk-debug` | Prove the root cause with evidence, then fix at the cause |
| `sk-test` | Pick the cheapest test level that catches the defect; test behaviour, not internals |
| `sk-code-review` | Review a diff for correctness defects with reproducible triggers |
| `sk-git` | Conventional commits, one concern per commit, secret scan before publishing |
| `sk-go-service` | Handler, service and repository work in a Go backend |
| `sk-react` | React and TypeScript components: state, effects, data fetching, re-renders |
| `sk-sql` | Schema, queries, indexes, and migrations with a real rollback path |
| `sk-api` | Design and change API contracts without breaking existing callers |
| `sk-security` | Find real security defects, starting from what the code protects |
| `sk-perf` | Measure, find the dominant cost, fix that, measure again |
| `sk-incident` | Triage a live problem: blast radius, mitigate first, capture evidence |
| `sk-docs` | Update the smallest owning surface, and verify every claim against source |
| `sk-explain` | Explain grounded in the source, mental model before detail |
| `sk-handoff` | Capture in-progress work so another session can resume cold |
| `sk-diagram` | Mermaid diagrams that show a real mechanism |

## Adding a skill

Create `skills/<name>/SKILL.md` with `name` (matching the directory) and `description`, then
re-run `install.sh`. See [AGENTS.md](AGENTS.md) for the conventions and the portability rules.
