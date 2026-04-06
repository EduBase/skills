# EduBase Quiz Hierarchy & Concepts

This reference codifies the three-layer architecture of EduBase Quiz.
Source: https://help.edubase.net/#quick-overview-of-edubase-quiz

## Table of Contents
1. [The Three Layers](#the-three-layers)
2. [Relationships Between Layers](#relationships-between-layers)
3. [Question Groups Within Quiz Sets](#question-groups-within-quiz-sets)
4. [Exam Types Deep Dive](#exam-types-deep-dive)
5. [Exam Lifecycle and Statuses](#exam-lifecycle-and-statuses)
6. [Quiz Set Types vs Exam Types](#quiz-set-types-vs-exam-types)
7. [Common Misconceptions](#common-misconceptions)

---

## The Three Layers

EduBase Quiz has exactly three content layers. Think of them like a building:

```
LAYER 3 — EXAMS (the event)
  "When does it happen? Who takes it? Under what rules?"
  An Exam is a scheduled, user-scoped instance of a Quiz set.
  It adds: time window, assigned users, attempt limits, branding,
  certificates, and behavioral rules (pause/resume, proctoring, etc).

  ┌───────────────────────────────────────────────────┐
  │  Exam #1: "Midterm — Mon 9am"                     │
  │  → Questions from: Quiz set "Calculus Pool"       │
  │  → Open: 2026-04-15 09:00   Close: 11:00          │
  │  → Assigned: 42 students                          │
  └───────────────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LAYER 2 — QUIZ SETS (the content package)
  "What gets asked?"
  A named, reusable collection of questions. Optionally organized
  into question groups for randomized selection.

  ┌──────────────────┐     ┌──────────────────────────┐
  │  Quiz set #1     │     │  Quiz set #2             │
  │  "Practice Set"  │     │  "Calculus Pool"         │
  │  (5 questions)   │     │  (20 questions, 2 groups)│
  └──────────────────┘     └──────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

LAYER 1 — QUESTIONS (the atoms)
  "The actual items students answer."
  Questions live independently in the user's QuestionBase.
  They can belong to zero, one, or many Quiz sets simultaneously.

  □  □  □  □  □  □  □  □  □  □
```

### Key architectural consequence

Because questions are **shared by reference** (not copied), editing a question changes it
everywhere it appears — in every Quiz set and every Exam that uses those Quiz sets. This is
powerful (fix a typo once, fixed everywhere) but dangerous (change difficulty of a question
mid-exam). Warn the user when they edit questions that are part of active exams.

---

## Relationships Between Layers

```
Questions ←─ many-to-many ─→ Quiz Sets ←─ one-to-many ─→ Exams
```

- A **Question** can belong to 0..N Quiz sets.
- A **Quiz set** contains 1..N questions, and can power 0..N Exams.
- An **Exam** references exactly 1 Quiz set.

This means:
- Multiple Exams can share the same Quiz set (e.g., "Section A" and "Section B" of the
  same course, at different times).
- A single question can appear in a practice Quiz AND an exam Quiz, simultaneously.
- Deleting a question from a Quiz set (via `edubase_delete_quiz_questions`) only removes
  the association — the question itself stays in QuestionBase.
- Permanently deleting a question (via `edubase_delete_question`) removes it from
  everywhere, including any Quiz set it was part of.

---

## Question Groups Within Quiz Sets

A Quiz set can organize its questions into **named groups**. Groups enable:

1. **Random selection per group**: "Pick 5 from Algebra, 3 from Geometry" — the Quiz
   engine selects randomly within each group per attempt.
2. **Topical structure**: Even without random selection, groups label sections of the quiz.

### How groups work via MCP

When adding questions to a Quiz set, the `group` parameter is optional:
- Omit `group` → questions go into the default (ungrouped) pool.
- Provide `group="Algebra"` → questions go into the "Algebra" group. If the group
  doesn't exist yet, it's created automatically.

```
edubase_post_quiz_questions(quiz="qz_123", questions="q1,q2,q3", group="Algebra")
edubase_post_quiz_questions(quiz="qz_123", questions="q4,q5", group="Geometry")
```

Removing questions from a specific group:
```
edubase_delete_quiz_questions(quiz="qz_123", questions="q2", group="Algebra")
```

### Inspecting groups

`edubase_get_quiz_questions(quiz="qz_123")` returns all questions with their group
assignments.

---

## Exam Types Deep Dive

| Type           | Use case                      | Pause/resume? | Graded? | Leaderboard? |
|----------------|-------------------------------|---------------|---------|--------------|
| `exam`         | Formal assessment             | No            | Yes     | No           |
| `homework`     | Take-home assignments         | Yes           | Yes     | No           |
| `survey`       | Feedback, course evaluations  | No            | No      | No           |
| `championship` | Competitions, gamified tests  | No            | Yes     | Yes          |

### When to recommend each type

- **exam**: The user wants a traditional assessment — sit down, complete in one session,
  timed. Most common for midterms, finals, certifications.
- **homework**: The user wants students to work at their own pace over days/weeks. Students
  can pause and return. Best for problem sets, weekly assignments.
- **survey**: The user wants to collect opinions or feedback, not test knowledge. Can be
  anonymous. Best for course evaluations, exit surveys, needs assessments.
- **championship**: The user wants competitive elements — rankings, fastest-time boards,
  point accumulation. Best for quiz bowls, training competitions, gamified learning.

### Type is immutable

Once created, an Exam's type cannot be changed. If the user realizes they picked the wrong
type, the only option is to create a new Exam (they can use `copy_settings` from the old one
to preserve configuration).

---

## Exam Lifecycle and Statuses

An Exam moves through these statuses based on time and admin actions:

```
         open time                           close time
            │                                     │
  INACTIVE  │  ACTIVE ──(admin pause)─→ PAUSED    │  EXPIRED
  ──────────┼─────────────────────────────────────┼──────────
            │  ←──(admin resume)──                │
            │                    REVIEW           │
            │                  (optional window)  │
```

- **INACTIVE**: Created but `open` hasn't arrived yet. Students see it listed but can't start.
- **ACTIVE**: Within the time window. Students can begin and complete attempts.
- **PAUSED**: Admin has temporarily halted new attempts (existing in-progress attempts may
  continue depending on settings). Useful for emergencies.
- **REVIEW**: A configured review period after the main window. Students can view their
  results but not start new attempts.
- **EXPIRED**: Past `close` time. No further attempts possible.

These are read-only from the API — they're computed from the `open`/`close` times and any
admin actions. The agent cannot directly set a status, only influence it by setting times
or (in the case of pause) through the web UI.

---

## Quiz Set Types vs Exam Types

This is a frequent source of confusion. They are **independent** settings at different layers:

**Quiz set `type`** (set at Quiz creation):
- `set` → Appears in practice mode. Students can access freely and replay.
- `exam` → Intended to back Exams. By convention, may be hidden from practice.
- `private` → Hidden. For internal testing.

**Exam `type`** (set at Exam creation):
- `exam` / `homework` / `survey` / `championship` → Controls assessment behavior.

A Quiz set with `type=set` CAN still back an Exam with `type=exam`. These are orthogonal.
The Quiz set type controls discoverability in practice mode; the Exam type controls what
happens during the assessment.

---

## Common Misconceptions

1. **"I need to copy questions into a new Quiz set"**
   → No. Just add the same question IDs to the new Quiz set. Questions are shared, not
   duplicated. Only use `copy_questions` on `edubase_post_quiz` when you want a true
   independent copy (e.g., you plan to edit questions for one set without affecting the other).

2. **"Deleting an Exam deletes the questions"**
   → No. Deleting/archiving an Exam only removes the Exam object. The Quiz set and its
   questions are untouched.

3. **"I can change the exam type after creation"**
   → No. Exam type is immutable. Create a new Exam if you need a different type.

4. **"All questions in a Quiz set appear in every Exam"**
   → Not necessarily. Quiz sets can be configured (in the web UI) to randomly select a
   subset of questions per attempt. Question groups control this selection.

5. **"Each Exam needs its own Quiz set"**
   → No. Multiple Exams can share a Quiz set. This is the intended pattern for running
   the same test at different times or for different sections.
