# PictuRAS Project Constitution

This constitution defines the mandatory principles for extending PictuRAS with
video support during Phase 1. It applies to specifications, architectural
decisions, code, tests, and documentation produced with the assistance of AI
agents.

## Core Principles

### I. Incremental Extension of the Baseline

The project MUST extend the provided solution rather than rewrite it. Every
change MUST identify the delta from the baseline, including the requirements
documents, architectural solution, and starting repository commit.

Whenever existing behavior changes, the affected baseline elements MUST be
identified by their IDs (`UCnn`, `RFnn`, and `RNFnn`). Changes unrelated to
video support are out of scope unless they are necessary to fix a baseline
problem that prevents integration.

### II. MVP Focused on Functional Validation

Phase 1 MUST prioritize functional validation of video support. The team MUST
select features with appropriate value and complexity, without treating the MVP
as a production-ready solution. Non-functional requirements MUST be specified
and verified as far as practical, but Phase 1 is not required to achieve
production-level robustness, performance, or quality.

Isolated trivial operations do not constitute a sufficient extension on their
own. Specified but unimplemented features MUST explicitly state their status.

### III. End-to-End Traceability

Every feature MUST close the following loop:

```text
use case -> requirement -> component -> test -> result
```

Every requirement MUST have an identifiable origin, MUST be realized by one or
more components, and MUST have at least one test or an explicit justification
for its non-implementation. Orphan requirements and uncovered relevant use-case
elements are not allowed.

Requirements shared by multiple features MUST be specified once, with all their
origins identified. Cross-cutting requirements MUST NOT be duplicated.

### IV. Verifiable Requirements and Consistent Terminology

Requirements MUST be atomic, testable, and written using the pattern
“The system shall...”. Acceptance criteria MUST use the
`Given... When... Then...` format.

Non-functional requirements MUST be classified according to ISO/IEC 25010.
Numeric values, limits, quotas, codecs, formats, states, and authentication
rules MUST have a documented source. Agents MUST NOT invent them or copy them
from an implementation without validating the decision.

The domain model MUST represent problem-domain concepts rather than classes,
tables, or microservices, and MUST use the terminology established by the use
cases and requirements.

### V. Stable Identification

Identifiers are part of the documentation contract:

- `UC-VID-nnn`: video use case, with unique numbering starting at
  `UC-VID-001`;
- `REQ-VID-{FUNC}-nnn`: video requirement;
- `FAk`, `RNK`, `Ak`, and `Qk`: alternative flow, rule, assumption, and
  question local to a use case;
- `RNG-nn`: cross-cutting business rule;
- `DQ-nnn`: quality decision;
- `DA-nn`: architectural decision;
- `TST-{FUNC}-nn`: test;
- `T-nn`: corrective-maintenance task;
- `UCnn`, `RFnn`, and `RNFnn`: baseline elements.

An identifier MUST NOT be reused, even after a requirement, test, or decision
has been removed.

### VI. Evidence-Based Architecture

Architectural changes MUST describe only the delta from the baseline solution.
New or changed components, responsibilities, architectural decisions
(`DA-nn`), alternatives, consequences, installation, and execution MUST be
linked to the requirements they realize.

When applicable, the updated model MUST explicitly address the relationship
between video, image, project, and processing job, including state, result,
duration, resolution, and format. Video profiles, quotas, and limits are
cross-cutting decisions and MUST be represented as cross-cutting business
rules (`RNG-nn`) applied consistently.

### VII. Documented AI Use and Human Responsibility

The use of AI agents MUST be documented, including tools, models, skills,
instructions, supported tasks, validation performed, and available evidence
such as commits or pull requests.

The team retains full responsibility for all delivered content. Code,
requirements, decisions, and tests produced with AI MUST be reviewed,
understood, executed, and justified by their authors.

Agents MUST NOT introduce secrets, tokens, credentials, personal data, or
`.env` files into code, documentation, prompts, logs, or commits.

## Quality and Delivery Rules

### Minimum Documentation

The Phase 1 report MUST cover:

1. context, baseline, and cross-cutting overview;
2. video use cases;
3. functional and non-functional requirements;
4. impact on the existing solution;
5. traceability matrix;
6. architectural changes;
7. AI-assisted implementation;
8. testing, validation, limitations, and known defects;
9. corrective maintenance of the baseline, when applicable;
10. conclusion and future work.

Use-case and domain-model diagrams MUST be updated for video, replacing
image-only versions whenever they are affected.

### Validation

Every change MUST state how it will be validated. Commands and environments
documented in the [`README.md`](../../README.md) SHOULD be preferred, with
focused tests run before broader test suites.

No feature may be claimed as validated without executing the corresponding
verification and recording its result. Known limitations and defects MUST be
declared rather than hidden behind defaults or silent fallbacks.

### Deliverables

Phase 1 deliverables are:

- requirements-extension report in PDF;
- editable report source;
- extended solution with the video MVP;
- evidence of AI use and validation;
- instructions for running the solution and tests;
- `grupo.csv` according to the delivery rules.

The Typst template is optional. Its use MUST NOT be treated as a mandatory
project dependency.

## Spec Kit Workflow

Specifications MUST follow this workflow:

1. `/speckit-constitution` to review principles and governance;
2. `/speckit-specify` to create one specification per feature;
3. `/speckit-clarify` to resolve material ambiguities;
4. `/speckit-plan` to define the implementation;
5. `/speckit-tasks` to decompose the plan into tasks;
6. `/speckit-analyze` and `/speckit-checklist` for optional checks;
7. `/speckit-implement` only after the specification, plan, and tasks have
   been reviewed.

When a decision changes, the corresponding source MUST be updated and
dependent artifacts MUST be regenerated. Generated artifacts MUST NOT be
manually edited to bypass validation.

## Governance

This constitution takes precedence over conflicting local conventions.
[`AGENTS.md`](../../AGENTS.md) provides operational context and MUST NOT
replace these principles.

Changes to this constitution require:

1. an explicit justification;
2. updating the version and amendment date;
3. reviewing the impact on `AGENTS.md`, specifications, and dependent
   artifacts;
4. validating that traceability and deliverables remain complete.

**Version**: 1.0.0  
**Ratified**: 2026-10-18  
**Last Amended**: 2026-10-18
