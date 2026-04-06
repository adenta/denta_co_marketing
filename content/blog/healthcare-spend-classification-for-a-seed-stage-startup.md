---
title: Before ChatGPT, We Were Building AI for Healthcare Reimbursement
excerpt: Built an early healthcare fintech product that linked personal accounts, classified medical spend, and helped users recover money through AI-assisted reimbursement review.
published_on: 2022-11-09
tags:
  - project
  - case-study
  - ai
  - fintech
  - healthcare
---

Back in late 2022, before ChatGPT made generative AI the talk of the town, I was working on a healthcare fintech product with a much more useful problem: figuring out which bank and credit card transactions were actually medical.

The product connected accounts, pulled transaction history, identified health and wellness spend, and helped people recover money through reimbursement workflows like HSA and FSA claims.

This was not a budgeting app. It was an early attempt at applying AI to a real operational problem people actually had.

## Business Impact

- Turned raw bank and credit card feeds into a healthcare-specific data product instead of a generic personal finance dashboard
- Gave beta users one place to connect accounts, review likely medical spend, and compare provider pricing before care
- Built an AI-assisted workflow for classifying medical spend and reviewing reimbursement opportunities

## The Problem

Healthcare spending is hard to reconstruct after the fact.

People pay with a mix of debit cards, credit cards, insurance, and out-of-pocket funds. Merchant names are noisy. Bills show up late. A charge that might be reimbursable through an HSA or FSA often just looks like another line item on a statement.

That is the real product problem we were going after. Not "show me my finances." More like: show me which transactions were actually healthcare, help me understand what I spent, and give me a cleaner path to getting money back where reimbursement rules allowed it.

## What I Built

I built the early full-stack product around that workflow.

- Private beta onboarding with Clerk-based authentication
- Plaid Link flows for connecting bank and credit card accounts
- Backend token exchange and transaction retrieval against Plaid
- Persisted transaction records plus a CSV export task for downstream analysis
- Dashboard concepts for summarizing annual healthcare and wellness spend
- Early UX for provider and procedure price lookup, including out-of-pocket cost estimates
- Supporting product instrumentation with FullStory for beta feedback and session review

The most important technical move was not the chart. It was setting up the data loop.

Once users linked accounts, the app could pull transaction history, store normalized transaction records, and export them for deeper analysis. That is the foundation you need before any classifier is useful. The AI story here started with the data layer, but it did not stop there. The point was to use that dataset to decide which transactions looked medical, which looked ambiguous, and which might map to reimbursement opportunities.

The core workflow looked like this:

```text
User creates an account
-> links bank and credit card accounts with Plaid
-> backend exchanges tokens and pulls transaction history
-> app stores transaction records and exports the data for analysis
-> product surfaces likely healthcare spend and pricing context
-> user gets a clearer view of what may be reimbursable or worth challenging
```

## Outcome

This became a real applied AI product, not just a data pipe.

The app had authenticated users, linked financial accounts, transaction ingestion, healthcare-specific classification logic, reimbursement review workflows, and a product direction centered on medical spend intelligence rather than generic consumer finance.

That is why I remember it as early applied AI work. The hard part was not making a chart. The hard part was getting the data, shaping it into something usable, and then turning that into a workflow that could do real work for real people.
