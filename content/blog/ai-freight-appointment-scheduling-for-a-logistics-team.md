---
title: AI Agent for Freight Appointment Scheduling
excerpt: Built an internal AI agent that turned live freight data, facility notes, and scheduling rules into appointment suggestions and ready-to-send emails.
published_on: 2024-06-18
tags:
  - project
  - case-study
---

I built an internal AI agent for a logistics company dealing with appointment-heavy freight moves. It pulled live order data into one place, read facility notes, surfaced the right contacts, suggested appointment times, and drafted outbound scheduling emails.

The users were freight operations staff trying to schedule pickup and delivery appointments without missing receiving windows, blowing up transit logic, or getting buried in bad data.

The goal was simple: take a bloated manual scheduling process and compress it into something one operator could actually run.

## Business Impact

I put shipment search, facility notes, contact lookup, appointment suggestions, and outbound email drafting into one internal agent. That helped reduce a scheduling operation from roughly **20 people to 1**.

## The Problem

Freight appointment scheduling is ugly work.

Operators were juggling order data, stop details, facility comments, contact records, audit logs, call-ins, and email. Some of the rules lived in SOPs. A lot of them lived in someone's head. The real job was part timing math, part exception handling, and part hard-earned operator instinct.

That falls apart fast when volume goes up. A strong scheduler can still waste hours digging for the right contact, checking whether a facility is appointment-only, figuring out whether a pickup time is actually realistic, or rewriting the same appointment request over and over.

They needed something that could absorb the ugly parts of the job and get a human to a real appointment faster.

## What I Built

I built the product around the scheduling workflow itself.

- Authentication and organization-based access for internal operators
- Shipment search against a live freight API using order IDs
- Shipment views that pulled stop data, distance, timing, and appointment context into one screen
- Services to pull facility notes, contact details, audit history, and call-in activity from the underlying logistics system
- A generative AI workflow that used the team's SOP, transit rules, facility constraints, and prior examples to suggest appointment times
- Email drafting through Outlook so operators could generate appointment requests without rewriting the same message every time
- Task records and task updates so follow-up work could be tracked instead of living entirely in memory

The core workflow looked like this:

```text
Scheduler searches for an order
-> reviews stops, miles, and timing constraints
-> pulls facility notes and contact information
-> checks call-in / audit context when needed
-> gets a suggested appointment time based on SOP and transit logic
-> drafts the outbound scheduling email
-> tracks follow-up as a task until the appointment is locked in
```

That was the value. The agent handled the repetitive, annoying, error-prone work that used to require a much bigger team.

## Outcome

This turned into a real internal product for a narrow, high-friction operations job. It connected live order data, scheduling rules, generative AI appointment suggestions, and outbound communication in one place.

The end result was an operational agent with enough real context to do useful work: read the shipment, understand the constraints, suggest the move, and tee up the email.
