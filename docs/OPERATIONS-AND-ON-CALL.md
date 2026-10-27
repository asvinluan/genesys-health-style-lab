# Operations and on-call guide: Health-style lab

How to run the platform day to day, and what to do when it breaks. Written so that anyone on the on-call roster acts the same way. It answers these lines of the job description: monitoring platform health, troubleshooting, root cause analysis, release validation, documentation, knowledge articles and the on-call roster.

> **Honest status.** This is a design for a lab. Severity targets, contacts and thresholds below are **examples** to be replaced by the real service levels, contracts and roster. Nothing here describes any department's real process.

---

## 1. The daily routine (10 minutes)

1. Run `08-health-check`. It must end with "All checks passed". A WARN about the surge switch needs an answer: who turned it on, and why.
2. Open the performance views. For each queue look at: longest wait, abandon rate, service level so far today, agents on queue.
3. Open the telephony view. Trunks connected? Any carrier notice in your inbox?
4. Open integration status. Any data action with a rising failure count?
5. Look at yesterday's incidents and open changes. Is anything scheduled for today that touches routing or flows?
6. Write one line in the run log: date, your name, "all healthy" or what you found.

> **Why a routine?** Nobody notices a slow decline. A five-minute look every morning catches the unpublished flow, the expired credential and the left-on switch before the callers do.

---

## 2. What to watch, and when to act (examples)

| Measure | Healthy | Look closer | Act now |
|---|---|---|---|
| Health check | All OK | Any WARN | Any FAIL |
| Longest wait, any queue | Under the service level time | Over it for 10 minutes | Over twice it, or climbing |
| Abandon rate, any queue | Under 5 percent | 5 to 10 percent | Over 10 percent |
| Service level, priority queue (Urgent Clinical Referral) | On target | Under target for 30 minutes | Under target and a vulnerable caller is waiting |
| Trunk status | Connected | One trunk down, other up | All trunks down |
| Data action failures | None | A few timeouts | Over 10 percent failing |
| Published flows | All published | A flow saved but not published | A flow unpublished that was live |
| Surge switch | Matches the plan | Left on after the event | On without an approval |

**Alert rules.** Genesys lets you create alert rules on queue and system measures in the UI. I did not find a provider resource for them, so they are not code here. Create them in the UI, record the rule names in this guide, and add them to the quarterly review. Each rule needs an owner, a threshold and a link to the knowledge article for that alert.

---

## 3. Severity levels (examples)

| Level | What it means | Examples | First response | Update every |
|---|---|---|---|---|
| **P1** | Callers cannot reach us, or a safety route is down | All inbound calls fail. The urgent or safety queue is unreachable. The surge flow cannot be switched on during an event | 15 minutes | 30 minutes |
| **P2** | A large part of the service is degraded | One line is down. A whole queue has no eligible people. The assistant is giving wrong answers | 30 minutes | 1 hour |
| **P3** | A part is degraded, a workaround exists | A data action is timing out and the flow's failure path is working. A wrong holiday | 4 business hours | Daily |
| **P4** | Small or cosmetic | A typo in a prompt. A report column | Next business day | On change |

If in doubt, go one level higher and downgrade later.

---

## 4. The first 15 minutes of a major incident (P1 or P2)

1. **Acknowledge** in the incident channel. Say your name and "I have it".
2. **Classify.** Which level? Use the table. If P1, tell the service owner now, not after you know more.
3. **Scope.** Which numbers, queues, channels? All callers or some?
4. **Check the three outside causes first:** the carrier status, the Genesys status page, and the change log (what changed in the last 24 hours?).
5. **Follow the call-path order** (Brief, section 12): number, emergency group, schedule, flow published, menu branch, queue, eligible person, data action, carrier.
6. **Stabilise.** If a safe fallback exists, use it: the surge flow on the lines that allow it, a closed message, a second trunk path. A safe message is better than silence.
7. **Communicate.** Plain words: what is wrong, who is affected, what we are doing, when the next update is.
8. **Keep a timeline.** Time, what you saw, what you did. This becomes the root cause analysis.
9. **Restore through the code where you can.** If you had to change something in the screen to stop the harm, say so in the log and reconcile it into the repo afterwards, or the next apply will undo it.
10. **Close properly.** Check with a test call. Tell the service owner. Book the root cause analysis.

---

## 5. Message templates

**First message (P1).** "[Service name]: inbound calls on [numbers] are failing from [time]. We are investigating. Callers [hear a busy tone / reach the closed message / are not affected on chat]. Next update at [time]. Incident lead: [name]."

**Update.** "[Time] update: cause [is / is not yet] known. We have [action]. Callers now [effect]. Next update at [time]."

**Resolved.** "[Time]: service restored. Cause: [one sentence]. Customer impact: [from, to, scale]. A review will be completed by [date]."

---

## 6. Root cause analysis template

