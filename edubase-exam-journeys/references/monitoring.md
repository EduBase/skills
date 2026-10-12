# Monitoring Journeys — Status, Errors, Automation

## Table of Contents

1. [Journey overview](#journey-overview)
2. [One user's journey](#one-users-journey)
3. [Statuses](#statuses)
4. [Error codes and how to resolve them](#error-codes-and-how-to-resolve-them)
5. [Interface-only actions](#interface-only-actions)
6. [Automation: webhooks and exports](#automation-webhooks-and-exports)
7. [Sharing and requirements](#sharing-and-requirements)
8. [Reporting template](#reporting-template)

All date-times returned are **UTC**; convert to the user's local time when reporting. Only the
users visible to the caller (e.g. their organization's members) are counted and returned.

---

## Journey overview

`edubase_get_exam_journey(exam)` — `GET /exam:journey`

| Field | Meaning |
|-------|---------|
| `journey`, `active`, `published` | Title, enabled flag, last publish time (`null` = never published → nobody can be on it). |
| `users` | Users who ever entered (all statuses). |
| `status` | Counts: `active` (working on a step), `waiting` (at a wait), `error` (stuck, needs an educator), `completed` (reached an end), `stopped` (stopped by an educator, a publish remap, or `loop-limit`). |
| `outcomes` | `[{outcome, users}]` for completed and stopped users. |
| `steps` | Every step, wait, and end node in marker order (A, B, …) with its `content`, plus: |
| `steps[].users` / `.status` | Users **currently** at the node, by status. |
| `steps[].passed_users` / `.passed_visits` | Distinct users / visits that already moved past the node (not for ends). |
| `steps[].result_average` | Average result (%) of completions of the node. |
| `steps[].time_spent_average` | Average **wall-clock seconds** between entering and leaving the node. |

Reading it:

- **Funnel**: compare `passed_users` along the main path; a sharp drop shows where users stall.
- **Bottleneck**: many `active` users at one step with a long `time_spent_average` — check that
  step's content is reachable (open window, attempts, class tasks).
- **Errors**: `status.error > 0` always needs attention — find the users (next section).
- **Outcome mix**: `outcomes` vs `users` shows completion and pass rates; `loop-limit` outcomes
  mean the loop design lets users circle until the cap.

## One user's journey

`edubase_get_exam_journey_user(exam, user)` — `GET /exam:journey:user` (`user` = the user's
identification string; find it with `edubase_get_user_search` or the starting exam's users via
`edubase_get_exam_users`).

| Field | Meaning |
|-------|---------|
| `status` | `active` / `waiting` / `error` / `completed` / `stopped`, or `null` = has not started the starting exam yet (no other fields then). |
| `outcome` | For `completed`/`stopped`. |
| `error` | Error code when `status` is `error` (table below). |
| `run` | Run index (increases on restart). |
| `step` | Current node: `step` key, `marker`, `type`, `title`, `content`, `time_start`. `null` once finished. |
| `wait_until` | When a waiting user continues (UTC). |
| `time_start` / `time_end` | Entered / finished the journey. |
| `steps_completed` / `steps_total` | Distinct step nodes completed in this run / step nodes in the journey (start included). |
| `steps_remaining` | Lower-bound estimate of steps left on the shortest way to an end (`null` if not running). |
| `flags` | Values set by `flag` nodes. |
| `history[]` | Every visit, all runs, in order: `run`, `visit`, node fields, `status` (`active`/`waiting`/`completed`/`moved`/`stopped`/`error`), `time_start`, `time_end`, `time_spent` (test minutes), and when available `result` (%), `successful`, `grade`, `play` (the completing attempt's Quiz play code), `skills`, `decisions[]` (the decision/action nodes walked after the step with the `output` and branch `label` taken). |
| `events[]` | Manual changes: `type` (`move`/`stop`/`resume`/`restart`), `source` (`operator` = an educator, `publish` = moved by a publish remap or re-enrolled by a content change), `from`/`to` (`step`, `status`), `operator` (educator's user code), `time`. |

Answering "why did X end up here?": walk `history`, and for each step read its `result`/
`successful` and the `decisions` (branch labels) taken after it.

## Statuses

| Status | Meaning | Final? |
|--------|---------|--------|
| `active` | At a step, working on its content | no |
| `waiting` | At a `wait` node until `wait_until` | no |
| `error` | Cannot continue (see codes); educators were notified | no — resumable |
| `completed` | Reached an `end` node or an unconnected output | yes (restartable journeys can start a new run) |
| `stopped` | Stopped by an educator, a publish remap to `""`, or `loop-limit` | yes (resumable on the interface) |

Disabling the journey freezes every user in place (no status change) until it is re-enabled.

## Error codes and how to resolve them

Educators (the journey's `educators` setting, or the exam owner) are notified for every error and
for `loop-limit` stops. Stuck users are detected by an hourly background job.

| Code | Cause | Resolution |
|------|-------|------------|
| `content-invalid` | The step's content was deleted | Point the node to new content and publish (users there are re-enrolled), or move the users |
| `content-archived` | The step's content is archived | Unarchive it, or replace it in the journey |
| `content-locked` | The step's exam is locked | Unlock the exam, then resume |
| `content-closed` | The step's exam closed before the user completed it | Extend the exam's end date (`edubase_patch_exam`), then resume |
| `class-not-progressive` | The step's class is no longer progressive | Make it progressive again or replace it |
| `class-membership-missing` | The user was removed from the step's class | Re-add the user (`edubase_post_class_members`), then resume |
| `class-membership-expired` | The user's class membership expired | Extend the membership, then resume |
| `attempts-exhausted` | `complete_on: success`, the latest attempt failed, no attempts left | Grant another attempt, move the user (e.g. to remediation), or redesign with `final` + a condition |
| `enroll-failed` | The user could not be added to the step's exam or class | Check the content's limits/settings, then resume |
| `error` | The walk failed (missing node, >64 instant nodes in a row) | Fix the graph, publish, then move/resume |

After fixing the cause, the user must be **resumed or moved on the interface** — the API has no
endpoint for it.

## Interface-only actions

These have no API endpoint; point the user to the EduBase interface:

| Action | Where |
|--------|-------|
| Enable / disable the journey | Exam settings → learning path (journey) option |
| Visual editing | Journey editor: `https://www.edubase.net/exam/journey:editor/<exam code>` |
| Restore the published version into the draft | Journey editor (API: PUT the `published` export's `nodes`) |
| Overview with per-node user lists | `https://www.edubase.net/exam/journey/<exam code>` |
| Move a user to a node / stop / resume / restart | Overview → a node's users → the user |
| Share a journey in a class | Class contents → add content → journey |
| Require a journey for a competency | Organization → competency requirements |
| Learners' own view | `https://www.edubase.net/account/journeys` |

On custom EduBase instances replace the domain. **Resume** re-enters the user's current node
(on the start node it restarts). **Restart** begins a new run from the starting exam and grants a
retake of it.

## Automation: webhooks and exports

**Completion webhook** — an organization webhook with `trigger_event: journey-completed` fires
when a user reaches the end of a journey (an `end` node or an unconnected output). It does *not*
fire for stops or `loop-limit`. Only journeys whose starting exam belongs to the organization,
and only users who are members of it, trigger it. Payload:

| Field | Value |
|-------|-------|
| `exam` | Starting exam's identification string |
| `journey` | Journey title |
| `user` | User identification string |
| `run` | Run index |
| `outcome` | The reached outcome (`completed` for unconnected outputs) |
| `steps_completed` | Distinct exam, class, and Quiz set steps completed (start included) |
| `time_start` / `time_end` | UTC date-times |

Create it with `edubase_post_organization_webhook(organization, title, trigger_event:
"journey-completed", endpoint, …)`. The trigger event cannot be changed later
(`edubase_patch_organization_webhook` has no `trigger_event`) — create a new webhook instead.
`edubase_post_organization_webhook_trigger` only fires `api` webhooks, so it cannot test this one;
test with a real completion instead.

**Results export** — set `export_journey: true` in the starting exam's settings
(`edubase_post_exam_settings` or `POST /exam:settings`), then `edubase_post_exam_results_export`
adds the journey status, current step, completion time, and outcome columns for each examinee.

## Sharing and requirements

- **Classes** can share a journey as class content (interface only). Joining from the class adds
  the user to the starting exam; the journey starts when they start it. The class can count the
  item done when the user **starts** the journey or when they **complete** it — optionally only
  with specific accepted outcomes.
- **Competency requirements** of an organization can require a journey (interface only), with
  accepted outcomes. `edubase_get_organization_competency_requirements` lists them (`type:
  journey`, with `journey.exam`, `journey.title`, `journey.active`, `journey.outcomes`).
  Assigning such a requirement adds the members to the starting exam.
- Because outcomes are matched case-insensitively there, keep outcome names consistent when
  editing end nodes — renaming an outcome silently stops it from matching existing requirements.

## Reporting template

```
Journey "Safety certification" (exam: Safety entry test) — enabled, published 2026-10-12 09:30 CEST
Users: 120 · active 31 · waiting 4 · error 2 · completed 79 · stopped 4
Outcomes: certified 71 · failed 8 · loop-limit 4
Funnel: A Entry test 120 → B Practice 46 → C Retest 39 (avg 64%) → certified 71
Needs attention: 2 users in error at C Retest (content-closed: the retest exam closed on 10-10).
  → Extend the retest end date, then resume them on the journey overview.
```
