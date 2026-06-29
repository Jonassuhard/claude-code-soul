---
name: awesome-design-md
description: Access design system templates from 59 top companies (Claude, Anthropic, OpenAI, Cohere, ElevenLabs, Linear, Vercel, Framer, Figma, Stripe, Apple, BMW, Ferrari, etc.) as .md files. Use when the user asks for frontend design inspiration, wants to mimic a specific company's design language, needs typography/color/layout guidelines matching a reference brand, or wants to escape generic "AI slop" frontend. The templates are located at ~/Desktop/PROJETS_DEV/awesome-design-md/design-md/[company-name]/README.md.
---

# Awesome Design MD — Reference Design Systems

## Source
Repo cloned : `~/Desktop/PROJETS_DEV/awesome-design-md/`
Upstream : https://github.com/VoltAgent/awesome-design-md (38K+ stars)

## Available design systems (59 companies)

Anime, airbnb, airtable, apple, bmw, cal, claude, clay, clickhouse, cohere, coinbase, composio, cursor, elevenlabs, expo, ferrari, figma, framer, hashicorp, ibm, intercom, and many more.

List current templates :
```bash
ls ~/Desktop/PROJETS_DEV/awesome-design-md/design-md/
```

## How to use

### Step 1 — Pick a reference design
Ask user (or infer from context) which brand aesthetic fits the project :
- Premium/enterprise SaaS → Claude, Linear, Vercel
- AI/dev tools → Cohere, Anthropic, ElevenLabs, Cursor
- Consumer-facing → Airbnb, Apple, Intercom
- Finance/trust → Coinbase, Stripe
- Auto/luxury → BMW, Ferrari

### Step 2 — Read the template
```bash
cat ~/Desktop/PROJETS_DEV/awesome-design-md/design-md/[company]/README.md
```

Each template contains :
- Typography choices (no generic Inter/Roboto/Arial)
- Color palette with exact hex codes
- Spacing rules
- Button/component patterns
- Voice/tone guidelines
- Layout conventions (bentos, hero sections, pricing pages)

### Step 3 — Apply to the target project
Inject the template content into the system prompt when generating the UI code. Example for a Next.js landing page :
```
Using the Cohere design system (see ~/Desktop/PROJETS_DEV/awesome-design-md/design-md/cohere/README.md),
build a landing page for [offer] with hero, 3-column features, pricing table, and footer.
```

## Rules

- **Never use Inter/Roboto/Arial by default** — each template specifies intentional typography
- **Always start by reading the chosen .md file** before generating code
- **Mix templates when appropriate** (e.g., Claude typography + Framer animations) but document the choice
- **For {{USER_NAME}} specifically** : prefer Cohere, Claude, Linear for freelance offers (RAG, Chef de projet IA). Airbnb/Intercom for landing pages consumer-facing.

## Why this skill exists

Native `frontend-design` skill produces generic output. This repo provides 59 curated design systems with intentional choices, avoiding the "vibe-coded SaaS template" look that makes 95% of LLM-generated UIs feel identical.
