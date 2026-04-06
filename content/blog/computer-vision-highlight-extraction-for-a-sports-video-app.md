---
title: Computer Vision Highlight Extraction for a Sports Video App
excerpt: Built a Rails and React Native product that turned long game recordings into searchable highlight clips using OCR, transcript embeddings, semantic search, and vision-based metadata experiments.
published_on: 2024-03-01
tags:
  - project
  - case-study
---

In March 2024, I built a sports video product that turned long game recordings into short, searchable highlight clips.

There were really two products in one. On the backend side, there was an internal workflow for ingesting full game streams, generating transcripts, cutting clips, and tagging them well enough to be useful. On the frontend side, there was a mobile app where fans could browse the feed, search for moments, and follow teams and players they cared about.

The real problem was curation. Anybody can store video. Getting from a two-hour game recording to a highlight feed without paying someone to scrub through footage all day is the expensive part.

## Business Impact

- Turned full recorded streams into short highlight clips with a much more automated pipeline
- Let operators search for moments in plain English and save the good ones as highlights
- Shipped a mobile app where fans could browse, search, like, download, and personalize the feed around team and player preferences

## The Problem

Raw sports video is long, repetitive, and annoying to work with.

If you want a real highlight product, storage and playback are the easy part. The ugly part is everything around them. You need ingest, subtitles, clip timing, search, metadata, export, and a fast enough workflow that somebody can actually operate the system without losing their mind.

That is the real job here. The system has to take messy game footage and push it toward something structured enough to publish.

## What I Built

I built the backend ingestion and curation system in Rails and the consumer app in React Native.

That included:

- recorded stream ingest from source URLs
- long-form video processing through a hosted pipeline that generated playback assets and subtitle tracks
- transcript chunk storage plus embeddings so operators could search by meaning instead of exact words
- a plain-language search flow where operators could describe a play, retrieve nearby transcript matches, preview them, and save them as new highlight clips
- highlight indexing across transcript text, team names, player names, and embedded representations
- an internal web interface for managing recorded streams, subtitles, AI-assisted highlight generation, and preference data
- a mobile feed of autoplaying short clips
- search across the highlight library
- full-screen clip playback with likes and downloads
- team and player preference flows so the app could lean toward clips a user was likely to care about
- a mobile video import and edit flow for user-created uploads

The most interesting part is the computer vision and AI layer.

I wrote OCR scripts that sampled frames from the video, cropped the scoreboard area, read the game clock from the broadcast overlay, and wrote those values out to CSV. I tried leaning on language-model-style OCR first, but it was not good enough for this job. The clock was too small, too inconsistent, and too easy to read wrong. I needed something more literal and repeatable, so I went lower-level with OpenCV and Tesseract. Then I used jumps in game time to infer likely clip boundaries inside a longer recording. That let the system cut full games into candidate highlights without a human dragging a scrubber around for hours.

I also built a semantic search workflow on top of subtitle chunks. The system embedded transcript text so an operator could search for a moment by meaning, not just by exact words. If somebody wanted late-game threes or a certain kind of scoring sequence, the system could pull back likely matches from transcript embeddings, preview them, and save them out as clips.

Then there is the vision work around metadata. I sampled frames from highlight videos, passed them into a multimodal model with roster context, generated a narrative description of the play, and tried to map that back to the most likely player and play type. That is still early, but it feels like the right direction. I want the system to recover more than clip boundaries. I want it to say what happened, who did it, and how much of that can be pulled out automatically.

I also tested better transcription against local highlight audio and passed player-name context into the transcription flow. Sports transcripts get messy fast. If names are wrong, search gets worse, labels get worse, and the whole system gets noisier.

The core workflow looked like this:

```text
Operator adds a recorded game stream
-> system processes the video and generates subtitle tracks
-> OCR reads the game clock from sampled frames
-> clip boundaries are inferred from game-time jumps
-> transcript chunks are embedded for semantic retrieval
-> operator searches for moments in plain English and saves good matches as highlights
-> highlights are indexed and published to the mobile app
-> fans browse, search, react to, and download clips
```

## Outcome

At this point, this is a real working stack for sports highlight extraction and distribution.

It has long-form ingest, subtitle generation, transcript embeddings, semantic clip search, OCR-based clip segmentation, vision-based play analysis experiments, internal curation tools, and a mobile app on top.

The part I like most is that the AI work is attached to a real operations problem. It helps cut video faster, search moments better, and push raw footage closer to a real highlight product. And this is clearly going to matter for a lot more than sports over the next decade.
