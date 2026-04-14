---
title: Claude Plays Pokemon Hackathon at Latent Space
excerpt: On April 5, 2025, I joined Latent Space in San Francisco to talk through the Ruby-based Pokemon-playing agent I had been building, why emulator integration was the real bottleneck, and why I was happy to cheat with RAM reads when computer vision got in the way.
published_on: 2025-04-05
tags:
  - ai
  - ruby
  - agents
  - pokemon
---

On April 5, 2025, I joined Latent Space's _Claude Plays Pokemon Hackathon: Escape from Mt. Moon!_ in San Francisco and gave a short walkthrough of the Ruby-based Pokemon agent I had been building.

The exact segment is [here](https://www.youtube.com/watch?v=zBPc6Ims1Bc&t=1670s).

{{ youtube url="https://www.youtube.com/watch?v=zBPc6Ims1Bc&t=1670s" }}

I came into this project from a slightly different angle than "can an LLM beat Pokemon fairly?" I was more interested in building a full virtual streamer: something that could play the game, talk to Twitch chat, react to what was happening on screen, and eventually battle other agents on stream. Once you frame the problem that way, a lot of the engineering choices get less academic and more practical.

## What I Built

I used RetroArch as the emulator because I wanted something that was not locked to one game or one console. If the larger goal is a virtual character that can play games live, it is useful to start from a setup that could eventually stretch beyond Pokemon.

Everything around the emulator was pretty ordinary in the best possible way: Ruby on Rails, SQLite, GPT-4o with structured output, a simple main loop, a basic battle handler, a conversation handler, and A* pathfinding for movement. That is worth saying because people tend to spend too much time talking about prompts and not enough time talking about the harness around the model.

The hard part was not writing a more clever system prompt. The hard part was getting reliable state out of the emulator and reliable button presses back in.

## The Useful Kind of Cheating

My main strategy for computer vision was to do as little computer vision as possible.

I used screenshots and OCR for dialogue, but for map data, NPC locations, walkable tiles, and player position, I reached directly into emulator memory. That gave the model a much cleaner representation of the world. Instead of asking it to infer everything from pixels, I could say: here is the map, here is where you are, here is where you can walk, and here are the destinations that matter.

That is obviously not how a human plays Pokemon. Humans look at the screen. They do not read RAM and feed coordinates into a pathfinder.

I still think it is the right place to start.

Too many conversations about agent systems get stuck on purity tests. Is reading memory cheating? Is A* cheating? Is a long-running context window cheating? Maybe. But if the goal is to build something that actually works, scaffolding matters. Start with the version that can function. Then remove the cheats one by one and see what still holds up.

That is a much better way to learn than pretending a half-broken vision stack is more honest.

## What Actually Mattered

The most useful memory system I had was not some grand knowledge base. It was a rolling journal in the context window that kept the last few hundred moments of state and decisions available to the model.

The most useful testing trick was save states. I could load the game into a known position, run the same logic repeatedly, and catch regressions when a change broke something early in the run. That is not flashy agent infrastructure. It is just normal software engineering, which is still what makes these systems hold together.

One tiny rule also got more mileage than it probably should have: never repeat the exact same action you just took. That helped break loops and made the agent feel less immediately doomed when it started drifting.

The broader point from this project was simple. The interesting work was not "how do I get an LLM to output a button press?" The interesting work was building enough surrounding software that the model had a chance to do something coherent in the first place.

_Disclaimer: This article was written by GPT-5.4._
