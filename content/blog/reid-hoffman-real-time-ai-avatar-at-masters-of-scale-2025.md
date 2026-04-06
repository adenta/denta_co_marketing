---
title: Reid Hoffman Real-Time AI Avatar at Masters of Scale 2025
excerpt: Built a realtime AI avatar experience that turned Reid Hoffman into an interactive presence for exhibition at the Masters of Scale 2025 conference presented by WaitWhat, in partnership with HeyGen, Proto Hologram, and Make Believe.
published_on: 2025-11-01
tags:
  - project
  - ai
  - realtime
---

![Allie Miller speaking into a microphone in front of the Reid Hoffman AI hologram at Masters of Scale 2025.](/images/blog/reid-hoffman-hologram/masters-of-scale-2025-reid-hoffman-hologram.png)

In 2025, I built a realtime AI avatar of Reid Hoffman for the Masters of Scale 2025 conference presented by [WaitWhat](https://waitwhat.com), in partnership with [HeyGen](https://www.heygen.com), [Proto Hologram](https://protohologram.com), and [Make Believe](https://makebelieve.co).

This was not a chatbot hidden in a browser tab. It was a public installation. People walked up, asked Reid questions, and expected the thing in front of them to respond like a coherent presence instead of a stitched-together AI demo.

That changes the standard immediately. At a conference, nobody cares how clever the architecture diagram is. They care whether it works, whether it responds fast enough, and whether the illusion holds once there is noise in the room and a line of people waiting behind them.

## Business Impact

- Exhibited live at the Masters of Scale 2025 conference as an interactive installation
- Turned a recognizable media personality into a realtime conversational AI experience people could approach in person
- Combined avatar generation, live conversation, and holographic display into one public-facing system

## The Problem

Most AI avatar demos fall apart the second you put them in a room with real people.

A conference installation is harsher than a product demo. Audio is messy. Network conditions are never perfect. The audience has no patience for latency theater. If the system hesitates too long, talks over itself, or lands in the uncanny valley, the whole thing stops feeling magical and starts feeling embarrassing.

This one had an even higher bar because the subject was Reid Hoffman. People know who he is. They know how he talks. They know what kind of answers they expect from him. So the problem was not just generating a response. The problem was getting close enough to presence that the audience would stay inside the experience instead of mentally stepping outside it to inspect the seams.

## What I Built

I built the realtime application layer that held the whole experience together.

That included:

- realtime orchestration for the live avatar experience
- conversation flow management for attendee questions and avatar responses
- browser-based control logic for coordinating input, response timing, and display state
- integration work across the avatar stack from [HeyGen](https://www.heygen.com), the physical display layer from [Proto Hologram](https://protohologram.com), and creative collaboration with [Make Believe](https://makebelieve.co)
- exhibition-ready behavior tuned for a live event environment instead of a scripted demo

The real work here was system design under performance pressure. Realtime projects live or die on timing. Every handoff matters: user input, model response, avatar rendering, screen state, and physical presentation all have to stay coherent enough that the audience stops thinking about the machinery and just talks to the character in front of them.

That is the part people tend to underestimate about this category. It is not enough for each vendor layer to work in isolation. The whole stack has to behave like one thing.

The core workflow looked like this:

```text
Attendee approaches the installation
-> asks a question to the AI version of Reid Hoffman
-> the runtime coordinates the live conversation flow
-> the avatar response is rendered through HeyGen
-> the experience is displayed through Proto's holographic hardware
-> the audience gets a realtime, in-person interaction instead of a passive video loop
```

## Outcome

The result was a working realtime AI avatar of Reid Hoffman exhibited at Masters of Scale 2025. More importantly, it held up as a public experience, which is the only test that really matters for this kind of work.

A lot of AI avatar projects look good in a controlled demo. Far fewer survive the chaos of a live room. This one did.

Allie Miller also [shared the project on LinkedIn](https://www.linkedin.com/posts/alliekmiller_asking-reid-hoffman-cofounder-of-linkedin-activity-7382082092198678529-fD-a/?utm_source=share&utm_medium=member_desktop&rcm=ACoAAA-y6HsBsEX5EWzRSphQ78pFaZ3-f6mxqlU).
