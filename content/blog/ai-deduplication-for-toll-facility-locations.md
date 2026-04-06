---
title: AI Deduplication for Toll Facility Locations
excerpt: Built a hybrid rules-plus-AI system that reconciled duplicate facility location records across two toll datasets and turned a manual matching job into an operational data pipeline.
published_on: 2026-04-06
tags:
  - project
  - case-study
  - ai
  - data
---

In late 2025, I worked on a data problem for the [electronic toll collection](https://en.wikipedia.org/wiki/Electronic_toll_collection) industry that sounds boring until you try to solve it at scale: two toll datasets were both describing the same real-world plazas and facilities, but the names, codes, coordinates, and identifiers did not line up cleanly enough for ordinary matching to work.

One system had service locations. The other had canonical plaza identifiers used for downstream reporting. If those did not reconcile, everything downstream got softer: reporting, rollups, facility-level analysis, and any workflow that assumed one place in the real world had one clean ID.

This was really a deduplication problem hiding inside a cross-system mapping problem.

## Business Impact

- Matched **81.5%** of the working dataset across tens of thousands of location records flowing through the reconciliation pipeline
- Resolved a couple thousand discrepancies automatically with smaller, locally built and run models after a rules pass cleared the obvious cases
- Cut what had been a weeks-long reconciliation problem down to hours of automated location matching for just **$28.15** in total AI cost

## The Problem

Real-world facility data is ugly.

The same plaza can appear under different names, different abbreviations, different ramp descriptions, different numbering schemes, and different coordinate quality depending on which system you are looking at. Sometimes one dataset has the state. Sometimes it does not. Sometimes the plaza number is present but the human-readable label is useless. Sometimes the human-readable label is decent but the codes drifted years ago.

That means naive deduplication breaks fast.

Exact-name matching misses too much. Simple fuzzy matching creates bad merges. Coordinate matching helps, but only when the coordinates are actually trustworthy. And manual review gets expensive fast once you are into the thousands of records.

## What I Built

I built a hybrid matching pipeline that treated the easy cases like engineering and the hard cases like judgment.

- A rule-based matching pass for exact plaza-number matches, code matches, coordinate proximity, and high-similarity name matches
- Confidence scoring so obvious matches could clear without spending model tokens
- An AI matching pass for the unresolved cases using smaller models on the ambiguous middle instead of throwing a giant model at every record
- Candidate selection across the canonical plaza dataset so the model had real alternatives instead of having to hallucinate
- Batch processing and incremental saves so long-running jobs could finish cleanly and survive partial failures
- Output files and reporting that separated matched, unmatched, no-match, and malformed-response cases for review

The workflow looked like this:

```text
load source facility locations
-> run deterministic matching on names, codes, coordinates, and state
-> remove the easy wins from the queue
-> build ranked candidate sets for the hard cases
-> send only those cases to the AI matcher
-> store match ID, confidence, and reasoning
-> route low-confidence or no-match cases to follow-up review
```

This also turned out to be more of a language problem than it looked at first.

Yes, coordinates and codes mattered. But the hard cases were mostly about naming. Different systems described the same plaza with different abbreviations, route references, ramp labels, directional hints, and operator-specific shorthand. Once that was obvious, it made sense that large language models performed so well. They were good at interpreting whether two messy location descriptions were actually talking about the same place.

The part that surprised me was cost. This was one of the projects that made it obvious that smaller models were getting genuinely useful for narrow industrial data work. I was also surprised by how well the Gemini 3 models were performing on this task. Once the candidate set was constrained and the prompt was pointed at the right decision, the economics got silly fast.

## Outcome

The end result was not perfect, and that was fine. The point was to turn a messy identity-resolution problem into a tractable pipeline.

The system matched **81.5%** of the dataset and separated the clean matches from the records that still needed follow-up, better geographic context, or manual review. That is much better than a fake **100%** match rate built on bad merges.

More importantly, it proved that this category of deduplication work did not need to stay manual. With the right rules, candidate generation, and constrained AI judgment, the team could reconcile facility data at production scale for **$28.15** total, spend human time on the genuinely weird cases instead of all of them, and stop treating reconciliation like a permanent manual cleanup project.
