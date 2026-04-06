---
name: edubase-quiz-exam-builder
description: >
  Builds, assembles, and manages EduBase Quiz sets and Exams end-to-end — from grouping questions
  into Quiz sets, to creating time-boxed Exams, assigning users, and configuring branding.
  Use whenever the user wants to: create a Quiz set or Exam, add/remove questions to/from a Quiz,
  assign students or classes to an Exam, schedule an Exam with open/close times, copy settings
  between Exams, set up Exam branding, choose exam types (exam/homework/survey/championship),
  list or inspect existing Quizzes or Exams, or perform any assembly step ABOVE the individual
  question level. Also trigger when the user says "set up a test", "schedule an exam",
  "make a quiz from these questions", "assign students to the exam", "create a homework",
  "launch a survey", or references Quiz sets, Exam objects, or the three-layer EduBase hierarchy.
  Do NOT use for creating or editing individual questions — that is the `edubase-question-creator`
  skill. Do NOT use for analyzing results or score reporting — out of scope for this skill.
---

# EduBase Quiz & Exam Builder

You assemble questions into Quiz sets and Quiz sets into Exams — the two upper layers of the
EduBase content hierarchy. For the question-level layer beneath you, delegate to
`edubase-question-creator`.

Before starting any build workflow, read `references/hierarchy-and-concepts.md` to internalize
the three-layer model and the mental model behind it. It codifies the visual overview from
https://help.edubase.net/#quick-overview-of-edubase-quiz and the critical constraints that
follow from it.

---

## The Three-Layer Mental Model (quick summary)

```
┌─────────────────────────────────────────────────┐
│  EXAM          "When, who, and how"             │
│  A time-boxed, user-scoped instance of a Quiz   │
│  set. One Quiz can power many Exams.            │
├─────────────────────────────────────────────────┤
│  QUIZ SET      "What to ask"                    │
│  A reusable collection of questions, optionally │
│  organized into question groups.                │
├─────────────────────────────────────────────────┤
│  QUESTIONS     "The atomic unit"                │
│  Individual items. Can exist independently and  │
│  belong to multiple Quiz sets simultaneously.   │
└─────────────────────────────────────────────────┘
```

The key insight: **Questions are shared, not copied.** A single question can appear in many
Quiz sets. A single Quiz set can power many Exams. This is a many-to-many relationship at
every boundary — design accordingly.

---

## Workflow — Phases

The user may enter at any phase. Detect where they are and pick up from there.

### Phase 1: Clarify Intent

Determine what the user actually needs. The request space maps to a few distinct jobs:

| User says something like…                        | Job                          |
|--------------------------------------------------|------------------------------|
| "Make a quiz from these questions"               | Create Quiz set + populate   |
| "Set up an exam for next Monday"                 | Create Exam from Quiz set    |
| "Add questions X, Y, Z to my quiz"              | Populate existing Quiz set   |
| "Assign my class to the exam"                    | Enroll users on Exam         |
| "Create a homework due Friday"                   | Create Exam (type: homework) |
| "Launch a survey"                                | Create Exam (type: survey)   |
| "Copy settings from last semester's exam"        | Create Exam with copy        |
| "Show me what's in Quiz set ABC"                 | Inspect Quiz set             |
| "Brand the exam with our logo"                   | Configure Exam branding      |
| "Remove 3 questions from the quiz"               | Edit Quiz set membership     |

If ambiguous, ask one focused question to disambiguate. Avoid multi-question interrogations.

### Phase 2: Resolve Prerequisites

Every build operation has a dependency chain. Walk it **bottom-up**:

1. **Questions must exist** before they can be added to a Quiz set.
   - If the user provides question content inline → delegate to `edubase-question-creator` to
     create them first, collect the returned question identification strings.
   - If the user references existing questions → verify they exist via `edubase_get_question`.

2. **A Quiz set must exist** before an Exam can reference it.
   - If the user wants an Exam but has no Quiz set yet → create one first.
   - If they reference an existing Quiz set → verify via `edubase_get_quiz`.

3. **Users must exist** before they can be assigned to an Exam.
   - If the user mentions people by name/email → look them up via `edubase_get_user_search`.
   - If they mention a class → get members via `edubase_get_class_members`.

Present a brief dependency summary only when prerequisites are missing. If everything is in
place, skip straight to execution.

### Phase 3: Build

Execute the operations in the correct order. See the MCP Tool Reference in
`references/mcp-tool-reference.md` for exact tool names and parameters.

#### Creating a Quiz Set

```
edubase_post_quiz
  title       — descriptive name
  type        — "set" (practice), "exam" (assessment), or "private" (testing)
  mode        — "TEST" (all questions at once) or "TURNS" (one-by-one)
  language    — ISO 639-1 code
  description — optional short blurb
  id          — optional external identifier for programmatic updates
```

**Choosing `type`:**
- `set` → the Quiz set appears in practice mode; students can replay freely.
- `exam` → the Quiz set is intended to back Exams; stricter by convention.
- `private` → invisible to students; use for internal testing before going live.

**Choosing `mode`:**
- `TEST` → all questions visible, student navigates freely. Best for shorter quizzes or
  when you want students to manage their own time across questions.
- `TURNS` → one question at a time, linear progression. Best for preventing students from
  skipping ahead, or when question order matters pedagogically.

After creation, the returned `quiz` identification string is the handle for all subsequent
operations.

#### Populating a Quiz Set with Questions

```
edubase_post_quiz_questions
  quiz      — Quiz identification string
  questions — comma-separated question identification strings
  group     — optional question group name
```

**Question groups** are named subsets within a Quiz set. They control random selection: if a
Quiz is configured to "pick 5 from group A and 3 from group B", groups are the mechanism.
Use them when the user wants randomized subsets from a pool, or topical organization within
a single Quiz set.

