# Comparing EduBase with Competitors

How to build a fair, evidence-based comparison between EduBase and another platform, or the customer's current way of working. The EduBase side comes from [features.md](features.md) with feature IDs; the competitor side needs its own evidence.

## Contents

- [Evidence rules](#evidence-rules)
- [Method](#method)
- [Comparison dimensions](#comparison-dimensions)
- [Competitor landscape](#competitor-landscape)
- [Output template](#output-template)

## Evidence rules

1. **EduBase claims** cite feature IDs from `features.md`. Nothing else counts.
2. **Competitor claims** need a source. When a web search or fetch tool is available, check the competitor's current product pages, documentation, pricing page or release notes, and cite the URL and the date you checked. Products change quickly, especially around AI.
3. **Without a source**, a competitor claim may come from general knowledge only if it is labelled, e.g. "(unverified, general knowledge)". Prefer "Verify: does X support Y?" over guessing.
4. **Use confidence labels** in the competitor column: **Verified** (source cited), **Reported** (third-party review or analyst source), **Unverified** (memory or assumption).
5. **Be fair.** Name the competitor's real strengths. A comparison that only flatters EduBase gets discarded by buyers; one that concedes the right points wins trust.
6. **No disparagement** and no claims about a competitor's security incidents, financial health or customers unless the user provides the source and asks for it.
7. **Compare on the buyer's criteria**, not on a list chosen to make EduBase look good.

## Method

1. **Frame it.** Which product (and edition) is being compared, for which use case and buyer? A Moodle comparison for a university exam office is a different document than one for a factory's safety training.
2. **Agree criteria.** Take them from the user, the RFP or the discovery notes. If none are given, propose five to eight from [Comparison dimensions](#comparison-dimensions) that fit the use case, and say you chose them.
3. **Gather evidence.** EduBase: search `features.md`. Competitor: research per the evidence rules.
4. **Compare criterion by criterion.** Rate each side **Strong**, **Basic**, **Not offered**, or **Unknown**. "Unknown" is a valid answer and better than a guess.
5. **Give the verdict.** Where EduBase wins, where the competitor wins, where they are equivalent. Then say who should choose which, and what to prove in a pilot.
6. **Suggest coexistence when it is true.** EduBase often complements an existing LMS through LTI (`INTEG.LTI`) rather than replacing it.

## Comparison dimensions

Use these as the menu of criteria. The IDs are where to look in `features.md`.

| Dimension | What to compare | EduBase IDs |
|-----------|-----------------|-------------|
| Question authoring | Question types, math and STEM, media, hints, banks, import formats | `QUIZ.TYPES`, `QUIZ.QUESTIONS`, `QUIZ.UPLOAD` |
| Individualized questions | Random values, constraints, personal datasets in attachments | `QUIZ.PARAMS` |
| Exam delivery | Scheduling, time limits, access without accounts, accommodations, live control | `QUIZ.EXAM`, `QUIZ.SETS` |
| Exam integrity | AI-cheating detection, audit trail, lockdown browser, parallel logins | `QUIZ.ANTICHEAT`, `QUIZ.EXAM.SEB` |
| Grading and analytics | Partial credit, rubrics, skills, manual scoring, error patterns, exports | `QUIZ.SCORING`, `QUIZ.RESULTS` |
| Certification | Verifiable certificates, validity, renewal, bulk export | `QUIZ.EXAM.CERTIFICATES` and siblings |
| Compliance and competencies | Competency register, document control, offline evidence, deadlines, heatmap | `COMP` |
| Learning delivery | Classes, paths, video, SCORM, live sessions, attendance | `LEARN.CLASSES`, `LEARN.PATHS`, `LEARN.VIDEO`, `LEARN.HOSTING` |
| Adaptive learning | Routing by results, skills, data and time; remediation loops | `LEARN.JOURNEYS` |
| AI | Generation, translation, analysis, provider choice, privacy | `AI`, `INTEG.MCP` |
| Integrations | API, LTI, webhooks, HR sync, SSO | `INTEG`, `USER.AUTH` |
| Organization and access | Departments, permission levels, data visibility, multi-tenant setups | `USER.ORG`, `USER.ACCESS` |
| Security and privacy | Audit logs, GDPR, retention, password policy | `SEC` |
| Deployment and data residency | Cloud, dedicated, on-premise | `PLAT.DEPLOY` |
| Branding | Exam and platform branding, custom domain | `PLAT.BRANDING`, `QUIZ.EXAM.BRANDING` |
| Languages | Interface languages, content languages | `LOC` |
| Support and onboarding | Support tiers, digitization services | `PLAT.SUPPORT` |
| Pricing | Free tier, plan structure | `Plans:` lines (no prices in the catalog) |

## Competitor landscape

Starting points, not facts to repeat. Competitor names are examples of each category; their strengths are typical for the category and must be verified for the specific product and edition. The "EduBase angles" are documented in `features.md`.

### Academic LMS

Examples: Moodle, Canvas, Blackboard, D2L Brightspace, Google Classroom.

- **Typical strengths:** broad course management, institutional adoption, large plugin and integration ecosystems, familiar to staff. Some include calculated or randomized question types and lockdown-browser support; check the specific product and plugins.
- **EduBase angles:** depth of assessment on top of the LMS rather than instead of it (`INTEG.LTI.PROVIDER`, `INTEG.LTI.GRADE-PASSBACK`); parameterized attachments (`QUIZ.PARAMS.FILES`); AI-era integrity analytics (`QUIZ.ANTICHEAT.SUSPICION`); expression and matrix answers (`QUIZ.TYPES.EQUATION`, `QUIZ.TYPES.MATRIX`); adaptive journeys (`LEARN.JOURNEYS`); Moodle import (`QUIZ.UPLOAD.MOODLE`).
- **Verify:** how the competitor handles randomized numeric questions, AI-cheating signals, and what is core versus plugin.

### Corporate LMS and learning experience platforms

Examples: Docebo, TalentLMS, Cornerstone, SAP SuccessFactors Learning, 360Learning, iSpring Learn, LearnUpon, Absorb.

- **Typical strengths:** course catalogs, off-the-shelf content libraries or marketplaces, authoring tools, HR suite integration, social and LXP features, broad interface localization.
- **EduBase angles:** a full competency register with versioned documents, offline requirements and a compliance heatmap (`COMP`); results-driven adaptive journeys (`LEARN.JOURNEYS`); serious exam security and certificates (`QUIZ.ANTICHEAT`, `QUIZ.EXAM.CERTIFICATES`); registration-free shop-floor testing (`QUIZ.EXAM.NO-REGISTRATION`); on-premise option (`PLAT.DEPLOY.ON-PREM`); MCP (`INTEG.MCP`).
- **Concede when true:** ready-made content libraries and wider interface localization are usually stronger in this category (see [Documented limits](sales-playbook.md#documented-limits)).

### Quiz and engagement tools

Examples: Kahoot!, Quizizz (Wayground), Mentimeter, Google Forms, Microsoft Forms, Socrative.

- **Typical strengths:** very easy, fast, engaging, often free or bundled with an office suite.
- **EduBase angles:** everything that turns a quiz into evidence: scheduled and secure exams (`QUIZ.EXAM`), integrity signals (`QUIZ.ANTICHEAT`), certificates (`QUIZ.EXAM.CERTIFICATES`), audit logs (`SEC.AUDIT`), competencies (`COMP`), parameterization (`QUIZ.PARAMS`). EduBase also covers live, projectable competitions (`QUIZ.EXAM.TYPES`) and gamification (`LEARN.GAMIFICATION`).
- **Concede when true:** for a quick classroom game or a simple form, these tools can be the lighter choice.

### Dedicated assessment and exam platforms

Examples: Questionmark (Learnosity), ExamSoft, Inspera, TAO, Mercer Mettl, ClassMarker, Testportal, ProProfs, FlexiQuiz.

- **Typical strengths:** high-stakes exam workflows, item banking, psychometrics, often webcam or live remote proctoring, standards such as QTI.
- **EduBase angles:** parameterized questions and datasets (`QUIZ.PARAMS`), Suspicion Score (`QUIZ.ANTICHEAT.SUSPICION`), Safe Exam Browser (`QUIZ.EXAM.SEB`), plus what assessment-only tools lack: learning delivery (`LEARN`), competency management (`COMP`), adaptive journeys (`LEARN.JOURNEYS`) and MCP (`INTEG.MCP`).
- **Concede when true:** webcam or live remote proctoring and QTI are not documented in the EduBase catalog.

### EHS and compliance training suites

Examples: SafetyCulture Training (EdApp), Vector Solutions, KPA, Litmos, and EHS modules of larger EHS software suites.

- **Typical strengths:** ready-made safety course libraries, incident and inspection modules alongside training, industry focus.
- **EduBase angles:** training on the customer's own procedures with version-aware required reading and re-certification (`COMP.LIBRARY.REQUIRED-READING`, `COMP.RECERT`); offline qualifications with evidence (`COMP.REQUIREMENTS.NON-DIGITAL`); strict video (`LEARN.VIDEO.STRICT`); contractor access without accounts (`QUIZ.EXAM.NO-REGISTRATION`); HR sync (`INTEG.HR-SYNC`); turning existing material into questions (`AI.ASSISTANT.QUESTION-GEN`, `PLAT.SUPPORT.DIGITIZATION`).
- **Concede when true:** no off-the-shelf safety course library and no incident or inspection management are documented in the catalog.

### STEM homework and math assessment systems

Examples: WeBWorK, STACK (Moodle), Möbius, WebAssign, MyLab / Mastering.

- **Typical strengths:** computer-algebra-based answer checking, large publisher question banks tied to textbooks.
- **EduBase angles:** parameters with constraints and formulas (`QUIZ.PARAMS`), expression, matrix and set answers (`QUIZ.TYPES.EQUATION`, `QUIZ.TYPES.MATRIX`, `QUIZ.TYPES.SET`), personal datasets in files (`QUIZ.PARAMS.FILES`), plus a complete platform around it (exams, integrity, classes, LTI).
- **Verify:** the depth of symbolic answer checking the buyer needs, and whether they rely on publisher content.

### The status quo

Paper sign-off sheets, spreadsheets, shared drives and email. Often the real competitor.

- **EduBase angles:** one register instead of scattered files (`COMP.PROGRESS.COMPLIANCE`), automatic deadlines and statuses (`COMP.PROGRESS.STATUSES`), audit-ready logs (`SEC.AUDIT.USER-ACTIVITY`), a printable test page for paper backup (`QUIZ.EXAM.PRINTABLE`), and a Free plan to start small.

## Output template

Adapt the length to the request; a quick question deserves a short table, a tender deserves the full version.

```markdown
## EduBase vs <Competitor> for <use case>

**Bottom line:** <two sentences: who should pick which, and why>

| Criterion | EduBase | <Competitor> |
|-----------|---------|--------------|
| <criterion> | **Strong**: <how> (`ID`, `ID`) | **Basic**: <how> (Verified: <source>, <date>) |
| <criterion> | **Not documented** | **Strong**: <how> (Unverified) |

### Where EduBase is stronger
- <point with IDs>

### Where <Competitor> is stronger
- <honest point with source>

### Open questions to verify
- <item> (ask the EduBase team / check the competitor's docs)

### Suggested pilot
<the two or three scenarios that would prove the difference, e.g. one parameterized exam with Suspicion Score review>

_EduBase capabilities from the EduBase feature catalog (<catalog_updated>). Competitor information checked <date>; plans and pricing vary by contract._
```
