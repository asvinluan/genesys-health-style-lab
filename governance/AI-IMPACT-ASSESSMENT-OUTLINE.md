# AI impact assessment outline: Health-style lab virtual assistant

> **DRAFT TEMPLATE FOR A LAB.** A skeleton for the impact assessment the Commonwealth AI policy expects for each use case. It is not the official assessment tool. The real agency would use its own approved template and complete it with the privacy officer, legal, the accessibility lead and the business owner.

## 1. What is the use case, in one paragraph?

[Plain-language description. Who uses it, for what, and what happens if it is turned off.]

## 2. Who is affected?

| Group | How they are affected | Special considerations |
|---|---|---|
| Members of the public | They talk to the assistant | Older people, carers under stress, people who are deaf or hard of hearing, people with limited English, and people in distress or danger |
| Officers | They receive transfers and summaries | Workload, training, trust in the summaries |
| The agency | Reputation, legal exposure | Accuracy, accountability |

## 3. What could go wrong, and how bad?

| Risk | Likelihood | Impact | Control in the lab | Residual risk / owner |
|---|---|---|---|---|
| The assistant gives wrong or outdated information | [ ] | [ ] | Knowledge-only tool; content owner approves each answer; review date | [ ] |
| A person treats the assistant's information as medical advice, or a safety concern is not recognised | [ ] | [ ] | Instructions and guardrail refuse clinical advice; mentions of danger trigger triple zero, Lifeline and immediate transfer | [ ] |
| A person in danger is not routed to help | [ ] | Severe | Safety instructions and guardrail; keyword analytics; immediate transfer; test set; quality review | [ ] |
| Personal or sensitive information is shared with the assistant | [ ] | [ ] | Instruction to refuse; guardrail; redaction; function takes a reference only | [ ] |
| The assistant is manipulated (prompt injection) | [ ] | [ ] | Guardrail; violation threshold; no tools beyond the knowledge base | [ ] |
| People who cannot use it are left behind | [ ] | [ ] | Always a route to a person; relay and interpreter routes; plain language; assistive-technology testing [not done in the lab] | [ ] |
| Bias or unequal service across groups | [ ] | [ ] | Information only, same content for everyone; monitor hand-off and complaint rates by language and channel | [ ] |

## 4. Privacy

- What personal information could the assistant receive, even though it is told not to?
- Where is it stored, for how long, who can read it?
- Does the assistant make, or substantially make, a decision that significantly affects someone using their personal information? (APP 1.7 to 1.9.) The lab's answer is no, and why.
- Is the privacy policy updated?

## 5. Fairness and accessibility

- Has the assistant been tested with assistive technology, with relay users, and in the languages offered?
- What happens when the assistant does not understand?

## 6. Human oversight and escalation

- When does a person take over? (Three blocked requests; any safety keyword; any request to speak to a person.)
- Who reviews performance, how often, using which measures?

## 7. Monitoring and review

| Measure | Why | Review |
|---|---|---|
| Hand-off rate and reasons | Shows where the assistant fails people | Weekly |
| Guardrail violations | Shows manipulation and gaps | Weekly |
| Complaints mentioning the assistant | Shows harm | Monthly |
| Safety-topic conversations | Confirms the route works | Every one reviewed |
| Content accuracy checks | Keeps answers current | Quarterly |

## 8. Decision

[Approved / approved with conditions / not approved. Name, role, date.]
