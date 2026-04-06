---
title: The Cutout Sessions
excerpt: What we learned from training music models on Waitwhat's back catalog and using the results as raw material for a human composer.
published_on: 2024-07-01
tags:
  - project
  - ai
  - music
---

I had the pleasure of collaborating with [WaitWhat](https://waitwhat.com) during the middle of 2024.

WaitWhat is the media company behind shows like [*Masters of Scale* with Reid Hoffman](https://mastersofscale.com/about-us/), along with properties like *Rapid Response* and *Pioneers of AI*. They are focused on building media properties, not AI music production. This project was a specific exploration of what might be possible with their back catalog of originally composed tracks made for those shows. WaitWhat wanted to understand how valuable that library might be as AI training data and what could be done with it. The main questions we were trying to answer were:

- Is an extensive back catalog of licensed music tracks valuable as AI training data?
- Can AI help a human composer make music better, faster, and cheaper?
- How controllable is AI-generated music when trained only on WaitWhat's data?

The way I see it, there is art and there is work. The line between the two is blurry.

Music produced for Spotify, meant to be listened to by itself, is totally art. Music that is played as the lead-in to a segment on a podcast, or as a backing track during an intense scene on *Law & Order*, sounds more like work to me. Nobody in Hollywood is waking up in the morning with enthusiasm to produce this kind of stuff. They do work so they can do art.

How do you empower composers to get work done better, faster, and cheaper?

This field is still so young, and there is so much to build at the frontier of music production. Everything is changing quickly. We are happy to release [*The Cutout Sessions*](https://drive.google.com/drive/folders/1KT96V4yV_8hRbHwj40HJFRhYB7cNBNcS), an album of human-composed music based on AI-generated samples from the WaitWhat library.

[*The Cutout Sessions*](https://drive.google.com/drive/folders/1KT96V4yV_8hRbHwj40HJFRhYB7cNBNcS) was produced by Jaron Miller, one of my best friends from college. We are super happy with the sound we were able to get from the AI-generated tracks, coupled with a human composer.

## Nerd Stuff

Oh gosh. This was so hard.

Training models has never been easier, but it is still never easy.

After trying some paid SaaS platforms and being unable to get good results, I stumbled upon [AudioCraft by Meta](https://github.com/facebookresearch/audiocraft). I found the out-of-the-box experience somewhat lacking. The tracks did not sound that great.

Luckily, I came across the work [nateraw](https://github.com/nateraw) was doing and his wonderful [blog post](https://wandb.ai/onlineinference/genmusic/reports/Tutorial-How-To-Train-Your-Own-MusicGen-Model--Vmlldzo0OTI5OTI5). He used some additional data from Splice, creating a fine-tune designed for composers.

I totally understand what all of these fancy charts are telling me.

The best results I was able to generate came from training on all of the data I had, 56 hours, for 40k steps. I trained on a cluster of 8 A100 GPUs hosted on Lambda Labs. I was originally saving a checkpoint every five hundred iterations, but that majorly slowed things down.

I wanted to train several models, one for each audio identity WaitWhat has in their catalog, for example a *Masters of Scale* model and a *Rapid Response* model, but this did not work for two reasons:

1. Not enough data.
2. The music was not unique enough between shows. An episode of *Masters of Scale* might have some dramatic segments coupled with some slow segments, so distilling a unique audio identity did not prove useful.

Another big thing I noticed is how much of modern data science is still an exercise in data preparation. Putting files in the right place, and referencing those files across a myriad of config files, is still most of the job.

I wish more teams would release comprehensive training instructions, so it is easy to tell what is required and where to put it. This is not usually done because most data science is trained on data that cannot be released publicly.

## Conclusions

### Is an extensive back catalog of licensed music tracks valuable as AI training data?

I'd say yes, but the keyword is *extensive*.

WaitWhat has a back catalog that can be measured in days. Enough music to listen to a different track nonstop for a long weekend. For a podcast studio composing music in one to two minute chunks, this is quite a lot of original music.

What you need to train something from the ground up is enough music to listen to a different track nonstop for two to three years. I believe AudioCraft was trained on 20k hours. That is the kind of scale you need.

### Can AI help a human composer make music better, faster, or cheaper?

Thus far in our experiments, we have not found any evidence that this is the case.

Incorporating AI-generated samples into the music production process was a chore internally instead of something musicians were flocking to. The outputs just were not good enough yet to call it better, faster, or cheaper.

### How controllable is AI-generated music when trained only on data the company owns?

While we had high hopes that we could distill various past WaitWhat shows into audio identities, for example *Meditative Story* being soft and calm while *Masters of Scale* would be higher energy, we were unable to generate such models.

Our best results came from putting everything into a single model. Part of the problem is how varied the tracks were. A single episode of *Masters of Scale* might have segments that are intense, calm, or light.

## Open Questions

- What is legal? Can you fine-tune on top of open weights and own the output? What about the software? Do we own that? AudioCraft is open source and open weight, but the weights are licensed with a CC-BY-NC license, so I think anything that uses them cannot be sold. This is probably the case because Facebook does not own the data it trained on.
- How much data do you need to do a whole clean-room training exercise? I am really curious to see if Inflection publishes any case studies on audio models, as well as Splice. Splice seems well positioned to do a clean-room audio model that they own outright.
- How do you know when a music model is fully trained? Without a scored training set, how do you know if you are undertraining or overtraining? There is not really a good way to score inference from an audio model other than vibes.
- There is probably a whole discussion on ethics here. I am a big believer that AI is going to enable teams to shrink. Eighty-person organizations might get cut down to thirty-five. Our work here was, at its core, centered around empowering human composers, because that is what we need: better tools for humans, not fully autonomous AI composing robots.

## Special Thanks

Special thanks to Nathaniel Raw of Splice for writing the world's greatest blog post. I literally could not have done this without building on his prior efforts. Same goes to Graham Seamans for many pointers in the later stages of model training.
