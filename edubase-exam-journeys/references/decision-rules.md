# Decision Rules — Fields, Operators, Semantics

Rules live in `condition` node branches:

```json
{ "key": "passed", "label": "Passed", "match": "all",
  "rules": [ { "field": "step.result", "operator": "gte", "value": 70 } ] }
```

| Rule key | Required | Notes |
|----------|----------|-------|
| `field` | yes | What is compared (tables below). |
| `operator` | yes | How it is compared. |
| `param` | for parameterized fields | ≤64 chars. |
| `value` | for comparing operators | Number, text, boolean, or list depending on the operator. |
| `aggregate` | optional | `node.*` result fields only: `last` (default), `first`, `best`, `worst`, `average`. |
| `measure` | optional | Skill fields only: `points` (default) or `percent`. |
| `time` | optional | `date.weekday` only: `"HH:MM"`, the rule matches on the listed days **from that time on**. |
| `timezone` | optional | Zoned rules only (`date.hour`, `date.datetime`, `date.weekday` with a `time`): IANA name such as `Europe/Budapest`, `UTC` when missing. |

## Table of Contents

1. [Which step is "the step"](#which-step-is-the-step)
2. [Fields](#fields)
3. [Operators](#operators)
4. [Comparison semantics](#comparison-semantics)
5. [Dates, times, and timezones](#dates-times-and-timezones)
6. [Aggregates and measures](#aggregates-and-measures)
7. [Recipes](#recipes)

---

## Which step is "the step"

`step.*` fields describe the **step completed just before the decision**: the starting exam for
a condition right after `start`, the Quiz set for a condition after a `quiz` step, and so on.
After a `wait` (or when an educator moves a user onto a decision), they describe the **last
completed step** of the current run.

Class steps carry no result — after a `class` step, `step.result`, `step.successful`, and
`step.grade` are missing (→ the `else` branch).

## Fields

### The completed step

| Field | Type | Param | Value |
|-------|------|-------|-------|
| `step.result` | number | — | Result in **percent (0–100)**. Missing without points; tests without questions count as 100. |
| `step.successful` | boolean | — | Passed according to the exam's grading. **Missing if the exam has no grading.** |
| `step.grade` | text | — | Name of the grade (e.g. `"Excellent"`, `"5"`). Missing without grading. |
| `step.attempts` | number | — | The user's attempts at the completed **exam** so far. |
| `step.time_spent` | number | — | Time spent on the completing attempt, in **minutes**. |
| `step.visits` | number | — | How many times the user has visited the completed step in this run (1 on the first). |
| `step.skill` | skill | skill identifier | The skill result of the completing attempt (see measures). Identifiers come from `edubase_get_exam_skills` / `edubase_get_quiz_skills`. |

### An earlier step of the journey (`param` = its node key)

The referenced node must be a step node (`start`, `exam`, `class`, `quiz`), otherwise the draft
gets `rule-node-missing`. Only the **current run** counts.

| Field | Type | Param | Value |
|-------|------|-------|-------|
| `node.result` | number | node key | Result (%) of the node's completions, aggregated. |
| `node.successful` | boolean | node key | Passed, aggregated (needs grading). |
| `node.grade` | text | node key | Grade, aggregated. |
| `node.time_spent` | number | node key | Minutes, aggregated. |
| `node.completed` | boolean | node key | Completed at least once. |
| `node.visits` | number | node key | Number of visits (entering counts, completed or not). |
| `node.skill` | skill | `nodekey:skillidentifier` | Skill result of the node's completions, aggregated. |

`node.*` is how loops count attempts (`node.visits` of the retest ≥ 3) and how later decisions
compare against earlier results (`node.result` of `start` < 50).

### The user

| Field | Type | Param | Value |
|-------|------|-------|-------|
| `exam.custom` | custom | `examcode:field` | A custom registration field the user filled in on **that** exam. `field` is the field's label (or hash) — labels with a `:` cannot be used. Needs report permission on the exam. Usually the starting exam's own fields. |
| `user.gender` | list | — | `male`, `female`, `other` (unset = missing). |
| `user.customer_field` | text | field name | A customer-specific user field (custom EduBase instances). |
| `user.department` | list | — | The user's department **and its parent departments** in the starting exam's organization. Values: department titles (or external identifiers). |
| `user.team` | list | — | The user's teams. Values: team codes (teams of the editing user). |
| `user.generated` | boolean | — | The user is a generated exam account (not a registered user). |

`exam.custom` values are normalized by field type: yes/no and true/false fields → boolean (in any
interface language), gender fields → `male`/`female`/`other`, number and range fields → number,
date fields → `YYYY-MM-DD` (as entered), date-time fields → `YYYY-MM-DD HH:MM` **in UTC** (EduBase
stores them in UTC), others → trimmed text (select fields: the chosen option's text).

### The journey and the date

| Field | Type | Param | Value |
|-------|------|-------|-------|
| `journey.flag` | text | flag name (lowercase) | Value set by a `flag` node earlier (also earlier in the same instant walk). Missing if never set. |
| `journey.days` | number | — | Whole days since the user first entered the journey. |
| `journey.steps` | number | — | Completed step visits in the current run (the starting exam included, repeats counted). |
| `date.weekday` | list | — | Current weekday, 1 (Monday) – 7 (Sunday). Without `time`: the user's own day. With `time`: zoned, matches the listed days only from that time on. |
| `date.hour` | number | — | Current hour 0–23, zoned (rule `timezone`). |
| `date.date` | date | — | Today, `YYYY-MM-DD`, the user's own calendar day. |
| `date.datetime` | datetime | — | Now, `YYYY-MM-DD HH:MM`, zoned (rule `timezone`). |

## Operators

| Operator | Value | Matches when |
|----------|-------|--------------|
| `eq` / `neq` | scalar | equal / not equal |
| `gt` `gte` `lt` `lte` | number or date | ordered comparison (numbers, or `YYYY-MM-DD[ HH:MM]` dates) |
| `between` | `[min, max]` | min ≤ actual ≤ max — **inclusive**, limit order irrelevant |
| `in` / `not_in` | list (≤64 items) | actual is / is not one of the values |
| `contains` | text | actual text contains the value |
| `empty` / `not_empty` | none | missing, blank text, or empty list / the opposite |
| `is_true` / `is_false` | none | truthy / falsy |

## Comparison semantics

These follow the engine exactly — design branches with them in mind:

1. **Missing values fail everything except `empty`.** `neq`, `not_in`, `is_false`, `lt` all
   return *false* on a missing value, so the user falls through to `else`. Make `else` the safe
   path, or test `empty` explicitly in an earlier branch.
2. **Branch order decides overlaps.** The first matching branch wins: with `between [0,50]` and
   `between [50,80]`, a result of exactly 50 takes the first. Prefer a descending `gte` ladder.
3. **Text is compared case-insensitively and trimmed** (`eq`, `in`, `contains`).
4. **Numbers compare numerically**: `eq 80` matches `80.0`. Results are percentages (0–100),
   never 0–1.
5. **Dates** compare by day unless both sides have a time. A `between` range cannot mix a date
   with a date-time (`rule-range-mixed` error).
6. **List fields** (`user.department`, `user.team`) match when **any** of the user's items
   matches: use `in`, `eq`, or `contains` (all mean "any item equals a value"), or `not_in`/`neq`
   (no item equals any value). Ordering operators never match lists.
7. **Truthiness** (`is_true`/`is_false`): booleans as is; numbers ≠ 0 are true; the texts `1`,
   `true`, `yes`, `y`, `on` are true, other texts false. Use these for `step.successful`,
   `node.completed`, `user.generated`, yes/no custom fields, and flag skills.
8. Boolean `value`s are stored as `1`/`0`; prefer `is_true`/`is_false` over `eq true`.

## Dates, times, and timezones

One rule decides everything: **dates without a time are calendar days and are never converted;
anything with a time is either UTC or zoned.**

| Value | How it is read |
|-------|----------------|
| `date.date`, `date.weekday` without `time` | The user's own calendar day (their profile timezone). |
| `date.hour`, `date.datetime`, `date.weekday` with `time` | **Zoned**: evaluated in the rule's `timezone` (UTC when missing). Write the time as the user means it and set `timezone`, e.g. `{"field": "date.hour", "operator": "gte", "value": 9, "timezone": "Europe/Budapest"}`. |
| `exam.custom` date fields | As the user entered them (calendar days). |
| `exam.custom` date-time fields | UTC — give rule values in UTC. Compared with a date-only value, the user's own day of the stored moment is used. |

The same rule holds for `wait` nodes: a `date` of `YYYY-MM-DD` waits until that day starts for
each user, while `YYYY-MM-DD HH:MM` and a `weekday` wait's optional `time` are zoned like the
rules above (the node's `timezone`, UTC when missing).

The journey editor writes the editor's timezone into new zoned rules and always shows local time.
Rules and waits created through the API without `timezone` are UTC, and the editor labels their zone.

## Aggregates and measures

**`aggregate`** (on `node.result`, `node.successful`, `node.grade`, `node.time_spent`,
`node.skill`) picks among the node's completions in this run; missing values are skipped:

| Aggregate | Numbers | Booleans | Text |
|-----------|---------|----------|------|
| `last` (default) | last | last | last |
| `first` | first | first | first |
| `best` | maximum | true if any is true | last |
| `worst` | minimum | true only if all are true | last |
| `average` | mean (3 decimals) | last | last |

**`measure`** (on `step.skill`, `node.skill`): `points` (default) compares the collected skill
points; `percent` compares the percentage of the skill's maximum (missing if the skill has no
maximum). Flag-type skills always compare their boolean state — use `is_true`/`is_false`.

## Recipes

```json
{ "field": "step.successful", "operator": "is_true" }
```
Passed the step's exam (needs grading).

```json
{ "field": "step.result", "operator": "gte", "value": 80 }
```
Scored 80% or more.

```json
{ "field": "node.visits", "param": "retest", "operator": "gte", "value": 3 }
```
Third time through the `retest` node (loop exit).

```json
{ "field": "node.result", "param": "start", "aggregate": "first", "operator": "lt", "value": 50 }
```
The starting exam's first result was below 50%.

```json
{ "field": "node.successful", "param": "module-1", "aggregate": "best", "operator": "is_true" }
```
Passed `module-1` at least once in this run.

```json
{ "field": "step.skill", "param": "algebra", "measure": "percent", "operator": "lt", "value": 60 }
```
Below 60% of the algebra skill's maximum in the completed test.

```json
{ "field": "node.skill", "param": "diagnostic:listening", "operator": "gte", "value": 12 }
```
12+ points in the `listening` skill on the `diagnostic` node.

```json
{ "field": "exam.custom", "param": "EXAM_CODE:Years of experience", "operator": "gte", "value": 5 }
```
Answered 5 or more to the starting exam's "Years of experience" number field.

```json
{ "field": "user.department", "operator": "in", "value": ["Sales", "Customer Success"] }
```
Member of Sales or Customer Success (or any of their sub-departments).

```json
{ "field": "journey.flag", "param": "variant", "operator": "eq", "value": "video" }
```
The A/B flag set earlier.

```json
{ "field": "date.weekday", "operator": "in", "value": [6, 7] }
```
It is the weekend for the user (their own day).

```json
{ "field": "date.weekday", "operator": "in", "value": [5], "time": "14:00", "timezone": "Europe/Budapest" }
```
Friday from 14:00 Budapest time (before 14:00 on Friday, `in` fails and `not_in` matches).

```json
{ "field": "date.datetime", "operator": "gte", "value": "2026-11-02 08:00", "timezone": "Europe/Budapest" }
```
From the 2 November 08:00 Budapest launch on, the same moment for everyone.

```json
{ "field": "step.time_spent", "operator": "lt", "value": 5 }
```
Finished in under 5 minutes (e.g. to catch rushed attempts).
