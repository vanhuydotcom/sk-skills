# hd-skills

A personal set of Agent Skills, written to the [Agent Skills](https://agentskills.io)
specification so one copy works in every runtime that reads `SKILL.md`.

## Working in this repo

- `skills/<name>/SKILL.md` is the only source. Nothing is duplicated per runtime; `install.sh`
  symlinks the canonical directory into each runtime's path, and every supported runtime follows
  symlinks.
- A skill's `name` must equal its directory name: 1-64 characters, lowercase `a-z0-9-`, no
  leading, trailing or doubled hyphen.
- The `hd-` prefix is deliberate. These install alongside other skill sets, and runtimes that
  merge several skill directories deduplicate by name.
- Keep `SKILL.md` under 500 lines. Detail belongs in `references/`, which is loaded only when the
  skill needs it.
- `description` is the only part loaded into every prompt at startup. Write what the skill does
  *and* when to use it, with the words a user would actually say.

## Portability rules

These exist because runtimes differ in what they expose. Breaking one of them means the skill
silently stops working somewhere.

- Assume only a shell and file access. Do not assume a subagent tool, an interactive question
  tool, or a hooks system — Codex has no `Skill` tool at all, and invocation is caught elsewhere.
- Do not put required procedure in a rules directory. Only Claude Code loads `.claude/rules/`;
  Codex has no equivalent, and omp's `.omp/rules` match streamed output rather than entering the
  prompt. Anything mandatory belongs in the skill or in this file.
- Keep scripts in `scripts/` POSIX-compatible and dependency-light, and state real requirements
  in the `compatibility` field.
- Write skill bodies in English regardless of the conversation language. Model instruction
  following is measurably more reliable there, and these are read by machines.

## Verifying a change

```bash
./install.sh --list                                     # what is linked where
claude -p ok --output-format stream-json --verbose | head -1   # init event lists loaded skills
```

The `init` event is the cheap proof that discovery works. Do not assume a skill is installed
because the symlink exists.
