---
title: Context Engineering Is Only Half the Battle
excerpt: Why scaffolds matter just as much as context engineering when you want reliable AI-assisted software delivery.
published_on: 2025-07-07
---

The next decade of software engineering will revolve around Context Engineering. We no longer write the thing, we write the thing *that writes the thing*.

But I think this is only half the equation.

Lets watch this cool video of a laser etched dog tag:

{{ youtube url="https://youtu.be/8IkufN4_Tr0" }}

The laser engraver represents context engineering itself: a process of precision and focus. The engraver must follow an exact path to etch a design. This is similar to how you want to construct a prompt to guide the model's attention.

The dog tag represents a different, more primitive technology. Millions of identical blank tags were pumped out of a factory, using the exact same process at thousands a minute. If context engineering is like a laser engraver, lets call the dog tags a **scaffold**.

## What Is a Scaffold?

A scaffold is a computer program that writes boilerplate code. It's code that generates code, but **without** an LLM. The key benefit here is it's deterministic: It works the same way every time. Scaffolds help AI write better code, because now the AI can focus on the unique parts of an application, instead of the boilerplate.

## Rails + React

I spend a lot of time in Ruby on Rails, and I prefer using React on the front end. This isn't exactly a default combo, and there are a dozen ways to wire the two technologies together.

Here's the problem: even with carefully crafted prompts and "rules," language models just don't set it up the same way every time. I wind up with three methods to send data to the front end and like *five* to send it to the back end. The LLM is just taking its best guess each step along the way.

So I built a [scaffold](https://gist.github.com/adenta/35d2443957f11fc75b2f0df81005c043#file-react_generator-rb)[^1].

Now, when I spin up a page, it follows the layout I *actually* use and not some boilerplate hallucination. I still use LLMs, but only for the bespoke stuff: business logic that will change with every application. The LLMs can dance on top of the generated code from the scaffold. It's faster, cleaner, and way less frustrating.

Scaffolds aren't glamorous or demo-worthy, but they're the invisible infrastructure we'll increasingly rely on to make LLM-powered workflows truly reliable. **The challenge isn't generating output, it's guiding it.** The future won't be written by LLMs alone; it'll be shaped by the scaffolds that guide them.

[^1]: In Ruby on Rails these are called Templates and Generators. <https://guides.rubyonrails.org/generators.html>. Python has an unrelated thing called a generator, so I went with scaffold for this article.
