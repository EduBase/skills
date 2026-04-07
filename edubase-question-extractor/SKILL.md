---
name: edubase-question-extractor
description: >
  Extracts existing questions from documents into EduBase format — faithfully converting
  past papers, printed exams, question banks, worksheets, or any document that ALREADY
  CONTAINS questions into properly structured EduBase questions. Reads PDF, DOCX, PPT, images,
  or pasted text that contains questions and extracts them as-is.
  Use when the user already HAS questions and wants to extract/import/convert them —
  "extract questions from this exam", "convert these questions to EduBase", "import this
  past paper", "upload these existing questions". Do NOT use when the user wants to GENERATE
  new questions from educational content — that is the edubase-content-to-question-generator skill.
---

# EduBase Question Extractor

You faithfully extract existing questions from documents into EduBase format. The user provides
a file (e.g., PDF, DOCX, PPT, image, pasted text) that **already contains questions**, and you extract
and structure them for EduBase — preserving the original intent, wording, and answers exactly.

**Your role is faithful extraction, not creative generation.** For question content rules,
field syntax, and type semantics, rely on the `edubase-question-creator` skill. For EDU file
output, rely on the `edubase-edu-writer` skill. This skill handles the **extraction workflow**:
parsing questions from documents, recognizing their types, and mapping them to EduBase fields.

---

## Workflow — Follow These Phases

### Phase 1: Document Parsing

1. Read/receive the uploaded file(s) or pasted text
2. Extract every question found in the document:
   - Question text (preserve original wording exactly)
   - Answer(s) if provided (answer keys, solutions, marking schemes)
   - Options/choices if present
   - Point values if shown
   - Question numbering / grouping structure
   - Any images, diagrams, or figures associated with questions
   - Some questions may be in a different language than the document
   - Some questions may be a composite of different question types
3. Assess parsing quality — flag issues:
   - Illegible or garbled text (poor scan quality) → show what you can read, mark uncertain parts
   - Questions that span page breaks → reassemble them
   - Ambiguous question boundaries → ask the user
   - Missing answer keys → note which questions lack answers

### Phase 2: Recognition & Mapping

For each extracted question, determine the best EduBase type using the
Type Recognition Guide in `references/type-recognition-guide.md`.

Present the extraction results as a verification table:

```
| # | Original Question (truncated)        | Detected Type    | Answer Found? | Confidence |
|---|--------------------------------------|------------------|---------------|------------|
| 1 | "What is the capital of France?"     | CHOICE           | Yes (Paris)   | High       |
| 2 | "Calculate the area of..."           | NUMERICAL        | Yes (42 m^2)  | High       |
| 3 | "Explain why photosynthesis..."      | FREE-TEXT         | No            | Medium     |
| 4 | [illegible section]                  | ???              | ???           | Low        |
```

- **High confidence**: Question text clear, type obvious, answer found
- **Medium confidence**: Question text clear, but type ambiguous or answer missing
- **Low confidence**: Parsing issues, needs user verification

Ask the user: "I extracted N questions. Please verify the mapping, especially items marked
Medium/Low confidence. Should I proceed?"

### Phase 3: Faithful Conversion

Convert each verified question into EduBase format. **Preservation rules:**

If installed, you can use the `edubase-question-creator` skill as an
implementation helper.

1. **Question text**: Use the original wording. Only modify for:
   - Formatting adaptation (apply EduTags / LaTeX where the original uses bold, math, etc.)
   - Fixing obvious typos IF the user approves
   - Never rephrase, simplify, or "improve" the question
2. **Answers**: Transcribe exactly as given in the source
   - If the source says "approximately 4.17", use `4.17` with appropriate TOLERANCE
   - If the source provides a formula as the answer, decide: NUMERICAL vs EXPRESSION
   - If the source shows multiple acceptable answers, use `&&&` separator
3. **Options/choices**: Preserve all options in their original form
   - Keep the original order information (use OPTIONS_FIX if order was meaningful)
   - Mark the correct answer(s) as ANSWER, wrong ones as OPTIONS
4. **Point values**: Map to POINTS column
5. **Difficulty**: Infer from source context if not explicit (exam position, point value, etc.)

#### Type-Specific Conversion Rules

**Multiple choice in source → CHOICE or MULTIPLE-CHOICE**
- Single correct answer → CHOICE
- "Select all that apply" / multiple correct → MULTIPLE-CHOICE
- Transcribe all options; correct → ANSWER, wrong → OPTIONS

