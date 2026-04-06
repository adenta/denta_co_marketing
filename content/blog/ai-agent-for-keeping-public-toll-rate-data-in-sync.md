---
title: AI Agent for Keeping Public Toll Rate Data in Sync
excerpt: Built an AI agent that checked toll rates against public source-of-truth websites and schedules, separated real data issues from website noise, and showed exactly which records needed updating.
published_on: 2026-04-06
tags:
  - project
  - case-study
  - ai
  - data
---

In November 2025, I built an AI agent for a toll-data company that had a very normal enterprise problem: the source of truth was public, but it was scattered across official websites, calculators, and PDFs, and the internal database was drifting.

The job was not just to ask whether the existing data was "valid." The real job was to figure out what the most up to date rate probably was, where the public source was reliable, and which rows in the database actually needed attention.

This was exactly the kind of problem AI is good at when it is boxed in properly. The pages were messy, the URL patterns were inconsistent, the naming was ambiguous, and some of the "official" sources were half-calculator, half-website, half-broken. A deterministic scraper alone was not enough, but a raw LLM pass without structure would have been useless.

## Business Impact

- Validated roughly **122k** toll-rate records against public source-of-truth pages, schedules, and calculators
- Reduced the review queue down to the roughly **2%** of records that were actually invalid and worth checking instead of dumping every scrape failure and website quirk on the data team
- Used a hybrid of **rules engine**, **language model**, and **browser agent** workflows so static schedules, clean routes, and messy interactive pages could all be validated in one system

## The Problem

Toll-rate data looks simple until you try to keep it current.

The public source of truth is often not an API. It is a calculator page, a PDF, a schedule table, or some strange authority website that assumes a human is clicking through it. Entry and exit names do not always line up cleanly with the names in your database. Vehicle classes are encoded differently. Payment methods do not map one to one. Sometimes the page loads but does not actually show the rate you need.

So the data team had two bad options:

- trust stale rows in the database
- send somebody to manually check routes against public sites one at a time

That does not scale when one agency alone has thousands of route and vehicle combinations.

## What I Built

I built a validation system around the actual shape of the problem instead of pretending every rate lived on a clean web page.

- A rules engine that handled deterministic work first: canonical URL generation, plaza-name mapping, vehicle-class mapping, and other cases where the source could be reached and interpreted reliably without a model
- A language-model workflow that read public pages and schedules, extracted the relevant rate, compared it to the database value, and returned structured validation results with notes and confidence
- A browser-agent workflow for the ugly cases where the source of truth lived behind interactive toll calculators, JavaScript-rendered content, or page flows that a simple fetch could not handle
- Context-aware disambiguation for ambiguous plaza names where the correct meaning depended on the paired entry and exit
- A schedule-based path for barrier tolls and other routes where same-entry and same-exit logic broke the public calculator
- Reporting that broke failures into useful categories instead of treating every miss as the same problem

There were really three workflows in the system:

1. Rules engine for the clean deterministic cases
2. Language model for semi-structured public pages and schedules
3. Browser agent for interactive or JavaScript-heavy sources that had to be operated more like a person

The workflow looked like this:

```text
database row comes in
-> system routes it to the rules engine, language model, or browser-agent path
-> app maps internal plaza names and vehicle classes to the public source format
-> validator fetches or operates the public source
-> system extracts the relevant rate and compares it to the database value
-> result is stored as valid, invalid, or unvalidated with notes about why
-> data team gets a prioritized list of real mismatches instead of raw noise
```

The split between real mismatches and website failure modes mattered a lot. The whole point was to avoid sending operators after every apparent failure. A broken calculator page, an unsupported route, missing public data, and an actually wrong rate are not the same thing, and the system had to classify them differently if the output was going to be useful.

## Outcome

The useful outcome was not "AI checked some websites." The useful outcome was that a messy public-data maintenance job became a workable operations pipeline.

By the end, the system had validated data at real operating scale and made the cleanup queue much sharper. The team was no longer chasing every weird website behavior as if it were a pricing bug. They could focus on the small slice of records that were actually invalid, while the rest of the system handled deterministic cases with rules, fuzzy public-source interpretation with a model, and the truly annoying interactive cases with a browser agent.

That is the kind of AI work I like: narrow scope, real source material, structured outputs, and a direct path from model judgment to something an operations team can actually use.
