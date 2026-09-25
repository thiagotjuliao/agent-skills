# Haskell pitfalls

cabal, GHC, HLS, fourmolu and hlint.

- **fourmolu and hlint are not installed locally** on the user's machine; HLS
  runs fourmolu inside the editor. Their CI steps are therefore the first real
  check of a formatting or lint change — say so, and ask the user to look at
  the run.
- **The package name is the directory name** when a project is created from
  the template (`{{PROJECT}}.cabal`): lowercase letters, digits and hyphens.
