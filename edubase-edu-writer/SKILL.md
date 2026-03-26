---
name: edubase-edu-writer
description: >
  Writes EduBase questions as EDU files — the single-question text format used for one-by-one upload
  to EduBase Quizzing. Use this skill whenever the user wants to create, generate, or export a question
  as an EDU file, save a question to .edu format, produce EDU file output for EduBase, or write
  questions that will be uploaded individually (not via XLSX batch). Also use when the user asks to
  convert a question description into an EDU file, or when creating a question and a file output is needed.
  Always use alongside the edubase-question-creator skill for content decisions — this skill handles
  the EDU file formatting and serialization.
---

# EduBase EDU File Writer

EDU files are single-question text files for one-by-one upload to EduBase Quizzing.
This skill handles **format and serialization** — for question content rules, types, operators,
and field semantics, use the `edubase-question-creator` skill alongside this one.

---

## EDU File Format — Rules

### Section headers
Every field is wrapped in a header/footer pair:
```
%------FIELDNAME------%
value goes here
```

### Mandatory fields (marked `!!`)
```
%------QUESTION!!------%
%------ANSWER!!------%
%------TYPE!!------%
```
If QUESTION or ANSWER is empty → entire file is skipped on upload.

### Recommended fields (marked `!`)
```
%------SUBJECT!------%
%------CATEGORY!------%
```

### Checkbox fields
Some fields present options as checkboxes. Mark exactly one with `[X]`, rest stay `[ ]`:
```
% [X] CHOICE
% [ ] MULTIPLE-CHOICE
```
For TYPE, mark **exactly one** type. For SUBSCORING, MANUAL_SCORING, PENALTY_SCORING,
QUESTION_FORMAT, TOLERANCE — mark exactly one option.

### Empty fields
Leave the content area blank (nothing between header and next header):
```
%------PARAMETERS------%
%------CONSTRAINTS------%
```
Empty sections are fine — the parser ignores them.

### Multi-value fields
Use the `&&&` triple-and operator to separate multiple values **on the same line** or across lines.
The EDU format accepts both inline and multi-line — keep it readable:
```
%------ANSWER------%
Option A &&& Option B &&& Option C
```

### No trailing whitespace issues
The parser is whitespace-tolerant but keep values clean.

---

## Complete Section Order

Always output sections in this exact order (matches the template):

```
LANGUAGE
QUESTION!!
ANSWER!!
TYPE!!
SUBJECT!
CATEGORY!
MAIN_CATEGORY
PARAMETERS
CONSTRAINTS
POINTS
SUBSCORING
SUBPOINTS
MANUAL_SCORING
PENALTY_POINTS
PENALTY_SCORING
OPTIONS
NOTE
PRIVATE_NOTE
EXPLANATION
SOLUTION
SOLUTION_IMAGE
HINT
VIDEO
DIFFICULTY
ANSWER_REQUIRE
QUESTION_FORMAT
ANSWER_FORMAT
SOURCE
TAG
DECIMALS
MAXIMUM_CHOICES
OPTIONS_FIX
ANSWER_ORDER
ANSWER_HIDE
ANSWER_LABEL
ANSWER_INDEFINITE
GROUP
EXPRESSION_CHECK
EXPRESSION_DECIMALS
EXPRESSION_RANDOM_TYPE
EXPRESSION_RANDOM_TRIES
EXPRESSION_RANDOM_RANGE
EXPRESSION_RANDOM_INSIDE
EXPRESSION_RANDOM_OUTSIDE
EXPRESSION_EXPLICIT_GOAL
EXPRESSION_EXTENDED
EXPRESSION_FUNCTIONS
EXPRESSION_VARIABLE
IMAGE
ATTACHMENT
MEDIA_VIDEO
MEDIA_AUDIO
OPTIONS_ORDER
NUMERICAL_RANGE
FREETEXT_CHARACTERS
FREETEXT_WORDS
FREETEXT_RULES
TRUEFALSE_THIRD_OPTIONS
TRUEFALSE_THIRD_OPTIONS_LABEL
DATETIME_PRECISION
DATETIME_RANGE
GROUPING
PARAMETERS_SYNC
TOLERANCE
GRAPH
SOLUTION_PENALTY
HINT_PENALTY
VIDEO_PENALTY
FILE_COUNT
FILE_TYPES
HOTSPOT_IMAGE
HOTSPOT_ZONES
TAGS
EXTERNAL_ID
```

