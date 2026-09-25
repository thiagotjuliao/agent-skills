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
