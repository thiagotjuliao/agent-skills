# Working in this repository

Skills for AI coding agents. A change here changes how an agent works in every
project it is used in, so a skill is written with the care of code that runs
everywhere.

## Writing a skill

- **The header's `description` decides when the skill is used.** Say what it
  does and every situation it applies to, including the ones where the user
  would not name it. A skill that is never triggered does nothing.
- **Describe the workflow, not the tool.** Where a step depends on one agent
  (Claude Code's `@file` imports, a particular CLI), say so in that step.
- **Explain why, not only what.** An instruction with its reason is followed
  sensibly in cases it did not foresee; a bare MUST is followed literally.
- **Keep `SKILL.md` short** — under 500 lines — and move detail into
  `references/`, with a line in `SKILL.md` saying when to read each file.
- **Point to the source of truth instead of copying it.** A skill that uses
  another repository reads that repository's README; it does not restate it.
- **Learned the hard way goes in `references/`.** A pitfall that cost a
  debugging round is written down with its fix, in the file for its area.

## Changing one

- Test it on the tasks it is for before merging: run the agent on a realistic
  request with the skill and without it, and compare.
- After a change is merged, `./install-claude.sh --update` puts it in use.
- Artifacts are in English; scripts come in `.sh` / `.ps1` pairs.