| Heading | What to write |
|---|---|
| **Summary** | Two sentences: what happened, how long, who was affected |
| **Timeline** | Time-stamped list, from the first sign to the all-clear |
| **Impact** | Calls offered, answered, abandoned; people affected; any safety or compliance effect |
| **Trigger** | What started it (a change, a carrier fault, a surge) |
| **Cause** | Why it was possible. Use five whys, and stop when you reach something you can change |
| **What went well** | Detection, response, communication |
| **What went badly** | Detection delay, missing runbook, wrong assumption |
| **Fix** | What restored service |
| **Prevention** | A test, a check, a guardrail or a document that stops a repeat. Each with an owner and a date |
| **Knowledge** | The article created or updated |

**Tone.** Blameless. Name causes, not people. A mistake that a person could make is a gap in the system.

---

## 7. Change and release validation

**Before the change.**
1. Pull request with the plan attached. A reviewer who is not the author approves.
2. Check the change calendar: no freeze, no peak, no announcement.
3. Apply to the test org. Run the test list (Build Manual, Part 6).
4. Write the rollback: the previous commit, and who applies it.

**During.**
5. Apply to production in a quiet window. Watch the health check and the queue views.

**After.**
6. Run the smoke tests: one call to each number, one chat, one assistant allow and one block.
7. Record the result against the change.

**Emergency change.** Allowed when the harm of waiting is greater than the harm of the change. Someone with authority approves by message. Record it. Reconcile it into the repo within one business day.

---

## 8. Knowledge article template

| Field | Content |
|---|---|
| **Title** | Starts with the symptom a person sees ("Callers hear the closed message during opening hours") |
| **When to use** | Which alert or complaint leads here |
| **Check** | Numbered steps, each with where to click or which command to run |
| **Fix** | The safest fix first |
| **Escalate** | To whom, with what information |
| **Last reviewed / owner** | Date and name |

Every incident ends with a new article or an update to one.

---

## 9. On-call handover note

| Field | Content |
|---|---|
| Date and your name | |
| Open incidents and their level | |
| Changes planned in the next 24 hours | |
| Known risks (a carrier works tonight; a peak tomorrow) | |
| Anything left in a non-standard state (the surge switch, a manual change not yet in the repo) | |
| Who to call if you need help | |

---

## 10. The on-call routine in plain words

- Be reachable, rested and calm. Acknowledge fast.
- Follow the written order. Do not improvise unless the page runs out.
- Restore service first, understand second.
- Tell people early, even if you know little.
- Change through the code. If you cannot, say what you changed.
- Hand over in writing.

---

## 11. Common faults and where to look

| Symptom | First checks |
|---|---|
| "We were open and it said closed" | Schedule group and time zone; a holiday row for today; the line's closed flow |
| Callers reach the wrong menu | The IVR config for that number; whether the emergency group is on and the line is in it |
| A queue's calls wait while people are free | Eligible people: group, skill, language, utilization, presence; whether a ring has opened |
| The surge switch seems to do nothing | The line may not allow the override (by design); the emergency group `enabled`; the surge flow published |
| The assistant says something it shouldn't | Switch it off at the flow, keep the transcript, tell the accountable official, add the case to the test set |
| A data action fails | Credential, endpoint, timeout; the flow's failure path |
| Recordings missing | Whether the queue is in a recording policy; whether it was meant to be (the restricted queue is not) |
| A flow shows an old version | Saved is not published; re-publish from the repo |
| Terraform wants to change things nobody changed | Drift: someone edited in the screen. Find out who and why before you apply |

---

## 12. The queue map (for reference)

| Queue | Division | Service level | After-call work | Rings (extra pool after N seconds in queue) | Surge rules (add pool when estimated wait is at least) |
|---|---|---|---|---|---|
| Aged Care Information | Aged Care Information | 80 percent in 120 s | 90 s | Generalist Pool after 180 s | Generalist Pool at 300 s; Surge Pool at 600 s |
| Carers and Complex Needs | Client Care | 90 percent in 60 s | 180 s | Aged Care Officers after 120 s | none |
| Health Professionals | Providers | 80 percent in 180 s | 60 s | Generalist Pool after 240 s | none |
| Public Health Information | Public Health | 80 percent in 180 s | 60 s | Generalist Pool after 180 s | Surge Pool at 300 s |
| Urgent Clinical Referral | Clinical Triage | 95 percent in 15 s | 180 s | Carer Support Team after 30 s | none |
| Accessibility and Interpreter | Client Care | 80 percent in 180 s | 120 s | Aged Care Officers after 180 s | none |
| Complaints and Feedback | Client Care | 80 percent in 600 s | 180 s | none | none |
| Surge Response | Public Health | 60 percent in 600 s | 60 s | Generalist Pool after 180 s | none |
| Digital Messaging | Client Care | 70 percent in 300 s | 30 s | Generalist Pool after 240 s | none |

The restricted queue is **Clinical Triage**. It is outside the builders' and publishers' reach, is not on the surge switch, and its handling rules come from the agency, not from this lab.
