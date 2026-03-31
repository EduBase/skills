# Type Recognition Guide — Identifying Question Types in Source Documents

This reference helps you recognize what EduBase question type an existing question maps to,
based on how it appears in the source document. Use it during Phase 2 (Recognition & Mapping)
of the content digitizer workflow.

---

## Recognition Patterns

### Pattern: Numbered options with one correct answer

**Looks like:**
```
What is the capital of France?
a) London    b) Paris    c) Berlin    d) Madrid
```
or
```
Which of the following is correct?
A. Statement one
B. Statement two
C. Statement three
```

**Maps to:** CHOICE
- ANSWER = the correct option text (e.g., "Paris")
- OPTIONS = all wrong option texts, `&&&` separated

**Watch out for:**
- "Choose TWO" / "Select all that apply" → MULTIPLE-CHOICE instead
- Only 2 options that are True/False → TRUE/FALSE instead

---

### Pattern: Multiple options, multiple correct

**Looks like:**
```
Which of the following are mammals? (Select all that apply)
[ ] Eagle    [ ] Dolphin    [ ] Shark    [ ] Bat    [ ] Salmon
```

**Maps to:** MULTIPLE-CHOICE
- ANSWER = all correct options, `&&&` separated
- OPTIONS = all wrong options, `&&&` separated
- Consider MAXIMUM_CHOICES if the source limits selections

---

### Pattern: True/False or Yes/No statements

**Looks like:**
```
Mark each statement as True or False:
1. The Earth orbits the Sun. ___
2. Sound travels faster than light. ___
3. Water boils at 100C at sea level. ___
```

**Maps to:** TRUE/FALSE
- ANSWER = true statements, `&&&` separated
- OPTIONS = false statements, `&&&` separated
- If there's a "Not sure" / "Cannot determine" option → TRUEFALSE_THIRD_OPTIONS

---

### Pattern: Blank line or box for a short answer

**Looks like:**
```
The process by which plants convert sunlight to energy is called _____________.
```
or
```
Name the largest planet in our solar system: ___________
```

**Maps to:** TEXT (default) or GENERIC
- Use TEXT for most fill-in-the-blank (punctuation/spacing forgiven)
- Use GENERIC only if exact character-level matching is required
  (chemical formulas like "H2SO4", code syntax, formal notation)
- Multiple blanks in one question → multiple answers with `&&&` + ANSWER_LABEL

---

### Pattern: Calculate / compute / solve (numeric answer expected)

**Looks like:**
```
Calculate the kinetic energy of a 5 kg object moving at 3 m/s.
```
or
```
Solve: 3x + 7 = 22. What is x?
```

**Maps to:** NUMERIC
- ANSWER = the numeric value
- Set DECIMALS based on expected precision
- If the source accepts a range → NUMERICAL_RANGE=+
- Consider TOLERANCE for approximate answers (e.g., physics calculations)

**Parameterization opportunity:** If the specific values (5 kg, 3 m/s) are arbitrary,
offer to parameterize. But ask the user first — this is digitization, not generation.

---

### Pattern: Write an expression / formula as the answer

**Looks like:**
```
Simplify: (x + 2)(x - 3)
```
or
```
Find f'(x) if f(x) = 3x^2 + 2x - 1
```

**Maps to:** EXPRESSION
- ANSWER = the simplified expression
- EXPRESSION_VARIABLE = the variable(s) used
- EXPRESSION_CHECK = RANDOM (default) or EXPLICIT if source provides test values

---

### Pattern: Put items in order / rank / sequence

**Looks like:**
```
Arrange the following events in chronological order:
- World War II ends
- Moon landing
- Fall of Berlin Wall
- Internet invented
```

**Maps to:** ORDER
- ANSWER = items in correct order, `&&&` separated
- EduBase will randomize the display order

---

### Pattern: Match items in two columns

**Looks like:**
```
Match each scientist with their discovery:
Newton        ___    Gravity
Darwin        ___    Evolution
Einstein      ___    Relativity
```

**Maps to:** PAIRING
- ANSWER = right column targets, `&&&` separated
- ANSWER_LABEL = left column items, `&&&` separated
- Or use `item >>> target` syntax

