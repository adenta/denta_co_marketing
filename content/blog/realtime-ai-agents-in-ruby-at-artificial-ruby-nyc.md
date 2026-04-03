---
title: Realtime AI Agents in Ruby at Artificial Ruby NYC
excerpt: On February 18, 2026, I spoke at Artificial Ruby in New York City about building realtime AI agents in Ruby, using my open source Pokemon-playing project to show where agent systems get interesting.
published_on: 2026-04-03
tags:
  - ai
  - ruby
  - agents
  - realtime
---

*April 3, 2026, 3:45 PM ET*

On February 18, 2026, I gave a talk at Artificial Ruby in New York City called *Realtime AI Agents in Ruby*.

I used the session to walk through an open source Pokemon-playing agent I have been building and to talk about a problem I think is getting more important: AI systems become much more interesting the moment they stop being turn-based.

If you want to watch the talk, the [video is here](https://www.youtube.com/watch?v=2fgFwBAf_JA). The [slide deck is here](https://docs.google.com/presentation/d/1TaeB8XMMBAWaGquoL9FMLL3YifT6Rb_k7XpQs6M-CqQ/edit?slide=id.p#slide=id.p).

{{ youtube url="https://www.youtube.com/watch?v=2fgFwBAf_JA" }}

What I wanted to show in this talk was pretty simple. It is easy to make an agent look smart when it has unlimited time to think, a clean prompt, and a narrow task boundary. It is much harder when the environment keeps changing underneath it and the agent has to observe, decide, and act fast enough to stay in sync.

That is why the Pokemon demo was useful. A game gives you a live environment, constant feedback, and obvious failure modes. If the agent is too slow, too noisy, or too uncertain, you see it immediately. There is nowhere to hide behind a polished chat interface.

In the talk, I focused on the parts that actually matter in a realtime system:

- getting structured state out of a messy live environment
- keeping the control loop tight enough that latency does not compound
- deciding what should be deterministic code versus model-driven reasoning
- handling the fact that "almost right" is usually the same as wrong once timing matters

This is also why I keep coming back to Ruby for this kind of work. Ruby is still a great language for expressing orchestration logic clearly. The challenge is not that Ruby cannot participate in AI systems. The challenge is that realtime systems force you to be honest about architecture. You need clean boundaries, predictable interfaces, and a clear sense of what the model is allowed to decide.

One of the broader points I tried to make in NYC is that agents get most interesting when they leave the chat box. The moment an agent has to operate inside a live system, whether that is a game, a browser, a terminal, or a production workflow, you stop thinking in terms of prompts alone. You start thinking about control loops, state estimation, tool reliability, and recovery paths.

That is the part I find exciting.

I like chat interfaces, but I am much more interested in systems that can perceive an environment, take action, learn from feedback, and keep going. That is where the engineering gets real.

Thanks to the Artificial Ruby team for having me in New York. It was a fun room, a sharp audience, and exactly the kind of meetup I want more of.