**Fill-in-the-blank in source → TEXT (usually) or GENERIC**
- Blanks with word/phrase answers → TEXT (more forgiving)
- Blanks requiring exact notation (chemical formulas, codes) → GENERIC
- If multiple blanks in one question → multiple answers with `&&&`, add ANSWER_LABEL

**Calculation / numeric answer in source → NUMERICAL**
- Transcribe the numeric answer
- If the source gives units, include unit guidance in NOTE or in ANSWER_LABEL
- If the source shows a formula, consider parameterizing (ask user first)
- Set DECIMALS to match the source's expected precision

**True/False in source → TRUE/FALSE**
- True statements → ANSWER
- False statements → OPTIONS
- If source has "explain why" after T/F → consider splitting into TRUE/FALSE + FREE-TEXT

**Matching / pairing in source → PAIRING**
- Left column → ANSWER_LABEL, right column → ANSWER
- Or use `item >>> target` syntax in ANSWER

**Sorting / ordering in source → ORDER**
- Transcribe items in the correct order in ANSWER
- They'll be randomized for the student

**Classify / group items in source → GROUPING**
- Items → ANSWER_LABEL, groups → ANSWER
- Or use `item >>> group` syntax

**Essay / long answer in source → FREE-TEXT**
- Set FREETEXT_CHARACTERS or FREETEXT_WORDS if the source specifies length
- If the source has a rubric/keywords, encode as FREETEXT_RULES
- If an answer key exists, put it in SOLUTION (not ANSWER — FREE-TEXT answers are moderated)

**Diagram-based in source → HOTSPOT or CHOICE/TEXT**
- If the original requires pointing at an image → HOTSPOT
  (you'll need the image file and zone coordinates)
- If the image is just context → CHOICE or TEXT with `[[IMAGE:filename]]`

### Phase 4: Output & Publishing

Same output options as the content-to-question generator:

| Format | When to use | How |
|--------|------------|-----|
| **EDU files** | Individual questions, small batches | Write `.edu` files using `edubase-edu-writer` |
| **XLSX batch** | Large batches (10+ questions) | Generate spreadsheet with proper column headers |
| **MCP API** | Direct publish to EduBase | Use `edubase_post_question` per question |
| **Preview only** | Review before committing | Show structured table of all fields |

---

## Critical Rules

1. **Faithfulness above all**: This is extraction, not generation. The user's questions
   are the authority. Do not improve, simplify, or "enhance" unless explicitly asked.

2. **Missing answers are OK**: Not every source has an answer key. For questions without
   answers, mark them clearly and ask the user. Do not guess answers.

3. **Preserve difficulty signals**: If the source organizes questions by section (easy → hard),
   or assigns point values, use those signals for DIFFICULTY and POINTS.

4. **Language preservation**: Extract in the source language. Don't translate.
   Set LANGUAGE field to match the source.

5. **Image handling**: If questions reference figures/diagrams:
   - Note which questions need which images
   - If the image is in the uploaded file, extract/reference it
   - If the image is missing, flag it — don't proceed without it for HOTSPOT types

---

## Handling Edge Cases

### Source has questions but no clear answer key
- Extract all questions with type mapping
- Leave ANSWER blank for questions you can't determine
- Present to user: "These N questions have no answer key. Would you like me to:
  (a) Leave answers blank for you to fill in, or (b) attempt to derive answers from
  the question context?"
- Option (b) should be offered cautiously and only for factual/objective questions

### Source mixes questions with educational content
- Extract only the questions, not the surrounding content
- If unsure whether something is a question or explanatory text, ask the user
- Suggest: "There's also educational content here that could generate additional questions.
  Want me to switch to the `edubase-content-to-question-generator` for those sections?"

### Source has questions in multiple formats on one page
- Handle each question independently — detect the type per question
- A single exam can yield CHOICE, NUMERICAL, FREE-TEXT, and TRUE/FALSE questions

### Source quality is poor (bad scan, handwriting)
- Show what you can parse, mark uncertain text with `[unclear: best guess]`
- Ask the user to verify before converting
- Never silently guess at illegible content

### Source has sub-questions (a, b, c under one stem)
- Each sub-question becomes its own EduBase question
- Copy the stem to each question (or use READING type for the stem + separate questions)
- Maintain grouping via the GROUPING column (same group number)
- Prefix sub-questions: "Part (a): ...", "Part (b): ..."
