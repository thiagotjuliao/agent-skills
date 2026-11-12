# Writing a Motion Canvas scene for an animation segment

Read this when a `scene: animation` segment names an animation that has no
scene yet. The pilot's `kleisli-compose` is the model to copy: read its files
in the lessoncraft repository before writing a new one.

## The files of one animation

For an animation named `<name>` (the slug in `animation.name`):

| file | what it is |
| --- | --- |
| `animations/src/<name>.ts` | the Motion Canvas project: `makeProject({scenes: [scene]})`, importing `./scenes/<camelName>?scene` |
| `animations/src/<name>.meta` | project settings; copy `kleisli-compose.meta` (1920×1080, 60 fps, ffmpeg exporter) |
| `animations/src/scenes/<camelName>.tsx` | the scene itself |
| `animations/src/generated/<name>.beats.json` | written by `lesson-check` / `tts-render`; never edited by hand |

Register the project in `animations/vite.config.ts` (the `project` list next to
`./src/kleisli-compose.ts`); the editor only shows registered projects, and
only after a restart (`npm start`). Run `lesson-check` before opening the
editor, so the beats file the scene imports exists.

## Rules for the scene

- **Time it with `beatClock`** (`src/lib/beats.ts`): `const clock =
  beatClock(beatsData as Beats)`, `yield* clock.until('<step>')` before each
  step, and `yield* clock.end()` last. The step names are the keys of
  `animation.beats` in the YAML. Beats are estimated (from `wpm`) until audio
  exists and exact after `tts-render`, so the scene is written against names,
  never against fixed seconds.
- **Finish within the narration.** The assembly cuts the clip at
  `beats.duration`; `clock.end()` warns in the editor console when the scene
  runs past it. Motion started at the last beat must fit in the narration that
  follows that phrase — shorten the motion or move the beat earlier.
- **Use the palette in `src/lib/theme.ts`** (`theme.background`, `theme.text`,
  `theme.type` for types, `theme.effect` for effects/wrappers, `theme.ok`,
  `theme.error`, `theme.font`). It mirrors the editor's color scheme so the
  animation does not clash with the screencast; a new color goes into both
  `theme.ts` and `intellij-player/color-scheme/gen_icls.py`, never inline.
- **`letterSpacing={NO_LIGATURES}` on every `Txt`** (`src/lib/code.ts`). The
  canvas otherwise draws JetBrains Mono ligatures (`=>` as `⇒`), and the viewer
  must see the characters they would type. It is not inherited, so every `Txt`
  needs it; a zero-width non-joiner does not work.
- Keep the scene's comments in Portuguese, like the existing TypeScript.

## Checking it

`cd animations && npx tsc --noEmit` type-checks the scene. Rendering
(`npm start`, Render button) is the user's step unless they ask; when they do,
look at the result against the narration's beats.
