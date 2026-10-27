# Compliance map: Health-style lab

> **Read this honestly.** Items marked **✓** I confirmed against public sources in October 2026. Everything marked **verify** is stated from general knowledge and must be checked against the current text and the agency's own obligations. This is a design aid, not legal advice, and not a statement that any system complies.

| Rule or framework | What it asks, in plain English | How this lab touches it | Status |
|---|---|---|---|
| **✓ Privacy Act 1988 and the APPs** (including APP 1.7 to 1.9, automated decisions, from 10 December 2026) | Collect only what you need, tell people, protect it, say when a program decides things about them | The function takes a reference number only; the bot takes no identity data; the register entry says the bot makes no decisions; retention is a reviewed variable | Confirmed (OAIC guidance, September 2026) |
| **✓ Policy for the responsible use of AI in government, v2.0** (DTA, from 15 December 2025) | Accountable officials, an AI use-case register, impact assessments, a transparency statement | `governance/` has a draft register entry, an impact assessment outline and statement notes | Confirmed |
| **✓ IRAP assessment of Genesys Cloud** | Independent assessment of a cloud service against the Information Security Manual, at a stated classification | Ask Genesys for the current report: its scope, the classification level it covers (published material has said OFFICIAL and PROTECTED at different times), the date, and which regions and features are in scope. Do not quote a level without reading the report | Confirmed that assessments exist; **verify** scope and currency |
| **verify: Information Security Manual (ISM)**, Australian Signals Directorate | The control catalogue that IRAP assesses against: identity, access, logging, encryption, incident response | Roles, MFA, IP allow-list, audit, encryption at rest by the provider. Map the platform to the controls the agency has chosen | Verify the current edition and the agency's control selection |
| **verify: Essential Eight** | Eight baseline mitigation strategies: application control, patching, macros, hardening, restricting admin privileges, patching operating systems, MFA, backups | SaaS means Genesys patches the platform. What is yours: MFA, restricting admin privileges (roles and divisions), and backups (configuration in Git) | Verify the target maturity level |
| **verify: Protective Security Policy Framework (PSPF)** | Governance, information, personnel and physical security for Commonwealth entities | Need-to-know division, separation of duties, vetted team for the restricted queue (the design assumes vetting; it cannot enforce it) | Verify current requirements |
| **verify: Hosting Certification Framework (DTA)** | Rules about where government data is hosted and who controls it | The org is in the Sydney region. Ask whether the provider and the AI features are certified for the data in scope | Verify |
| **verify: Archives Act 1983** | Commonwealth records must be kept and disposed of under a records authority | Retention policy with a placeholder; the restricted queue is outside it by design; evidence export described | Verify the records authority that applies |
| **verify: Disability Discrimination Act 1992 and digital accessibility (WCAG 2.2 AA for web)** | Services must be usable by people with disability | Relay and interpreter routes, plain prompts, chat widget testing with assistive technology (not done in the lab) | Verify the standard the agency is held to |
| **verify: Notifiable Data Breaches scheme (Privacy Act, Part IIIC)** | Notify the OAIC and affected people of eligible breaches | An incident runbook step: who decides whether it is a data breach. Logging and audit make the facts findable | Verify |
| **verify: Public Governance, Performance and Accountability Act 2013** | Proper use of public resources, risk management | Cost section; improvement ideas aimed at cost per resolved contact | Verify |
| **verify: Health information is sensitive information (Privacy Act, APP 3) and must be kept secure (APP 11)** | Collect health information only with consent or a permitted reason, only what is needed, and protect it | The assistant is told never to take health details; the evaluation form has a critical question on collecting only what is needed; consent is a wrap-up code | Verify |
| **verify: Aged care legislation (a new Aged Care Act was legislated in 2025; confirm commencement and how it applies to information services)** | Sets out rights, obligations and complaints arrangements for aged care | The information line explains services and complaints routes and does not decide anything. Complaints go to a person | Verify |
| **verify: My Health Records Act 2012 (only if the contact centre ever touches that system)** | Strict rules on access to and use of a person's health record | Not integrated in this lab. If it ever were, it would need its own assessment and likely a separate division | Verify; not in scope |
| **verify: Therapeutic Goods regulation of software that gives clinical advice** | Software that diagnoses or advises on treatment can be a regulated medical device | The assistant is told never to give clinical advice and a guardrail blocks it. If that boundary were ever relaxed, the regulatory position would change | Verify |
| **verify: Duty of care and mandatory reporting duties for suspected abuse (these vary by state and by role)** | Some people must report; all should have a clear route to safety | A one-press route to the clinical triage queue, an analytics topic for suspected abuse or neglect, and a high-priority queue with a 15-second target. The reporting duty itself belongs to the agency's policy | Verify with the agency's legal team |

## Evidence you can show

| Evidence | Where |
|---|---|
| Roles, groups and division exclusions | `terraform/locals.tf` (`roles`, `group_roles`), and the plan output |
| Separation of duties | Roles *Flow Developer* and *Release Manager* |
| Recording and retention rules | `terraform/locals.tf` (`recorded_queue_keys`), `modules/quality` |
| AI rules and test evidence | `terraform/locals.tf` (`ai`), Build Manual Part 6 |
| Sign-in rules | `modules/security`, `envs/hardened.tfvars` |
| Change control | Pull requests, CI, `terraform/tests/plan.tftest.hcl` |
| Secrets hygiene | `tools/check_repo.py`, `.gitignore` |
| Operations | `docs/OPERATIONS-AND-ON-CALL.md`, `scripts/*/08-health-check` |
| AI governance | the other files in `governance/` |
