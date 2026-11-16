# The reading library

Each course keeps its sources in `references/`:

| path | in git | holds |
| --- | --- | --- |
| `references/README.md` | yes | every source, by chapter and milestone: authors, title, venue, year, status, file name, link, licence |
| `references/open/` | yes | PDFs whose licence allows redistribution |
| `references/local/` | no (`.gitignore`) | personal copies of the rest |

The courses are public repositories. A PDF is committed only when its licence
says it may be shared; a free download is not the same thing. Status in the
manifest is one of **open** (committed), **local** (free to download, kept
out of git), **link** (readable online, not as one file), **paid**, or
**missing** (no free copy found, or the server did not answer — worth another
try). `scala-advanced-fp/references/README.md` is the worked example.

## Procedure

1. **List** the sources: the chapter's *Further reading*, and for a new course
   the papers the plan names. Prefer the primary source and the published
   version.
2. **Find a free copy**, in this order: the publisher, when it is open access;
   the author's page; arXiv or an institutional repository; the authors' own
   repository. Avoid aggregators and mirrors of unclear standing.
3. **Download** it (see *How downloads work*), into a temporary folder.
4. **Check each file** before it goes anywhere: it opens, its first page is the
   paper you meant, and its licence is what you will record. Read the licence
   **from the file itself** (`pdftotext`, first two pages, look for "Creative
   Commons", "CC BY", "Permission to make digital", "Copyright"), or from the
   source's licence statement. Name the file
   `firstauthor[-coauthor|-et-al]-year-short-title.pdf`, in lowercase kebab-case.
5. **Sort**: open licences (CC BY, CC BY-SA, CC BY-ND, BSD, MIT — keeping the
   notice) into `open/`; everything else into `local/`. When unsure, `local/`.
6. **Write the manifest entry** with status, file name, link and licence, then
   check that the manifest and the folders agree in both directions: every
   file named exists, and every file present is named.
7. Commit `README.md` and `open/` on a branch, in the course's commit style.
   Put `local/` on the user's machine, in their clone of the course, and tell
   them where.

## How downloads work

Each of these cost a round of trial and error once.

- **The agent's shell often cannot reach paper sites.** Sandboxed sessions
  allow package registries and little else: arXiv, publishers and GitHub
  release assets are refused. Do not retry from another command; use the
  user's browser.
- **The Claude desktop app's built-in browser works.** On a page of the same
  site (so the request is same-origin), run a script that `fetch`es the PDF,
  makes a blob URL and clicks an `<a download="name.pdf">` link: the file lands
  in the user's Downloads folder under that name. Several files of one site go
  in one script. Check `response.ok` and that the type is a PDF before
  clicking, or a 404 page gets saved as a PDF.
- **GitHub release assets** cannot be fetched by script (the redirect fails
  CORS), but navigating the browser to the asset's
  `/releases/download/...` URL downloads it, even though the navigation
  reports an error. The release list comes from
  `api.github.com/repos/<owner>/<repo>/releases`, which a script can read.
- **The ACM Digital Library** answers automated requests with a bot challenge.
  Do not try to get past it; use the author's or arXiv's copy, record the
  published version's DOI, and note that replacing the copy with the published
  version (often CC BY for PACMPL papers) would let it move to `open/`.
- **arXiv's licence is per paper**, on the abstract page. Many papers there
  carry arXiv's non-exclusive licence even when the venue publishes them under
  CC BY; the arXiv copy then stays in `local/` unless it carries the CC notice
  itself.
- **Old papers come as PostScript** (Wadler's, for one). Convert with
  `ps2pdf` (Ghostscript) and say so in the manifest.
- **Some sites list a directory as 403** but serve the files under it; fetch
  the PDF's URL directly before concluding it is gone.
- **Unlinked files on a book's site** may be a different version than the one
  advertised. Read the title page and the build date before choosing.
- Afterwards, remove the copies the browser left in Downloads, after asking
  for permission to delete there.
