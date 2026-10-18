# EduBase Sales Playbook

How to position EduBase, which features to lead with for each segment, what to ask, and how to handle objections. Every feature ID below exists in [features.md](features.md); check details and plan availability there before quoting them.

## Contents

- [Positioning](#positioning)
- [Core differentiators](#core-differentiators)
- [Segment guides](#segment-guides)
- [Discovery questions](#discovery-questions)
- [Objection handling](#objection-handling)
- [Documented limits](#documented-limits)

## Positioning

**One line:** EduBase is one platform for secure online exams, compliance and competency management, and adaptive learning, which AI assistants can operate directly.

**Thirty seconds:** EduBase combines a serious assessment engine (parameterized questions, AI-era integrity analytics, verifiable certificates) with competency management (versioned documents, requirements, deadlines and a compliance heatmap) and learning delivery (classes, strict video, SCORM, adaptive journeys). It runs in the browser on any device, works without accounts for shop-floor or event testing, integrates through REST, LTI, webhooks, HR sync and an official MCP server, and is available as cloud, dedicated instance or on-premise.

**Where it is strongest** (from the catalog's own summary): secure online examination, parameterized STEM questions, compliance and EHS training with competency tracking, adaptive learning journeys, and AI-native operation through MCP.

## Core differentiators

Lead with the ones that match the prospect's pain. Each is something buyers rarely get in one product.

| Differentiator | Why it matters | IDs |
|----------------|----------------|-----|
| Compliance loop in one register | Documents, competencies, digital and offline requirements, deadlines and evidence in one auditable place, with a department × competency heatmap | `COMP`, `COMP.PROGRESS.COMPLIANCE`, `COMP.REQUIREMENTS.NON-DIGITAL` |
| Version-aware required reading and re-certification | A new SOP version reopens acknowledgement; changed material can trigger deliberate re-certification | `COMP.LIBRARY.REQUIRED-READING`, `COMP.REQUIREMENTS.DOCUMENT`, `COMP.RECERT` |
| Adaptive learning journeys | Results route each person: remediation loops, placement, spaced refreshers, A/B splits, all explainable afterwards | `LEARN.JOURNEYS` |
| AI-era exam integrity | A 0–100 Suspicion Score per attempt with itemized reasons, plus a second-by-second audit trail and an AI usage declaration | `QUIZ.ANTICHEAT.SUSPICION`, `QUIZ.ANTICHEAT.FLOW`, `QUIZ.EXAM.AI-DECLARATION` |
| Parameterized questions and attachments | Each participant gets their own values, even inside downloaded Excel, Word or CSV files, so copying answers doesn't work | `QUIZ.PARAMS`, `QUIZ.PARAMS.FILES` |
| Lockdown when it matters | Safe Exam Browser required per exam, with configuration served and verified | `QUIZ.EXAM.SEB` |
| Registration-free mass testing | QR code, link or PIN with generated accounts; a whole cohort can arrive in the same minute; results looked up by ID | `QUIZ.EXAM.NO-REGISTRATION`, `QUIZ.EXAM.AUTOLOGIN`, `QUIZ.EXAM.RESULT-IDENTIFIER` |
| Verifiable certificates | Serialized PDF/A with QR verification, validity, renewal workflows and expiry alerts that can reach HR | `QUIZ.EXAM.CERTIFICATES`, `QUIZ.EXAM.CERTIFICATES-ADVANCED`, `QUIZ.EXAM.CERTIFICATE-RENEWAL` |
| Evidence-grade video | No forward seeking; only measured, near-complete viewing counts; exams can be locked until watched | `LEARN.VIDEO.STRICT`, `LEARN.VIDEO.ANALYTICS`, `LEARN.COURSES.PRE-EXAM` |
| AI-native operation | Official MCP server: assistants create questions, run exams and analyze results in plain language; every API endpoint is a tool | `INTEG.MCP`, `INTEG.OAUTH` |
| Model-agnostic, privacy-aware AI | Choice of AI provider per instance; exam summaries aggregate data before anything reaches a model | `AI.ASSISTANT.MODELS`, `AI.ASSISTANT.EXAM-SUMMARY` |
| Deployment freedom | Managed cloud, isolated dedicated instance on your domain, or on-premise containers | `PLAT.DEPLOY` |
| Open content formats | Human-readable EDU text format (git- and LLM-friendly), XLSX, Moodle XML, JSON; full-fidelity export | `QUIZ.UPLOAD`, `QUIZ.UPLOAD.EDU`, `QUIZ.UPLOAD.EXPORTS` |

## Segment guides

Each guide lists typical pains, the features to lead with and a demo story. Adapt to the prospect; don't recite the whole list.

### EHS, industrial safety and regulatory compliance

Manufacturing, energy, logistics, construction, pharma (GMP), contractor and visitor induction.

- **Pains:** proving who is qualified right now; paper sign-off sheets; SOP changes that don't reach the shop floor; workers without email accounts or desks; audits (ISO 45001, ISO 9001, GMP); multilingual workforce; offline qualifications such as forklift licences.
- **Lead with:**
    - Competency register and statuses: `COMP.COMPETENCIES`, `COMP.PROGRESS.STATUSES`, `COMP.PROGRESS.COMPLIANCE`
    - Offline qualifications with evidence: `COMP.REQUIREMENTS.NON-DIGITAL`, `COMP.REQUIREMENTS.ATTACHMENTS`, `COMP.REQUIREMENTS.CUSTOM-FIELDS`
    - Validity and deadlines: `COMP.REQUIREMENTS.VALIDITY`, `COMP.REQUIREMENTS.DEADLINES`
    - Versioned SOPs and required reading: `COMP.LIBRARY.VERSIONING`, `COMP.LIBRARY.REQUIRED-READING`, `COMP.RECERT`
    - Shop-floor access: `QUIZ.EXAM.NO-REGISTRATION`, `QUIZ.EXAM.AUTOLOGIN`, `QUIZ.EXAM.CUSTOM-FIELDS`, `QUIZ.EXAM.RESULT-IDENTIFIER`, `PLAT.ACCESS.WEB`
    - Evidence: `LEARN.VIDEO.STRICT`, `QUIZ.EXAM.CERTIFICATES`, `SEC.AUDIT.USER-ACTIVITY`, `QUIZ.EXAM.LOCKING`
    - Hazard spotting on photos: `QUIZ.TYPES.HOTSPOT`
    - HR-driven assignment: `INTEG.HR-SYNC`, `COMP.COMPETENCIES.ASSIGNMENT`
    - In-person training and toolbox talks recorded as completions: `QUIZ.EXAM.QUESTIONLESS`, `LEARN.ATTENDANCE`
- **Demo story:** contractor scans a QR code at the gate → enters their ID and company → watches the safety video in strict mode → takes the exam → receives a QR-verifiable certificate → the site manager sees the compliance heatmap update.
- **Plan note:** most `COMP` capabilities are Business; `COMP.REQUIREMENTS.JOURNEY` is also on Pro.

### Corporate L&D, onboarding and HR

- **Pains:** onboarding that depends on manual chasing; one-size-fits-all training; proving training effectiveness; keeping the org chart in sync; reports for every team leader.
- **Lead with:** `LEARN.PATHS` (gated onboarding with 20+ completion rules), `LEARN.JOURNEYS` (placement and remediation), `COMP.REQUIREMENTS.DEADLINES` ("within 30 days of joining"), `INTEG.HR-SYNC`, `USER.ORG.DEPARTMENT-HIERARCHY`, `USER.ACCESS.MEMBER-VISIBILITY`, `USER.ORG.REPORTS`, `QUIZ.SCORING.SKILLS`, `QUIZ.SETS.FEEDBACK`, `LEARN.LIVE-SESSIONS`, `LEARN.GAMIFICATION`.
- **Demo story:** new hire arrives from the HR system → competencies assigned by position code → progressive onboarding class → placement exam routes them past what they already know → team leader sees only their team's progress.

### Higher education and STEM

Universities, colleges, engineering and medical schools.

- **Pains:** AI-assisted cheating in online and take-home exams; answer sharing in large cohorts; marking load; math that multiple choice can't test; existing LMS investments.
- **Lead with:** `QUIZ.PARAMS` and `QUIZ.PARAMS.FILES` (individual datasets), `QUIZ.TYPES.EQUATION`, `QUIZ.TYPES.MATRIX`, `QUIZ.TYPES.NUMBER`, `QUIZ.SCORING.TOLERANCE`, `QUIZ.ANTICHEAT.SUSPICION`, `QUIZ.EXAM.SEB`, `QUIZ.EXAM.AI-DECLARATION`, `QUIZ.SCORING.RUBRIC`, `QUIZ.TYPES.FILE`, `QUIZ.EXAM.EXTRA-TIME` (accommodations), `QUIZ.RESULTS.ERROR-PATTERNS`, `INTEG.LTI` (works inside Canvas, Moodle, D2L, Schoology), `QUIZ.UPLOAD.MOODLE`.
- **Demo story:** a physics question with random values and a personalized CSV dataset → a student pastes an AI answer → the reviewer sees the Suspicion Score with reasons → scores flow back to the LMS gradebook.

### Schools and K-12

- **Pains:** budget; engagement; simple setup for teachers; homework that can't be copied.
- **Lead with:** the Free plan capabilities (classes, most question types, parameterization), `LEARN.CLASSES`, `QUIZ.EXAM.TYPES` (projectable championships with live ranking, pausable homework), `LEARN.GAMIFICATION`, `QUIZ.SETS.SELF-CHECK`, `QUIZ.RESULTS.RETRY`, `USER.AUTH.SOCIAL`, `LEARN.CALENDAR.SUBSCRIPTIONS`, `AI.ASSISTANT.QUESTION-GEN` (Pro) to turn existing worksheets into quizzes.

### Certification bodies, training providers and exam centers

- **Pains:** issuing trustworthy certificates; renewals and expiry; selling courses and exam seats; handling candidates without accounts; running branded exams for clients.
- **Lead with:** `QUIZ.EXAM.CERTIFICATES`, `QUIZ.EXAM.CERTIFICATES-ADVANCED`, `QUIZ.EXAM.CERTIFICATE-PRESETS`, `QUIZ.EXAM.CERTIFICATE-RENEWAL`, `QUIZ.EXAM.CERTIFICATE-REPORTS`, `LEARN.EVENTS` (paid tickets and coupons, Managed), `QUIZ.EXAM.BRANDING`, `PLAT.BRANDING.GLOBAL`, `PLAT.DEPLOY.DEDICATED`, `QUIZ.EXAM.USER-GENERATION`, `QUIZ.EXAM.USERS` (login slips, live control), `QUIZ.EXAM.CUSTOM-FIELDS`, `QUIZ.EXAM.REVIEWS`.

### Software vendors, EdTech and system integrators

Teams embedding assessment or automating training from their own systems.

- **Pains:** building an assessment engine is expensive; integrations that break; AI workflows.
- **Lead with:** `INTEG.API` (users, exams, certificates, departments, competencies, journeys), `INTEG.API.EXAM-LIFECYCLE`, `INTEG.LTI.PROVIDER`, `INTEG.WEBHOOKS`, `INTEG.MCP`, `INTEG.OAUTH`, `QUIZ.UPLOAD.EDU`, `QUIZ.UPLOAD.JSON`, `INTEG.API.JOURNEYS` (journeys as portable JSON with a public JSON Schema), developer docs with `llms.txt`.

### Public sector, defense, healthcare and other data-sensitive buyers

- **Pains:** data residency; procurement rules on AI vendors; audits; identity integration.
- **Lead with:** `PLAT.DEPLOY.ON-PREM`, `PLAT.DEPLOY.DEDICATED`, `AI.ASSISTANT.MODELS` (provider per instance), `AI.ASSISTANT.EXAM-SUMMARY` (aggregation before any model call), `SEC.DATA.GDPR`, `SEC.DATA.RETENTION`, `SEC.DATA.PASSWORD-POLICY`, `SEC.AUDIT`, `USER.AUTH.SSO`, `USER.AUTH.LDAP`, `USER.AUTH.2FA`, `USER.AUTH.EXAM-ONLY` (minimal personal data), `USER.ACCESS.PERMISSIONS`.

## Discovery questions

Ask a few, not all. Each answer points to features to lead with.

- Who takes the tests or training, and do they have company accounts or email addresses? (→ `QUIZ.EXAM.NO-REGISTRATION`, `QUIZ.EXAM.AUTOLOGIN`)
- What has to be proven, to whom, and how often? Which audits or regulations apply? (→ `COMP`, `SEC.AUDIT`, certificates)
- How do you track qualifications that happen outside the system, like licences or in-person training? (→ `COMP.REQUIREMENTS.NON-DIGITAL`)
- What happens today when a procedure document changes? (→ `COMP.LIBRARY.REQUIRED-READING`, `COMP.RECERT`)
- How high are the stakes of your exams, and how worried are you about AI-assisted cheating? (→ `QUIZ.ANTICHEAT`, `QUIZ.EXAM.SEB`, `QUIZ.PARAMS`)
- Which systems must EduBase talk to: HR, LMS, SSO, BI? (→ `INTEG`, `USER.AUTH`)
- Do different people need different routes through the training? (→ `LEARN.JOURNEYS`, `LEARN.PATHS`)
- Where must the data live, and are there rules on which AI vendors may process it? (→ `PLAT.DEPLOY`, `AI.ASSISTANT.MODELS`)
- How much existing content do you have, and in what format? (→ `QUIZ.UPLOAD`, `AI.ASSISTANT.QUESTION-GEN`, `PLAT.SUPPORT.DIGITIZATION`)
- Who will run the platform day to day, and how much support do they expect? (→ `PLAT.SUPPORT`, `INTEG.MCP`)

## Objection handling

Acknowledge, answer with documented capabilities, offer proof (a pilot or demo). Never answer an objection with an undocumented promise.

| Objection | Response direction | IDs |
|-----------|--------------------|-----|
| "We already have an LMS (Moodle, Canvas, ...)." | EduBase doesn't have to replace it: it plugs in as an LTI tool with SSO and grade passback, and Moodle question banks import directly. Position EduBase where the LMS is weak: exam integrity, parameterization, certificates, competencies. | `INTEG.LTI`, `INTEG.LTI.GRADE-PASSBACK`, `QUIZ.UPLOAD.MOODLE` |
| "Students will just use ChatGPT." | Layer the defences: parameterized questions and personal datasets, the Suspicion Score with itemized reasons, the attempt timeline, Safe Exam Browser for high stakes, and a voluntary AI declaration to separate declared from suspected use. The score is a triage aid for reviewers, not an automatic verdict. | `QUIZ.PARAMS.FILES`, `QUIZ.ANTICHEAT.SUSPICION`, `QUIZ.ANTICHEAT.FLOW`, `QUIZ.EXAM.SEB`, `QUIZ.EXAM.AI-DECLARATION` |
| "Our workers don't have accounts or email." | QR, link or PIN access with generated accounts, printed login slips, and result lookup by employee number. | `QUIZ.EXAM.NO-REGISTRATION`, `QUIZ.EXAM.AUTOLOGIN`, `QUIZ.EXAM.USERS`, `QUIZ.EXAM.RESULT-IDENTIFIER` |
| "We can't send our data to an AI vendor." | AI is optional and model-agnostic per instance; exam summaries aggregate before anything is sent and exclude names; dedicated and on-premise deployments are available. | `AI.ASSISTANT.MODELS`, `AI.ASSISTANT.EXAM-SUMMARY`, `PLAT.DEPLOY` |
| "It has to stay in our data center." | On-premise containerized deployment, or an isolated dedicated instance on your own domain. | `PLAT.DEPLOY.ON-PREM`, `PLAT.DEPLOY.DEDICATED` |
| "Migration will take forever." | Batch upload of up to 500 questions per file from XLSX, CSV, EDU, ZIP, Moodle XML or JSON; AI drafts questions from existing documents; EduBase offers content digitization help. | `QUIZ.UPLOAD`, `QUIZ.UPLOAD.AI-GEN`, `PLAT.SUPPORT.DIGITIZATION` |
| "We need it connected to HR." | Scheduled HR, ERP or SIS synchronization of users, departments and competencies, already in production with several source systems; plus a REST API and webhooks. | `INTEG.HR-SYNC`, `INTEG.API`, `INTEG.WEBHOOKS` |
| "Auditors need proof, not checkboxes." | Timestamped activity logs, strict video viewing, versioned documents, frozen historical exams and serialized certificates. | `SEC.AUDIT`, `LEARN.VIDEO.STRICT`, `COMP.LIBRARY.VERSIONING`, `QUIZ.EXAM.LOCKING`, `QUIZ.EXAM.CERTIFICATES` |
| "Is it reliable when everyone starts at once?" | Automatic login is built for a whole cohort arriving at once; there is a public status page. Don't quote uptime figures the catalog doesn't state. | `QUIZ.EXAM.AUTOLOGIN`, `PLAT.SUPPORT.STATUS` |
| "How much does it cost?" | There is a Free plan, plus Pro and Business. Don't quote prices; offer the pricing page or a call with EduBase sales, and map the needed features to a plan. | `Plans:` lines in `features.md` |

## Documented limits

Know these before the customer finds them. State them plainly and offer what EduBase does instead.

- **Interface languages:** the platform interface is fully localized in Hungarian and English. Question content can be written in most languages, and certificates and exports can be produced in a specific language (`LOC.LANGUAGES.MULTI`, `LOC.LANGUAGES.DOWNLOADS`). Don't promise other interface languages.
- **Question types:** the catalog lists 17 question types (`QUIZ.TYPES`). Use that number, not older marketing figures.
- **Mobile:** responsive web app on every device, no separate native app (`PLAT.ACCESS.WEB`).
- **Plan gating:** most competency management is Business-only, as are SSO, LDAP, global branding, dedicated and on-premise deployment, password policy and organizational reports. Check each `Plans:` line.
- **Managed settings:** some features are configured with the EduBase team rather than self-service: admin settings, events and paid ticketing, document types (`PLAT.ADMIN`, `LEARN.EVENTS`, `COMP.LIBRARY.DOC-TYPES`).
- **Not documented in the catalog** (say so and suggest confirming with EduBase; never claim them): webcam or live remote proctoring, xAPI / cmi5, QTI import or export, GIFT or Aiken import (these names appear only as search keywords on `QUIZ.UPLOAD.EDU`, EduBase's own text format), SCIM provisioning, an off-the-shelf course library, SCORM authoring (SCORM is hosted and played, `LEARN.HOSTING.SCORM`), e-commerce beyond event tickets, and compliance certifications held by EduBase itself (e.g. ISO 27001, SOC 2). This list is a reminder, not exhaustive: anything absent from `features.md` is "not documented".
