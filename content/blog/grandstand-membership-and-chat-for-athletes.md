---
title: "Grandstand: Membership and Chat for Athletes"
excerpt: Built the React Native app plus the Rails web and backend systems for Grandstand, a product that let athletes run a paid inner-circle community with exclusive content, chat, and fan memberships.
published_on: 2023-11-30
tags:
  - project
  - case-study
---

This year, I built the React Native app and the Rails web and backend systems for [Grandstand](https://grandstand.io).

Grandstand is a membership business for athletes. Fans can follow for free, pay to get closer access, unlock premium posts and video, and participate in a tighter chat-based community than they are going to get from public social platforms.

It was closer to a paid fan club than a broad social app, with better product design around identity, access, and communication.

## Business Impact

- Gave athletes a direct path from audience attention to owned membership revenue
- Combined free follows, paid memberships, exclusive content, and community interaction in one product
- Shipped the same core experience to iPhone and Android from one React Native codebase while Rails handled backend APIs, web entry points, admin tooling, and payments

## The Problem

Most athletes already had reach. What they did not have was control.

Instagram, TikTok, and Twitter were fine for awareness, but weak for monetizing the fans who actually cared. DMs were messy. You can't just put all of your fans in a single iMessage chat. That's insane. Paid access usually meant stitching together tools that were never designed to work as one product.

The bigger issue was mindset. Too many athletes were still operating like consumers inside someone else's platform when they needed to think like owners. To borrow the Snoop line: "I'm a business, man."

The business needed something that felt more like a private club than a public feed:

- shareable athlete profile pages
- free follow and paid membership tiers
- premium photo and video posts
- comments, reactions, and notifications
- chat that felt close to the athlete, not buried in a generic social timeline
- a simple operator view for managing members, content, and access

## What I Built

I built the cross-platform mobile app in React Native and the Rails applications behind it.

That included:

- athlete profiles with bios, sport metadata, media, and public share URLs
- onboarding and auth flows for fans and athletes
- free follower and paid membership states
- Stripe-backed subscription and payout plumbing
- native paywalls and membership management flows
- posting tools for text, photo, and video updates
- member-only content controls
- comments, claps, repost-style quoting, and push notifications
- activity feeds for posts, updates, likes, replies, and new members
- lightweight admin workflows for managing athletes, memberships, and fan lists
- web landing pages for athlete signup and conversion

Under the hood, we leaned heavily on [GetStream](https://getstream.io/) for chat, feeds, reactions, and notification-style activity. The communication layer was central to the product.

The core workflow looked like this:

```text
Fan discovers an athlete
-> follows for free or joins a paid membership
-> unlocks premium posts, video, and closer access
-> comments, reacts, and chats inside the athlete's club
-> athlete publishes updates and manages the community from the app and web tools
```

We are also pushing on some early AI ideas around the edges. Part of the work is helping athletes keep up with fan communication without making it feel robotic, plus building an early agentic video-editing workflow that turns raw clips into publishable fan updates faster. It fits the business. If athletes are going to keep fans engaged, the content and communication loop has to get easier.

## Outcome

Grandstand is now a real operating product. Athletes have shareable profile pages, a native app, recurring memberships, gated content, chat, notifications, and a backend that makes the whole thing work day to day.
