# General pitfalls

Whatever the stack: shell, git, GitHub and the editor.

- **Piping a script into `head` kills it midway** (SIGPIPE). A scaffold run as
  `script | head -3` created only its first files and exited silently.
  Redirect the output to a file and read that instead.
- **Many heredocs and quotes in one shell call** can fail to parse as a whole,
  and then nothing runs. Write files with the editor tools, or one heredoc per
  call.
- **`rm` on a path built from shell variables** is blocked by a safety check,
  because an empty variable could turn it into `rm -rf /`. Write the path
  literally, or guard each variable: `"${VAR:?}/..."`.
- **Git Bash rewrites `origin/main:path`** into a Windows path, and git then
  cannot find the revision. Prefix the command with `MSYS_NO_PATHCONV=1`, or
  read the file from the working tree.
- **`bash` called from PowerShell is WSL's bash**, not Git Bash: another view of
  the filesystem, and no Java or sbt. Run `.sh` scripts from Git Bash, or use
  their `.ps1` twin.
- **A deep `git worktree` breaks Windows' MAX_PATH** (2026-11-10). Under the
  Claude scratchpad (`C:\Users\...\AppData\Local\Temp\claude\<hash>\<uuid>\scratchpad\wt\<project>`),
  `cabal build` failed in `ghc-pkg` with `openBinaryTempFileWithDefaultPermissions: invalid argument (Invalid argument)`
  on `dist-newstyle\...\package.conf.inplace`, and `git worktree remove`
  failed with `Filename too long` on an sbt project's `target/`. Put the
  worktree at a short path, a sibling of the repository (`git worktree move`
  an existing one). Remove a stuck one from PowerShell with
  `Remove-Item -LiteralPath '\\?\<path>' -Recurse -Force`, then
  `git worktree prune`.
- **`gh pr merge --auto` does not wait for CI when nothing requires it**
  (2026-11-10, scala-type-programming#29). With no required status checks in
  the branch protection, the pull request is mergeable at once and is merged
  on the spot. Wait for the checks (`gh pr checks --watch`) and merge after
  them, or make the checks required first.
- **A private repository is invisible to the API without a login.** Workflow
  runs and settings cannot be read with plain `curl`; ask the user to look, or
  use an authenticated `gh`.
- **GitHub Actions permissions on a personal account are per repository.**
  There is no account-wide switch to let Actions create pull requests; that
  exists for organizations only.
- **Verify versions against the source, not memory.** Artifact versions from
  Maven Central's `maven-metadata.xml`, Action versions from the GitHub releases
  API, and an Action's input names from its `action.yml`.
- **A new `.gitattributes` can renormalise line endings.** Before committing
  one, stage everything plus `git add --renormalize .` and count the files
  whose only change is CRLF → LF.
- **VS Code colours have two layers.** A language server's semantic tokens win
  over the TextMate grammar, so a colour set only in
  `editor.tokenColorCustomizations` may seem to do nothing; set
  `editor.semanticTokenColorCustomizations` as well.
