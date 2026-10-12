---
name: edubase-exam-journeys
description: >
  Designs, builds, publishes, and monitors EduBase exam journeys — adaptive learning paths that
  route each user from an exam through further exams, classes, and practice Quiz sets based on
  results, skills, user data, and time. Use whenever the user wants to: create a learning path,
  chain exams, branch on scores or pass/fail, send failing users to remediation and retest, place
  users by a placement test, route by skill gaps, department, or registration answers, add waiting
  periods or drip content, A/B split users, notify users or educators, edit, republish, export, or
  import a journey, or check journey progress ("who is stuck", outcomes, errors). Also trigger on
  "exam journey", "learning path", "adaptive path", "remediation loop", or /exam:journey endpoints.
  Do NOT use for creating questions (`edubase-question-creator`) or for single Quiz sets and Exams
  without a path between them (`edubase-quiz-and-exam-builder`, which also builds their contents).
---

# EduBase Exam Journeys

An **exam journey** is a directed graph owned by a **starting exam**. When a user starts that exam,
they enter the journey and are walked, node by node, through further steps: other exams,
progressive classes, and practice Quiz sets. Decisions, random splits, waits, notifications, flags,
and marks between the steps make the path adaptive. Every user finishes at an end node with an
**outcome** (e.g. `certified`, `failed`), which classes, competency requirements, webhooks, and
exports can then use.

You design these graphs, save them as a draft, fix validation issues, publish them, and monitor
the users walking them.

Reference files (read them when the task needs the detail):

- `references/portable-format.md` — every node type, config key, default, output, setting, limit,
  and validation/import error code. **Read before writing or editing any journey JSON.**
- `references/decision-rules.md` — condition rule fields, operators, comparison semantics.
  **Read before writing any `condition` node.**
- `references/patterns.md` — engine-verified example journeys (linear, remediation loop,
  placement bands, skill gaps, A/B split with drip, routing by user data).
- `references/monitoring.md` — status endpoints, user statuses, error codes and how to resolve
  them, webhooks, exports, and what can only be done on the EduBase interface.
- `assets/exam-journey.schema.json` — the official JSON Schema (draft 2020-12) of the format,
  generated from the journey engine. Validate against it when you can run code.

---

## Mental model

```
user starts the STARTING EXAM
          │
       [start] ─done─► <check> ─passed─► [final exam] ─done─► (end "certified")
                          └─else─► [practice quiz] ─done─► ~wait 3 days~ ─next─► [retest] ─done─► …

[ ] steps hold the user until completed   < > decisions/actions are instant
~ ~ waits hold the user until a time      ( ) ends finish the journey with an outcome
```

| Node kind | Types | Behavior | Outputs |
|-----------|-------|----------|---------|
| Steps | `start`, `exam`, `class`, `quiz` | User stays until the content is completed | `done` |
| Decisions | `condition`, `split` | Evaluated instantly | one per branch `key` (+ `else` for conditions) |
| Actions | `notify`, `flag`, `mark` | Executed instantly | `next` |
| Wait | `wait` | Holds the user until a time | `next` |
| End | `end` | Finishes the journey with its `outcome` | none |

- Exactly **one `start` node** — it *is* the starting exam (no content to configure). Nothing may
  lead back into it.
- An output that is **left out or `null` finishes the journey** with outcome `completed`.
- Node keys are the **identity** of a node: users' positions, histories, and `node.*` rules refer
  to them. Keep them stable across edits.
- A journey belongs to its starting exam and uses that exam's permissions. One exam starts at most
  one journey; a journey can use any exam, class, or Quiz set the editor controls as a step.

## Lifecycle: draft → published → enabled

1. **Draft** — `PUT /exam:journey:graph` replaces the whole draft. Users never see the draft.
   If the exam has no journey yet, this call **creates and enables** it (and removes the exam's
   simple "next exam" chaining setting).
2. **Published** — `POST /exam:journey:publish` copies the draft to the live version; users
   continue on it. Blocked while the draft has errors. Users on nodes removed from the draft must
   be remapped.
3. **Enabled** — users only enter (and advance on) an enabled journey. Disabling freezes users in
   place; it is done with the learning path (journey) option of the exam's settings on the EduBase
   interface. Publishing a disabled journey succeeds with a `warning`.

**Settings** (`title`, `description`, `max_visits`, `restartable`, `notify_user`, `educators`) are
not versioned: they are sent with the PUT call and apply immediately, even before publishing. To
change only settings, PUT the current draft's `nodes` unchanged together with the new `settings`.

## Tools

