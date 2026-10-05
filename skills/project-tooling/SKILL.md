---
name: project-tooling
description: Create, align or check a project's tooling — formatter, editor settings, .gitignore/.gitattributes, compiler flags, CI, update bots — from the user's project-templates repository (github.com/thiagotjuliao/project-templates, stacks scala-sbt and haskell-cabal). Use it whenever the user starts a new Scala or Haskell project, asks to set up, configure, standardise, align or "bring up to the pattern" an existing one, asks whether a project follows the template, wants to upgrade the pinned stack (Scala, sbt, scalafmt, munit, Java, GHC) across projects, or changes something in the templates themselves — even if they never say "template" or "skill".
---

# project-tooling

The user keeps the configuration every project starts from in one repository,
github.com/thiagotjuliao/project-templates (private). This skill is how that
repository gets used: on a new project, on an existing one that should follow
it, and on the templates themselves.

## Find the templates

The user works on more than one machine and operating system, and the clone
sits in a different place on each (`C:\Git\Pessoal\project-templates` on one,
nowhere yet on another), so its path is found, never assumed:

1. Look for an existing clone — a sibling of the current project's directory
   first, since the user keeps their repositories side by side — and confirm it
   is the right one with `git -C <dir> remote get-url origin`.
2. If there is none, ask where to put it (offer the sibling directory) and
   clone it with an authenticated `gh repo clone
   thiagotjuliao/project-templates <dir>`; the repository is private, so a
   plain `git clone` over HTTPS without credentials fails.
3. Bring it up to date with `git -C <dir> pull --ff-only` before using it. A
   stale clone renders old templates, and an Align would then report the
   project as drifted in the wrong direction. If the pull is refused, the clone
   has local work: report it and stop rather than discard it.

Use `apply.sh` from bash (macOS, Linux, Git Bash) and `apply.ps1` from
PowerShell; they do the same thing.

Read the repository's `README.md` next, every time. It is the source of truth
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

## Ask first, once per task

Two answers shape everything after them, so get both before the first change:

- **Who the author is** — name and email. They go into `LICENSE.md` and into
  every commit, which is authored by the person with the agent as
  `Co-Authored-By`. Offer what git resolves in the project
  (`git config user.name`, `git config user.email`) as the default, but show
  it: the global identity can be a work address that does not belong in a
  personal project. If the two differ across the user's repositories, say so.
- **Whether you may merge yourself** — see *Merging*.

The answers hold for this task, not for the next one.

## The tool

```bash
./apply.sh <stack> <target> [--check] [--diff] [--contract-only] [--author "Name <email>"]
./apply.ps1 <stack> <target> [-Check] [-Diff] [-ContractOnly] [-Author "Name <email>"]
```

It never overwrites. Missing files are created; differing contract files are
reported (`DIFFERS`), with the diff under `--diff`; starter files are created
when missing and otherwise left alone. `--check` writes nothing and exits 1 on
any drift. `--contract-only` skips starters — use it on every existing project,
where a template `build.sbt` or CI workflow would not fit. Always pass
`--author` with the answer from above.

## Create

1. Create the directory (its name becomes `{{PROJECT}}`: the sbt `name`, the
   Haskell package name — so a valid package name, lowercase with hyphens).
2. `git init` there, then `apply.sh <stack> <dir> --author "<name> <email>"`.
3. Make the starters the project's own: what the project is in `CLAUDE.md` (it
   already loads `CONVENTIONS.md`), its modules and dependencies in
   `build.sbt` / the `.cabal` file. Add flags from `CompilerFlags` groups
   rather than writing flag strings.
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
5. The project's documents: `CONVENTIONS.md` arrives as a contract file; make
   sure the project's `CLAUDE.md` loads it (`@CONVENTIONS.md`) — creating a
   minimal `CLAUDE.md` if there is none, written from the project's README —
   and that anything project-specific that contradicts it stays stated in
   `CLAUDE.md`, which wins. A project without a `LICENSE.md` gets the starter
   (render it with `--author`); an existing MIT license keeps its year and
   gains the author's email, and a `LICENSE` without extension becomes
   `LICENSE.md` (`git mv`, so history follows). A license that is not MIT is
   never changed without asking.
6. Before committing, check that the new `.gitattributes` does not silently
   renormalise line endings: stage everything plus `git add --renormalize .`
   and count files whose only change is CRLF → LF (should be none, or be
   mentioned).
7. One commit per project, in that repository's commit-message style (look at
   `git log`) and under `CONVENTIONS.md`'s git rules, explaining what changed
   and what was verified. Push the branch, then merge as described in
   *Merging*.

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
- Without it, where `main` is free to check out: `git switch main`,
  `git merge --no-ff <branch>`, push `main`, delete the branch.
- Without it, where `main` is checked out in the user's own working copy
  (and so cannot be checked out anywhere else): build the merge commit
  without a checkout — `git commit-tree <branch>^{tree} -p origin/main -p
  <branch> -m "Merge branch '<branch>'"` — and push it with
  `git push origin <sha>:refs/heads/main`. That is a fast-forward of the
  remote as long as the branch was cut from the latest `origin/main`; if the
  push is rejected, `main` moved: rebase the branch onto it and build again.
  The user's local `main` is then behind until they pull — say so.
- Without `gh`, mention once that installing it — `brew install gh` on macOS,
  `winget install GitHub.cli` on Windows, the distribution's package on Linux
  — then `gh auth login`, which only the user can do, would keep the pull
  request as the record.

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
