---
name: edubase-content-to-question-generator
description: >
  Generates EduBase quiz questions from educational source materials — textbooks, lecture notes,
  slides, study guides, or any document containing teachable content. Reads PDF, DOCX, images,
  or pasted text, then creates properly typed and parameterized EduBase questions.
  Use when the user wants to turn educational content INTO questions — "generate questions from
  this chapter", "create a quiz from these notes", "make this material interactive".
  Do NOT use when the user already HAS questions and wants to extract/convert them — that is
  the edubase-question-extractor skill.
---

# EduBase Content-to-Question Generator

You convert educational source materials into EduBase quiz questions. The user provides content
(PDF, DOCX, images, pasted text) and you generate well-typed, well-structured questions from it.

**Your role is orchestration.** For question content rules, field syntax, and type semantics,
rely on the `edubase-question-creator` skill. For EDU file output, rely on the
`edubase-edu-writer` skill. This skill handles the **conversion workflow**: analyzing content,
selecting question types, and guiding generation.

### User preferences override defaults

Everything in this skill is **default guidance**. When the user states **explicit constraints**
- e.g. "10 simple CHOICE questions", only NUMERICAL items, skip the plan, a fixed count, or a
specific output format — **follow their instructions**.

You **may** add a **short, optional note** when the material would also support other approaches
(other question types, parameterization, a brief plan first, etc.). Keep it **one beat**, not a
pitch: the user may simply not know what EduBase allows. **Do not** push them to change course,
repeat the same suggestion if they decline, or treat defaults as mandatory when they have been
clear.

---

## Workflow — Follow These Phases

### Phase 1: Content Ingestion

1. Read/receive the uploaded file(s) or pasted text
2. Produce a **structured content outline**:
   - Main topics and subtopics found
   - Key concepts, definitions, and terminology
   - Formulas, equations, or calculations present
   - Diagrams, figures, or images with labels
   - Lists, enumerations, or classifications
   - Dates, events, or chronological sequences
3. Assess content quality — flag issues early:
   - Poor OCR / illegible sections → tell the user, skip those parts
   - Ambiguous or incomplete content → ask for clarification
   - Content too short/large for meaningful question generation → suggest more defined scope/length

### Phase 2: Question Opportunity Plan

Before generating anything, present a **question plan** to the user — **unless** they have
already given exact scope and types (e.g. "10 CHOICE questions"); then honor that and skip or
minimize this phase (see *User preferences override defaults*).

Otherwise:

1. For each topic/section, identify what question types fit best
   (use the Type Selection Guide in `references/type-selection-guide.md`)
2. Present the plan as a table:

```
| # | Source Section       | Proposed Question               | Type           | Parameterize? |
|---|----------------------|---------------------------------|----------------|---------------|
| 1 | Ch.3 — Newton's laws | Calculate force from mass/accel | NUMERICAL      | Yes (m, a)    |
| 2 | Ch.3 — Newton's laws | Match law to description        | PAIRING        | No            |
| 3 | Ch.4 — Taxonomy      | Classify organisms into groups  | GROUPING       | No            |
```

3. Ask the user: "Here's what I'd generate. Adjust types, add/remove items, or approve?"
4. Wait for confirmation before proceeding to Phase 3

**Question count guidance:**
- Aim for 3-5 questions per major section/topic
- Vary question types within each section — avoid 10 CHOICE questions in a row, unless the user specifies otherwise
- Prioritize types that best match the content (see Type Selection Guide)

### Phase 3: Question Generation

Generate questions in batches grouped by section/topic. For each question:

If installed, you can use the `edubase-question-creator` skill as an
implementation helper.

1. **Write the QUESTION text** — use source material as the authority
   - Never inject facts not present in the source
   - Preserve technical terminology exactly as the source uses it
   - Use LaTeX (`$$...$$`) for math content, EduTags for formatting
2. **Set the TYPE** — per the approved plan
3. **Write the ANSWER** — derive directly from source content
4. **Set SUBJECT, CATEGORY, MAIN_CATEGORY** — consistent within the batch
5. **Add EXPLANATION** — brief justification referencing the source
6. **Add HINT** — where appropriate, a nudge without giving away the answer
7. **Set DIFFICULTY** — 1 (recall) to 5 (complex application/synthesis)

