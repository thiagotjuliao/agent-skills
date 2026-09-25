---
name: project-tooling
description: Create, align or check a project's tooling — formatter, editor settings, .gitignore/.gitattributes, compiler flags, CI, update bots — from the user's project-templates repository (C:\Git\Pessoal\project-templates, stacks scala-sbt and haskell-cabal). Use it whenever the user starts a new Scala or Haskell project, asks to set up, configure, standardise, align or "bring up to the pattern" an existing one, asks whether a project follows the template, wants to upgrade the pinned stack (Scala, sbt, scalafmt, munit, Java, GHC) across projects, or changes something in the templates themselves — even if they never say "template" or "skill".
---

# project-tooling

The user keeps the configuration every project starts from in one repository:
`C:\Git\Pessoal\project-templates` (github.com/thiagotjuliao/project-templates).
This skill is how that repository gets used: on a new project, on an existing
one that should follow it, and on the templates themselves.

Read the repository's `README.md` first, every time. It is the source of truth
for the layout, the stacks, the pinned versions, the flag groups and the
deliberate exceptions; this skill only describes how to work with it, and it
does not repeat what the README says, so that the two cannot disagree.

## Decide which of three jobs this is

| the user wants | job |
| --- | --- |
| a new project | **Create** |
| an existing project to follow the templates, or to know whether it does | **Align** (or just **Check**) |
| to change a template, a pinned version or the scripts | **Evolve the templates** |

If the stack is not obvious (a new project with no language named, say), ask.
A stack that does not exist yet is not invented here: it is created in
project-templates later, from a real project, once there is one.

## The tool

```bash
./apply.sh <stack> <target> [--check] [--diff] [--contract-only]
./apply.ps1 <stack> <target> [-Check] [-Diff] [-ContractOnly]   # same thing, PowerShell 7
```

It never overwrites. Missing files are created; differing contract files are
reported (`DIFFERS`), with the diff under `--diff`; starter files are created
when missing and otherwise left alone. `--check` writes nothing and exits 1 on
any drift. `--contract-only` skips starters — use it on every existing project,
where a template `build.sbt` or CI workflow would not fit.

## Create

1. Create the directory (its name becomes `{{PROJECT}}`: the sbt `name`, the
   Haskell package name — so a valid package name, lowercase with hyphens).
2. `git init` there, then `apply.sh <stack> <dir>`.
3. Make the starters the project's own: what the project is in `CLAUDE.md`, its
   modules and dependencies in `build.sbt` / the `.cabal` file. Add flags from
   `CompilerFlags` groups rather than writing flag strings.
4. Prove it: `sbt verify` (Scala) or `cabal build all && cabal test all`
   (Haskell) must pass before the first commit.
5. Tell the user about the one step only they can do if the project will run
   Scala Steward: in the repository's Settings → Actions → General → Workflow
   permissions, "Read and write" plus "Allow GitHub Actions to create and
   approve pull requests". It is per repository on a personal account — there
   is no account-wide switch.

## Align

This is where care pays off. An existing project has history, work in progress
and reasons of its own.

**Leave the user's working copy alone.** Check `git status` and the current
branch first. Do the work in a `git worktree` on a new branch from
`origin/main`, so uncommitted changes, unpushed commits and the branch the user
is on are untouched. Remove the worktree when done.

**Read the project's CLAUDE.md before changing anything.** It may set the
language of comments and commit messages, or forbid editing source files
without an explicit request. A formatter upgrade that rewrites sources is such
an edit: show its diff size and a sample, and get the user's word.

**Measure before, then after.** Run the project's own gate (its `verify` alias,
or `testFull`, or `cabal test`) on the untouched branch first and write the
numbers down. Pre-existing failures are part of the baseline, not something to
fix or to hide. After aligning, the numbers must be identical; any difference is
explained before anything is committed.

Then:

1. `apply.sh <stack> <worktree> --check --diff --contract-only` to see the drift.
2. Sort every difference into one of three kinds:
   - **drift** — the project is simply behind: take the template's version;
   - **a project addition** — a line with a reason, like a `.gitignore` entry for
     the project's own data: keep it, with its original comment, in a section
     at the end headed as the project's additions;
   - **an improvement** — something every project of the stack would want: it
     goes into project-templates first (see Evolve), then comes back.
3. Replace drifted contract files with the rendered template (remove them from
   the worktree and re-run `apply.sh --contract-only`), then re-append the
   project additions.
4. Version bumps (sbt, Scala, scalafmt) are checked by running the gate, not by
   reading changelogs. A formatter bump: run the formatter and report how many
   files it touched.
5. Before committing, check that the new `.gitattributes` does not silently
   renormalise line endings: stage everything plus `git add --renormalize .`
   and count files whose only change is CRLF → LF (should be none, or be
   mentioned).
6. One commit per project, in that repository's commit-message style (look at
   `git log`), explaining what changed and what was verified. Push the branch,
   then merge as described in *Merging*.

**Check** is steps 1–2 alone, reported without changing anything.

## Evolve the templates

A change starts in project-templates and reaches projects afterwards, never the
other way round — otherwise the projects drift apart again.

1. Edit the template. A new compiler flag goes into
   `scala-sbt/project/CompilerFlags.scala` as a named `val` with a one-line
   description, and into a group only if every project of that group should
   get it.
2. Prove it locally before pushing, the way the `selftest` workflow does:
   render every stack into scratch directories with **both** `apply.sh` and
   `apply.ps1` and `diff -r` the results; build the Scala result with a small
   fixture (`.github/selftest/scala-sbt/`) through `sbt verify`; build the
   Haskell result with `cabal build all && cabal test all`.
3. Commit and push project-templates (the repository is private; ask the user
   to glance at the Actions tab for the `selftest` result).
4. Propagate with **Align** to each project that should follow.

## Merging

Ask once, at the start of the task, whether you may merge the branches
yourself or the user wants to review and merge them — the answer holds for
that task, not for the next one. Either way the merge is a merge commit, never
a squash: squashing drops the branch's commits, and a tag pointing at one of
them (chapter tags, release tags) falls out of `main`'s history.

**Merging yourself:**

- With the GitHub CLI installed and authenticated (`gh auth status`):
  `gh pr create --fill --base main`, wait for the checks, then
  `gh pr merge --merge --delete-branch`. The pull request stays as the record,
  and CI runs before the merge.
- Without it: merge locally in a worktree of `main` with
  `git merge --no-ff <branch>`, push `main`, then delete the branch locally
  and on the remote. Mention once that installing `gh`
  (`winget install GitHub.cli`, then `gh auth login`, which only the user can
  do) would keep the pull request as the record.

**The user merges:** push the branch and give a compare link,
`https://github.com/<owner>/<repo>/compare/main...<branch>?expand=1`. When
they say it is merged, check that the branch is contained in `origin/main`
before offering to delete it, locally and on the remote.

## Known pitfalls, by stack

Each of these cost a debugging round once. Read the file for the stack at hand
before starting, and add to it when a new one turns up:

- `references/general.md` — shell, git, GitHub and editor, whatever the stack
- `references/scala.md` — sbt 2, scalac, Metals, Coursier
- `references/haskell.md` — cabal, GHC, HLS, fourmolu, hlint
