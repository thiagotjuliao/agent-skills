# agent-skills

Skills for AI coding agents: the workflows I keep asking an agent to follow,
written down once so they are followed the same way every time.

A skill is a folder with a `SKILL.md` — a short header saying what the skill is
for and when to use it, then the instructions — plus any reference files it
reads on demand. The format is Anthropic's open Agent Skills format; the
instructions themselves describe *the workflow*, not a particular tool, so they
stay useful to any agent that can be pointed at a Markdown file.

## Skills

| skill | what it does |
| --- | --- |
| [project-tooling](skills/project-tooling/SKILL.md) | creates, aligns and checks a project's tooling from [project-templates](https://github.com/thiagotjuliao/project-templates) |

## Installing

Claude Code reads personal skills from `~/.claude/skills/`.

```bash
./install-claude.sh                    # install every skill that is not installed yet
./install-claude.sh project-tooling    # just one
./install-claude.sh --update           # also replace installed copies that differ
./install-claude.sh --check            # write nothing; exit 1 if anything is out of date
```

```powershell
./install-claude.ps1 -Update
```

An installed skill that differs from this repository is reported with its
diff and left alone unless `--update` is given: the installed copy may carry an
edit made in place, and a blind copy would lose it. Skills installed from
anywhere else are never touched.

Another agent gets its own `install-<agent>` pair next to these; the skills do
not change.

## Layout

```
skills/<name>/SKILL.md           the skill: header, then instructions
skills/<name>/references/*.md    detail read only when the skill says so
install-claude.sh / .ps1         installers, one pair per agent
```
