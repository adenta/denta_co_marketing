---
title: 5 takeaways from doing AI diligence in healthcare
excerpt: I spent some time doing AI diligence in healthcare and came away with a handful of opinions that feel more durable than any one company or demo.
published_on: 2023-07-12
tags:
  - ai
  - healthcare
  - diligence
---

## 1. Think about what the models will be capable of in 18 months, not just today

The interesting companies are not the ones building something anyone could have built five years ago.

The interesting companies are building things that only kind of work today, but will probably work extremely well once the models get a lot better.

That is the real bet.

If you are building something that works great right now with today's model quality, there is a decent chance you are already too late or not aiming at a very interesting wedge.

The better question is: if the models get materially better over the next 18 months, does this unlock a much bigger workflow?

That is the pattern I keep looking for.

## 2. Agentic workflows will get more common once tool calling gets better

A lot of healthcare work is not one prompt.

It is more like:

- read a document
- pull context from a system
- check a rule
- draft something
- log the action
- hand the case to a human if it gets weird

That is why the "AI agent" story still feels early to me in 2023. The vision makes sense. The reliability does not always make sense yet.

Once models get better at calling tools, holding state, and recovering from mistakes, a lot more of these workflows open up. Until then, a lot of "agentic" product talk is really just smart prompt chaining with a nice UI on top.

## 3. Language models are really good at language tasks

This sounds obvious, but I think it rules out a lot of bad ideas.

Language models are really good at *language* tasks.

That means a useful question is: how much of this workflow can be broken down into *language*?

Filling out forms is a *language* task. Explaining what is going on in a prior auth workflow to a physician or provider is a *language* task. Reading policy docs is a *language* task. Summarizing a chart, drafting an appeal, classifying an inbound fax, extracting fields from messy text, or routing a case based on what somebody wrote are all *language* tasks.

Healthcare has a lot of these hidden in plain sight.

Notes, faxes, policy docs, intake forms, appeal letters, referral text, message threads, payer communications. The space is full of operations problems that are really *language* problems once you look closely.

That does not mean models solve everything. It means they are best when pointed at the part of the workflow that is actually made of *language*.

## 4. Security matters even more than people want it to

In healthcare, you cannot casually throw sensitive data at whichever model is easiest to access.

That sounds basic, but in practice it creates real product and infrastructure tradeoffs.

Right now, the model decision is not just about quality. It is also about where the model is running, what contractual protections exist, and what kind of data handling story you can actually defend.

Azure OpenAI is now generally available. OpenAI changed its API data policy on March 1, 2023 so customer data sent through the API is not used to train models by default. AWS announced Bedrock in April 2023, but it is still in preview.

So the practical question is not just "which model is best?"

It was more like:

- can we aggressively de-identify or redact the data before it touches a model?
- if we do that, how much useful context do we lose?
- do we pay more for enterprise cloud rails and stricter contractual controls?
- how much extra cost and procurement drag does that introduce?

That tradeoff feels very real. Anonymization lowers risk, but it can also remove the exact context that makes the output useful. More locked-down infrastructure preserves more of the workflow, but it costs more money and slows you down.

My strong bias is that healthcare teams should take security paranoia seriously. It is not red tape. It is part of the product.

## 5. Human in the loop today, automation tomorrow

The strongest companies were not pretending the model could own the whole workflow on day one.

They were using models to tee up work for humans:

- summarize the case
- extract the relevant fields
- suggest the draft
- flag the edge case
- route the work to the right person

That is a much more believable wedge.

In healthcare, the hard part is usually not getting a model to say something plausible. The hard part is getting to a workflow that is reliable, auditable, and safe enough to trust.

So the path usually looks like human in the loop first, then deeper automation later.

That is not a weakness. That is the normal path.
