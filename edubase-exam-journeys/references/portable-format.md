# Portable Journey Format — Complete Reference

The format used by `GET`/`PUT /exam:journey:graph` and by the journey editor's export/import.
Contents are referenced by their identification strings. The official JSON Schema is in
`assets/exam-journey.schema.json` (also served at
https://www.edubase.net/download:view/exam:journey:schema).

## Table of Contents

1. [Document](#document)
2. [Settings](#settings)
3. [Nodes](#nodes)
4. [Node types and their config](#node-types-and-their-config)
5. [Outputs and `next`](#outputs-and-next)
6. [Outcomes](#outcomes)
7. [Limits](#limits)
8. [Validation issues (draft)](#validation-issues-draft)
9. [Import errors (PUT)](#import-errors-put)
10. [Round-tripping an export](#round-tripping-an-export)

---

## Document

```json
{
  "schema": 1,
  "settings": { "title": "Safety certification", "max_visits": 4 },
  "nodes": [ { "node": "start", "type": "start", "next": { "done": "end" } },
             { "node": "end", "type": "end", "config": { "outcome": "completed" } } ]
}
```

| Key | Sent on PUT | Notes |
|-----|-------------|-------|
| `schema` | optional | Format version, currently `1` (default). Higher versions are refused. |
| `settings` | optional | Merged over the current settings, applied immediately (not versioned). |
| `nodes` | **required** | The complete node list; replaces the whole draft. 1–200 items. |
| `$schema`, `exam`, `journey`, `active`, `version`, `published`, `graph`, `unpublished_changes`, `issues`, `publishable` | — | Returned by the export, read-only. The starting exam is chosen by the `exam` parameter of the call. |

## Settings

Every key is optional; omitted keys keep their current value.

| Key | Type | Default | Notes |
|-----|------|---------|-------|
| `title` | string/null | null | Custom journey title (≤255). `null`/empty → the starting exam's title is used. Shown to users and in webhooks. |
| `description` | string/null | null | ≤1024 chars, shown to users on their journeys page. |
| `max_visits` | integer | `5` | 1–50. Maximum visits of any single step node per user per run. Entering a node beyond it stops the user with outcome `loop-limit` and notifies the educators. |
| `restartable` | boolean | `false` | A finished (completed or stopped) user who starts the starting exam again begins a new **run** (the `run` index increases). The exam must allow the user another attempt. |
| `notify_user` | boolean | `false` | Notify users when a new step becomes available and when they finish the journey. (`notify` nodes targeting the user are sent regardless.) |
| `educators` | list of user codes | `[]` | ≤10. Who receives error, loop-limit, and `notify`→`educators` messages. Only the owner and managers of the starting exam are allowed. Empty → the exam owner. |

## Nodes

| Key | Type | Notes |
|-----|------|-------|
| `node` | string, **required** | Stable key, unique in the journey, `^[A-Za-z0-9_-]{1,32}$`. |
| `type` | enum, **required** | `start`, `exam`, `class`, `quiz`, `condition`, `split`, `wait`, `notify`, `flag`, `mark`, `end`. |
| `label` | string/null | Custom title (≤64). Default: the content's title for steps, the type name otherwise. Shown to users ("Next step: …") — give steps meaningful labels when the content title is not self-explanatory. |
| `position` | `{x, y}` | Canvas position (−100000…100000). Omit to auto-layout: columns by distance from `start` (x = 60 + 260·depth), rows in reach order (y = 200 + 160·row). Nodes with a position are never moved. Markers (A, B, …) follow position order. |
| `config` | object | Depends on `type` (below). Unknown keys are ignored by the import and reported in `ignored`; the JSON Schema rejects them. |
| `next` | object | `{ "<output>": "<node key>" \| null }`. See [Outputs](#outputs-and-next). |
| `marker`, `title`, `content` | — | Export-only, ignored by the import. |

## Node types and their config

### `start` — the starting exam (step)

Exactly one. Its content is the exam the journey belongs to; nothing can lead into it.

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `complete_on` | `finish` / `success` / `final` | `finish` | `finish`: any finished attempt. `success`: only a successful attempt (needs grading). `final`: successful, or no attempts left. |

Plays of the starting exam always count, even if started before the user entered the journey.

### `exam` — another exam (step)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `exam` | exam code / null | — | The exam. Required for publishing (`content-missing`). |
| `complete_on` | `finish` / `success` / `final` | `finish` | As for `start`. |
| `retake` | boolean | `true` | Revisiting this step (loop) grants a new attempt if the last attempt was made before entering the step — even if the exam's attempt limit is used up. |
| `reuse` | boolean | `true` | On the **first** visit, an already finished, published result of the exam's current round (not yet used by another step of this journey) completes the step immediately. Set `false` to force a fresh attempt. |

On entry the user is added to the exam's users automatically. Only attempts started after
entering the step count. The exam must stay open, unarchived, and unlocked while users can arrive.

### `class` — a progressive class (step)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `class` | class code / null | — | Must be a **progressive** class (task-based progress). |
| `reuse` | boolean | `true` | An earlier completion of the class completes the step (on every visit). `false`: the user must redo the class's repeatable tasks — only activity after entering counts. |

On entry the user is enrolled automatically (membership method `journey`); if their journey is
stopped before they complete the class, that automatic membership is removed. The step completes
when the user completes the class.

### `quiz` — a practice Quiz set (step)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `quiz` | Quiz set code / null | — | Practice Quiz set (active, not of `private` type). |
| `min_result` | number 0–100 | `0` | Minimum result (%) of a practice play to count. |
| `min_plays` | integer 1–100 | `1` | Number of qualifying plays needed. |

The user is granted access to the Quiz set even if practicing by link is disabled. Only
**practice** plays (not exam attempts) started after entering the step count.

### `condition` — rule-based decision (instant)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `branches` | list (≤16) | `[]` | Evaluated **in order**; the first matching branch is taken, `else` otherwise. |
| `branches[].key` | key pattern, not `else`/`done`/`next`, unique | — | Becomes an output name. |
| `branches[].label` | string ≤64 | `""` | Shown in histories (e.g. "Passed"). |
| `branches[].match` | `all` / `any` | `all` | Every rule or any rule must match. A branch **without rules always matches**. |
| `branches[].rules` | list (≤16) | `[]` | See `references/decision-rules.md`. |
| `else_label` | string ≤64 | — | Label of the `else` output. |

### `split` — weighted random split (instant)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `branches` | list, 2–16 | — | Needs a positive total weight. |
| `branches[].key` | key pattern, not `else`/`done`/`next`, unique | — | Output name. |
| `branches[].label` | string ≤64 | `""` | |
| `branches[].weight` | integer 0–1000 | `1` | Relative share. `0` = never taken. |

The pick is deterministic per user, journey, run, and step, so re-evaluation never changes a
user's branch.

### `wait` — hold the user (waiting)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `mode` | `duration` / `date` / `weekday` | `duration` | |
| `minutes` | integer 1–525600 | `1440` | `duration` mode: minutes from entering. |
| `date` | `"YYYY-MM-DD HH:MM"` / `"YYYY-MM-DD"` / null | null | `date` mode. With a time: in `timezone`, the same moment for everyone. Without one: the start of that day in the **user's own timezone**. Required in this mode (`wait-invalid`). A past date continues immediately. |
| `weekday` | integer 1 (Mon) – 7 (Sun) | `1` | `weekday` mode: the next such day… |
| `time` | `"HH:MM"` / null | null | …at this time in `timezone`. Without it: at the start of that day in the **user's own timezone**. If that moment is now or past, the following week's. |
| `timezone` | IANA name | `UTC` | Only with a `time` or a `date` with a time, e.g. `Europe/Budapest` (the editor writes its own timezone). One zone serves both. |

Users at a wait have status `waiting` and `wait_until` (UTC) in the API. Waits are processed every
minute.

### `notify` — send a message (instant action)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `target` | `user` / `educators` | `user` | `educators` = the journey's `educators` setting (or the exam owner). |
| `message` | string ≤500 | — | Required (`message-missing`). Plain text, single line. |

### `flag` — store a value on the user's journey (instant action)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `name` | key pattern | — | Required (`flag-invalid`). **Stored lowercase.** |
| `value` | string ≤64 | `""` | Read later with the `journey.flag` rule field; visible as `flags` in the user status. Reset on restart. |

### `mark` — bookmark the user in the starting exam (instant action)

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `mode` | `mark` / `unmark` | `mark` | Marks (or unmarks) all of the user's results in the starting exam's users list, e.g. to flag users for follow-up. |

### `end` — finish the journey

| Config | Values | Default | Meaning |
|--------|--------|---------|---------|
| `outcome` | string ≤64 | `completed` | Built-ins: `completed`, `failed`; any custom text allowed (`certified`, `level-b`, …). |

## Outputs and `next`

| Node types | Outputs |
|------------|---------|
| `start`, `exam`, `class`, `quiz` | `done` |
| `wait`, `notify`, `flag`, `mark` | `next` |
| `condition` | each branch `key` + `else` |
| `split` | each branch `key` |
| `end` | none (`next` must be empty or omitted) |

- `next` maps outputs to node keys. An output **left out or `null` is unconnected**: users taking
  it finish the journey with outcome `completed`. The export lists every output (unconnected ones
  as `null`).
- Each output connects to at most one node; any number of outputs may lead to the same node.
- No output may lead to the `start` node.

## Outcomes

| Outcome | Status | Set by |
|---------|--------|--------|
| `outcome` of the reached `end` node | `completed` | the graph |
| `completed` | `completed` | an unconnected output |
| `loop-limit` | `stopped` | `max_visits` exceeded |
| `stopped` | `stopped` | an educator, or publishing with a `remap` to `""` |
| error codes (see monitoring) | `error` | the engine; not final, the user can be resumed |

The outcomes a journey can produce (end outcomes + `completed` if any output is unconnected) are
what classes sharing the journey and competency requirements can accept. Outcomes are compared
case-insensitively there.

## Limits

| Item | Limit |
|------|-------|
| Nodes | 200 |
| Branches per decision | 16 (split: at least 2) |
| Rules per branch | 16 |
| Items in an `in`/`not_in` list | 64 |
| Notified educators | 10 |
| `max_visits` | 1–50 (default 5) |
| Key / flag name / branch key | 1–32 chars `A-Za-z0-9_-` |
| `label`, branch `label`, `else_label`, `outcome`, flag `value`, rule `param` | 64 chars |
| `message` | 500 chars |
| Instant nodes walked in one go | 64 (beyond → user `error`) |

## Validation issues (draft)

Returned in `issues` by GET (draft) and PUT; errors block publishing.

| Code | Level | Meaning / fix |
|------|-------|---------------|
| `start-missing` | error | Add the `start` node. |
| `content-missing` | error | A step has no `exam`/`class`/`quiz` code. |
| `content-invalid` | error | The step's content no longer exists. |
| `content-archived` | error | The step's content is archived. |
| `content-access` | error | You lack control permission on the step's content. |
| `class-not-progressive` | error | The class step's class is not progressive. |
| `rule-invalid` | error | A rule lacks its `param` (or `node.skill`/`exam.custom` lack the `a:b` form). |
| `rule-node-missing` | error | A `node.*` rule refers to a key that is not a step node (`start`/`exam`/`class`/`quiz`). |
| `rule-value-missing` | error | A comparing operator has no `value`. |
| `rule-range-mixed` | error | A `between` range mixes a date with a date-time — use the same kind for both limits. |
| `split-invalid` | error | Split needs ≥2 branches and a positive total weight. |
| `wait-invalid` | error | `date` mode without a date. |
| `message-missing` | error | `notify` without a message. |
| `flag-invalid` | error | `flag` without a valid name. |
| `logic-cycle` | error | A loop made only of decisions/actions — add a step or wait into the loop. |
| `cycle-no-exit` | error | A loop with no output leaving it — add an exit branch. |
| `branches-missing` | warning | A condition with no branches: everyone takes `else`. |
| `rules-empty` | warning | A branch without rules always matches (later branches never run). |
| `output-unconnected` | warning | A decision output leads nowhere: users finish with `completed`. |
| `unreachable` | warning | The node cannot be reached from `start`. |

## Import errors (PUT)

The import is strict: if any of these occur, nothing is saved and the error message lists them
all (up to 10, then "and N more"), each prefixed with its location (`node 'x', branch 'y',
rule #n` or `settings.key`).

| Code | Cause |
|------|-------|
| `schema-unsupported` | `schema` is higher than 1. |
| `nodes-missing` | Empty or missing `nodes`. |
| `node-key-missing` / `node-key-invalid` / `node-duplicate` | Node key absent, malformed, or repeated. |
| `node-type-invalid` | Unknown `type`. |
| `start-duplicate` | More than one `start`. |
| `node-limit` | More than 200 nodes. |
| `next-invalid` / `output-target-invalid` | `next` is not an object, or a target is not a string/null. |
| `output-target-missing` | An output leads to a non-existent node key. |
| `output-invalid` | An output name the node does not have (message lists the valid ones). |
| `edge-into-start` | An output leads to `start`. |
| `branch-key-invalid` / `branch-duplicate` / `branch-limit` | Bad, repeated, or too many branch keys. |
| `rule-field-unknown` / `rule-operator-unknown` | Unknown rule `field` or `operator` (message lists valid ones). |
| `rule-value-invalid` | `between` without a two-item list. |
| `rule-time-invalid` | `date.weekday` `time` is not `HH:MM`. |
| `rule-timezone-invalid` | Unknown `timezone` on a zoned rule (use an IANA name). |
| `rule-limit` | More than 16 rules in a branch. |
| `content-unknown` | Step content code not found or not controlled by you. |
| `exam-unknown` / `custom-field-unknown` | `exam.custom` exam not found/not reportable, or no such field. |
| `department-unknown` / `team-unknown` | Unknown department title (in the starting exam's organization) or team code (among your teams). |
| `settings-*` | Invalid setting value, educator not allowed, or more than 10 educators. |

## Round-tripping an export

The export of `GET /exam:journey:graph` is a valid PUT body: send its `nodes` (and optionally
`settings`) back unchanged and the draft stays identical. The export:

- orders nodes by position and gives a `marker` letter to steps, waits, and ends, a resolved
  `title`, and the step's `content` (`{type, exam|class|quiz, id, title}`, or `null` if removed);
- lists every output in `next`, unconnected ones as `null`;
- writes rule references in portable form (exam codes, department titles, team codes).

When editing, change only what is needed and keep keys and positions.
