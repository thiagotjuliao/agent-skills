# Writing a chapter: the checklist

The course's `CONTRIBUTING.md` is the rule; this is the checklist to hold
against it, plus what slips through when it is followed loosely.

1. **Re-read the plan entry** for the chapter in `CURRICULUM.md`, and the
   previous chapter's document: the new one starts where that one stopped.
2. **Scaffold** with `new-chapter`. It lays out exactly what `finish-chapter`
   checks for.
3. **Document.** *Why this exists* first, written from the code that cannot be
   written without the idea. *Pitfalls* with real error messages, verbatim —
   produce them, do not remember them. An *Inside …* section for any machinery
   the reader is given but not asked to write.
4. **Spec.** Before the stub. It compiles against the stub. Claims about types
   go in compile-time snippets, never as plain code. Laws are checked on
   samples chosen to discriminate. Stack-safety claims run at a depth that
   overflows a naive version.
5. **Prove the spec discriminates**: run it against the stub, and against a
   deliberately wrong solution, and watch both fail for the right reason.
6. **Stub.** Compiles, does not work, says in prose what is wanted, one hint at
   the end that points at the mechanism. No exercise depends on another
   exercise's stub.
7. **Solution.** Its doc comment explains why this is the answer and what the
   near miss breaks. Compiles under the strict flags.
8. **Walkthrough.** The document's ideas as code that compiles.
9. **Further reading.** Primary sources, each with why it matters here. New
   ones go into the course library first (`reading-library.md`).
10. **Gate.** The practice run is red for the new exercises; the full gate is
    green; `finish-chapter` commits, tags and pushes.

## What slips through

- **A spec that tests what the solution happens to do.** It is what you get
  when the solution is written first. The order exists to prevent it.
- **A claim nobody ran.** A number, a compiler message, an overflow depth: run
  it, then write it down from the output.
- **A chapter that leans on the learner's milestone code.** Specs never depend
  on the modules the user is still writing.
- **Exercises that chain.** Exercise 3 that cannot run until exercise 1 is
  solved has turned three exercises into one.
