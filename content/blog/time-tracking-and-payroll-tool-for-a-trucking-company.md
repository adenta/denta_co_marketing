---
title: Time Tracking and Payroll Tool for a Trucking Company
excerpt: Built a web app that let truck drivers clock trips, submit reimbursements and accessorial pay, and gave carrier admins a cleaner path to approvals and payroll.
published_on: 2022-11-02
tags:
  - project
  - case-study
---

Between October and early November 2022, I built a trucking operations tool for a company that needed cleaner driver time tracking and a lot less payroll cleanup.

The users were drivers on the road and carrier admins back at the office. Drivers needed a dead simple way to clock into a load, clock out when it was done, and attach the extra stuff payroll always misses. Admins needed one place to review everything before it turned into payroll.

## Business Impact

- Cut weekly payroll prep from roughly **5.5 hours** down to about **75 minutes**
- Reduced missing, disputed, or incomplete trip records by **16%**
- Shortened reimbursement and accessorial approval turnaround from **weeks** to **days**

## The Problem

The problem went past hours. It included all the little line items that pile up in trucking.

- Start and end times were easy to miss or log late
- Extra pay like detention, TONU, per diem, and lumper charges had to be tracked separately
- Receipts for reimbursements were easy to lose
- Payroll teams had to manually piece together hours, extras, and expenses before they could pay anyone
- Admins had no clean approval layer between what drivers submitted and what payroll exported

So the same thing happened every week: payroll took too long, small mistakes turned into annoying disputes, and the back office had to reconstruct work that had already happened.

## What I Built

I built a full-stack app with separate workflows for drivers and carrier admins.

- Driver clock in and clock out tied to a trip record
- Load ID tracking per trip
- Start and finish stops with timestamps, timezone awareness, and GPS or IP-based location capture
- Editable stop times when a correction was needed
- Reimbursement submission with receipt uploads
- Accessorial submission tied to a trip, including detention, TONU, per diem, lumper, and other charges
- Driver onboarding for carrier admins, including wage rate and payroll type setup
- Approval queues for trips, reimbursements, and accessorials
- Payroll batch generation that pulled approved line items into one calculation
- CSV payroll exports split by **1099** and **W-2**
- Stripe-based banking setup for drivers

The core workflow was straightforward:

```text
Driver clocks into a load
-> system records start time, timezone, and location
-> driver clocks out when the trip is done
-> driver adds reimbursements or accessorial pay with receipts
-> carrier admin reviews and approves outstanding line items
-> system batches approved trips, extras, and reimbursements into payroll
-> admin downloads payroll exports and drivers complete banking setup
```

## Outcome

By the end, this was more than a punch clock. It was a working back-office tool for a trucking company: drivers could log real trip activity as it happened, admins could approve it, and payroll could finally run off something cleaner than memory, texts, and spreadsheet cleanup.
