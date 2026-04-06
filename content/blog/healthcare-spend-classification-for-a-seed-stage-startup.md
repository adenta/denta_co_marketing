---
title: Before ChatGPT, I Was Building AI for Healthcare Reimbursement
excerpt: I built an early healthcare fintech product that connected personal accounts, figured out which transactions were actually medical, and helped users recover money through reimbursement workflows.
published_on: 2022-11-09
tags:
  - project
  - case-study
  - ai
  - fintech
  - healthcare
---

In late 2022, before ChatGPT made generative AI the talk of the town, I was building a healthcare fintech product.

The problem was not "personal finance," really. The problem was: people spend money on healthcare in messy ways, and later they have no clean way to figure out what was actually medical, what might be reimbursable, and what they should do next.

The product connected financial accounts, pulled transaction history, identified likely health and wellness spend, and helped people work through reimbursement flows like HSA and FSA claims.

The interesting part was the plumbing. I was linking accounts through Plaid, ingesting transaction data, and using that data in healthcare-specific workflows like spend review and provider pricing.

## Business Impact

- Turned raw bank and credit card feeds into a healthcare-specific data product
- Gave users one place to connect accounts, review likely medical spend, and understand what might be reimbursable
- Built a workflow that helped people go from noisy transaction history to something they could actually act on
- Pointed the product toward medical spend intelligence instead of generic budgeting

## The Problem

Healthcare spending is annoying to reconstruct after the fact.

People pay with credit cards, debit cards, insurance, out-of-pocket funds, and whatever card happens to be in their wallet that day. Merchant names are vague. Bills come in late. A charge that might matter for reimbursement often just looks like random statement noise.

So the real product question was:

- Which of these transactions were actually healthcare?
- What did the user really spend?
- What might be reimbursable?
- What should they look at more closely?

## What I Built

I built the full-stack product around that workflow.

- User onboarding and authenticated account access
- Financial account connection and transaction retrieval
- Backend pipelines for ingesting, normalizing, and storing transaction history
- Classification logic for identifying likely healthcare and wellness spend
- Dashboards for annual healthcare spend visibility
- Consumer-facing flows for provider pricing, procedure lookup, and reimbursement review
- Secure data handling and a production architecture built with HIPAA, SOC 2, and HITRUST readiness in mind
- Instrumentation and feedback loops for beta usage and iteration

The hard part was getting the data loop right.

Once a user connected accounts, the product could ingest transaction history, turn messy financial records into structured data, and feed that into analysis and classification. Without that layer, the AI part is mostly theater.

The product only worked if it could identify likely healthcare spend, flag ambiguity, and surface reimbursement opportunities in a way a real person could actually use.

The workflow looked something like this:

```text
user creates an account
-> connects financial accounts
-> backend retrieves transaction history
-> app normalizes and stores the data
-> system identifies likely healthcare spend
-> product surfaces reimbursement and pricing context
-> user gets a clearer picture of what happened and what might be worth reviewing
```

## Outcome

This was a real product, not just an AI wrapper demo.

It had authenticated users, linked accounts, transaction ingestion, healthcare-specific classification, reimbursement review flows, and a product direction centered on helping people make sense of medical spend.

That is what I mean when I say I was building AI in healthcare before the current hype cycle. The hard part was turning messy inputs into a workflow that could do useful work for real people.
