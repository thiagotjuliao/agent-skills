---
name: course-forge
description: Plan, scaffold and write the user's self-study courses — repositories where chapters teach a subject through a theory document, a compiled walkthrough and exercises with specs and an answer key, and milestones build one system from scratch across the course (scala-type-programming, scala-advanced-fp). Use it whenever the user wants to study a subject in depth "as a course" or "in the type-programming style", asks to plan or outline a curriculum, start a new study project, write or finish the next chapter, open or design a milestone, add an optional chapter, revise a course's plan, or gather, download and organise a course's bibliography — even if they never say "course-forge" or "skill". Not for video lessons (lesson-author) or for guiding the user through an exercise (tutor).
---

# course-forge

The user learns a subject by building a course for it, in a repository of its
own: chapters that teach, milestones that build. The agent writes most of a
chapter; the user writes the milestones, by hand, from an empty module. This
skill is how such a course is planned, set up and grown, the same way each
time.

## The sources of truth

This skill describes the workflow. The rules it relies on live elsewhere, and
are read there, every time, so that the two cannot disagree:

- **project-templates** (github.com/thiagotjuliao/project-templates, private):
  its `README.md` says how the course layer is applied on top of a stack, and
  the course layer itself holds the chapter templates, the scripts and the
  starter `CONTRIBUTING.md`, `CLAUDE.md` and `CURRICULUM.md`. Find and update
  the clone as the `project-tooling` skill says.
- **The course's own `CLAUDE.md`, `CONTRIBUTING.md` and `CURRICULUM.md`**, once
  the course exists. `CLAUDE.md` says who writes what; `CONTRIBUTING.md` says
  how a chapter and a milestone are written; `CURRICULUM.md` is the plan. A
  course may have diverged from the template for a reason: what the course
  says wins.
- **The finished courses** are worked examples, not templates:
  `scala-type-programming` (the first, which settled the layout) and
  `scala-advanced-fp` (the first with milestones and a reference library).
  Look at one when a question is about how something turned out in practice.

## Decide which job this is

| the user wants | job | read |
| --- | --- | --- |
| to study something new as a course | **Plan**, then **Scaffold** | `references/curriculum-design.md` |
| the next chapter written, or one finished | **Write a chapter** | the course's `CONTRIBUTING.md`, `references/chapter-workflow.md` |
| to start, design or review a milestone | **Run a milestone** | the course's `CONTRIBUTING.md`, *Working on a milestone* |
| papers, books, the bibliography, PDFs | **Build the library** | `references/reading-library.md` |
| to reorder, add or drop chapters | **Revise the plan** | `references/curriculum-design.md` |

Then read the file for the course's stack (`references/scala.md`). A course in
a language with no file yet works from the language-neutral parts of this
skill, and the pitfalls it meets become that language's file after it is
done, the same way a stack enters project-templates only from a real project.

## Plan

The plan is a conversation, and its deliverable is `CURRICULUM.md`. No
repository and no code until the user has approved it: a plan is cheap to
change, and a scaffolded course is not.

1. Ask what the user wants to be able to do at the end, and what they already
   know. The user builds things from scratch to learn them, so the answer is
   usually a system, not a list of topics.
2. Propose the **thread**: one system the course builds across its milestones,
   small enough to finish and real enough to matter. In `scala-advanced-fp` it
   is the kernel of a pipeline framework the user plans to build for real.
3. Propose parts, chapters and milestones, following
   `references/curriculum-design.md`, with the acceptance criteria of each
   milestone stated as tests.
4. Revise until the user approves. Then write `CURRICULUM.md` from the
   template's starter.

## Scaffold

1. Create the project with the `project-tooling` skill (*Create*), adding
   `--course` and the root package (`--package`) as project-templates' README,
   section *Courses*, says. Ask the author and whether you may merge, as that
   skill asks.
2. Make the starters the course's own: what the course is in `CLAUDE.md`, the
   milestone modules in the build, the root package in the templates.
3. Add the course's reference library (*Build the library*) with the papers the
   plan already names, so the first chapter starts with its reading in place.
4. The gate passes before the first commit, with no chapter yet.

## Write a chapter

Read the course's `CONTRIBUTING.md` first, every time, and follow its order:
document, spec, stub, solution, walkthrough. The order is the point: each step
done out of order produces a chapter that looks finished and teaches nothing.
`references/chapter-workflow.md` is the checklist, with the mistakes that slip
through a review.

Scaffold with the course's `new-chapter` script, never by hand, and close with
`finish-chapter`: it re-runs the gate on the staged tree and refuses a chapter
with a missing piece or a leftover `TODO`.

The chapter's *Further reading* names its sources and says why each matters
here; before writing it, add each new source to the library, so the reader
finds the file as well as the name.

## Run a milestone

A milestone is the user's. The agent writes its design document **together**
with the user, records decisions as ADRs, writes tests and Scaladoc, reviews,
explains and points at bugs — and writes no implementation code, not a stub,
not a one-line fix, whatever the request seems to need. Building it by hand is
the reason the milestone exists. If a task cannot be done without
implementation code, stop and say so.

The design document is written when the milestone starts, not when the course
is planned: the chapters before it shape it. A test the agent writes is proven
by reintroducing the bug it targets and watching it go red.

## Build the library

Every source a chapter cites is listed in `references/README.md` of the
course, by chapter, with its link and licence, and downloaded when it is free.
Files that may be redistributed are committed; the rest are personal copies
kept out of git, because the courses are public repositories.
`references/reading-library.md` has the procedure and the ways downloading
goes wrong.

## Never

- Write implementation code in a milestone module (see *Run a milestone*).
- Commit a PDF whose licence does not allow redistribution.
- Solve an exercise for the user while they are working on it: that is the
  `tutor` skill's job, and its rule is to ask, not answer.
- Change a course's plan silently. A chapter that turns out to need a
  different scope is a change to `CURRICULUM.md`, proposed to the user first.
