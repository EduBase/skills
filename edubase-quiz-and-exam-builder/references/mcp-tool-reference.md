# MCP Tool Reference — Quiz & Exam Operations

Quick lookup for the exact MCP tool to use for each operation. Parameters marked [!] are
required.

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
| `type`           |          | string | `set` (default) / `exam` / `private`                   |
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

### Delete/archive a Quiz set
**Tool:** `edubase_delete_quiz`

| Parameter | Required | Notes                      |
|-----------|----------|----------------------------|
| `quiz`    | [!]      | Quiz identification string |

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
| `open`                     | [!]      | string  | Start: `YYYY-MM-DD HH:ii:ss` in UTC                       |
| `close`                    | [!]      | string  | End: `YYYY-MM-DD HH:ii:ss` in UTC                         |
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

**Returns:** exam ID, name, quiz (the backing Quiz set), active status, status (INACTIVE/
ACTIVE/PAUSED/REVIEW/EXPIRED), start/end times.

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

---

## Exam User Management

### Assign users to an Exam
**Tool:** `edubase_post_exam_users`

| Parameter | Required | Notes                                          |
|-----------|----------|------------------------------------------------|
| `exam`    | [!]      | Exam identification string                     |
| `users`   | [!]      | Comma-separated user identification strings    |

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
**Tool:** `edubase_post_exam_branding` (if available)

| Parameter | Required | Notes                                                   |
|-----------|----------|---------------------------------------------------------|
| `exam`    | [!]      | Exam identification string                              |
| `type`    |          | `foreground` (logo, default) / `background` (cover)     |
| `image`   | [!]      | Base64-encoded image or URL (PNG/JPEG/WebP)             |
| `color`   | [!]      | `branding`/`red`/`blue`/`yellow`/`green`/`purple`/`gray`|

### Get branding
**Tool:** `edubase_get_exam_branding` (if available)

### Remove branding
**Tool:** `edubase_delete_exam_branding` (if available)

If branding tools are not exposed via MCP, guide the user to the EduBase web UI.

---

## Tags and Permissions

### Tags
| Operation | Exam tool                     | Quiz tool                    |
|-----------|-------------------------------|------------------------------|
| Attach    | `edubase_post_exam_tag`       | `edubase_post_quiz_tag`      |
| List      | `edubase_get_exam_tags`       | `edubase_get_quiz_tags`      |
| Detach    | `edubase_delete_exam_tag`     | `edubase_delete_quiz_tag`    |

All take `exam`/`quiz` + `tag` identification strings.

### Permissions
| Operation | Exam tool                          | Quiz tool                         |
|-----------|------------------------------------|-----------------------------------|
| Grant     | `edubase_post_exam_permission`     | `edubase_post_quiz_permission`    |
| Check     | `edubase_get_exam_permission`      | `edubase_get_quiz_permission`     |
| Revoke    | `edubase_delete_exam_permission`   | `edubase_delete_quiz_permission`  |

All take `exam`/`quiz` + `user` + `permission` (level: view/report/control/modify/grant/admin).

---

## Lookup and Discovery

### Find a user by email, username, or code
**Tool:** `edubase_get_user_search`

| Parameter | Required | Notes                     |
|-----------|----------|---------------------------|
| `search`  | [!]      | Email, username, or code  |

### Get class members
**Tool:** `edubase_get_class_members`

| Parameter | Required | Notes                       |
|-----------|----------|-----------------------------|
| `class`   | [!]      | Class identification string |

### Get question by external ID
**Tool:** `edubase_get_question`

| Parameter | Required | Notes                              |
|-----------|----------|------------------------------------|
| `id`      | [!]      | External unique question identifier|

### Get question internal ID from external ID string
**Tool:** `edubase_get_question_id`

| Parameter       | Required | Notes                                |
|-----------------|----------|--------------------------------------|
| `identification`| [!]      | Question identification string       |

---

## Transfer and Ownership

### Transfer Quiz set to another user
**Tool:** `edubase_post_quiz_transfer`

| Parameter | Required | Notes                            |
|-----------|----------|----------------------------------|
| `quiz`    | [!]      | Quiz identification string       |
| `user`    | [!]      | New owner user identification    |

### Transfer Exam to another user
**Tool:** `edubase_post_exam_transfer`

| Parameter | Required | Notes                            |
|-----------|----------|----------------------------------|
| `exam`    | [!]      | Exam identification string       |
| `user`    | [!]      | New owner user identification    |