Journeys are managed through five API endpoints, exposed by the EduBase MCP server (version 2.0.4
or later) as the tools below, in its `exams` toolset. In read-only mode (`EDUBASE_READONLY`) only
the three GET tools are available; with dynamic toolsets, enable `exams` first. If the tools are
missing (older server, toolset disabled), call the REST API directly
(`https://www.edubase.net/api/v1/<endpoint>` with the integration's `app` and `secret`, see the
`edubase-mcp-setup` skill) — the parameters are identical.

| Tool | Endpoint | Purpose | Needs |
|------|----------|---------|-------|
| `edubase_get_exam_journey_graph` | `GET /exam:journey:graph` | Export the `draft` (default) or `published` graph, with `issues` and `publishable` for drafts | report permission |
| `edubase_put_exam_journey_graph` | `PUT /exam:journey:graph` | Replace the draft (`nodes`) and merge `settings`; strict, all-or-nothing | modify permission |
| `edubase_post_exam_journey_publish` | `POST /exam:journey:publish` | Publish the draft (`remap` for removed nodes) | modify permission |
| `edubase_get_exam_journey` | `GET /exam:journey` | Overview: users per status, per step, outcomes, averages | report permission |
| `edubase_get_exam_journey_user` | `GET /exam:journey:user` | One user's status, current step, full history, decisions, manual changes | report permission |

