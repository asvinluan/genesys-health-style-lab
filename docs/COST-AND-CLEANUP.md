# Cost and cleanup: Health-style lab

Genesys Cloud is not billed by the hour, so there is no "stop the meter" script. This guide says where cost hides and how to clean up.

## What costs money

| Item | How it is billed | Where it hides in this lab |
|---|---|---|
| Named or concurrent user licences | By contract, by tier | Your lab org's licence may cover few users; the build creates groups, not users |
| AI features (virtual agent, summaries, guardrails) | Add-on and usage | `enable_ai = true` |
| Speech and text analytics | Add-on and usage | `enable_ai = true` (topics, programs) |
| Workforce management | Add-on licence | `enable_quality = true` (business unit) |
| Quality management | Feature licence | `enable_quality = true` (forms) |
| Telephony minutes and numbers | Carrier or Genesys Cloud Voice | The DID pool is only a range. Numbers cost when you actually rent them |
| Recording storage | Storage and retention | The retention policy; recordings that already exist stay until the policy deletes them |
| Messaging | Usage | `enable_digital = true` |

## How to build cheaply

- Start with `minimal`. It has routing, flows, telephony and integrations only.
- Turn on one optional area at a time (`enable_ai`, then `enable_quality`, then `enable_digital`).
- Leave `hardened` and any external integrations off unless you are testing them.

## How to check

1. Run `05-inventory` before and after. It lists object counts and everything with the `DH` prefix.
2. In Genesys, open **Admin, then Billing and subscription**. Look at the subscription and the usage.
3. Check your contract for add-ons you switched on.
4. Check the carrier for numbers you rented.

## How to clean up

1. `05-inventory`. Note the counts.
2. `07-destroy`. Type `DESTROY` when you have read the list.
3. `05-inventory` again. No `DH` objects should remain.
4. Release any rented numbers with the carrier.
5. Remove the OAuth client in the screen if you will not use it again.
6. Leave the repo in Git. It is the only copy of the function source and the design.

## What `destroy` does not remove

- Recordings and transcripts already stored (they follow the retention policy).
- Anything you bought outside Terraform (numbers, add-on licences).
- The organisation itself.
- Users you added by hand.

> **Public sector note.** Value for money is a duty. The improvement ideas in the Brief (section 16B) aim at a lower cost per resolved contact, not at more features.
