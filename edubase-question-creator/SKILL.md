---
name: edubase-question-creator
description: >
  Expert EduBase question creator for the EduBase Quizzing platform. Use this skill whenever the user wants
  to create, design, prepare, or upload questions to EduBase — including via XLSX spreadsheet, EDU files,
  ZIP archives, or the MCP API. Triggers on: creating quiz questions, building exam content, preparing
  EduBase uploads, writing XLSX rows for EduBase, designing CHOICE/GROUPING/HOTSPOT/NUMERIC/PAIRING/TRUE-FALSE
  questions, setting up parameters or constraints, or any mention of EduBase question types or fields (ANSWER,
  OPTIONS, HOTSPOT_ZONES, PARAMETERS, etc.). Also use when the user asks for help formatting answers,
  structuring categories, or checking question correctness for EduBase.
---

# EduBase Question Creator

You are an expert at creating questions for the EduBase Quizzing platform. You know every question type,
every column/field, all syntax rules, and all common pitfalls by heart.

## Core Upload Formats

Questions can be uploaded:
- **One by one** via EduBase UI or EDU files
- **In batch** via Excel XLSX spreadsheet (first worksheet only!) or ZIP archive (EDU + XLSX + images)
- **Via MCP API** using `edubase_post_question`

For XLSX: one row = one question. After 3 blank rows, upload stops. No Excel formulas. Column names are case-insensitive.

---

## Question Types Reference

| Type | Symbol | Key behavior |
|------|--------|-------------|
| GENERIC | ○ | Full match required; spaces & punctuation must match |
| TEXT | A | Fill-in-the-blank; spaces/punctuation ignored |
| FREE-TEXT | ¶ | Long text; semi-automatic scoring (moderator may be needed) |
| READING | □ | Non-assessed text display; no answer needed |
| CHOICE | ⊙ | Single correct answer from options; randomized order |
| MULTIPLE-CHOICE | ☑ | Multiple correct answers |
| ORDER | | Correct ordering of options |
| GROUPING | | Assign items to groups |
| PAIRING | | Pair items together |
| TRUE/FALSE | | True/false statements; can add 3rd option |
| NUMERIC | # | Numerical values; supports intervals, fractions, pi/e |
| DATE/TIME | 📅 | Calendar dates; many formats; BC/AD support |
| EXPRESSION | ƒ | Formula evaluation |
| MATRIX | [ ] | Matrix/vector evaluation |
| MATRIX:EXPRESSION | | Matrix of expressions |
| SET | {} | Unordered numeric elements |
| SET:TEXT | | Unordered text elements |
| HOTSPOT | 📍 | Mark zones on an image |
| FILE | 📎 | Upload file evaluation (semi-automatic) |

**Important:** Leaving TYPE blank inherits the previous question's type.

---

## Mandatory Columns

| Column | Notes |
|--------|-------|
| `QUESTION` | The question text. Supports LaTeX (`$$...$$` inline, `$$$$...$$$$` block when QUESTION_FORMAT=LATEX), EduTags, images `[[IMAGE:filename]]`, parameters `{p}` |
| `ANSWER` | The correct answer(s). Multiple answers separated by `&&&`. Can use `label >>> answer` for labeled answers. Some types allow blank. |
| `TYPE` | Question type (see table above). Inherits if blank. |
| `SUBJECT` | Broad topic. Check UI for valid values. Inherits if blank → "Other" |
| `CATEGORY` | Question category. Can have parent via `MAIN_CATEGORY`. Inherits if blank. |

**Unique identifier** = QUESTION + ANSWER + TYPE + SUBJECT + CATEGORY + MAIN_CATEGORY + IMAGE + MEDIA fields.
Duplicate = skipped (enables safe re-uploading of same file).

---

## Operators — Use Correctly!

| Operator | Syntax | Use for |
|----------|--------|---------|
| Triple-and | `&&&` | Separate multiple answers/options/parameters/labels |
| Triple-or | `\|\|\|` | Alternative values (e.g. EXPRESSION intervals) |
| Triple-per | `///` | Category hierarchy levels (up to 2 levels) |
| Triple-arrow | `>>>` | `label >>> answer` pairing in ANSWER or ANSWER_LABEL |
| Triple-wave | `~~~expression~~~` | Quick inline parameter expressions |

⚠️ Do NOT insert stray triple operators — they break parsing.

---

## Key Type-Specific Rules

### GROUPING
- `ANSWER` field: **group names** (repeated for each item in that group!)
- `ANSWER_LABEL`: the items to be grouped
- Alternative: `item >>> group` in ANSWER field
- Both elements and groups appear in random order

### PAIRING
- `ANSWER`: the pair targets
- `ANSWER_LABEL`: the items to pair
- Alternative: `item >>> pair` in ANSWER field
- Pairs appear in random order

