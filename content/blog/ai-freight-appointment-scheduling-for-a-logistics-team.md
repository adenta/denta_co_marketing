---
title: Voice Agent for Freight Appointment Confirmation
excerpt: Built a voice agent for a freight carrier that called warehouses, confirmed truck appointment times, and pushed the results back into the scheduling workflow.
published_on: 2025-03-01
tags:
  - project
  - case-study
---

In early 2025, right as voice started becoming mainstream instead of just demo bait, I built a voice agent for a freight carrier that called warehouses to confirm when trucks were supposed to show up.

The users were carrier ops and scheduling staff dealing with appointment-heavy freight. Their job was to make sure trucks hit the dock at the right time without missing receiving windows, creating detention, or spending half the day chasing somebody at a warehouse who may or may not pick up.

[Vapi](https://vapi.ai) was the main reason this got deployed quickly. I did not need to burn weeks on telephony plumbing, SIP trivia, or stitching together a brittle call stack from scratch. That said, I was not blown away by the latency. Voice systems still had, and still have, a long way to go before they feel truly sharp in live operations. Even so, Vapi got me to a deployable system fast enough that I could focus on the real problem: giving the agent enough shipment context, guardrails, and workflow hooks to handle confirmation calls like an actual operations tool.

## Business Impact

- Cut manual appointment-confirmation work by roughly **15 to 20 scheduler hours per week**
- Automated or materially accelerated roughly **60 to 70%** of routine outbound warehouse confirmation calls
- Reduced the time from "this load needs a confirmed appointment" to a logged scheduling outcome from about **45 minutes** to under **10 minutes** for straightforward cases

## The Problem

Freight appointment scheduling is ugly work.

The ugly part is not just setting an appointment. It is confirming that the appointment still means anything in the real world.

Warehouses have different receiving rules, different hours, different phone trees, and different levels of chaos. Trucks run early. Trucks run late. Notes in the TMS are incomplete. Sometimes the appointment is in an email thread. Sometimes it is buried in a comment. Sometimes nobody can tell you anything until you get the right person on the phone.

So schedulers were stuck doing repetitive outbound calls just to answer a basic question: when is this truck actually expected at the warehouse, and is that time confirmed?

That is exactly the kind of work voice is good at when it is grounded in real context. It is repetitive, high-friction, and operationally important, but it still needs to sound coherent and capture the answer cleanly.

## What I Built

I built the product around that confirmation workflow.

- An outbound voice agent deployed through Vapi
- Internal tooling that assembled the call context: load details, stop data, facility phone numbers, ETA context, and warehouse notes
- Prompt and call logic shaped around the team's actual SOP instead of generic customer support scripts
- Structured capture of confirmed appointment times, callback instructions, check-in constraints, and unresolved outcomes
- Escalation paths for edge cases where the agent should stop guessing and hand the call back to a human
- Write-back into the scheduling workflow so the result of the call was operational data, not just a transcript

The core workflow looked like this:

```text
Scheduler flags a load that needs appointment confirmation
-> system assembles the warehouse number, shipment context, ETA, and notes
-> Vapi voice agent places the outbound call
-> agent confirms the receiving appointment time or captures the constraint blocking confirmation
-> system records the outcome as structured scheduling data
-> human ops staff only step in for exceptions, escalations, or bad facility data
```

This was the right use of voice. The agent was not trying to charm people or freestyle. It had a narrow job, real context, and a clear definition of done.

## Outcome

By the end, this was a real internal operations tool for a freight carrier, not a sandbox demo. It handled one of the most annoying parts of appointment scheduling with an interface warehouses already use every day: the phone.

More importantly, it landed at the right moment. Early 2025 was when voice finally started feeling deployable for narrow business workflows. Vapi made it practical to ship fast, and the rest of the work was about making the agent useful in the messy reality of freight: bad notes, changing ETAs, warehouse ambiguity, and the constant need to get to a confirmed time without wasting another operator's afternoon.
