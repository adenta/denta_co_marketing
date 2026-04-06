---
title: Context Engineering Is Only Half the Battle
excerpt: Why scaffolds matter just as much as context engineering when you want reliable self building software.
published_on: 2025-07-07
---

The next decade of software engineering will revolve around context engineering. We no longer just write the thing. We write the thing _that writes the thing_.

But I think that is only half the equation.

Watch this video of a laser-etched dog tag:

{{ youtube url="https://youtu.be/8IkufN4_Tr0" }}

The laser engraver is context engineering: precision, focus, and a very specific path. That is what a good prompt is doing too.

The dog tag is a different kind of technology. Millions of identical blanks were pumped out of a factory using the same process over and over. If context engineering is the laser engraver, the dog tags are the **scaffold**.

## What Is a Scaffold?

A scaffold is a computer program that writes boilerplate code. It generates code, but **without** an LLM. The benefit is that it is deterministic. It works the same way every time. Scaffolds help AI write better code because the model can focus on the unique parts of an application instead of burning cycles on boilerplate.

## Rails + React

I spend a lot of time in Ruby on Rails, and I prefer using React on the front end. This isn't exactly a default combo, and there are a dozen ways to wire the two technologies together.

Here is the problem: even with carefully crafted prompts and rules, language models just do not set it up the same way every time. I end up with three ways to send data to the front end and five ways to send it to the back end. The model is taking its best guess at each step.

So I built a [scaffold](https://gist.github.com/adenta/35d2443957f11fc75b2f0df81005c043#file-react_generator-rb).

Now when I spin up a page, it follows the layout I _actually_ use instead of some boilerplate hallucination. I still use LLMs, but only for the bespoke stuff: business logic that changes from app to app. The models can work on top of generated code that is already shaped correctly. It is faster, cleaner, and a lot less frustrating.

Scaffolds are not glamorous or demo-worthy, but they are the invisible infrastructure we are going to rely on if we want LLM workflows to be reliable. **The challenge is not just generating output. It is guiding it.** The future will not be written by LLMs alone. It will be shaped by the scaffolds around them.

[^1]: In Ruby on Rails these are called Templates and Generators. <https://guides.rubyonrails.org/generators.html>. Python has an unrelated thing called a generator, so I went with scaffold for this article.
