# MCP Tool Reference — Quiz & Exam Operations

Quick lookup for the exact MCP tool to use for each operation. Parameters marked [!] are
required.

**All date-times are UTC** (`YYYY-MM-DD HH:ii:ss`), both in parameters and in returned data.
Convert from/to the user's local time zone.

## Table of Contents
1. [Quiz Set Operations](#quiz-set-operations)
2. [Quiz Set Question Management](#quiz-set-question-management)
3. [Exam Operations](#exam-operations)
4. [Exam User Management](#exam-user-management)
5. [Exam Branding](#exam-branding)
6. [Tags and Permissions](#tags-and-permissions)
7. [Lookup and Discovery](#lookup-and-discovery)
8. [Transfer and Ownership](#transfer-and-ownership)

---

## Quiz Set Operations

### Create a Quiz set
**Tool:** `edubase_post_quiz`

| Parameter        | Required | Type   | Notes                                                  |
|------------------|----------|--------|--------------------------------------------------------|
| `title`          | [!]      | string | Descriptive name shown to users                        |
| `type`           |          | string | `set` (default) / `final` / `exam` / `private`         |
| `mode`           |          | string | `TEST` (default, all-at-once) / `TURNS` (one-by-one)   |
| `language`       |          | string | ISO 639-1 code (e.g. `en`, `hu`)                       |
| `description`    |          | string | Short blurb                                            |
| `id`             |          | string | External unique ID, max 64 chars                       |
| `copy_questions` |          | string | Quiz ID to clone questions from                        |
| `copy_settings`  |          | string | Quiz ID to clone settings from                         |

**Returns:** `{ quiz: "<identification string>" }`

### Get Quiz set details
**Tool:** `edubase_get_quiz`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `quiz`    | [!]      | Quiz identification string |

### List all Quiz sets
**Tool:** `edubase_get_quizes`

| Parameter | Required | Notes                                 |
|-----------|----------|---------------------------------------|
| `search`  |          | Filter by keyword                     |
| `limit`   |          | Max results (default 16)              |
| `page`    |          | Page number (not used in search mode) |

### Update a Quiz set
**Tool:** `edubase_patch_quiz` — `quiz` [!], plus any of `title`, `description`, `language`, `id`,
`organization`.

### Quiz set settings
**Tools:** `edubase_get_quiz_settings` / `edubase_post_quiz_settings` (`quiz` [!])

| Setting             | Notes                                                        |
|---------------------|--------------------------------------------------------------|
| `shuffle`           | Shuffle questions for every play (boolean)                   |
| `timelimit`         | Whole-test limit in seconds (`0` = none)                     |
| `roundtime`         | Per-question limit in seconds (TURNS mode only)              |
| `grading`           | Grading preset code (`edubase_get_quiz_grading_presets`) or `none` |
| `grading_threshold` | Percentage, for presets with a configurable threshold        |

`edubase_patch_quiz_settings(quiz, source)` copies only the settings not yet configured.

### Delete/archive a Quiz set
**Tool:** `edubase_delete_quiz`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `quiz`    | [!]      | Quiz identification string |

### Get skills defined in a Quiz set
**Tool:** `edubase_get_quiz_skills`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `quiz`    | [!]      | Quiz identification string |

**Returns:** list of skills, each with `identifier`, `name`, and optional `description`.

Skills are defined at the Quiz set level (in the web UI). Questions reference these
identifiers in their `skills` field to alter skill scoring — identifiers not defined in
the Quiz set are ignored.

---

## Quiz Set Question Management

### Add questions to a Quiz set
**Tool:** `edubase_post_quiz_questions`

| Parameter   | Required | Notes                                          |
|-------------|----------|------------------------------------------------|
| `quiz`      | [!]      | Quiz identification string                     |
| `questions` | [!]      | Comma-separated question identification strings|
| `group`     |          | Question group name (created if new)           |

### List questions in a Quiz set
**Tool:** `edubase_get_quiz_questions`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `quiz`    | [!]      | Quiz identification string |

**Returns:** list of questions with group assignments.

### Remove questions from a Quiz set
**Tool:** `edubase_delete_quiz_questions`

| Parameter   | Required | Notes                                          |
|-------------|----------|------------------------------------------------|
| `quiz`      | [!]      | Quiz identification string                     |
| `questions` | [!]      | Comma-separated question identification strings|
| `group`     |          | Remove from specific group only                |

This detaches questions from the Quiz set. It does NOT delete the questions themselves.

---

## Exam Operations

### Create an Exam
**Tool:** `edubase_post_exam`

| Parameter                  | Required | Type    | Notes                                                     |
|----------------------------|----------|---------|-----------------------------------------------------------|
| `title`                    | [!]      | string  | Exam title shown to students                              |
| `quiz`                     | [!]      | string  | Quiz set identification string (the question source)      |
| `start`                    | [!]      | string  | Start: `YYYY-MM-DD HH:ii:ss` in UTC                       |
| `end`                      | [!]      | string  | End: `YYYY-MM-DD HH:ii:ss` in UTC                         |
| `type`                     |          | string  | `exam` (default) / `homework` / `survey` / `championship` |
| `language`                 |          | string  | ISO 639-1 code                                            |
| `id`                       |          | string  | External unique ID, max 64 chars                          |
| `copy_settings`            |          | string  | Exam ID to clone settings from                            |
| `keep_certificate_settings`|          | boolean | Also copy certificate config (default: false)             |

**Returns:** `{ exam: "<identification string>" }`

### Get Exam details
**Tool:** `edubase_get_exam`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `exam`    | [!]      | Exam identification string |

**Returns:** title, language, quiz (the backing Quiz set), active state, status (INACTIVE/
ACTIVE/PAUSED/REVIEW/EXPIRED), start/end times and deadline (UTC), and Safe Exam Browser links.

### Update an Exam
**Tool:** `edubase_patch_exam` — `exam` [!], plus any of `title`, `description`, `language`, `id`,
`organization`, `start` (only until the first result arrives), `end`, `deadline` (latest start
time) — all date-times in UTC.
The exam `type` cannot be changed.

### Exam settings
**Tools:** `edubase_get_exam_settings` / `edubase_post_exam_settings` (`exam` [!])

Common settings: `timelimit` (seconds or `default`), `pausable`, `nonblocking`, `grading`,
`view_results` (`after` / `always` / `datetime` / `datetime_blind` / `manual` / `none`),
`view_results_start` (UTC), `hide_points`, `hide_grade`, `results_page`, and the `export_*` options.

Copy settings from another exam: `edubase_put_exam_settings(exam, source)` replaces all,
`edubase_patch_exam_settings(exam, source)` fills only unset ones (both accept
`keep_certificate_settings`).

### Allow / stop new attempts
**Tools:** `edubase_get_exam_status` / `edubase_post_exam_status`

| Parameter | Required | Notes                                              |
|-----------|----------|----------------------------------------------------|
| `exam`    | [!]      | Exam identification string                         |
| `status`  | [!]      | `true` = new tests can start, `false` = stop them  |

Only while the exam is active and not yet closed.

### Start a new round
**Tool:** `edubase_post_exam_round` (`exam` [!], optional `force`, `notify`)

Closes running tests, detaches previous results from exam accounts and resets generated
accounts. ⚠️ Irreversible — confirm with the user.

### List all Exams
**Tool:** `edubase_get_exams`

| Parameter | Required | Notes                                    |
|-----------|----------|------------------------------------------|
| `search`  |          | Filter by keyword                        |
| `active`  |          | `true` = active only, `false` = inactive |
| `limit`   |          | Max results (default 16)                 |
| `page`    |          | Page number (not used in search mode)    |

### Delete/archive an Exam
**Tool:** `edubase_delete_exam`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `exam`    | [!]      | Exam identification string |

⚠️ **Destructive.** Results associated with this exam may be lost. Always confirm with user.

### Get skills for an Exam
**Tool:** `edubase_get_exam_skills`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `exam`    | [!]      | Exam identification string |

**Returns:** the skills defined in the Quiz set backing the Exam, each with `identifier`,
`name`, and optional `description`. (Exams inherit skills from their Quiz set — there is
no Exam-level skill configuration.)

---

## Exam User Management

### Assign users to an Exam
**Tool:** `edubase_post_exam_users`

| Parameter | Required | Notes                                          |
|-----------|----------|------------------------------------------------|
| `exam`    | [!]      | Exam identification string                     |
| `users`   | [!]      | Comma-separated user identification strings    |

### Generate exam accounts
**Tool:** `edubase_post_exam_users_generate`

| Parameter  | Required | Notes                                                          |
|------------|----------|----------------------------------------------------------------|
| `exam`     | [!]      | Exam identification string                                     |
| `names`    |          | List of names (one account each); or use `count` (1–500)       |
| `emails`   |          | Emails matching `names`                                        |
| `username` |          | Pattern, e.g. `exam{index}` — required on first use            |
| `password` |          | Pattern, e.g. `{random:8}` — required on first use             |
| `name`     |          | Full-name pattern, e.g. `{Name}` — required on first use       |

Placeholders: `{index}`, `{random:N}`, `{number:N}`, `{name}`, `{Name}`, `{username}` (name pattern only).

### List users assigned to an Exam
**Tool:** `edubase_get_exam_users`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `exam`    | [!]      | Exam identification string |

### Remove users from an Exam
**Tool:** `edubase_delete_exam_users`

| Parameter | Required | Notes                                          |
|-----------|----------|------------------------------------------------|
| `exam`    | [!]      | Exam identification string                     |
| `users`   | [!]      | Comma-separated user identification strings    |

### Enrolling a whole class

There is no direct "assign class to exam" tool. Instead, chain two calls:

1. `edubase_get_class_members(class=<class_id>)` → extract user IDs
2. `edubase_post_exam_users(exam=<exam_id>, users=<comma-separated user IDs>)`

---

## Exam Branding

### Set branding
**Tool:** `edubase_post_exam_branding`

| Parameter | Required | Notes                                                   |
|-----------|----------|---------------------------------------------------------|
| `exam`    | [!]      | Exam identification string                              |
| `image`   | [!]      | Base64-encoded image or URL (PNG/JPEG/WebP)             |
| `type`    |          | `foreground` (logo, default) / `background` (cover)     |
| `color`   | [!]      | `branding`/`red`/`blue`/`yellow`/`green`/`purple`/`gray`|

### Get branding
**Tool:** `edubase_get_exam_branding`

### Remove branding
**Tool:** `edubase_delete_exam_branding`

---

## Tags and Permissions

Generic content tools — pass `type` (`exam` or `quiz`) and `content` (the identification string).

### Tags
| Operation | Tool                         | Extra parameters |
|-----------|------------------------------|------------------|
| Attach    | `edubase_post_content_tag`   | `tag`            |
| List      | `edubase_get_content_tags`   | —                |
| Check     | `edubase_get_content_tag`    | `tag`            |
| Detach    | `edubase_delete_content_tag` | `tag`            |

Find tag identification strings with `edubase_get_tags`.

### Permissions
| Operation | Tool                                | Extra parameters      |
|-----------|-------------------------------------|-----------------------|
| Grant     | `edubase_post_content_permission`   | `user`, `permission`  |
| Check     | `edubase_get_content_permission`    | `user`, `permission`  |
| Revoke    | `edubase_delete_content_permission` | `user`, `permission`  |

Permission levels: `view` / `report` / `control` / `modify` / `grant` / `admin`.

---

## Lookup and Discovery

### Find a user by email, username, or identification string
**Tool:** `edubase_get_user_search`

| Parameter | Required | Notes                                         |
|-----------|----------|-----------------------------------------------|
| `query`   | [!]      | Email, username, or user identification string |

### Get class members
**Tool:** `edubase_get_class_members`

| Parameter | Required | Notes                       |
|-----------|----------|-----------------------------|
| `class`   | [!]      | Class identification string |

Returns names and whether each membership is active.

### Check a question by external ID
**Tool:** `edubase_get_question`

| Parameter | Required | Notes                               |
|-----------|----------|-------------------------------------|
| `id`      | [!]      | External unique question identifier |

For full question content, use `edubase_post_question_export(id=...)`.

### Get a question's external ID from its identification string
**Tool:** `edubase_get_question_id`

| Parameter  | Required | Notes                          |
|------------|----------|--------------------------------|
| `question` | [!]      | Question identification string |

---

## Transfer and Ownership

**Tool:** `edubase_post_content_transfer`

| Parameter | Required | Notes                                  |
|-----------|----------|----------------------------------------|
| `type`    | [!]      | `quiz` or `exam` (or other content)    |
| `content` | [!]      | Identification string of the content   |
| `user`    | [!]      | New owner's user identification string |

⚠️ Irreversible — confirm with the user first.
