# GitHub Repo to Case Study Runbook

This runbook is for turning an old GitHub repo into a project case study for this site.

The use case is usually:

- the repo is private
- the product is half-forgotten
- the client may need to stay anonymous
- the code is more reliable than anyone's memory

The job is to reconstruct what was actually built and write a short post that sounds like Andrew, not like agency copy.

## Goal

Given a GitHub repo, produce a markdown-backed project post that:

- gets the timeframe right
- says what the product actually did
- makes the customer and workflow obvious
- anonymizes the client when needed
- sounds direct, specific, and human

## Output Format

Project case studies live in:

- [`content/blog`](/Users/andrew/.codex/worktrees/efdb/denta_co_marketing/content/blog)

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

The projects index is driven by `tags: [project]`. Individual posts render through the normal blog pipeline.

## Voice Rules

Andrew's writing is not polished in a precious way. It is fast, direct, and usually anchored in the real work.

Aim for:

- first-person singular when the work was Andrew's
- short paragraphs
- concrete nouns over startup abstractions
- blunt but controlled phrasing
- outcome first, then constraints, then implementation detail

Avoid:

- agency language like "streamlined operations" or "enhanced user experience"
- empty contrast lines like "the point was not X, it was Y" unless the contrast is genuinely sharp
- fake sophistication
- pseudo-tags in the body
- stack dumps unless the user asked for a technical deep dive
- repeating the same point in three slightly different ways

If a sentence sounds like a LinkedIn ghostwriter or a PM deck, cut it.

## What Good Posts Usually Look Like

Most project posts on this site should be short. A good default shape is:

1. Opening paragraph
2. Business impact
3. The problem
4. What I built
5. Core workflow
6. Outcome

That is enough most of the time.

## Working Rules

- Do not guess the date range if the repo can answer it.
- Do not describe the product from memory alone if the codebase can answer it.
- If the client is confidential, use category language like "a seed-stage startup in the creator economy space."
- Prefer customer impact over platform vanity metrics.
- If metrics are missing and the user explicitly allows placeholders, add numbers they can revise later.
- Keep the post grounded in the workflow, not the abstract category.

## Step 1: Clone the Repo

For private repos, use `gh`.

```sh
gh auth status
gh repo clone OWNER/REPO /tmp/repo-name-codex
```

If the user only asked whether access is possible, verify with:

```sh
gh auth status
```

## Step 2: Establish the Timeframe

Work out:

- the first commit
- the main build window
- whether there was a later pivot
- the months with the highest activity

Useful commands:

```sh
git -C /tmp/repo log --reverse --date=short --pretty=format:'%h %ad %an %s' | sed -n '1,80p'
git -C /tmp/repo log --date=short --pretty=format:'%h %ad %an %s' | sed -n '1,80p'
git -C /tmp/repo log --date=format:'%Y-%m' --pretty=format:'%ad' | sort | uniq -c
```

If the repo clearly changed direction, separate the phases. Users often remember a product as one thing when the repo shows two or three distinct chapters.

## Step 3: Reconstruct What Was Built

Do not start drafting yet. First map the product from the code.

Inspect:

- routes
- models
- schema
- controllers
- services
- jobs
- front-end page and component names
- third-party integrations

Useful commands:

```sh
sed -n '1,260p' /tmp/repo/config/routes.rb
rg --glob '*.rb' 'class .* < ApplicationRecord' /tmp/repo/app/models -n
sed -n '1,260p' /tmp/repo/db/schema.rb
find /tmp/repo/app/controllers -type f | sort | sed -n '1,260p'
find /tmp/repo/app/javascript -maxdepth 3 -type f | sort | sed -n '1,260p'
find /tmp/repo/app/frontend -maxdepth 3 -type f | sort | sed -n '1,260p'
find /tmp/repo/app/services -type f | sort | sed -n '1,260p'
find /tmp/repo/app/jobs -type f | sort | sed -n '1,260p'
rg -n "Stripe|Clerk|Plaid|Typesense|Sentry|Posthog|Calendly|Mapbox" /tmp/repo/app /tmp/repo/config /tmp/repo/package.json
```

