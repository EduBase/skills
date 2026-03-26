# EduBase Fields — Complete Reference

This file is a deep reference. Load it when you need precise syntax for a specific column or
field that isn't fully covered in SKILL.md.

## Table of Contents
1. [QUESTION formatting](#question-formatting)
2. [ANSWER variants by type](#answer-variants-by-type)
3. [OPTIONS and ordering](#options-and-ordering)
4. [HOTSPOT zones](#hotspot-zones)
5. [NUMERIC and intervals](#numeric-and-intervals)
6. [DATE/TIME formats](#datetime-formats)
7. [EXPRESSION evaluation modes](#expression-evaluation-modes)
8. [MATRIX and SET](#matrix-and-set)
9. [Parameterization deep-dive](#parameterization-deep-dive)
10. [Scoring columns](#scoring-columns)
11. [TOLERANCE methods](#tolerance-methods)
12. [GRAPH column](#graph-column)

---

## QUESTION Formatting

### Formats (QUESTION_FORMAT column)
- `NORMAL` (default): plain text
- `LONG`: smaller text with paragraph support
- `LATEX`: KaTeX math rendering (`$$inline$$`, `$$$$block$$$$`)

### EduTags
```
[[B]]bold[[/B]]
[[I]]italic[[/I]]
[[U]]underline[[/U]]
[[SUB]]subscript[[/SUB]]
[[SUP]]superscript[[/SUP]]
[[CODE]]inline code[[/CODE]]
[[CODEBLOCK]]block of code[[/CODEBLOCK]]
[[BACKGROUND:colorname]]highlighted text[[/BACKGROUND]]
[[COLOR:colorname]]colored text[[/COLOR]]
[[LINES]]numbered line block[[/LINES]]
[[IMAGE:filename.ext]]  — image embedded in question (file must be in ZIP)
[[___]]  — answer placeholder field
[[1; 2 | 3; 4]]  — 2x2 table (semicolon=column sep, pipe=row sep)
```

### LaTeX Rules
- `$$...$$` for inline math (use within LATEX format)
- `$$$$...$$$$` for block math (starts on new line, not centered)
- ⚠️ Do NOT put `\\` before a block `$$$$`
- ⚠️ Do NOT put `\\` immediately before an inline `$$`

### Parameters in QUESTION
- Referenced as `{param_name}` where param_name is defined in PARAMETERS column
- Quick expressions: `~~~{x}*2~~~` → auto-converted to FORMULA parameter

---

## ANSWER Variants by Type

### GENERIC
- Exact match including spaces and punctuation (`.`, `,`, `;`)
- Multiple accepted answers: `answer1 &&& answer2`

### TEXT
- Match ignoring spaces and punctuation
- Multiple accepted: `answer1 &&& answer2`
- e.g. `"apple."` matches `"apple"`

### CHOICE / MULTIPLE-CHOICE
- ANSWER = correct option(s)
- OPTIONS = incorrect options, separated by `&&&`
- The label-answer pattern: `label >>> answer` (label shown, answer evaluated)
- If no OPTIONS specified, system dynamically pulls from same group/category

### ORDER
- ANSWER = the items in correct order, separated by `&&&`
- Displayed randomly to test taker
- `ANSWER_ORDER=+` is implied

### GROUPING
```
ANSWER:       GroupA &&& GroupA &&& GroupB &&& GroupB
ANSWER_LABEL: Item1 &&& Item2 &&& Item3 &&& Item4
```
OR (using triple-arrow in ANSWER):
```
ANSWER: Item1 >>> GroupA &&& Item2 >>> GroupA &&& Item3 >>> GroupB
```
- Each item in the same group has the SAME group name in ANSWER
- Groups and items both appear in random order

### PAIRING
```
ANSWER:       Target1 &&& Target2 &&& Target3
ANSWER_LABEL: Item1 &&& Item2 &&& Item3
```
OR:
```
ANSWER: Item1 >>> Target1 &&& Item2 >>> Target2
```
- Pairs appear in random order

### TRUE/FALSE
- ANSWER = true statements (separated by `&&&`)
- OPTIONS = false statements (separated by `&&&`)
- All statements shown in random order
- Third option: TRUEFALSE_THIRD_OPTIONS=+ or list custom texts with `&&&`

### NUMERIC
- Single value: `42` or `3.14` or `22/7`
- Constants: `pi`, `e`
- Interval: `{2.5}-{7.5}` or with notation: `[2.5;7.5]`, `]2.5;7.5[`, `(2.5;7.5)`, `[2.5;7.5[`
- Multiple answers: `3 &&& -3` (both ±3 accepted)
- Use `DECIMALS` column for precision (default: 2)

### DATE/TIME
- Single date or range (`{date1}-{date2}`)
- Accepted formats: `12/26/2015`, `12.26.2015`, `12262015`, `26 December 2015`, `dec 2015`
- BC dates supported (negative dates)
- Partial dates: `2000-15` (year precision: year 2000 to 2015)
- Recommended: `YYYY`, `MM/YYYY`, `MM/DD/YYYY`

### HOTSPOT
- ANSWER = names of valid zones (defined in HOTSPOT_ZONES), separated by `&&&`
- These are just labels — the actual geometry is in HOTSPOT_ZONES

### EXPRESSION
- The mathematical expression (function of variables)
- Variables defined in EXPRESSION_VARIABLE (default: `x`)
- Example: `x^2 + 2*x + 1`

### MATRIX / MATRIX:EXPRESSION
- Format: `[col1; col2 | col3; col4]`
- `;` separates columns, `|` separates rows
- `[1; 2 | 3; 4]` = 2×2 matrix
- `[1; 2; 3]` = 1×3 row vector
- `[1 | 2]` = 2×1 column vector

### SET / SET:TEXT
- Unordered list: `1 &&& 2 &&& 3`
- SET: numeric values
- SET:TEXT: text values
- Repetitions and order don't matter

---

## OPTIONS and Ordering

### OPTIONS column
Only for CHOICE and MULTIPLE-CHOICE. Wrong options separated by `&&&`.
```
OPTIONS: Wrong answer A &&& Wrong answer B &&& Wrong answer C
```

### OPTIONS_FIX
Controls order of answer+option display:
- `all`: answers first, then options
- `abc`: alphabetical order
- `first:N`: fix first N items in first position
- `last:N`: fix last N items in last position
- `answers`: answers always appear last

### OPTIONS_ORDER
Full custom ordering:
```
OPTIONS_ORDER: OPTION:1 &&& ANSWER:0 &&& OPTION:0 &&& ANSWER:1
```
All answers and options must be specified exactly once.

### ERRORS
Tag wrong options with error labels (CHOICE only):
```
ERRORS: label1 &&& - &&& label2|label3
```
(use `-` for options without a label; `|` separates multiple tags per option)

---

## HOTSPOT Zones

All values are **percentages** of image dimensions.
- Origin `(0, 0)` = upper-left corner
- `(100, 100)` = lower-right corner
- Zones separated by `&&&`

### Circle
```
{circle; X; Y; R}
```
- X: horizontal center (% of width)
- Y: vertical center (% of height)
- R: radius (% of width)
- Example: `{circle; 50; 50; 10}` — centered circle, 10% radius

### Rectangle
```
{rectangle; X1; Y1; X2; Y2}
```
- X1, Y1: upper-left corner
- X2, Y2: lower-right corner
- Example: `{rectangle; 25; 25; 75; 75}` — centered square covering 50% of image

### Multiple zones example
```
HOTSPOT_ZONES: {circle; 30; 40; 8} &&& {rectangle; 60; 20; 80; 50}
ANSWER:        Zone1 &&& Zone2
```

---

## NUMERIC and Intervals

### NUMERICAL_RANGE
Set `NUMERICAL_RANGE=+` to accept a range answer:
- ANSWER becomes `{min}-{max}`, e.g. `{2}-{8}`

### DECIMALS
- Default: 2 decimal places
- Applies to NUMERIC, EXPRESSION, MATRIX, MATRIX:EXPRESSION, SET
- Use `.` as decimal separator (commas also handled)

### TOLERANCE Methods
See [Tolerance section](#tolerance-methods).

---

## DATE/TIME Formats

### DATETIME_PRECISION values
- `YEAR`: only year must match
- `MONTH`: year and month must match
- `DAY` (default): full date

### DATETIME_RANGE
- `DATETIME_RANGE=+` → ANSWER is a range: `01/2020-12/2020`

### Partial dates
- Year range: `2000-2015` with YEAR precision
- Day range: `12/24/2015-26` (24th to 26th of December 2015)

---

## EXPRESSION Evaluation Modes

### EXPRESSION_CHECK values
- `RANDOM` (default): test at randomly generated variable values
- `EXPLICIT`: test at predefined x→f(x) pairs
- `COMPARE`: evaluate both sides, no variables

### RANDOM mode settings
```
EXPRESSION_RANDOM_TYPE:    INTEGER &&& FLOAT       (per variable)
EXPRESSION_RANDOM_TRIES:   5                        (default)
EXPRESSION_RANDOM_RANGE:   [1-10] &&& [2-5]        (per variable)
EXPRESSION_RANDOM_INSIDE:  [4-8] ||| [12-16]       (OR between intervals)
EXPRESSION_RANDOM_OUTSIDE: [0-1] ||| [9-10]        (AND between intervals)
```

### EXPLICIT mode
```
EXPRESSION_RANDOM_GOAL: [0;1] &&& [3;8.89] &&& [9;16]
```
Format: `[x;f(x)]` or `[x;y;z;f(xyz)]` for multiple variables.

### EXPRESSION_VARIABLE
```
EXPRESSION_VARIABLE: x          (default)
EXPRESSION_VARIABLE: omega &&& t  (multiple variables)
```

### Built-in functions (use sparingly — slow!)
Single-arg: `sqrt, abs, ln, log, log10, round, floor, ceil, sin, cos, tan, csc, sec,
degree2radian, radian2degree, number2binary, binary2number, number2octal, octal2number,
number2hexadecimal, hexadecimal2number, number2roman, roman2number, factorial, permutations,
sinh, arcsin, asin, arcsinh, asinh, cosh, arccos, acos, arccosh, acosh, tanh, arctan, atan, arctanh, atanh`

Two-arg (semicolon separator): `min(a;b), max(a;b), mod(n;i), fmod(n;i), div(a;b), intdiv(a;b),
gcd(a;b), lcm(a;b), number2base(n;b), base2number(n;b), combinations(n;k),
combinations_repetition(n;k), variations(n;k), variations_repetition(n;k)`

Extended (EXPRESSION_EXTENDED=+): `logN(x)` e.g. `log2(4)`, factorials `5!`

---

## MATRIX and SET

### MATRIX
Input format: `[col1; col2 | row2col1; row2col2]`
- `[1; 2 | 3; 4]` = 2×2 matrix
- `[1; 2; 3]` = row vector (1×3)
- `[1 | 2]` = column vector (2×1)

### MATRIX:EXPRESSION
- Same matrix input format
- Each cell is an expression (like EXPRESSION type)

### SET
- Unordered set of numbers: `1 &&& 2 &&& 3`
- Repetitions and order ignored

### SET:TEXT
- Unordered set of text values: `apple &&& banana &&& cherry`

---

## Parameterization Deep-Dive

### Parameter types

#### FIX
```
{p; FIX; 3.1415}
```

#### INTEGER
```
{x; INTEGER}                          — any integer
{x; INTEGER; 1; 10}                   — range 1–10
{x; INTEGER; -; -; [10-20]; [12-14] ||| [16-18]}   — full notation
```
- `inside`: intervals where numbers WILL be generated (OR between `|||`)
- `outside`: intervals where numbers will NOT be generated

#### FLOAT
```
{p; FLOAT; 2}                         — 2 decimal places
{p; FLOAT; 2; 0; 10}                  — range 0–10, 2 decimals
{p; FLOAT; 1; 0; 10; -; [0-1]}        — exclude 0–1
```

#### FORMULA
```
{disc; FORMULA; {b}^2-4*{a}*{c}}
{result; FORMULA; 2*{q}+1; 0}        — with precision
```
- Depends on other params → must appear AFTER them in PARAMETERS

#### LIST
```
{color; LIST; red; green; blue; yellow}   — up to 64 elements
```
- Selected randomly; use `PARAMETERS_SYNC=+` to sync LIST params

#### PERMUTATION
```
{items; PERMUTATION; A; B; C; D}
```
- Access via `{items_1}`, `{items_2}`, `{items_3}`, `{items_4}`

#### FORMAT
```
{pp; FORMAT; p; NUMBER}              — format p as number
{pp; FORMAT; p; NUMBER; 0}           — round to 0 decimal places
```
- Types: `NUMBER`, `NUMBERTEXT`, `ROMAN`

### PARAMETERS_SYNC
- `PARAMETERS_SYNC=+` makes LIST parameters select their values in sync
  (all synced LISTs pick the same index)

### CONSTRAINTS column
```
CONSTRAINTS: {b}^2-4*{a}*{c}>0
CONSTRAINTS: {x}+{y}<10 &&& {x}<{y}
```
Allowed: `<`, `<=`, `=`, `>=`, `>`, `<>`

---

## Scoring Columns

| Column | Values |
|--------|--------|
| POINTS | Max score (numeric) |
| SUBSCORING | `PROPORTIONAL` / `LINEAR_SUBTRACTED:N` / `CUSTOM` / `NONE` |
| SUBPOINTS | Percentages per answer, `&&&` separated (required with CUSTOM) |
| MANUAL_SCORING | `NO` / `NOT_CORRECT` / `ALWAYS` |
| PENALTY_SCORING | `DEFAULT` / `PER_ANSWER` / `PER_QUESTION` |
| PENALTY_POINTS | Numeric penalty for wrong answer |
| HINT_PENALTY | `NONE` / `ONCE:20%` / `ONCE:0.2` / `PER-HELP:10%` |
| SOLUTION_PENALTY | Same as HINT_PENALTY |
| VIDEO_PENALTY | Same but no PER-HELP |

Penalty logic: if partially correct → subpoints instead of penalty.
If no answer → no penalty.

---

## TOLERANCE Methods

For NUMERIC, EXPRESSION, MATRIX, MATRIX:EXPRESSION, SET:

```
TOLERANCE: ABSOLUTE:10          — max absolute difference
TOLERANCE: RELATIVE:5%          — max % difference (SMAP)
TOLERANCE: RELATIVE:0.05        — same (decimal form)
TOLERANCE: QUOTIENT             — integer multiples accepted
TOLERANCE: QUOTIENT2            — scalar multiples accepted
TOLERANCE: QUOTIENT:SYNCED      — synchronized quotient mode
TOLERANCE: QUOTIENT2:SYNCED
```

---

## GRAPH Column

Display a function graph under the question:
```
GRAPH: [-10-10] &&& [-20-20] &&& x ||| x/2
GRAPH: [-10-10] &&& [-20-20] &&& x &&& [-5-5]
```
Format: `[xstart-xend] &&& [ystart-yend] &&& functions(|||separated) &&& ranges(|||separated)`
- Functions must be of variable x (y= or f(x)= prefix optional)
- Can use parameters

---

## FREETEXT_RULES

Automatic evaluation rules for FREE-TEXT:
```
FREETEXT_RULES: {1; king, crown}     — correct if these keywords present
FREETEXT_RULES: {2; wrong, bad}      — wrong if these keywords present
FREETEXT_RULES: {3; correct, right}  — correct if none of these present
FREETEXT_RULES: {4; missing}         — wrong if none of these present
```
- Keywords: comma-separated (no semicolons in keywords!)
- type 1: keywords present → correct
- type 2: keywords present → wrong
- type 3: none present → correct
- type 4: none present → wrong