---

## EDU-Specific Field Name Differences ⚠️

The EDU format uses slightly different names than the XLSX column names in a few cases:

| XLSX column name | EDU section name | Note |
|-----------------|-----------------|------|
| `NUMERIC` | `NUMERICAL` | TYPE checkbox says `NUMERICAL` |
| `NUMERICAL_RANGE` | `NUMERICAL_RANGE` | Same |
| `TAGS` | `TAGS` | End of file (org/user tags by ID) |
| `TAG` | `TAG` | Earlier in file (legacy label field) |
| `EXPRESSION_RANDOM_GOAL` | `EXPRESSION_EXPLICIT_GOAL` | Different name in EDU! |

Always use the EDU section names listed in the Complete Section Order above.

---

## Checkbox Sections — Full Option Lists

### TYPE (mark exactly one)
```
%------TYPE!!------%
% [ ] CHOICE
% [ ] MULTIPLE-CHOICE
% [ ] TRUE/FALSE
% [ ] NUMERICAL
% [ ] EXPRESSION
% [ ] ORDER
% [ ] GROUPING
% [ ] PAIRING
% [ ] MATRIX
% [ ] MATRIX:EXPRESSION
% [ ] SET
% [ ] SET:TEXT
% [ ] DATE/TIME
% [ ] TEXT
% [ ] FREE-TEXT
% [ ] FILE
% [ ] HOTSPOT
% [ ] READING
% [ ] GENERIC
```

### SUBSCORING (default: PROPORTIONAL)
```
%------SUBSCORING------%
% [X] PROPORTIONAL
% [ ] LINEAR_SUBSTRACTED:N
% [ ] CUSTOM
% [ ] NONE
```
Note: `LINEAR_SUBSTRACTED` (with D) — this is the spelling in the EDU format.

### MANUAL_SCORING (default: NO)
```
%------MANUAL_SCORING------%
% [X] NO
% [ ] NOT_CORRECT
% [ ] ALWAYS
```

### PENALTY_SCORING (default: DEFAULT)
```
%------PENALTY_SCORING------%
% [X] DEFAULT
% [ ] PER_ANSWER
% [ ] PER_QUESTION
```

### QUESTION_FORMAT (default in template: LATEX)
```
%------QUESTION_FORMAT------%
% [ ] NORMAL
% [X] LATEX
% [ ] LONG
```
⚠️ The template defaults to LATEX — change to NORMAL if the question has no math.

### TOLERANCE (mark one, or leave all unchecked if not applicable)
```
%------TOLERANCE------%
% [ ] ABSOLUTE:N
% [ ] RELATIVE:N
% [ ] QUOTIENT
% [ ] QUOTIENT2
% [ ] QUOTIENT:SYNCED
% [ ] QUOTIENT2:SYNCED
```

---

## Output Approach

### When writing a single EDU file:
1. Output the complete EDU content in a code block (for preview)
2. Write it to a `.edu` file and present it for download
3. Include ALL 74 sections — even empty ones — to match the template exactly

### When writing multiple questions:
- Each question = one separate `.edu` file
- Name files descriptively: `question-type-topic.edu` or `q01.edu`, `q02.edu`, etc.
- Package into a ZIP if more than 3 files

### Minimal viable EDU (just mandatory + recommended fields filled):
Fill `QUESTION!!`, `ANSWER!!`, `TYPE!!`, `SUBJECT!`, `CATEGORY!` — leave everything else blank.
Still include all section headers.

---

## Full Template

The complete blank template is in `assets/template.edu`.
Load it with `view /path/to/skill/assets/template.edu` when you need the exact blank structure.

When generating output, reproduce the full template structure, substituting values into the
appropriate sections. Do not omit any section headers, even if the content is empty.

---

## Example — CHOICE question

```
%------LANGUAGE------%
hu
%------QUESTION!!------%
Mi a főváros neve?
%------ANSWER!!------%
Budapest
%------TYPE!!------%
% [ ] CHOICE
% [X] ...
```

→ See `references/examples.md` for complete worked examples for each major question type.

---

## Workflow with edubase-question-creator

1. Use **edubase-question-creator** to decide: type, answer syntax, operators, parameters
2. Use **this skill** to serialize the result into valid EDU file format
3. When in doubt about field semantics → edubase-question-creator
4. When in doubt about EDU syntax/structure → this skill
