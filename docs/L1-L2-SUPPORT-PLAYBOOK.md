# Level 1 and Level 2 support playbook: Health-style lab

> **Status: lab and design.** This is a practice playbook written for a fictional contact centre, using the queue map in [OPERATIONS-AND-ON-CALL.md](OPERATIONS-AND-ON-CALL.md#12-the-queue-map-for-reference). It has not been run against a live Genesys Cloud org. Menu names are from the Genesys Cloud admin interface as last known; confirm them in your own org. Not a real agency, not a production system.

The aim: show how a junior engineer works a ticket from first call to closure on a Genesys Cloud CX contact centre. The same shape fits any queue-based platform: **Triage, Check, Fix, Verify, Record, Escalate if stuck.**

## 1. How every ticket is worked

| Step | What to do | Evidence to write in the ticket |
|---|---|---|
| 1. Triage | Who is affected (one agent, one queue, one number, everyone)? Since when? What changed? Set severity using section 3 of the operations guide. | Affected scope, start time, last change |
| 2. Check | Follow the scenario table below. Change nothing until you know the cause. | What was checked and what it showed |
| 3. Fix | Make the smallest change inside your permissions. Anything outside them goes to a senior engineer (step 6). | Exact setting changed, old value, new value |
| 4. Verify | Test the way the caller or agent would: place a test call, sign in as a test user, run the report again. | Test result and time |
| 5. Record | Close with cause, fix and a knowledge article if it can happen again (template in the operations guide, section 8). | Ticket notes, knowledge article link |
| 6. Escalate | Hand over with the symptoms, what you checked, what you ruled out and what you need. Never "it does not work". | Handover note (operations guide, section 9) |

**Escalate straight away when:** callers cannot reach the contact centre at all, the restricted queue is involved, a recording or personal-information issue is suspected, or the fix needs a flow or telephony change you are not cleared to make.

## 2. Scenario runbooks (Level 1 and Level 2)

Each scenario names where to look in Genesys Cloud and in this repository. Queue names are the ones in this lab.

| # | Ticket | Level | Check in this order | Likely fix | Escalate when |
|---|---|---|---|---|---|
| 1 | "My agent is not receiving calls" | L1 | Agent status (On Queue?), presence, queue membership, skills and language match, utilisation settings, an open call stuck in wrap-up | Put the agent On Queue, correct queue membership or skill, clear a stuck interaction | Several agents affected, or the queue shows waiting calls with free eligible agents |
| 2 | "Calls reached the wrong queue" | L2 | Number mapped to which flow, the flow's menu branch, schedule group, emergency or surge override state | Correct the number-to-flow mapping or menu branch through the repo change process | The fix is a flow change |
| 3 | "We were open but callers heard the closed message" | L2 | Schedule group, time zone, a holiday row for today, the closed flow, whether the flow was published after the last edit | Fix the schedule or holiday entry; publish the flow | Time zone or schedule design is wrong across many lines |
| 4 | "IVR menu repeats or drops callers" | L2 | Flow version published, menu timeouts and no-input path, data action result on the failure path, last release date | Re-publish the correct version; fix a timeout in the repo; test again | Data action or integration is failing |
| 5 | "One-way or no audio on a call" | L2 | Which side cannot hear, agent phone or softphone, browser and headset, network or firewall change, trunk status, call time and conversation ID | Replace or re-register the device, retest from another network | Pattern across users or on one trunk or carrier; send the conversation ID and time to the senior engineer or carrier |
| 6 | "New starter needs access" | L1 | Approved request, role template for the job, division, queue membership, skills, phone or softphone, licence available | Create the user, add them to the right groups, assign the role template, test sign-in | Licence pool is empty, or the role needs a permission not in the template |
| 7 | "Leaver or role change" | L1 | Approval, last working day, groups and roles to remove, queue membership, recordings or evaluations still assigned | Remove access, reassign open items, record the change | Restricted queue or elevated roles involved |
| 8 | "Wrap-up codes or a queue setting changed" | L1 or L2 | Change request, which queue, current value, who may approve | Make the approved change in the repo or screen; record old and new values | Change touches service-level targets or rings; needs a senior engineer |
| 9 | "Report numbers look wrong" | L1 | Date range and time zone, queue and division filter, whether the queue was recently changed, interval versus daily view | Re-run with correct filters and explain; note a known cause | Data missing for a whole interval |
| 10 | "Recording missing" | L2 | Queue in a recording policy, whether it was meant to be (the restricted queue is not), retention rule, date range searched | Correct the recording policy if the queue was meant to be recorded | Any possible compliance or legal-request impact |
| 11 | "Service request: add a holiday, change opening hours" | L1 | Written request with dates and lines, who approved | Edit schedule and holiday entries, publish, test one call per affected line | Applies to more than a few lines at once |
| 12 | "Alert fired: queue wait high" | L2 | Service-level graph, agents on queue, any outage, whether surge rules opened | Ask the team lead to move people; confirm surge rules; watch for 15 minutes | Wait keeps rising, or the surge switch does not act |

## 3. User administration, licensing and permissions

| Task | Steps (lab approach) | Control |
|---|---|---|
| Add a user | Request approved, create the user, assign division, role template, groups, skills, licence, phone or softphone | Role templates only; no ad-hoc permissions |
| Change permissions | Move the user to a different role template through a request | Two people: requester and approver; builders and publishers are separate roles (see the lab's separation of duties) |
| Check licence use | Compare licences assigned with users active; reclaim from leavers first | Monthly check, written to the ticket |
| Remove a user | Remove roles and queue membership first, then disable; keep evaluation and recording records as required | Leaver checklist |

The six roles and sixteen groups in the repository (`terraform/modules/foundation`) are the model for the role templates above.

## 4. Supporting an upgrade, enhancement or deployment

Use this short checklist for any change window, whether a flow release, a new queue or a platform feature turned on.

1. Read the change record: what, who approved, rollback.
2. Before: take a note of current queue, schedule and flow versions (`scripts/*/05-inventory` and `06-export`).
3. During: apply the change as written, nothing extra.
4. After: run the health check (`scripts/*/08-health-check`), place one test call to each affected number, sign in as a test agent, check one report.
5. Within the hour: send the result message (operations guide, section 5). Roll back if a test fails.
6. Next day: watch the first busy period and note anything odd in the ticket.

## 5. Practice ticket (work it end to end)

> **Ticket:** "Since 9 am the Complaints and Feedback queue shows 14 waiting calls and nobody is answering. Agents say they are On Queue."
> 1. Triage: one queue, started 9 am, severity from the operations guide.
> 2. Check: are the agents On Queue for this queue specifically (membership), skills and language match, utilisation capped by an open interaction, flow published?
> 3. Fix and verify: place a test call, watch it route.
> 4. Record: write the cause and a knowledge article.
> 5. Escalate with notes if membership and skills are correct and calls still do not ring.

Write the answer in your own words in a ticket, then compare it with scenario 1.

## 6. What is not covered

Nothing here has been run in a live Genesys org. The scenarios test judgement and process, not the interface. Real escalation paths, licence counts, role templates and Architect behaviour depend on the organisation.
