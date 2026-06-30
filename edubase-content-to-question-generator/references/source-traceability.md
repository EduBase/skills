# Source Traceability — SOURCE Field Conventions

Populate the EduBase `SOURCE` field on **every** generated question so auditors and content owners
can trace it back to the exact origin. Be as specific as the available material allows.

---

## Recommended Format

Use a **pipe-separated** structure (most specific → least specific):

```
{filename} | {version if known} | {location} | {topic/heading}
```

**Examples:**

```
GDPR_Training_2024.pptx | v2.3 | Slide 12 | Lawful bases for processing
Code_of_Conduct.pdf | Effective 2024-06-01 | p.7 | Conflict of interest
HR_Policy.docx | (no version) | Section 4.2 / ¶3 | Reporting harassment
pasted-text | — | Outline §2.1 | Data retention periods
```

### Field components

| Component | Source | Notes |
|-----------|--------|-------|
| **Filename** | Upload name | Always include when a file was provided |
| **Version** | File metadata, slide footer, title slide, document properties | Use `docprops`, PDF metadata, or visible "v1.2" on slides when available; if unknown, write `(no version)` or omit segment — do not guess |
| **Location** | Slide number, page number, section ID | PPT: `Slide N` (and title if present). PDF: `p.N`. DOCX: heading path or section number |
| **Topic** | Slide title, section heading, or bullet group label | Short; matches the content outline |

### PPT-specific

- Prefer **slide index + title**: `Slide 8 | Incident reporting timeline`
- If question draws from **speaker notes** not visible on slide: `Slide 8 (notes) | …`
- If question synthesizes **multiple slides**: `Slides 5–6 | …` — list all used slides
- If built from **animation build** (only visible in native PPT): note `Slide 4 (build step 3)` when discernible

### Multi-file batches

When several files form one training package:

```
{primary-file} | {version} | {location} | {topic} ; ref: {secondary-file} Slide 2
```

---

## What to Avoid

- Vague values: `training deck`, `compliance`, `module 1` without slide/page
- Invented version numbers not present in file or user input
- External URLs unless they appeared in the source material

---

## Alignment with Phase 2 Plan

The **Source Section** column in the question plan should use the same location convention as
the final `SOURCE` field so the user can review traceability before generation.

---

## Compliance Mode

In compliance mode, **SOURCE is mandatory** and must include at minimum: filename (or
`pasted-text`), location (slide/page/section), and topic. Add version whenever extractable.
