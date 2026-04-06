# GitHub Repo to Case Study Runbook

This runbook explains how to turn an old GitHub repo into a project case study for this site.

It is optimized for:

- private repos cloned with `gh`
- incomplete memory about the project
- confidential clients
- old startup work where the real product has to be reconstructed from code and commit history

## Goal

Given a GitHub repo, produce a short, credible project writeup that:

- identifies the correct time period
- describes what was actually built
- avoids naming confidential clients if requested
- sounds like Andrew's writing, not generic agency copy
- lands as a markdown-backed project post on this site

## Output Format for This Site

Project case studies live in:

- [`content/blog`](/Users/andrew/.codex/worktrees/5376/denta_co_marketing/content/blog)

They need frontmatter like:

```md
---
title: Example project title
excerpt: One-sentence summary for the projects index.
published_on: 2026-04-06
tags:
  - project
  - case-study
---
```

The projects index is driven by `tags: [project]`. Individual posts render through the normal post pipeline.

## Working Rules

- Do not guess the date range if the repo can answer it.
- Do not describe the product from memory alone if the codebase can answer it.
- If the client is confidential, replace the client name with category language like "a seed-stage startup in the creator economy space."
- Keep the writing short and direct.
- Avoid fake sophistication like loose pseudo-tags in the body.
- If metrics are missing and the user explicitly allows placeholders, add numbers they can revise later.
- Prefer customer impact over platform vanity metrics.

## Step 1: Clone the Repo

For private repos, use `gh`, not unauthenticated `git clone`.

Example:

```sh
gh auth status
gh repo clone OWNER/REPO /tmp/repo-name-codex
```

If the user only asked whether access is possible, first verify:

```sh
gh auth status
```

Then clone into `/tmp` and inspect from there.

## Step 2: Establish the Timeframe

Start by identifying:

- the first commit
- the most recent commits
- whether there was a later pivot you should exclude
- the months with the most activity

Useful commands:

```sh
git -C /tmp/repo log --reverse --date=short --pretty=format:'%h %ad %an %s' | sed -n '1,80p'
git -C /tmp/repo log --date=short --pretty=format:'%h %ad %an %s' | sed -n '1,80p'
git -C /tmp/repo log --date=format:'%Y-%m' --pretty=format:'%ad' | sort | uniq -c
```

What to look for:

- initial build window
- dense product iteration window
- a later feature branch or pivot that changes what the product is

If a clear pivot exists, explicitly separate:

- "original product"
- "later pivot"

This matters because users often remember the project loosely and mix phases together.

## Step 3: Reconstruct What Was Built

Do not start with prose. First map the product from the code.

Inspect:

- routes
- models
- schema
- controllers
- services
- front-end page and component names
- third-party integrations

Useful commands:

```sh
sed -n '1,260p' /tmp/repo/config/routes.rb
rg --glob '*.rb' 'class .* < ApplicationRecord' /tmp/repo/app/models -n
sed -n '67,260p' /tmp/repo/db/schema.rb
find /tmp/repo/app/controllers -type f | sort | sed -n '1,260p'
find /tmp/repo/app/javascript -maxdepth 3 -type f | sort | sed -n '1,260p'
find /tmp/repo/app/services -type f | sort | sed -n '1,260p'
rg -n "Stripe|Clerk|Typesense|Sentry|Posthog|Calendly" /tmp/repo/app /tmp/repo/config /tmp/repo/package.json
```

From that, answer:

- Who were the users?
- What jobs were they trying to do?
- What workflows existed end to end?
- Was this a real product, a prototype, or a marketing shell?
- Which integrations made it operationally real?

The goal is a product description like:

> branded storefront + booking + scheduling + lead capture + contracts + payments

not:

> models for studios, products, pages, schedules, appointments

The latter is evidence, not the final story.

## Step 4: Find the Customer Angle

The best case studies talk about the user, not just the code.

Use the repo to infer:

- customer segment
- workflow pain
- business stakes

Sources of truth:

- enum values and business types in models
- labels in front-end copy
- onboarding flows
- fields in lead forms
- offer/package structure

Example:

- If the repo has business types like interior design and creator-style public profile pages, the customer angle might be small interior design influencers or independent studios selling high-touch services.

## Step 5: Draft the Case Study

For this site, keep the structure tight. A good default is:

1. Opening paragraph
2. Business impact
3. The problem
4. What I built
5. Core workflow
6. Outcome

That is usually enough. Add a technical section only if the user wants it.

### Writing Guidelines

- Keep paragraphs short.
- Prefer strong nouns over abstract startup phrases.
- Cut repeated words like "platform", "workflow", "solution", and "experience" if they appear too often.
- Avoid sounding like an agency deck.
- Sound like Andrew's articles: direct, specific, a little blunt, not overpolished.
- Do not use the phrase "The job was simple" or treat it as a default opening pattern.

### Good opening pattern

```md
Between late 2021 and mid-2022, I built...

The users were...

The business problem was...
```

### Good impact bullets

- Put the number in bold.
- Make them customer-facing.
- If the user says to invent placeholder metrics, do that and let them revise later.
- Use creator-language when appropriate: "social impressions", "inquiries", "bookings", "offers", "clients".

Example:

```md
- Cut the time to launch a new paid offer to roughly **20 to 30 minutes**
- Reduced scheduling, intake, contracts, and payment overhead by **60 to 70%**
- Improved conversion from social impressions to real inquiries by **25 to 35%**
```

### Things to avoid

- pseudo-tags in plain text like `Creator Economy · Seed Stage`
- repetitive sections that restate the same point three ways
- long stack dumps unless requested
- generic claims like "streamlined operations" without any concrete workflow

## Step 6: Add the Markdown File

Create a new file in [`content/blog`](/Users/andrew/.codex/worktrees/5376/denta_co_marketing/content/blog) with:

- project title
- short excerpt
- `published_on`
- `tags: [project, case-study]`
- markdown body

Use a slug that reads cleanly on the projects page.

## Step 7: Verify It Renders

At minimum, run the content-related tests:

```sh
bin/rails test test/services/blog/post_repository_test.rb test/controllers/projects_controller_test.rb test/controllers/posts_controller_test.rb
```

If tests fail:

- update brittle expectations if the content assumptions changed
- do not leave the suite red if the new project entry is now part of the expected output

## Step 8: Final Review Pass

Before handing it off, check:

- Is the date range correct?
- Is the client anonymized if needed?
- Is the customer segment clear?
- Does the piece say what was actually built?
- Are the impact bullets bolded and readable?
- Does it sound like a human wrote it, not a PM deck?
- Is there anything obviously repetitive that should be cut?

## Suggested Agent Prompt

Use this when delegating the task to another agent:

```text
Clone the target GitHub repo into /tmp using gh if needed. Use the repo itself to reconstruct what product was built, when it was built, and who it was for. Separate any later pivots from the original product if the commit history shows that. Then write a short markdown-backed project case study for this site in content/blog with tags [project, case-study]. Keep the client anonymous if requested. The writing should be punchy, direct, and closer to Andrew Denta's existing articles than generic startup copy. Prefer customer impact over platform metrics. If metrics are missing and I have allowed placeholders, include plausible bolded numbers I can revise later. Finally, run the blog/project controller tests and fix any brittle expectations caused by the new entry.
```

## Short Version

1. Clone with `gh`.
2. Use `git log` to find the real timeframe.
3. Use routes, models, schema, services, and UI file names to reconstruct the product.
4. Write the post around the customer, problem, workflow, and outcome.
5. Add it to `content/blog` with project tags.
6. Run the content tests.
