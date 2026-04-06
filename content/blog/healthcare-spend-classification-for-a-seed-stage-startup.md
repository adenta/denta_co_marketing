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

In late 2022, before ChatGPT made generative AI the talk of the town, I was working on a healthcare fintech product. The problem was much more useful: figuring out which bank and credit card transactions were actually medical.

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

I built a full-stack product that made that workflow real from end to end.

- User onboarding, account connection, and authenticated product access
- Backend data pipelines for retrieving, normalizing, and storing transaction activity
- Structured transaction records, secure data handling, and a hardened production architecture built with HIPAA, SOC 2, and HITRUST readiness in mind
- Product dashboards for annual healthcare and wellness spend visibility
- Consumer-facing flows for provider pricing, procedure lookup, and reimbursement review
- Instrumentation and feedback loops to support beta usage and product iteration

The most important technical move was not the chart. It was building the data loop underneath the product.

Once users connected their financial data sources, the app could ingest transaction history, turn it into normalized records, and feed that data back into analysis and classification. That is the foundation you need before any AI layer becomes useful. The point was not just to collect data, but to turn it into a product that could identify likely healthcare spend, flag ambiguity, and surface reimbursement opportunities in a way users could actually act on.

The core workflow looked like this:

```text
User creates an account
-> connects relevant financial accounts
-> backend retrieves and processes transaction history
-> app stores transaction records and exports the data for analysis
-> product surfaces likely healthcare spend and pricing context
-> user gets a clearer view of what may be reimbursable or worth challenging
```

## Outcome

This became a real applied AI product, not just a data pipe.

The app had authenticated users, linked financial accounts, transaction ingestion, healthcare-specific classification logic, reimbursement review workflows, and a product direction centered on medical spend intelligence rather than generic consumer finance.
