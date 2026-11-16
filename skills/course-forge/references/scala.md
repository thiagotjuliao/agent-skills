# Scala courses

What is specific to a course on Scala 3 and sbt. The course layer in
project-templates holds the files; this is what to know when using them.

## Layout

| module | holds | written by |
| --- | --- | --- |
| `core` | what every chapter shares, including the test base (`CourseSuite`, with `forAllSamples`) | the agent |
| `exercises` | stubs, specs and walkthroughs | the agent |
| `solutions` | the answer key, with the same specs | the agent |
| milestone modules (`laws`, `kernel`, …) | the system the course builds | the user; the agent writes tests and Scaladoc only |
| `playground` | worksheets and a console | anyone |

## The gate

- `sbt verify` is green: formatting, every module but `exercises` with
  `testFull`, and `exercises/Test/compile`. `sbt practice` runs the exercises,
  red by design until they are solved.
- **`testFull`, never `test`**: under sbt 2, `test` is incremental, and its
  greenest possible run is the one that ran nothing.
- The answer key and the milestone modules compile with
  `CompilerFlags.strict`; the exercises with `base`, because a stub ignores its
  parameters on purpose.

## Specs

- A body of `unsolved` makes a value-level assertion fail at run time. A claim
  about **types** — an instance exists, a program is rejected — would not
  compile against the stub, so it goes inside `CourseSuite`'s
  `assertTypeChecks` / `assertTypeError`, which are built on munit's
  `compileErrors`.
- Those snippets are strings: the imports they need look unused to the
  compiler, which is why the test sources drop `unusedImports`.
- Type-level recursion can exhaust the compiler's inline budget of 32; a course
  that needs more sets `CompilerFlags.maxInlines(n)` and records why, as
  `scala-type-programming` does.
- A stack-safety claim runs a million nested binds, not a hundred.

## Scripts

`new-chapter`, `finish-chapter` and `solve-chapter`, each as a `.sh` and a
`.ps1` pair. The usage line at the top of each script is authoritative.
`solve-chapter` is the learner's side: it commits solved exercises to a branch
of their own, never to `main`.