### HOTSPOT
- `HOTSPOT_IMAGE`: image filename (from ZIP)
- `HOTSPOT_ZONES`: zone definitions separated by `&&&`
  - Circle: `{circle; X%; Y%; R%}` — center coords and radius as % of image width
  - Rectangle: `{rectangle; X1%; Y1%; X2%; Y2%}` — top-left and bottom-right corners
  - `(0,0)` = upper-left, `(100,100)` = lower-right
- `ANSWER`: only the **names** of zones (matching HOTSPOT_ZONES)

### CHOICE / MULTIPLE-CHOICE
- `OPTIONS`: wrong options separated by `&&&`
- `OPTIONS_FIX`: `all` / `abc` / `first:N` / `last:N` / `answers`
- `MAXIMUM_CHOICES`: limit selections (MULTIPLE-CHOICE only)
- Options can be dynamically sourced from same group/category if not specified

### NUMERIC
- Supports: integers, floats, fractions (`a/b`), constants (`pi`, `e`)
- Intervals: `{from}-{to}`
- Open/closed: `[a;b]`, `]a;b[`, `(a;b)`, etc.
- Default precision: 2 decimal places (override with `DECIMALS`)
- Range question: set `NUMERICAL_RANGE=+`

### TRUE/FALSE
- `ANSWER`: true statements
- `OPTIONS`: false statements
- `TRUEFALSE_THIRD_OPTIONS`: add third option (+ or custom text)
- `TRUEFALSE_THIRD_OPTIONS_LABEL`: label for third option

### DATE/TIME
- Precision: `YEAR`, `MONTH`, `DAY`
- Range: `DATETIME_RANGE=+`
- Formats accepted: text months (`mar`, `March`), slashes, dots, numbers only
- Recommended: `YYYY`, `MM/YYYY`, `MM/DD/YYYY`
- BC/AD supported

### FREE-TEXT
- `ANSWER_FORMAT`: `normal` or `code:language` (e.g. `code:python`)
- `FREETEXT_CHARACTERS`: `min-max` (e.g. `-3000`, `100-`, `200-800`)
- `FREETEXT_WORDS`: same format
- `FREETEXT_RULES`: `{type; keyword1, keyword2}` — type 1-4 for include/exclude logic

### EXPRESSION
- Variables default to `x`; customize with `EXPRESSION_VARIABLE`
- Check method: `EXPRESSION_CHECK` = `RANDOM` (default) / `EXPLICIT` / `COMPARE`
- `EXPRESSION_RANDOM_RANGE`: `[min-max]` per variable, separated by `&&&`
- `EXPRESSION_EXTENDED=+` for logN, factorial support
- Use as few built-in functions as possible (they slow evaluation)

---

## Important Optional Columns

| Column | Notes |
|--------|-------|
| `LANGUAGE` | Language of the question |
| `MAIN_CATEGORY` | Parent category; use `///` for 2 levels: `TopLevel /// SubLevel` |
| `IMAGE` | Filename from ZIP (case-sensitive); <512px disables zoom |
| `ATTACHMENT` | Downloadable file from ZIP (not available to all users) |
| `MEDIA_VIDEO` | VideoBase video code |
| `MEDIA_AUDIO` | Audio filename from ZIP |
| `GROUPING` | 0 = none; 1-255 = group number for question bonding |
| `DIFFICULTY` | 0 (unclassified) to 5 (hardest) |
| `POINTS` | Max score; missing answers reduce proportionally |
| `ANSWER_ORDER` | `+` if order matters |
| `ANSWER_LABEL` | Input field labels; auto-enables ANSWER_ORDER |
| `ANSWER_REQUIRE` | How many answers needed for full score |
| `ANSWER_HIDE` | `+` to hide correct answers on results page |
| `NOTE` | Instruction shown below question |
| `EXPLANATION` | Shown on results page with answer |
| `HINT` | Guiding hints (not solutions); multiple via `&&&` |
| `SOLUTION` | Step-by-step solution; multiple via `&&&` |
| `SOLUTION_IMAGE` | Image shown with solution |
| `SUBSCORING` | `PROPORTIONAL` / `LINEAR_SUBTRACTED:N` / `CUSTOM` / `NONE` |
| `PENALTY_SCORING` | `DEFAULT` / `PER_ANSWER` / `PER_QUESTION` |
| `PENALTY_POINTS` | Points deducted for wrong answer |
| `HINT_PENALTY` | `NONE` / `ONCE:20%` / `PER-HELP:10%` |
| `SOLUTION_PENALTY` | Same as HINT_PENALTY |
| `EXTERNAL_ID` | For updating existing questions on re-upload |
| `TAGS` | Tag IDs/codes; multiple via `&&&` |
| `GROUP` | Question group name in Quiz set |

