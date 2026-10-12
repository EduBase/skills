# Journey Patterns — Engine-Verified Examples

Each example below passes the official JSON Schema and the journey engine's own sanitization and
validation with no errors, warnings, or dropped keys. Their branching was replayed with the
engine's decision function.

**Replace the `UPPER_CASE_CODE` placeholders with real identification strings** (look them up;
never send placeholders). Positions are omitted, so the engine lays the nodes out automatically.

## Table of Contents

1. [Linear path](#1-linear-path)
2. [Remediation loop with a retry limit](#2-remediation-loop-with-a-retry-limit)
3. [Placement by score bands](#3-placement-by-score-bands)
4. [Skill-gap routing](#4-skill-gap-routing)
5. [A/B split with drip timing](#5-ab-split-with-drip-timing)
6. [Routing by user data](#6-routing-by-user-data)
7. [Composing your own](#composing-your-own)

---

## 1. Linear path

Starting exam → progressive class → final exam that must be passed → `certified`.

```
start ─done─► course (class) ─done─► final (exam, success) ─done─► end "certified"
```

- `complete_on: success` on `final`: only a pass moves on. The final exam needs a **grading** and
  enough attempts (or users with failed, exhausted attempts become `attempts-exhausted` errors).
- `notify_user` tells users about each new step and the completion.

```json
{
  "schema": 1,
  "settings": {"title": "Onboarding path", "notify_user": true},
  "nodes": [
    {
      "node": "start",
      "type": "start",
      "config": {"complete_on": "finish"},
      "next": {"done": "course"}
    },
    {
      "node": "course",
      "type": "class",
      "config": {"class": "CLASS_CODE"},
      "next": {"done": "final"}
    },
    {
      "node": "final",
      "type": "exam",
      "config": {"exam": "FINAL_EXAM_CODE", "complete_on": "success"},
      "next": {"done": "end"}
    },
    {"node": "end", "type": "end", "config": {"outcome": "certified"}}
  ]
}
```

## 2. Remediation loop with a retry limit

Users who fail the entry test practice until they reach 80%, then retake a retest; after the
third failed retest the educators are notified, the user is marked in the starting exam's users
list, and the journey ends as `failed`.

```
start ─► entry-check ─passed─────────────────────────────────► certified
              └─else─► practice (quiz ≥80%) ─► retest (exam) ─► retest-check ─passed─► certified
                            ▲                                        ├─gave-up (3rd visit)─► alert ─► mark ─► failed
                            └──────────────── else ──────────────────┘
```

- The loop exits through `retest-check`'s branches, so validation accepts it (`cycle-no-exit` would
  block a loop without one).
- `node.visits` of `retest` counts visits in this run: 1st and 2nd failure loop back, the 3rd
  ends the journey. Branch order matters: `passed` is checked first, so a pass on the 3rd try
  still certifies.
- `max_visits: 4` is a safety net above the designed 3 retests, so users leave through the
  designed `failed` end instead of the generic `loop-limit` stop.
- `retake: true` grants a new retest attempt on every revisit; `reuse: false` prevents an old
  retest result from completing the step on the first visit.
- `entry-check` and `retest-check` use `step.successful`: both exams need a grading.

```json
{
  "schema": 1,
  "settings": {"title": "Safety certification", "max_visits": 4, "notify_user": true},
  "nodes": [
    {"node": "start", "type": "start", "label": "Entry test", "next": {"done": "entry-check"}},
    {
      "node": "entry-check",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "passed",
            "label": "Passed",
            "match": "all",
            "rules": [{"field": "step.successful", "operator": "is_true"}]
          }
        ],
        "else_label": "Failed"
      },
      "next": {"passed": "certified", "else": "practice"}
    },
    {
      "node": "practice",
      "type": "quiz",
      "label": "Practice until 80%",
      "config": {"quiz": "PRACTICE_QUIZ_CODE", "min_result": 80, "min_plays": 1},
      "next": {"done": "retest"}
    },
    {
      "node": "retest",
      "type": "exam",
      "label": "Retest",
      "config": {
        "exam": "RETEST_EXAM_CODE",
        "complete_on": "finish",
        "retake": true,
        "reuse": false
      },
      "next": {"done": "retest-check"}
    },
    {
      "node": "retest-check",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "passed",
            "label": "Passed",
            "rules": [{"field": "step.successful", "operator": "is_true"}]
          },
          {
            "key": "gave-up",
            "label": "Third failure",
            "rules": [{"field": "node.visits", "param": "retest", "operator": "gte", "value": 3}]
          }
        ],
        "else_label": "Try again"
      },
      "next": {"passed": "certified", "gave-up": "alert", "else": "practice"}
    },
    {
      "node": "alert",
      "type": "notify",
      "config": {
        "target": "educators",
        "message": "Failed the safety retest three times, please contact them."
      },
      "next": {"next": "mark"}
    },
    {"node": "mark", "type": "mark", "config": {"mode": "mark"}, "next": {"next": "failed"}},
    {"node": "certified", "type": "end", "config": {"outcome": "certified"}},
    {"node": "failed", "type": "end", "config": {"outcome": "failed"}}
  ]
}
```

## 3. Placement by score bands

A placement test routes users to the level that fits them; everyone converges on the final exam,
and the final outcome reflects passing it.

```
start ─► placement ─advanced (≥80%)─────────────────────────────► final ─► result ─passed─► "completed"
               ├─intermediate (≥50%)──────────► drill (quiz ≥70%) ─┘                └─else──► "failed"
               └─else (<50% or no result)─► basics (class) ─► drill
```

- A descending `gte` ladder: the first matching branch wins, so 80 → `advanced`, 50 →
  `intermediate`.
- `else` is the conservative path: users with a **missing** result (ungraded test, no points)
  also land there and start from the basics.
- `complete_on: final` on `final`: the step completes when the user passed, or failed with no
  attempts left; `result` then branches on `step.successful`.

```json
{
  "schema": 1,
  "nodes": [
    {"node": "start", "type": "start", "label": "Placement test", "next": {"done": "placement"}},
    {
      "node": "placement",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "advanced",
            "label": "80% or more",
            "rules": [{"field": "step.result", "operator": "gte", "value": 80}]
          },
          {
            "key": "intermediate",
            "label": "50-79%",
            "rules": [{"field": "step.result", "operator": "gte", "value": 50}]
          }
        ],
        "else_label": "Below 50% or no result"
      },
      "next": {"advanced": "final", "intermediate": "drill", "else": "basics"}
    },
    {
      "node": "basics",
      "type": "class",
      "label": "Basics course",
      "config": {"class": "BASICS_CLASS_CODE"},
      "next": {"done": "drill"}
    },
    {
      "node": "drill",
      "type": "quiz",
      "label": "Drill",
      "config": {"quiz": "DRILL_QUIZ_CODE", "min_result": 70},
      "next": {"done": "final"}
    },
    {
      "node": "final",
      "type": "exam",
      "label": "Final exam",
      "config": {"exam": "FINAL_EXAM_CODE", "complete_on": "final"},
      "next": {"done": "result"}
    },
    {
      "node": "result",
      "type": "condition",
      "config": {
        "branches": [
          {"key": "passed", "rules": [{"field": "step.successful", "operator": "is_true"}]}
        ]
      },
      "next": {"passed": "done", "else": "not-passed"}
    },
    {"node": "done", "type": "end", "config": {"outcome": "completed"}},
    {"node": "not-passed", "type": "end", "config": {"outcome": "failed"}}
  ]
}
```

## 4. Skill-gap routing

A diagnostic test with Quiz set **skills** (`algebra`, `geometry`) sends users to targeted
practice, then to the final exam; users with a big improvement get a congratulation message.

```
start ─► gaps ─algebra (<60%)──► algebra-practice (2 plays ≥75%) ─┐
             ├─geometry (<60%)─► geometry-practice (2 plays ≥75%) ─┼─► final ─► progress ─big-gain─► congrats ─► end
             └─else────────────────────────────────────────────────┘                  └─else───────────────────► end
```

- `step.skill` with `measure: percent` compares against the skill's maximum; skill identifiers
  must exist on the diagnostic exam's Quiz set (`edubase_get_exam_skills`).
- A user weak in both skills takes `algebra` (first match). To cover both, chain the practices
  (algebra → second condition on `node.skill` of `start` for geometry).
- `progress` compares the diagnostic (`node.result` of `start`) with the final (`step.result`).

```json
{
  "schema": 1,
  "nodes": [
    {"node": "start", "type": "start", "label": "Diagnostic", "next": {"done": "gaps"}},
    {
      "node": "gaps",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "algebra",
            "label": "Weak in algebra",
            "rules": [
              {
                "field": "step.skill",
                "param": "algebra",
                "measure": "percent",
                "operator": "lt",
                "value": 60
              }
            ]
          },
          {
            "key": "geometry",
            "label": "Weak in geometry",
            "rules": [
              {
                "field": "step.skill",
                "param": "geometry",
                "measure": "percent",
                "operator": "lt",
                "value": 60
              }
            ]
          }
        ],
        "else_label": "No gaps"
      },
      "next": {"algebra": "algebra-practice", "geometry": "geometry-practice", "else": "final"}
    },
    {
      "node": "algebra-practice",
      "type": "quiz",
      "config": {"quiz": "ALGEBRA_QUIZ_CODE", "min_result": 75, "min_plays": 2},
      "next": {"done": "final"}
    },
    {
      "node": "geometry-practice",
      "type": "quiz",
      "config": {"quiz": "GEOMETRY_QUIZ_CODE", "min_result": 75, "min_plays": 2},
      "next": {"done": "final"}
    },
    {
      "node": "final",
      "type": "exam",
      "config": {"exam": "FINAL_EXAM_CODE"},
      "next": {"done": "progress"}
    },
    {
      "node": "progress",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "big-gain",
            "label": "Weak start, strong finish",
            "match": "all",
            "rules": [
              {"field": "node.result", "param": "start", "operator": "lt", "value": 50},
              {"field": "step.result", "operator": "gte", "value": 80}
            ]
          }
        ]
      },
      "next": {"big-gain": "congrats", "else": "end"}
    },
    {
      "node": "congrats",
      "type": "notify",
      "config": {"target": "user", "message": "Huge progress since the diagnostic, well done!"},
      "next": {"next": "end"}
    },
    {"node": "end", "type": "end"}
  ]
}
```

## 5. A/B split with drip timing

Users are split 50/50 between two course formats, the variant is stored as a flag for later
analysis, and spaced practice follows with waits.

```
start ─► ab ─video───► flag variant=video ───► video-class ───┐
            └─reading─► flag variant=reading ─► reading-class ─┴─► wait 3 days ─► recall (quiz) ─► wait until Monday 9:00 ─► post-test ─► end
```

- `split` picks deterministically per user, so the assignment never flips.
- Flags appear in `edubase_get_exam_journey_user` → `flags`, and can be read later with the
  `journey.flag` rule field (e.g. to compare the variants' post-test routes).
- `duration` waits count from entering the wait (4320 minutes = 3 days). The `weekday` wait with
  a `time` is zoned (its `timezone`, UTC when missing); without a `time` it ends at the start of
  that day in the user's own timezone.

```json
{
  "schema": 1,
  "settings": {"notify_user": true},
  "nodes": [
    {"node": "start", "type": "start", "label": "Pre-test", "next": {"done": "ab"}},
    {
      "node": "ab",
      "type": "split",
      "config": {
        "branches": [
          {"key": "video", "label": "Video course", "weight": 50},
          {"key": "reading", "label": "Reading course", "weight": 50}
        ]
      },
      "next": {"video": "flag-video", "reading": "flag-reading"}
    },
    {
      "node": "flag-video",
      "type": "flag",
      "config": {"name": "variant", "value": "video"},
      "next": {"next": "video-class"}
    },
    {
      "node": "flag-reading",
      "type": "flag",
      "config": {"name": "variant", "value": "reading"},
      "next": {"next": "reading-class"}
    },
    {
      "node": "video-class",
      "type": "class",
      "config": {"class": "VIDEO_CLASS_CODE"},
      "next": {"done": "pause"}
    },
    {
      "node": "reading-class",
      "type": "class",
      "config": {"class": "READING_CLASS_CODE"},
      "next": {"done": "pause"}
    },
    {
      "node": "pause",
      "type": "wait",
      "label": "Wait 3 days",
      "config": {"mode": "duration", "minutes": 4320},
      "next": {"next": "recall"}
    },
    {
      "node": "recall",
      "type": "quiz",
      "label": "Spaced recall",
      "config": {"quiz": "RECALL_QUIZ_CODE"},
      "next": {"done": "monday"}
    },
    {
      "node": "monday",
      "type": "wait",
      "label": "Next Monday 9:00",
      "config": {"mode": "weekday", "weekday": 1, "time": "09:00", "timezone": "Europe/Budapest"},
      "next": {"next": "post-test"}
    },
    {
      "node": "post-test",
      "type": "exam",
      "config": {"exam": "POST_TEST_EXAM_CODE"},
      "next": {"done": "end"}
    },
    {"node": "end", "type": "end"}
  ]
}
```

## 6. Routing by user data

Registration data decides the onboarding track; generated exam accounts (external candidates)
finish immediately with their own outcome.

```
start ─► route ─guest (generated account)─────────► guest-end "external"
              ├─sales (department in Sales, CS)───► sales-class ────┐
              ├─manager (custom field "yes")──────► manager-class ──┼─► compliance (exam, success) ─► end
              └─else──────────────────────────────► general-class ──┘
```

- `user.department` values are **department titles** of the starting exam's organization
  (sub-departments match too).
- `exam.custom` reads the starting exam's own registration field by label: param
  `"<exam code>:<field label>"`. A yes/no field compares with `is_true`.
- Branch order makes the routing a priority list: a sales manager follows `sales`.

```json
{
  "schema": 1,
  "nodes": [
    {"node": "start", "type": "start", "label": "Registration", "next": {"done": "route"}},
    {
      "node": "route",
      "type": "condition",
      "config": {
        "branches": [
          {
            "key": "guest",
            "label": "Exam account",
            "rules": [{"field": "user.generated", "operator": "is_true"}]
          },
          {
            "key": "sales",
            "label": "Sales team",
            "rules": [
              {"field": "user.department", "operator": "in", "value": ["Sales", "Customer Success"]}
            ]
          },
          {
            "key": "manager",
            "label": "Managers",
            "rules": [
              {
                "field": "exam.custom",
                "param": "STARTING_EXAM_CODE:Do you manage a team?",
                "operator": "is_true"
              }
            ]
          }
        ],
        "else_label": "Everyone else"
      },
      "next": {
        "guest": "guest-end",
        "sales": "sales-class",
        "manager": "manager-class",
        "else": "general-class"
      }
    },
    {
      "node": "sales-class",
      "type": "class",
      "config": {"class": "SALES_CLASS_CODE"},
      "next": {"done": "compliance"}
    },
    {
      "node": "manager-class",
      "type": "class",
      "config": {"class": "MANAGER_CLASS_CODE"},
      "next": {"done": "compliance"}
    },
    {
      "node": "general-class",
      "type": "class",
      "config": {"class": "GENERAL_CLASS_CODE"},
      "next": {"done": "compliance"}
    },
    {
      "node": "compliance",
      "type": "exam",
      "config": {"exam": "COMPLIANCE_EXAM_CODE", "complete_on": "success"},
      "next": {"done": "end"}
    },
    {"node": "guest-end", "type": "end", "config": {"outcome": "external"}},
    {"node": "end", "type": "end", "config": {"outcome": "completed"}}
  ]
}
```

## Composing your own

| Need | Building block |
|------|----------------|
| Only passers continue | `complete_on: success`, or a `condition` on `step.successful` with `else` → an `end` "failed" |
| Score-based levels | `condition` with a descending `step.result` `gte` ladder, `else` = lowest level |
| Retry limit | `condition` branch `node.visits` (param: the retried node) `gte N`, before the loop-back `else` |
| Compare with an earlier test | `node.result` with `param` = that node's key and an `aggregate` |
| Weak skills | `step.skill` / `node.skill` with `measure: percent` |
| Personal track | `user.department`, `user.team`, `exam.custom`, `user.gender`, `user.generated` |
| Timed release | `wait` with `duration`, `date` (a user's day, or a zoned moment with a time), or `weekday` (+ optional zoned `time`); a launch moment as a `date.datetime` rule |
| Office hours only | `condition` on `date.weekday` / `date.hour` with the office's `timezone`, `else` → a `wait` until the next weekday morning |
| Educator follow-up | `notify` (target `educators`) + `mark` |
| Remember something | `flag` (lowercase name), read back with `journey.flag` |
| Experiments | `split` with weights, then a `flag` per branch |
| Different certificates/credentials | separate `end` nodes with distinct outcomes; classes and competency requirements can accept specific outcomes |