To remove questions without deleting them globally:
```
edubase_delete_quiz_questions
  quiz      — Quiz identification string
  questions — comma-separated question identification strings
```

This only detaches the questions from the Quiz set. The questions themselves remain in the
user's QuestionBase.

#### Creating an Exam

An Exam is always built **on top of** an existing Quiz set.

```
edubase_post_exam
  title     — exam title (shown to students)
  quiz      — Quiz set identification string (the source of questions)
  open      — start time, "YYYY-MM-DD HH:ii:ss" in UTC
  close     — end time, "YYYY-MM-DD HH:ii:ss" in UTC
  type      — "exam" | "homework" | "survey" | "championship"
  language  — optional ISO 639-1 code
  id        — optional external identifier
  copy_settings — optional: exam ID to clone settings from
```

**Exam types explained:**

| Type           | Behavior                                                         |
|----------------|------------------------------------------------------------------|
| `exam`         | Standard timed assessment. Once started, must be completed.      |
| `homework`     | Can be paused and resumed within the open/close window.          |
| `survey`       | No grading. Optionally anonymous. For feedback collection.       |
| `championship` | Competitive mode with leaderboard and championship features.     |

**Exam statuses** (read-only, determined by time and admin actions):
- `INACTIVE` → before `open` time
- `ACTIVE` → between `open` and `close`, accepting new attempts
- `PAUSED` → admin-paused, no new attempts but existing ones may continue
- `REVIEW` → in review period (after main window, before full close)
- `EXPIRED` → after `close` time

**Cloning settings:** Use `copy_settings` to replicate configuration (time limits, retake
policies, display options) from a previous exam. Add `keep_certificate_settings: true` if you
also want to copy certificate templates.

#### Assigning Users to an Exam

```
edubase_post_exam_users
  exam  — exam identification string
  users — comma-separated user identification strings
```

To enroll an entire class, first retrieve its members, then assign them:
1. `edubase_get_class_members(class=...)` → get list of user IDs
2. `edubase_post_exam_users(exam=..., users=<comma-separated IDs>)`

To remove users:
```
edubase_delete_exam_users
  exam  — exam identification string
  users — comma-separated user identification strings
```

#### Configuring Exam Branding

```
edubase_post_exam_branding (if available via MCP)
  exam  — exam identification string
  type  — "foreground" (logo) or "background" (cover image)
  image — base64-encoded image or URL (PNG/JPEG/WebP)
  color — "branding" | "red" | "blue" | "yellow" | "green" | "purple" | "gray"
```

If the branding tool is not available via MCP, inform the user they can configure branding
in the EduBase web UI under the exam's settings.

#### Tagging and Permissions

Tags and permissions use the standard EduBase content operations:
- `edubase_post_exam_tag` / `edubase_delete_exam_tag` — attach/detach tags
- `edubase_post_exam_permission` / `edubase_delete_exam_permission` — grant/revoke user access
- `edubase_post_quiz_tag` / `edubase_delete_quiz_tag` — same for Quiz sets
- `edubase_post_quiz_permission` / `edubase_delete_quiz_permission` — same for Quiz sets

Permission levels: `view` / `report` / `control` / `modify` / `grant` / `admin`

### Phase 4: Verify & Report

After building, confirm the result back to the user with a summary:

```
✓ Quiz set "Linear Algebra Midterm" created (ID: qz_abc123)
  → 25 questions across 3 groups (Vectors: 10, Matrices: 10, Eigenvalues: 5)
  → Mode: TURNS (one-by-one)

✓ Exam "LA Midterm — Section A" created (ID: ex_def456)
  → Based on: qz_abc123
  → Window: 2026-04-15 09:00 - 2026-04-15 11:00 UTC
  → Type: exam
  → 42 students assigned
```

If any step failed, report the error clearly and suggest a fix.

---

## Common Compound Workflows

These are frequent multi-step requests. Handle them as a single fluid operation.

### "Create a full exam from scratch"

1. Create questions → delegate to `edubase-question-creator`
2. Create Quiz set → `edubase_post_quiz`
3. Populate Quiz set → `edubase_post_quiz_questions`
4. Create Exam → `edubase_post_exam`
5. Assign users → `edubase_post_exam_users`
6. (Optional) Configure branding
7. Report summary

### "Duplicate last semester's exam with new dates"

1. Get the old exam → `edubase_get_exam` to find its Quiz set
2. Create new exam → `edubase_post_exam` with `copy_settings` pointing to the old exam
3. Adjust open/close times
4. Re-assign users (or assign a new class)

### "Turn a practice quiz into a graded exam"

1. Get the Quiz set ID
2. Create Exam → `edubase_post_exam(quiz=<that ID>, type="exam", ...)`
3. Assign users
4. The Quiz set still works for practice in parallel — they coexist

---

## Guardrails

1. **Never delete an Exam that has results** without explicit user confirmation. Results
   are permanently lost when an exam is archived.

2. **Time zones matter.** The API uses UTC. If the user gives local times, convert them.
   Ask for their timezone if not obvious from context.

3. **Exam types are immutable after creation.** You cannot change an exam from `exam` to
   `homework` after the fact. Get it right at creation time. If the user wants to change
   the type, they need a new Exam.

4. **Quiz set type vs Exam type are different concepts.** A Quiz set with `type=set` can
   still back an Exam with `type=exam`. The Quiz set type controls practice visibility;
   the Exam type controls assessment behavior.

5. **Don't over-engineer.** If the user just wants "a quick quiz with 10 questions", don't
   ask about branding, groups, championship mode, and certificates. Build the simple thing,
   then mention that more configuration is available if they want it.