---

## Parameterization

Parameters make questions dynamic — each student can get different numbers/values.

**Syntax in QUESTION/ANSWER:** `{param_name}`

**PARAMETERS column** — define params separated by `&&&`:

| Type | Syntax | Example |
|------|--------|---------|
| FIX | `{name; FIX; value}` | `{pi; FIX; 3.1415}` |
| INTEGER | `{name; INTEGER}` or `{name; INTEGER; min; max}` | `{x; INTEGER; 1; 10}` |
| FLOAT | `{name; FLOAT; precision}` or `{name; FLOAT; precision; min; max}` | `{p; FLOAT; 2; 0; 1}` |
| FORMULA | `{name; FORMULA; formula}` | `{disc; FORMULA; {b}^2-4*{a}*{c}}` |
| LIST | `{name; LIST; v1; v2; v3; ...}` | `{color; LIST; red; green; blue}` |
| PERMUTATION | `{name; PERMUTATION; A; B; C}` | Access as `{name_1}`, `{name_2}`, etc. |

**Quick expressions** in question text: `~~~{x}+1~~~` (converted to FORMULA on upload)

**CONSTRAINTS** — conditions params must satisfy, separated by `&&&`:
- Example: `{b}^2-4*{a}*{c}>0 &&& {x}<10`

**Rules:**
- Parameter names: start with English letter; can contain numbers and underscores
- Parameters with dependencies must be listed AFTER their dependencies
- Use `-` as placeholder when skipping optional fields

---

## EduTags for Question Formatting

```
[[B]]bold[[/B]]   [[I]]italic[[/I]]   [[U]]underline[[/U]]
[[SUB]]subscript[[/SUB]]   [[SUP]]superscript[[/SUP]]
[[CODE]]inline code[[/CODE]]   [[CODEBLOCK]]block code[[/CODEBLOCK]]
[[BACKGROUND:yellow]]text[[/BACKGROUND]]   [[COLOR:red]]text[[/COLOR]]
[[LINES]]numbered lines[[/LINES]]
[[IMAGE:filename.png]]  — embed image in question text
[[___]]  — answer placeholder
[[1; 2 | 3; 4]]  — inline table (matrix notation with double brackets)
```

LaTeX: `$$inline$$` and `$$$$block$$$$` (only when QUESTION_FORMAT=LATEX)
⚠️ No `\\` before LaTeX blocks; no `\\` followed by inline `$$`

---

## Common Pitfalls to Avoid

1. **GROUPING confusion**: ANSWER = group names (repeated!), ANSWER_LABEL = items. NOT the other way around.
2. **HOTSPOT percentages**: All zone coordinates MUST be percentages. `(0,0)` = top-left, `(100,100)` = bottom-right.
3. **Stray operators**: Extra `&&&`, `|||`, `///` in wrong places break the upload silently.
4. **Excel formulas**: Never use them — paste values only.
5. **Case sensitivity**: Column names are case-insensitive, but IMAGE/ATTACHMENT filenames ARE case-sensitive.
6. **Blank rows**: 3 consecutive blank rows = upload stops.
7. **Parameters order**: Dependent parameters must come AFTER their dependencies in PARAMETERS.
8. **EXPRESSION functions**: Use as few as possible — they slow evaluation significantly.
9. **Image size**: Images <512px in any dimension disable zoom. Recommended: ~800px JPEG for hotspot images.
10. **HOTSPOT_ZONES format**: Use `{circle; X%; Y%; R%}` with percent signs (or just numbers that represent percentages).

---

## MCP API Field Mapping

When using `edubase_post_question`, the fields map directly to the columns above.
Key fields: `content` (normally `question`), `answer`, `type`, `subject`, `category`, `main_category`, `language`,
`hotspot_image`, `hotspot_zones`, `options`, `parameters`, `constraints`, `difficulty`, `points`,
`explanation`, `hint`, `solution`, `note`, `tags`, `id` (normally `external_id`), `grouping`.

For detailed field-by-field reference, see `references/fields-reference.md`.

---

## Output Format

When creating questions, always output:

1. **A clear structured table or list** of all fields needed for each question
2. **Flag any issues** — missing required fields, syntax errors, type mismatches
3. **For XLSX upload**: provide the exact column names and values per row
4. **For MCP API**: provide the exact parameter names and values
5. **Validate**: confirm that ANSWER, TYPE, and any type-specific fields are consistent

When the user provides raw content to turn into questions, proactively:
- Choose the best question TYPE for the content
- Suggest appropriate DIFFICULTY, CATEGORY, and SUBJECT
- Warn about any content that doesn't fit EduBase's constraints
