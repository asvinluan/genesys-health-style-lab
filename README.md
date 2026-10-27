# genesys-health-style-lab

A design-and-code study: a public contact centre in the style of a department like **Department of Health**, built on **Genesys Cloud CX** as Terraform ("CX as Code"), with AI guardrails, a restricted division, separation of duties, quality, recording retention, workforce management, a governance pack and documentation written for review and interview.

It is the Genesys counterpart to my [AWS enterprise bank lab](https://github.com/asvinluan/aws-enterprise-bank-lab), and a sibling of [genesys-home-affairs-style-lab](https://github.com/asvinluan/genesys-home-affairs-style-lab): the same modules, a different design file.

> **Status: lab and design.** The Terraform passes `validate` against the real `mypurecloud/genesyscloud` provider schema (v1.87.1) and an **offline plan test** with the provider mocked (4 scenarios). It has **not been applied to a live org**, and the flow YAML has **not** been checked with Archy. The code was drafted with AI assistance and reviewed by me. This is **not** the real department, not a production system and not a claim of production experience. Public information only. See [what is not built](docs/BUILD-MANUAL.md#part-14-what-is-not-built-yet).

## What it models

| Area | What is in the repo |
|---|---|
| Foundation | 5 divisions (one restricted), 15 groups, 6 roles with separation of duties, skills, languages, wrap-up codes |
| Telephony | BYOC Cloud site, SIP trunk shell (A-law), DID pool, emergency location |
| Routing | Schedules, holidays, 9 queues with bullseye rings, service-level targets and surge rules by estimated wait |
| Architect | 10 flow templates (YAML), 4 number-to-flow configs, data tables, a per-line surge switch |
| Integrations | Least-privilege OAuth client, data actions, a tested Node.js function that accepts a reference number only |
| AI | Knowledge base, agentic virtual agent with custom guardrails, speech and text analytics, summaries |
| Quality | Evaluation form with critical and kill questions, survey, retention policy, WFM business unit |
| Digital | Web messaging limited to allowed domains, optional SSO |
| Security | Optional organisation-wide sign-in hardening (MFA, idle timeout, password rules, IP allow-list) |
| Governance | Draft AI register entry, impact assessment outline, transparency statement notes, compliance map |
| Operations | Health-check script (bash and PowerShell), operations and on-call guide, RCA and knowledge templates |

## Architecture

```mermaid
flowchart LR
    caller["Caller"] --> trunk["SIP trunk"] --> ivr["IVR config"] --> emerg{"Event switch on and line allows it?"}
    emerg -- yes --> surge["Event flow"]
    emerg -- no --> sched{"Open, closed, holiday?"}
    sched --> flow["Flow and menu"]
    surge --> q
    flow --> q["Queue with rings and surge rules"] --> agent["Officer"]
    flow --> triage["Clinical triage queue - own division, 15 second target"]
    web["Web chat"] --> mflow["Message flow"] --> q
    flow -.-> bot["Information-only assistant, never clinical advice"] -.-> kb["Knowledge base"]
```

## AI guardrails, in one table

| Layer | Genesys feature used | Bedrock equivalent |
|---|---|---|
| Scope | Agent role and instructions | System prompt |
| Input rules | Custom guardrail rules | Denied topics |
| Grounding | Knowledge-base-only tool | Contextual grounding check |
| Data protection | Instruction to refuse identity or health details, PII redaction | Sensitive information filters |
| Violations | Guardrails event with a violation threshold | Blocked-message handling |
| Human | Escalation event and transfer | (flow logic) |
| Monitoring | Speech and text analytics, quality evaluation | CloudWatch, invocation logs |
| Accountability | `governance/` pack | (not applicable) |

## Run it

```bash
python3 tools/check_repo.py        # secrets, numbers, flows, design consistency
cd terraform
tofu init -backend=false
tofu validate
tofu test                          # offline plan test, no Genesys org needed
```

To build in a **lab** org, follow [docs/BUILD-MANUAL.md](docs/BUILD-MANUAL.md) and one runbook ([PowerShell](docs/RUNBOOK-POWERSHELL.md) or [Bash](docs/RUNBOOK-BASH.md)). **Never run it against a customer or government org.**

## Documents

| Document | Purpose |
|---|---|
| [ARCHITECTURE-BRIEF](docs/ARCHITECTURE-BRIEF.md) | Why it is built this way. Includes the JD map and interview questions |
| [BUILD-MANUAL](docs/BUILD-MANUAL.md) | How to build it, step by step |
| [RUNBOOK-POWERSHELL](docs/RUNBOOK-POWERSHELL.md) / [RUNBOOK-BASH](docs/RUNBOOK-BASH.md) | Exact commands |
| [OPERATIONS-AND-ON-CALL](docs/OPERATIONS-AND-ON-CALL.md) | Daily routine, severity, incidents, RCA, change, knowledge |
| [COST-AND-CLEANUP](docs/COST-AND-CLEANUP.md) | Where cost hides, how to clean up |
| [governance/](governance/) | AI register entry, impact assessment outline, statement notes, compliance map |

PDF copies are in `docs/`.

## What was found by testing (and fixed)

- Genesys needs **at least two bullseye rings** and the last is "everyone": the routing module now builds that from a simple list.
- Queue **service level is a fraction** (0 to 1), not a percentage: the module divides by 100.
- `validate` cannot see inside loops. The **offline plan test** can, and that is how both were found.

## Licence

MIT. Phone numbers are in the range Australia reserves for TV and film (03 5550 xxxx). Nothing here is real government data or design.
