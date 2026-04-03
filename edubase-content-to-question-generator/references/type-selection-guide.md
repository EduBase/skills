# Type Selection Guide — Content to Question Type Mapping

This reference helps you choose the best EduBase question type for a given piece of
source content. Use it during Phase 2 (Question Opportunity Plan) of the content importer workflow.

---

## Decision Matrix

### Definitions, Terms, Vocabulary

| Content Pattern | Best Type | Why | Example |
|----------------|-----------|-----|---------|
| Term → definition (unique answer) | TEXT | Fill-in-the-blank; punctuation-insensitive | "The powerhouse of the cell is the ___" → mitochondria |
| Term → definition (exact wording matters) | GENERIC | Full match required | "The chemical symbol for gold is ___" → Au |
| Term → one of several options | CHOICE | Cleaner UX when distractors exist naturally | "Which organelle produces ATP?" |
| Multiple terms → true/false statements | TRUE/FALSE | Efficient for testing misconceptions | "Mitochondria produce DNA. (T/F)" |

### Calculations, Formulas, Numbers

| Content Pattern | Best Type | Why | Parameterize? |
|----------------|-----------|-----|---------------|
| Solve for a numeric value | NUMERIC | Precise numeric evaluation | Yes — replace given values with INTEGER/FLOAT params |
| Evaluate an expression / formula | EXPRESSION | Symbolic evaluation | Yes — use EXPRESSION_VARIABLE |
| Matrix/vector computation | MATRIX | Native matrix support | Sometimes — depends on problem |
| Find a set of values (order irrelevant) | SET | Unordered numeric elements | Rarely |
| Range/interval answer | NUMERIC + NUMERICAL_RANGE | Supports interval notation | Yes |

**Parameterization rules for calculations:**
- Replace 1-2 concrete values with INTEGER or FLOAT parameters
- Keep conceptually important constants as FIX parameters (e.g., `{g; FIX; 9.81}`)
- Add CONSTRAINTS to prevent: division by zero, negative square roots, absurdly large results
- Use FORMULA parameters for intermediate steps the student doesn't see
- Set TOLERANCE when approximate answers are acceptable

### Classifications, Categories, Groupings

| Content Pattern | Best Type | Why | Example |
|----------------|-----------|-----|---------|
| Items belong to categories | GROUPING | Assign items to groups | "Classify: eagle, salmon, frog → Bird, Fish, Amphibian" |
| Items pair one-to-one | PAIRING | Match items together | "Match inventor to invention" |
| Items in correct sequence | ORDER | Sequence matters | "Order the steps of mitosis" |
| One correct from several | CHOICE | Single selection | "Which kingdom does fungi belong to?" |
| Multiple correct from several | MULTIPLE-CHOICE | Multi-select | "Which are mammals? (select all)" |

### Factual Recall, Events, History

| Content Pattern | Best Type | Why | Example |
|----------------|-----------|-----|---------|
| Date/year of an event | DATE/TIME | Calendar-aware evaluation | "When was the Treaty of Versailles signed?" |
| True/false about events | TRUE/FALSE | Efficient for fact-checking | "Napoleon was exiled to Elba in 1814." |
| Identify one correct fact | CHOICE | Clean with good distractors | "Who led the French Revolution?" |
| Chronological ordering | ORDER | Tests temporal understanding | "Order these events chronologically" |
| Match event to person/date | PAIRING | Tests associations | "Match ruler to dynasty" |

### Diagrams, Images, Visual Content

| Content Pattern | Best Type | Why | Example |
|----------------|-----------|-----|---------|
| Labeled diagram → identify parts | HOTSPOT | Spatial interaction | "Click on the mitochondria in the cell diagram" |
| Diagram → name the component | TEXT or CHOICE | When image is context only | "What organ is highlighted in red?" |
| Multiple labels on diagram | GROUPING | Categorize visible elements | "Group these structures: plant cell vs animal cell" |

### Long-form, Analysis, Synthesis

| Content Pattern | Best Type | Why | Example |
|----------------|-----------|-----|---------|
| Open-ended explanation | FREE-TEXT | Needs moderator scoring | "Explain why biodiversity matters" |
| Short written answer | TEXT | Auto-scored, tolerant matching | "Name the process by which plants make food" |
| Read and comprehend passage | READING + follow-ups | Non-assessed display then questions | Present the passage, then ask questions about it |
| File-based submission | FILE | Upload evaluation | "Submit your lab report" |

---

## Combining Types for Rich Assessments

For a single source section, aim for type diversity. Example for a physics chapter on "Forces":

| Question | Type | Tests |
|----------|------|-------|
| "What is Newton's Second Law?" | TEXT | Recall |
| "Calculate force given mass and acceleration" | NUMERIC (parameterized) | Application |
| "Which of these is NOT a contact force?" | CHOICE | Conceptual understanding |
| "Classify forces as contact or non-contact" | GROUPING | Categorization |
| "True or false: gravity only acts on heavy objects" | TRUE/FALSE | Misconception correction |
| "Order the steps to draw a free-body diagram" | ORDER | Procedural knowledge |

This gives 6 questions, 6 different types, testing 6 different cognitive levels.

---

## Parameterization Opportunity Checklist

Ask yourself for each question:

1. Does the question contain concrete numeric values? → Consider INTEGER/FLOAT params
2. Are those values arbitrary (could be any reasonable number)? → Parameterize them
3. Are those values conceptually significant (speed of light, Avogadro's number)? → Keep as FIX
4. Does the answer depend on a formula? → Use FORMULA param for intermediate calculations
5. Can the answer become negative, zero, or absurdly large? → Add CONSTRAINTS
6. Does the question have multiple valid configurations? → Consider LIST or PERMUTATION params

### Example: Parameterizing a physics problem

**Source text**: "A car traveling at 60 km/h brakes and stops in 4 seconds. What is the deceleration?"

**Static version**:
- QUESTION: A car traveling at 60 km/h brakes and stops in 4 seconds. What is the deceleration in m/s^2?
- ANSWER: 4.17
- TYPE: NUMERIC

**Parameterized version**:
- QUESTION: A car traveling at {v} km/h brakes and stops in {t} seconds. What is the deceleration in m/s^2?
- ANSWER: ~~~{v}/3.6/{t}~~~
- TYPE: NUMERIC
- PARAMETERS: {v; INTEGER; 30; 120} &&& {t; INTEGER; 2; 10}
- CONSTRAINTS: {v}/3.6/{t}<20
- DECIMALS: 2
- TOLERANCE: ABSOLUTE:0.1

This single question now generates hundreds of unique variants.

---

## Types to Avoid (and when)

| Situation | Avoid | Use Instead | Why |
|-----------|-------|-------------|-----|
| Short factual answer, few words | GENERIC | TEXT | GENERIC requires exact punctuation match — frustrating |
| Only 2 options exist | CHOICE | TRUE/FALSE | 50% guess rate with CHOICE; T/F handles binary naturally |
| Ordering with >8 items | ORDER | GROUPING or break into parts | Too many items = frustrating drag-and-drop |
| Image required but unavailable | HOTSPOT | CHOICE or TEXT describing the image | Can't do HOTSPOT without an image file |
| Complex multi-step problem | NUMERIC alone | NUMERIC + READING (show steps) | Use READING type to present context, then NUMERIC to test |