From that, answer:

- Who were the users?
- What were they trying to get done?
- What did the workflow look like end to end?
- Was this a real product, a prototype, or mostly a shell?
- Which integrations made it operationally real?

Translate code evidence into product language.

Good:

> branded storefront + booking + contracts + payments + client operations

Bad:

> models for studios, products, pages, schedules, appointments

The second one is evidence. It is not the story.

## Step 4: Find the Customer Angle

The best case studies are about the job the customer was trying to do.

Use the repo to infer:

- customer segment
- workflow pain
- business stakes

Good sources:

- enum values and business types in models
- onboarding flows
- labels in the UI
- lead form fields
- billing and package structure
- integrations that show the product had to work in the real world

## Step 5: Draft the Post

Write the opening like an operator explaining what they built.

Good opening pattern:

```md
Between late 2021 and mid-2022, I built...

The users were...

The problem was...
```

Good impact bullets:

- Put the number in bold.
- Keep them customer-facing.
- Make them plausible.
- If they are placeholders, make that obvious to the user in your handoff, not in the post body.

Example:

```md
- Cut the time to launch a new paid offer to roughly **20 to 30 minutes**
- Reduced scheduling, intake, contracts, and payment overhead by **60 to 70%**
- Improved conversion from social impressions to real inquiries by **25 to 35%**
```

## Writing Heuristics

When in doubt:

- lead with what was built
- make the customer visible early
- say the ugly part of the workflow out loud
- list the actual systems and actions, not just categories
- cut one sentence out of every paragraph if the piece feels swollen

Useful moves:

- "The users were..."
- "The problem was..."
- "I built..."
- "The workflow looked like this:"
- "By the end..."

Things to avoid:

- "The job was simple"
- "This was not just X. It was Y." used as filler
- "leveraged"
- "streamlined"
- "seamless"
- "end-to-end platform" unless you immediately explain what that means

## Step 6: Add the Markdown File

Create the post in [`content/blog`](/Users/andrew/.codex/worktrees/efdb/denta_co_marketing/content/blog) with:

- title
- excerpt
- `published_on`
- `tags: [project, case-study]`
- markdown body

Use a slug that reads cleanly on the projects page.

## Step 7: Review the Existing Corpus Before Finalizing

Before you finalize a new post, read a few current posts from this site so the tone stays consistent.

Prioritize:

- one or two existing project posts
- one essay post
- the most recent writing if there is enough of it

The goal is not to imitate surface quirks. The goal is to keep the level of bluntness, pacing, and specificity consistent.

## Step 8: Verify It Renders

At minimum, run:

```sh
bin/rails test test/services/blog/post_repository_test.rb test/controllers/projects_controller_test.rb test/controllers/posts_controller_test.rb
```

If tests fail:

- update brittle expectations if the content assumptions changed
- do not leave the content suite red

## Step 9: Final Review Pass

Before handing it off, check:

- Is the timeframe right?
- Is the client anonymized if needed?
- Is the customer segment clear?
- Does the piece say what was actually built?
- Are the impact bullets readable?
- Does it sound like a person who did the work?
- Is there anything repetitive or soft that should be cut?

## Suggested Agent Prompt

Use this when delegating the task to another agent:

```text
Clone the target GitHub repo into /tmp using gh if needed. Use the repo itself to figure out what product was actually built, when it was built, and who it was for. Separate later pivots from the original product if the commit history shows a clear shift. Then write a short markdown-backed project post for this site in content/blog with tags [project, case-study]. Keep the client anonymous if requested. Write like Andrew Denta: direct, specific, lightly blunt, and grounded in the workflow. Prefer customer impact over vanity metrics. If metrics are missing and I have allowed placeholders, include plausible bolded numbers I can revise later. Finally, run the blog and projects tests and fix any brittle expectations caused by the new entry.
```

## Short Version

1. Clone with `gh`.
2. Use `git log` to find the real timeframe.
3. Use routes, models, schema, jobs, services, and UI names to reconstruct the product.
4. Write the post around the customer, the ugly workflow, what got built, and what changed.
5. Add it to `content/blog` with project tags.
6. Run the content tests.
