---
name: lesson-author
description: Author a lesson for the lessoncraft video-course pipeline (github.com/thiagotjuliao/lessoncraft) — turn a topic into a validated `.lesson.yaml` with English narration, pt-BR subtitles, code typed into IntelliJ, compile/run checkpoints, animations and slides. Use it whenever the user asks to create, write, plan, outline or script a lesson or episode ("create a lesson about X", "write the next episode", "turn this topic into a lesson", "split this topic into a series", "script the episode on Y"), to extend or rework an existing `.lesson.yaml`, or to add an animation or slide to one — even if they never say "lessoncraft" or "YAML".
---

# lesson-author

A lessoncraft lesson is one `.lesson.yaml`: narration (ElevenLabs TTS), EN and
pt-BR subtitles, the code the IntelliJ plugin types, Motion Canvas animations,
slides and the final ffmpeg assembly are all derived from it. Nothing is fixed
in video afterwards, so the YAML is the whole job — and a mistake in it costs
TTS credits and a re-recorded take.

## Find the repository and read it first

Look for the lessoncraft clone (`C:\Git\Pessoal\lessoncraft` on the Windows
machine; elsewhere, a sibling of the current project — confirm with
`git -C <dir> remote get-url origin`). Then read, every time:

- `CLAUDE.md` — commands, invariants, conventions and known pitfalls;
- `FORMAT.md` — the field-by-field specification of `.lesson.yaml`. This skill
  does not repeat it; when a field is in doubt, the answer is there;
- the existing lessons in `lessons/` — the pilot
  `lessons/m03-kleisli-composition.lesson.yaml` is the reference example. Copy
  its header (`format`, `course`, `voice`, `editor`) for a new lesson of the
  same course rather than writing one from memory, and follow its naming
  (`mNN-slug.lesson.yaml`, `lesson.id` `mNN-lNN-slug`);
- section 3 of `PRODUCTION.md` (episode format) and section 8 when the topic is
  one it already plans.

If the repository and this skill disagree, the repository wins: it changes
faster than the skill. Mention the disagreement so the skill can be fixed.

## 1. Plan the episode, and agree on it before writing

An episode is **15 to 20 minutes**. The voice speaks at `voice.wpm` (about 180
words/min) and typing competes for the same time, so budget the narration and
the code together; `lesson-check` prints the estimated length of what you wrote.

- **A topic too big for 20 minutes becomes a series**, each episode standing on
  its own with one main idea. Propose the split rather than cramming.
- **Every abstraction answers a concrete problem from the previous step.** Show
  the clumsy version first (the chain of `flatMap`s in the pilot), name what is
  wrong with it, then introduce the abstraction that fixes it. An abstraction
  that arrives unmotivated is memorised, not understood.
- **Open with a title slide, end with a recap**, and with an exercise when one
  fits — something the viewer can do with only what the episode showed.
- **Pick the scene for each step**: the IDE by default; an animation for a
  concept with spatial structure (composition, types fitting together, trees);
  a slide for the opening, part transitions, recap and exercise.

Present the outline to the user — the episode (or series) title, then one line
per segment with its scene, what it shows and roughly how long it runs — and
wait for their agreement. Restructuring an outline is cheap; restructuring
written segments with subtitles and beats is not.

## 2. Write the segments

Ids are `sNN-slug`, in order. Each segment is one narration block plus,
optionally, code or an animation or a slide.

**Narration** (`say`, in English) is spoken, not read: short sentences, one
idea each, the code described in words a listener can follow without seeing
punctuation. Every segment has `subtitles.pt-BR`, a faithful translation of the
same sentences (subtitles are timed proportionally over the narration, so a
translation that adds or drops a sentence drifts).

**Pronunciation**: a term the TTS would get wrong goes in `pronunciation` (audio
only; subtitles keep the original). Respellings are **lowercase, without
hyphens** — `"Klyslee"`, not `"KLY-slee"` (an initial capital is fine) —
because a run of capitals is read letter by letter as an acronym. Identifiers like `flatMap` get a spoken form
(`"flat map"`).

**Code** (`code` ops, see `FORMAT.md`):

- `type` with `at: end`, `at: {after: ...}` or `at: {before: ...}`; `replace`
  with `old`/`new` and `mode: retype` or `mode: edit`. **Every anchor and every
  `old` appears exactly once** in the file at that point — pick a distinctive
  fragment, not `=` or `)`.
- Every file the lesson touches is declared in `files` with its `initial`
  content, including the `//> using` directives scala-cli needs.
- Put `checkpoint: compile` after each step that leaves the code compilable,
  and `checkpoint: run` with `expect.stdout` (exact output) where the program
  runs. These are what proves, before recording, that the code on screen works.

**Pacing** — the viewer should almost never watch the screen in silence:

- Prefer **`sync: with`** (narrate while typing) over `sync: after`. Write the
  narration of a code segment so it lasts about as long as its typing; split a
  long block of code across segments, each with its own narration, rather than
  typing it in silence.
- **To narrate a program's output**, end one segment with
  `ide: [{action: run_main, target: ..., wait_ms: <short, often 0>}]` and
  describe the output in the next segment, which is spoken while scala-cli
  compiles and the console fills (as `s05-run` / `s05-output` in the pilot).
- Keep `highlight` `hold_ms` short; it is silent screen time too.

**Animations** (`scene: animation`, no `code`, no `ide`): `animation.name` is a
slug matching `animations/src/<name>.ts`, and `animation.beats` maps each scene
step to a **phrase of the narration that appears exactly once** in `say`. Choose
the phrase that names what appears, and leave enough narration after the last
beat for that step's motion to finish — the clip is cut when the narration ends.

**Slides** (`scene: slide`, no `code`, no `ide`): `slide.kind: title` with
`title` and `subtitle` for the opening and part transitions; `kind: bullets`
with `title` and `items` for recap and exercise, each item with an `at` phrase
(exactly once in `say`) where it appears. Slides are data only — never write a
scene for one.

## 3. Validate until clean

```
uv run lesson-check lessons/X.lesson.yaml --compile
```

Repeat until there are **no `ERROR` lines**, and treat every pacing `WARN` as
something to fix, not to report:

- *typing much longer than speech* — lengthen the narration, split the code
  across segments, or (last resort) raise `editor.typing.cps`;
- *more than 4 s on screen without narration* — switch to `sync: with`, narrate
  over the run, shorten `wait_ms` / `hold_ms`.

A failing checkpoint is fixed in the YAML's code, never by loosening
`expect.stdout`. Check the estimated length it prints against the 15–20 min
target. When it passes, show the user the length and any warning you
deliberately kept, with the reason.

## 4. Review the spoken text, then ask before generating audio

```
uv run tts-render lessons/X.lesson.yaml --dry-run
```

It prints the exact text the TTS will receive (pronunciation applied) and how
many characters of credit generation would spend. Read it for terms that will
be mispronounced and for sentences that only work on paper, and fix them.

Then **stop and ask the user before running `tts-render` without `--dry-run`**,
giving the character count: generating audio spends ElevenLabs credits, and
only they decide when. The rest of the pipeline (rendering animations,
recording the take, `subs-build`) is theirs too unless they ask.

## 5. New animations need a scene

A slide needs no scene code. An `animation` whose `name` has no scene yet needs
one in `animations/src/` — read `references/animations.md` before writing it.
Type-check with `cd animations && npx tsc --noEmit`.

## Conversation

Talk to the user in their language; everything written into the lesson
(narration, code, identifiers, segment and animation names) is in English, plus
the pt-BR subtitles. Comments in the YAML and in the TypeScript scenes follow
the repository's existing ones.