---

### Pattern: Sort items into categories / groups

**Looks like:**
```
Classify the following as "Renewable" or "Non-renewable":
Solar, Coal, Wind, Natural Gas, Hydroelectric, Oil
```

**Maps to:** GROUPING
- Use `item >>> group` syntax in ANSWER
- e.g., `Solar >>> Renewable &&& Coal >>> Non-renewable &&& ...`

---

### Pattern: Date or year as the answer

**Looks like:**
```
When did the French Revolution begin?
In what year was the Declaration of Independence signed?
```

**Maps to:** DATE/TIME
- ANSWER = the date value
- DATETIME_PRECISION = YEAR / MONTH / DAY depending on expected precision
- For date ranges → DATETIME_RANGE=+

---

### Pattern: Long written response expected

**Looks like:**
```
Explain the causes of World War I in 200-300 words.
```
or
```
Discuss the advantages and disadvantages of nuclear energy. (10 marks)
```

**Maps to:** FREE-TEXT
- FREETEXT_WORDS or FREETEXT_CHARACTERS if length is specified
- If rubric/marking criteria exist → encode as FREETEXT_RULES
- Put model answer (if available) in SOLUTION, not ANSWER
- MANUAL_SCORING = ALWAYS or NOT_CORRECT (needs human moderator)

---

### Pattern: Click/identify on an image or diagram

**Looks like:**
```
[DIAGRAM: human body organs]
Identify the location of the liver in the diagram above.
```

**Maps to:** HOTSPOT
- Requires the actual image file
- HOTSPOT_IMAGE = image filename
- HOTSPOT_ZONES = zone coordinates (you'll need to estimate or ask the user)
- ANSWER = zone name(s)

**If image is unavailable:** Convert to TEXT or CHOICE instead and note the limitation.

---

### Pattern: Matrix or vector answer

**Looks like:**
```
Calculate A x B where A = [1 2; 3 4] and B = [5; 6]
```

**Maps to:** MATRIX or MATRIX:EXPRESSION
- ANSWER = result in `[col1; col2 | row2col1; row2col2]` format
- Use MATRIX:EXPRESSION if cells contain expressions

---

### Pattern: Set of values (order doesn't matter)

**Looks like:**
```
List all prime numbers between 10 and 30.
```

**Maps to:** SET (numeric) or SET:TEXT (text)
- ANSWER = elements `&&&` separated
- Order and repetition are ignored during evaluation

---

### Pattern: Upload / submit a file

**Looks like:**
```
Submit your completed lab report as a PDF.
Upload your program code.
```

**Maps to:** FILE
- FILE_COUNT = number of files expected
- FILE_TYPES = accepted file extensions
- MANUAL_SCORING = ALWAYS

---

### Pattern: Read this passage (no question, just context)

**Looks like:**
```
Read the following passage carefully, then answer questions 5-8 below.
[long text passage]
```

**Maps to:** READING (for the passage itself)
- READING type = non-assessed display
- Followed by actual questions (CHOICE, TEXT, etc.) that reference the passage
- Group them using the GROUPING column

---

## Ambiguous Cases — Decision Tree

When a question could map to multiple types:

```
Is it multiple choice with options listed?
  YES → Are there multiple correct answers?
    YES → MULTIPLE-CHOICE
    NO  → CHOICE
  NO  → Does it expect a number?
    YES → Is it a formula/expression?
      YES → EXPRESSION
      NO  → NUMERIC
    NO  → Does it expect a date?
      YES → DATE/TIME
      NO  → Is it fill-in-the-blank (short)?
        YES → TEXT (or GENERIC if exact match needed)
        NO  → Is it long-form writing?
          YES → FREE-TEXT
          NO  → Is it ordering/ranking?
            YES → ORDER
            NO  → Is it matching/pairing?
              YES → PAIRING
              NO  → Is it classifying/grouping?
                YES → GROUPING
                NO  → Is it True/False?
                  YES → TRUE/FALSE
                  NO  → TEXT (safe default)
```

When genuinely uncertain, mark as Medium confidence and ask the user.