All of them take `exam` (the starting exam's identification string). Editing needs the **exam
journeys feature** on the account (error `Exam journeys are not enabled` means the plan lacks it —
tell the user, don't retry). Pass `nodes` (array of node objects), `settings`, and `remap`
(objects) as structured values to the tools; the REST API also accepts them as JSON-encoded
strings.

A GET on an exam without a journey fails with `Exam does not start a journey` — treat that as
"no journey yet", not as a failure.

**Neither the tools nor API access?** Write the journey as a `.json` file in the portable
format and have the user import it: enable the learning path in the exam's settings, open the
journey editor (`https://www.edubase.net/exam/journey:editor/<exam code>`), import the file,
review, save, and publish. The editor import is lenient — references it cannot resolve are
dropped with warnings, and the file's `settings` are ignored (set them in the editor's settings
dialog) — so tell the user to read its warnings. Files use the same date conventions as the API
(UTC date-times, zoned items with their `timezone`). The editor displays UTC date-times in the
user's local time — an `exam.custom` rule value of `2026-07-01 09:00` shows as 11:00 in Budapest —
while zoned items, such as wait dates, keep their own timezone.

---

## Workflow

The user may enter at any phase (e.g. "why is Anna stuck?" starts at monitoring). Detect where
they are.

### Phase 1 — Clarify the path

Pin down, asking only what you cannot infer:

- **Starting exam** — existing or new? (Championships and archived exams cannot start a journey.)
- **Steps** — which exams, classes, Quiz sets, in what order.
- **Decisions** — what routes users: pass/fail, score bands, skills, attempts, time spent,
  department/team, registration answers, random split?
- **Endings** — which outcomes exist (`certified`, `failed`, …) and who gets them.
- **Timing** — waits between steps (duration, a fixed date, or "next Monday 9:00")?
- **Communication** — notify users at each step (`notify_user`), custom messages, which educators
  hear about errors and `notify` nodes?

For anything beyond a straight line, **sketch the path in text and confirm it** before building:

```
start (Entry test) ─passed─► end "certified"
        └─failed─► practice quiz (≥80%) ─► retest ─passed─► end "certified"
                        ▲                     ├─3rd fail─► notify educators ─► end "failed"
                        └──────── else ───────┘
```

### Phase 2 — Resolve the contents

Every step needs an existing content, referenced by its **identification string** (code):

- Find codes with `edubase_get_exams`, `edubase_get_classes`, `edubase_get_quizes` (search, don't
  guess). Missing contents → create them first with the `edubase-quiz-and-exam-builder` skill.
- The current user must **control** every step's content (or it must already be on the journey);
  otherwise the import fails with `unknown or inaccessible … code`.
- Check the prerequisites that otherwise break users later:

| Step | Must be true | Otherwise |
|------|--------------|-----------|
| `start` | Users can start the exam: open window, users assigned (or joinable), not championship | Nobody enters the journey |
| `exam` | Open for the whole period users may arrive; not archived or locked; enough attempts for `complete_on: success` | User errors: `content-closed`, `content-locked`, `attempts-exhausted` |
| Pass/fail logic (`complete_on: success`/`final`, `step.successful`, `node.successful`, `step.grade`) | The exam has a **grading** with a pass threshold (`edubase_get_exam_settings` → `grading`; set it with `edubase_post_exam_settings` or on the Quiz set) | Without grading there is no pass/fail: `successful` rules go to `else`, and a `success` step **holds users forever** with no error |
| `class` | **Progressive** class (task-based progress), not archived | `class-not-progressive` blocks publishing |
| `quiz` | Active Quiz set that is **not `private`** type (private sets cannot be played by learners) | User cannot open the practice |
| `step.skill` / `node.skill` rules | Skills defined on the Quiz set behind the exam (`edubase_get_exam_skills`) | Rule value is missing → `else` |
| `exam.custom` rules | Field exists on that exam (`edubase_get_exam_fields`), label contains no `:` | Import error `custom-field-unknown` |
| `user.department` rules | Department titles of the starting exam's organization | Import error `department-unknown` |

Step exams are typically **long-running** (start now, end far in the future): users reach them at
different times, and the journey enrolls them automatically on arrival.

### Phase 3 — Design the graph

Write the portable JSON (`references/portable-format.md`). Design rules:

1. **Keys**: short, readable, stable kebab-case (`entry-check`, `retest`, `certified`); 1-32
   chars of `A-Z a-z 0-9 _ -`. Branch keys follow the same pattern and cannot be `else`, `done`,
   or `next`.
2. **Make `else` the safe fallback.** A missing value (ungraded test, survey, no skill result,
   empty field) fails every comparison except `empty`, so it always lands in `else`. Put explicit
   conditions on the "good" branches and the conservative path on `else`.
3. **Branches are evaluated in order; the first match wins.** For score bands, order from the
   top: `gte 80`, then `gte 50`, then `else`.
4. **End every path at an explicit `end` node** with a deliberate outcome instead of leaving
   outputs unconnected. Reuse the same outcome strings consistently (outcomes are matched
   case-insensitively elsewhere).
5. **Loops need an exit** (a decision branch leaving the loop) and are capped by `max_visits`
   (default 5 visits per node per run → the user is stopped with outcome `loop-limit`). Count
   attempts explicitly with `node.visits` so users exit through *your* end node, before the cap.
   Use `retake: true` on exam steps that are revisited.
6. **Pick `complete_on` deliberately** (start and exam steps):
   - `finish` (default) — any finished attempt; branch on the result afterwards.
   - `final` — passed, or failed with no attempts left; pair with a `step.successful` condition.
   - `success` — only a pass moves on; if attempts run out the user becomes an `error`
     (`attempts-exhausted`). Use only with unlimited attempts or a remediation path.
   - `success` and `final` rely on the exam's grading — without one, branch on `step.result`
     with `complete_on: finish` instead.
7. **Positions are optional** — omit `position` and the engine lays nodes out left-to-right. When
   editing an exported journey, keep the existing positions.
8. **Flag names are stored lowercase** — write them (and `journey.flag` params) in lowercase.
9. Keep notification messages free of personal data; they are plain text (≤500 chars).

### Phase 4 — Save the draft and fix issues

Call `edubase_put_exam_journey_graph(exam, nodes, settings?)`.

- **Import errors** (HTTP error, nothing saved): the message lists every problem with its
  location, e.g. `node 'retest-check', branch 'gave-up', rule #1: unknown field 'node.visit'`.
  Fix all of them and resend the complete node list.
- **Success** returns the saved draft with `issues` and `publishable`. `level: error` issues
  (missing content, invalid rule, loop without exit, …) block publishing; `warning` issues
  (unreachable node, unconnected decision output, branch without rules) are informative — but
  resolve them unless intentional.
- `ignored` lists unknown keys the import dropped (typos such as `config.minResult`) — fix them.
- When you can run code, validate against `assets/exam-journey.schema.json` first: it is stricter
  than the import (unknown keys are errors), so it catches typos before upload.

### Phase 5 — Publish

Call `edubase_post_exam_journey_publish(exam)`.

- Before publishing a journey that **already has users** (`users` above zero in
  `edubase_get_exam_journey`), summarize what changes for them and get the user's confirmation.
- If users sit on nodes removed from the draft, publishing fails with the affected nodes and user
  counts. Ask where to move them, then retry with `remap`: `{"old-node": "new-node"}`, or
  `{"old-node": ""}` to **stop** their journeys (confirm stopping explicitly — it cannot be
  undone by the API).
- Users on a node whose content changed (same key, new exam/class/Quiz set) are re-enrolled into
  the new content automatically.
- `unchanged: true` means the draft already equals the published version.
- A `warning` in the response means the journey is disabled — tell the user to enable it in the
  exam settings, or users will not enter it.

### Phase 6 — Verify and report

Re-read with `edubase_get_exam_journey_graph(exam, graph="published")` and report:

```
✓ Journey "Safety certification" published (version 3) on exam "Safety entry test" (EXAM_CODE)
  Path: Entry test → passed → certified | failed → Practice (≥80%) ⇄ Retest (max 3) → failed
  Outcomes: certified, failed · Max visits: 4 · Users notified at each step
  Remaining warnings: none
  Users enter when they start the entry test (open 2026-10-14 08:00 CEST / 06:00 UTC).
```

Remind the user that users enter **when they start the starting exam** — assign them to it
(`edubase_post_exam_users`) or share the journey in a class. Users who started the exam before
the journey was published and enabled are not on it, so publish before the exam opens.

---

## Editing an existing journey

1. `edubase_get_exam_journey_graph(exam)` → the current draft (check `unpublished_changes`: the
   draft may already differ from the live version — ask before overwriting someone's pending
   edits).
2. Modify the `nodes` list. **PUT replaces the entire draft**: send every node, not just the
   changed ones. The export's `marker`, `title`, `content` fields are read-only and ignored, so the
   exported list can be sent back as is.
3. Keep node keys stable. Renaming a key = deleting the node (users there need `remap`, history
   and `node.*` rules referencing it break).
4. PUT → check `issues` → publish (Phase 5).

To **discard** unpublished draft changes, export the `published` graph and PUT its `nodes` back
(the editor's restore button does the same; there is no restore endpoint). Confirm first — the
discarded draft cannot be recovered.

To copy a journey to another exam, export it, then PUT the same `nodes` to the new exam (the
`start` node binds to whichever exam you PUT to). Settings with `educators` must be valid for the
new exam.

## Monitoring (summary — details in `references/monitoring.md`)

- **Overview**: `edubase_get_exam_journey(exam)` → `users`, `status` counts (`active`, `waiting`,
  `error`, `completed`, `stopped`), `outcomes`, and per step (by marker letter A, B, …): users
  there, `passed_users`, `result_average`, `time_spent_average`. Only users visible to the caller
  are counted.
- **One user**: `edubase_get_exam_journey_user(exam, user)` → status, `error` code, current
  `step`, `wait_until`, `steps_completed`/`steps_remaining`, `flags`, full `history` with results
  and the decision branches taken, and manual `events`. `status: null` = has not started the
  starting exam yet.
- **Errors** need an educator: fix the cause (reopen/unarchive the exam, re-add the class
  membership, grant attempts…), then resume the user on the EduBase interface
  (journey overview → the user → resume/move). Moving, stopping, resuming, and restarting
  individual users is interface-only.
- **Automation**: organization webhook with `trigger_event: journey-completed`
  (`edubase_post_organization_webhook`); `export_journey: true` in exam settings adds journey
  columns to the results export.

## Gotchas

- Results in rules are **percentages 0-100**; `step.time_spent` (and a user's history
  `time_spent`) is test time in **minutes**, while the overview's `time_spent_average` is
  wall-clock **seconds** at the step.
- **Dates vs times**: dates without a time are the user's own calendar days and are never
  converted (`date.date`, `date.weekday`, `wait` days and weekday waits without a `time`). Anything
  with a time is either **UTC** (`exam.custom` date-time values) or **zoned** with its own
  `timezone` (`date.hour`, `date.datetime`, `date.weekday` with a `time`, and `wait` dates and
  weekday times).
  Convert the user's local times to UTC, or set `timezone` on zoned items, and show both when
  confirming. See `references/decision-rules.md` → Dates, times, and timezones.
- An exam step completes only when the attempt's result is **ready**: exams with manual grading
  or manual result approval hold users at the step until an educator approves the result (the
  user advances immediately on approval).
- Waits are processed every minute. Missed completions (e.g. a class completed but not revisited)
  and stuck users are detected by an hourly background job.
- Plays started **before** entering a step do not complete it (except on `start`); educator
  previews never count. `reuse: true` (default) lets an earlier finished result complete an exam
  step on its **first** visit, and an earlier class completion complete a class step.
- Quiz steps count **practice plays** (not exam attempts) reaching `min_result`, `min_plays` times.
- Splits are deterministic per user and step — re-evaluating never flips a user's branch.
- Only finishing the journey (an `end` node or an unconnected output) fires `journey-completed`
  webhooks; stops and `loop-limit` do not.
- At most 64 decision/action nodes can be walked in one go; longer instant chains error.

## Guardrails

1. **Never invent identification strings** — look them up; never put placeholder codes into a PUT.
2. **Confirm before**: publishing over a journey with active users, stopping users via `remap`,
   and overwriting a draft with `unpublished_changes` you did not make.
3. **Don't over-engineer.** "After the test, send failers to a practice quiz" is a 5-node journey.
   Offer extras (waits, notifications, flags) only when they serve the stated goal.
4. **Report truthfully**: if PUT or publish failed, quote the error and the fix you propose;
   never claim a journey is live until publish succeeded and it is enabled.