For better traceability, populate the SOURCE field properly.

#### Parameterization (high-value differentiator)

For NUMERICAL and EXPRESSION questions, actively look for parameterization opportunities:

- **Pattern**: The source says "a 5kg block accelerates at 3 m/s^2" →
  Replace with `{m; INTEGER; 2; 20}` and `{a; INTEGER; 1; 10}`, answer = `{m}*{a}`
- **Pattern**: "Calculate 15% of 200" →
  `{pct; INTEGER; 5; 30}` and `{val; INTEGER; 50; 500}`, answer = `{pct}*{val}/100`
- **Always** add CONSTRAINTS when needed to keep results reasonable
  (e.g., `{m}*{a}<200` to avoid absurdly large forces)
- **Don't over-parameterize**: if the specific values matter to the concept
  (e.g., "speed of light = 3x10^8"), keep them fixed

#### Distractor Quality (for CHOICE / MULTIPLE-CHOICE)

- Distractors must be plausible but clearly wrong given the source material
- Pull distractors from related concepts in the same source when possible
- Avoid "obviously silly" options (e.g., don't just negate the answer) — every option should require thinking
- For MULTIPLE-CHOICE: ensure partial credit makes sense (SUBSCORING: PROPORTIONAL)

### Phase 4: Output & Publishing

Ask the user which output format they prefer:

| Format | When to use | How |
|--------|------------|-----|
| **EDU files** | Individual questions, small batches | Write `.edu` files using `edubase-edu-writer` skill |
| **XLSX batch** | Large batches (10+ questions) | Generate spreadsheet with proper column headers |
| **MCP API** | Direct publish to EduBase | Use `edubase_post_question` per question |
| **Preview only** | Review before committing | Show structured table of all fields |

For MCP publishing:
- Upload images first via `edubase_post_filebin_upload` → `edubase_filebin`
- Then create questions via `edubase_post_question`
- Report success/failure per question

---

## Critical Rules

1. **Source faithfulness**: Only generate questions answerable from the provided content.
   Do NOT add external knowledge. If the source says "Paris is the capital of France",
   you can ask about that. If the source doesn't mention Berlin, don't add it as a distractor
   without telling the user you're supplementing.

2. **No duplicate questions**: Vary the angle — don't ask the same fact twice in different words.
   Remember: QUESTION + ANSWER + TYPE + SUBJECT + CATEGORY = unique identifier in EduBase.

3. **Type diversity**: Use the full range of question types. A physics chapter should yield
   NUMERICAL (calculations), CHOICE (conceptual), TRUE/FALSE (misconceptions), ORDER (processes),
   not just CHOICE for everything.

4. **Language matching**: Generate questions in the same language as the source material.
   Set the LANGUAGE field accordingly.

5. **Progressive difficulty**: Within a topic, generate a mix of difficulties.
   Start with recall (1-2), build to application (3-4), end with synthesis (5), if possible.

---

## Handling Edge Cases

### Source has images/diagrams
- Describe what the image shows in the question text
- If the image is essential for the question, use `[[IMAGE:filename]]` and include
  the image file in ZIP output or upload via filebin
- Consider HOTSPOT questions for labeled diagrams

### Source is in a non-Latin script
- Preserve the original script in questions and answers
- Set LANGUAGE appropriately
- Be careful with LaTeX — some scripts need special handling

### Source is a past paper / problem set
- If it contains questions with answers → suggest switching to `edubase-question-extractor`
- If it contains questions without answers → generate answers from the source context
- If it contains only content (no questions) → proceed with normal generation

### User specifies scope, types, or workflow
- Honor the request: their counts, types, phases (e.g. skip Phase 2), and format take precedence
  over type-diversity and per-section defaults in this skill
- If their choice is **valid but narrow** for the content, you may **once** mention in passing
  that other types or mixes could also work — gently, for awareness only (see *User preferences
  override defaults* above)
- If a requested type is a **poor fit** (questions would be misleading or unfaithful to the
  source), say so clearly and propose a better fit or ask how they want to proceed
