# Compliance Training Playbook

Use this reference when generating questions from **policy, regulatory, or mandatory training**
materials. It supplements the general workflow in `SKILL.md` and overrides educational defaults
(see *Defaults overridden in compliance mode* below).

**Activation:** Apply when compliance-related source is detected **or** the user explicitly asks
for compliance/policy/mandatory-training questions. **Always confirm with the user** before
switching into compliance mode — detection is a suggestion, not automatic lock-in.

---

## Detecting Compliance-Related Source

Treat material as **likely compliance-related** when several signals align (not one keyword alone):

| Signal type | Examples |
|-------------|----------|
| **Title / filename** | `Code_of_Conduct`, `GDPR_Training`, `Annual_Compliance`, `Policy_v2.3` |
| **Vocabulary** | policy, compliance, mandatory, regulation, statutory, obligation, shall/must, breach, whistleblowing, consent, retention, incident reporting |
| **Regulations / frameworks** | GDPR, HIPAA, SOX, PCI-DSS, ISO 27001, OSHA, FCPA, local labor law |
| **Slide / doc structure** | "All employees must…", effective dates, version footers, legal disclaimers, acknowledgment slides |
| **User intent** | "compliance quiz", "policy test", "certification exam from this deck", "mandatory training assessment" |

When detected, say something like:

> "This looks like compliance/policy training material. I can follow the **compliance playbook**
> (coverage-focused questions, scenario items, strict source traceability). Should I use that
> approach, or stick to general educational defaults?"

Wait for confirmation (or explicit prior instruction) before applying compliance defaults.

---

## Industry & Role Context (ask the user)

Compliance scenarios often land better when examples match the learner's job. **After** compliance
mode is confirmed (or in the same confirmation message), ask:

> "Should scenario-based questions use examples tailored to a specific **role or department**
> (e.g. HR, IT, Sales, Finance)? Or keep examples generic / exactly as written in the source?"

| User answer | Behavior |
|-------------|----------|
| **Specific role/industry** | Frame CHOICE/scenario stems around that context **only when** the source supports it or the obligation is role-agnostic. Do not invent role-specific facts not in the source. |
| **Generic / as in source** | Use neutral wording; quote policy language where possible. |
| **Mixed** | Generic recall questions + role-specific scenarios where the source allows application. |

If the user wants role-specific scenarios but the source is silent on that role, **say so** and
offer: (a) generic scenario, (b) user supplies supplementary context, or (c) labeled illustrative
example clearly marked as application of a stated rule (not a new rule).

---

## Defaults Overridden in Compliance Mode

These replace the general *Question count guidance* and *Type diversity* rules in `SKILL.md`:

| General default | Compliance default |
|-----------------|-------------------|
| 3–5 questions per section | **Coverage-first:** at least one question per substantive policy section/slide group; add more for high-risk or dense sections |
| Vary types within each section | **Fit over variety:** repeat CHOICE/TRUE-FALSE on critical obligations if needed; use ORDER for procedures, READING for long policy text + follow-ups |
| Progressive difficulty mix | **Risk-weighted:** must-know obligations → higher difficulty and scenario application; boilerplate/definitions → recall (1–2) |
| Parameterization for calculations | Rare in compliance; only when source includes numeric rules (retention periods, thresholds, deadlines) |

---

## Coverage Matrix (Phase 2)

In compliance mode, extend the question plan with a **coverage summary**:

```
| Section / Slide range | Substantive? | Questions planned | Gap? |
|-----------------------|--------------|-------------------|------|
| Slides 1–2 (intro)    | No — skip    | 0                 | —    |
| Slides 3–5 (GDPR Art.6)| Yes         | 3                 | —    |
| Slide 6 (exceptions)  | Yes          | 1                 | ⚠ thin — add scenario? |
```

Flag:

- **Gaps** — substantive section with zero questions
- **Thin coverage** — single T/F on a multi-rule slide
- **Ambiguous slides** — bullets without full context, conflicting shall/should, exception clauses → mark for user review before generation

Ask: "Any sections that must have more questions, or any slides to exclude (title/disclaimer only)?"

---

## Question Patterns for Compliance

| Content pattern | Preferred type | Notes |
|-----------------|----------------|-------|
| Absolute rule ("must report within 24h") | TRUE/FALSE or CHOICE | Distractors = plausible near-violations from same source |
| Procedure steps | ORDER | Keep ≤ 6–8 steps; split if longer |
| Long policy paragraph | READING + CHOICE/T-F follow-ups | Present text, then assess understanding |
| "Select all that apply" obligations | MULTIPLE-CHOICE | SUBSCORING: PROPORTIONAL |
| Definition of a regulated term | TEXT or CHOICE | Preserve exact terminology from source |
| "What should you do if…?" | CHOICE | Scenario stem; answer must follow source only |
| Role-specific handling | CHOICE | Only after user confirms role context (see above) |
| Labeled process diagram | HOTSPOT or CHOICE | Prefer image from slide export when available |

### Distractor quality (compliance)

- Pull distractors from **related rules in the same document** — common failure mode is confusing two similar obligations.
- Prefer **near-miss violations** (wrong timeframe, wrong recipient, wrong exception) over absurd options.
- Never add a distractor from external law or industry practice unless the user approved supplementation.

### Language nuance

- Preserve **shall / must / should / may** exactly as the source uses them.
- If a slide is ambiguous (e.g. exception not on the same slide), **do not** generate a definitive question — flag for user or ask a recall question about what the slide explicitly states.

---

## Versioning & Policy Updates

When file metadata or slide footers expose version info (e.g. "Policy v2.3", "Effective 2024-01-15"):

- Record it in every question's `SOURCE` field (see `source-traceability.md`).
- Note in the plan if the deck looks **dated** or **version-mismatched** across files.

This skill does **not** manage exam deployment or deprecation of old questions — but generated
`SOURCE` values should make it easy to filter or replace questions when policy updates.

---

## Assessment Intent (optional user question)

If not already clear, ask once:

> "Is this a **certification-style** assessment (learners must demonstrate mastery) or an
> **awareness check** (lighter recall)?"

| Intent | Emphasis |
|--------|----------|
| Certification | More scenarios, higher difficulty on critical rules, fewer "giveaway" T/F |
| Awareness | Shorter recall, may accept simpler CHOICE on key headlines |

This affects difficulty mix only — not source faithfulness.
