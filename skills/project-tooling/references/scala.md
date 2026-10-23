# Scala pitfalls

sbt 2, the Scala 3 compiler, Metals and Coursier.

- **sbt 2 runs test suites in parallel inside a forked JVM.** Suites that
  measure allocation or JIT behaviour interfere with each other and fail only
  in the full run, never alone. `Test / testForkedParallel := false` on those
  modules restores sbt 1 behaviour.
- **sbt 2's `test` is incremental**: it runs what failed, what never ran and
  what a change touched. A gate uses `testFull`; the greenest possible `test`
  run is the one that ran nothing.
- **sbt 2 stops an aggregated `testFull` at the first failing module**, and the
  modules after it report nothing. Run modules one by one to compare numbers.
- **sbt 2 caches compilation**, and a cache hit does not replay warnings. To
  list a build's warnings, force a recompile with a no-op option change:
  `set ThisBuild / scalacOptions += "-Xmax-inlines:32"`.
- **Settings that are not serialisable** (`incOptions`, for one) need
  `Def.uncached(...)` under sbt 2's cache.
- **scalafmt's sbt dialect is Scala 2 syntax**: `if (...) ...` rather than
  `if ... then` in `.sbt` files, or `scalafmtSbtCheck` cannot parse them.
- **An unknown compiler flag is only a warning** (`bad option '...' was
  ignored`). After adding a flag, check the build output for it.
- **`compileErrors`-based assertions only see the type checker.** Errors
  reported afterwards (multiversal equality — `==` between an opaque type and
  its representation) and every warning are invisible to them.
- **A string snippet hides its dependencies from incremental compilation**: a
  spec whose claims live in `compileErrors("...")` is not recompiled when the
  code it names changes, unless the build forces it.
- **Coursier on Windows** writes its cache to `./null` when `%LOCALAPPDATA%` is
  not visible; the scala-sbt `.gitignore` guards against it.
- **Metals runs the server version its extension ships with.** Never set
  `metals.serverVersion` in a template, and keep
  `metals.suggestLatestUpgrade` at `"off"` — a user setting of `"install"`
  otherwise fetches a SNAPSHOT on every start.
- **sbt 2.0.10 restores cached SemanticDB as links into a read-only CAS**
  (sbt/sbt#9877, a 2.0.10 regression; measured 2026-10-14, Scala 3.9.0, Metals
  through sbt BSP). A cache hit leaves `.semanticdb` files under
  `target/out/.../{meta,test-meta}/META-INF/semanticdb/` as symlinks into
  `~/Library/Caches/sbt/v2/cas/` (mode `r--r--r--`, sealed since #9847); the
  next compile that misses the cache writes through one and fails with
  `java.nio.file.AccessDeniedException: .../X.scala.semanticdb`, and Metals then
  neither compiles nor runs tests (`Scala test classes not supported by
  server`). SemanticDB is only on under BSP, so `sbt verify` never shows it;
  reproduce with `ThisBuild / semanticdbEnabled := true`, `rm -rf target/out`,
  compile twice, then compile with a changed `scalacOptions`. The scala-sbt
  template carries `project/SemanticdbLinks.scala`, which replaces the links
  with writable copies before Zinc runs (README, *Bridges*); delete it with
  the move to sbt 2.0.11 or 2.1.0, which carry the fix (#9879; 2.1.0-RC1
  verified, and on APFS it copies instead of linking at all). Do not jump to
  2.1.0-RC1 to fix it: it rewrites the test summary to `passed: total N`
  counted per module, which breaks scripts grepping `Passed: Total`.
- **Metals logs thousands of `swoval` `CreateStreamException`s** naming files
  in `~/Library/Caches/sbt/v2/cas/`, with advice to raise
  `metals.macos-max-watch-roots`. That is Metals' own watcher following the
  ~1000 symlinks sbt 2.0.x leaves under `target/`; it does not affect sbt. The
  sbt server keeps no file watcher outside `~`, and an edit/compile loop on a
  2.0.10 server with 946 such links (also after an `AccessDeniedException` and
  a by-hand `cp -L` repair) compiled every edit correctly (measured
  2026-10-14). A server that seemed to ignore edits was not reproduced;
  "Metals: Restart build server" (or `sbt --client shutdown`) is the cure.
- **A running sbt 2 server keeps its version.** The launcher hands even
  `sbt -batch` to a background server, and that server is not replaced when
  `project/build.properties` changes: check with `sbt --client sbtVersion`, and
  `sbt --client shutdown` after a version change.
- **Under sbt 2 the launcher always runs a thin client, which joins separate
  arguments into one command line** (measured 2026-10-14, launcher 2.0.8,
  sbt 2.0.10). `sbt -batch about "show name"` failed with `Expected end of
  input`; `sbt --server -batch about "show name"` worked. A script that
  passes several commands writes them as one argument joined by `;` —
  `sbt --server -batch "scalafmtCheckAll; exercises/testOnly ..."` — which
  both modes accept (scala-type-programming#25).
- **A script's `sbt -batch` leaves an sbt server running after it ends.** The
  thin client starts the server in the background, and when the script exits
  the server is reparented to pid 1 and stays in whatever folder the script
  ran in — a scratch copy under `target/`, typically. Its idle timeout
  (`serverIdleTimeout`) defaults to 7 days. Measured 2026-10-23 in
  scala-advanced-fp: one orphan from each of `finish-chapter` and
  `solve-chapter`, and a 7-day-old one on the project root that answered no
  BSP request, so Metals looped on `Timeout waiting for 'build/initialize'
  response` until it was killed. Scripts run sbt as `sbt --server -batch ...`,
  which runs it in the foreground and starts no server; both launchers accept
  the flag (the bash script and `sbt.bat`). `-Dsbt.server.autostart=false` and
  `--no-server` keep the thin client and fail when no server is running. To
  find leftovers: `ps -axo pid,ppid,etime,command | grep sbt.script`, where a
  ppid of 1 and an age in days mark an orphan; `sbt --client shutdown` in its
  folder, or `kill`, ends it. A CI runner is thrown away after the job, so a
  workflow's `sbt -batch` needs no change.
