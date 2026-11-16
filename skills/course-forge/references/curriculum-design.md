# Designing a curriculum

What a plan for one of the user's courses has to settle, and the choices that
have held up. `scala-advanced-fp/CURRICULUM.md` is the fullest example.

## The shape

- **Chapters teach, milestones build.** A chapter is a theory document, a
  walkthrough that compiles, and exercises with a spec and an answer key. A
  milestone has neither stub nor answer key: it is built by the user from an
  empty module, after a design written together.
- **Parts end in milestones.** Group the chapters into parts of three to eight,
  each closing with the milestone that uses them. A milestone that needs
  material from two parts back is a sign the order is wrong.
- **One thread.** The milestones build a single system, each adding one layer,
  and each layer is the subject of the part it closes. A course whose
  milestones are unrelated exercises loses the reason to keep going.
- **The first milestone builds the tool the rest relies on**, when the course
  needs one: in `scala-advanced-fp`, M1 is the property-based law checker every
  later test uses. Put it as early as its chapters allow.

## Choices that held up

- **No libraries besides the test framework**, and that only in tests. Every
  abstraction the course uses is one it builds: that is how the user learns,
  and it keeps the milestones honest.
- **The thread depends on no engine.** The kernel of `scala-advanced-fp` runs
  on in-memory collections, so every behaviour is testable exhaustively; the
  real backend belongs to the real project. Keep the course's system small
  enough to test completely.
- **Chapter numbers are fixed** once the plan is approved. Optional chapters
  added later take numbers from a reserved range (30 and up), so the main
  trail never renumbers and tags stay meaningful.
- **Acceptance criteria are tests.** Each milestone states what "done" means
  as checks that can be run ("the law suites catch the unlawful instances of
  chapters 01 and 02, each with a shrunk counter-example"), not as features.
- **The chapter list in the plan is a starting point for each chapter, not its
  content**: four or so bullets of what the exercises will ask, enough to see
  the progression. The chapter itself is designed when it is written.
- **Design documents wait for their milestone.** The plan states scope and
  acceptance criteria; the design is written when the milestone starts.

## Revising

A plan changes when writing a chapter shows that it must. Propose the change
with its reason, update `CURRICULUM.md` in its own commit, and keep the
numbering rule: renumbering written chapters breaks their tags and every link
to them.
