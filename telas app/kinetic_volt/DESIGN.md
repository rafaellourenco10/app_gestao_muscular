---
name: Kinetic Volt
colors:
  surface: '#131316'
  surface-dim: '#131316'
  surface-bright: '#39393c'
  surface-container-lowest: '#0e0e11'
  surface-container-low: '#1b1b1e'
  surface-container: '#1f1f22'
  surface-container-high: '#2a2a2d'
  surface-container-highest: '#353438'
  on-surface: '#e4e1e6'
  on-surface-variant: '#c4c9ae'
  inverse-surface: '#e4e1e6'
  inverse-on-surface: '#303033'
  outline: '#8e937a'
  outline-variant: '#444934'
  surface-tint: '#aad600'
  primary: '#ffffff'
  on-primary: '#283500'
  primary-container: '#c5f331'
  on-primary-container: '#556d00'
  inverse-primary: '#506600'
  secondary: '#c7c5d0'
  on-secondary: '#303038'
  secondary-container: '#46464f'
  on-secondary-container: '#b6b4be'
  tertiary: '#ffffff'
  on-tertiary: '#2f2f3b'
  tertiary-container: '#e3e1f1'
  on-tertiary-container: '#646370'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#c5f331'
  primary-fixed-dim: '#aad600'
  on-primary-fixed: '#161f00'
  on-primary-fixed-variant: '#3b4d00'
  secondary-fixed: '#e4e1ec'
  secondary-fixed-dim: '#c7c5d0'
  on-secondary-fixed: '#1b1b23'
  on-secondary-fixed-variant: '#46464f'
  tertiary-fixed: '#e3e1f1'
  tertiary-fixed-dim: '#c7c5d4'
  on-tertiary-fixed: '#1a1b26'
  on-tertiary-fixed-variant: '#464652'
  background: '#131316'
  on-background: '#e4e1e6'
  surface-variant: '#353438'
typography:
  display-hero:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 60px
    letterSpacing: -0.04em
  display-hero-mobile:
    fontFamily: Space Grotesk
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.03em
  timer-display:
    fontFamily: Space Grotesk
    fontSize: 64px
    fontWeight: '700'
    lineHeight: 64px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: 0em
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.01em
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0em
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.04em
  label-caps:
    fontFamily: Space Grotesk
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  margin: 1.25rem
  margin-tablet: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

The design system embodies the high-output intensity, discipline, and precision of modern functional training. Built for athletes and individuals pushing their physical limits, the experience balances focused tactical minimalism with electric kinetic energy. The aesthetic rejects decorative clutter in favor of crisp utility, deep immersion, and high-impact guidance.

- **Primary Style Direction:** High-Contrast Dark Minimal with Subtle Luminescence. Deep near-black environments focus the user's attention, while high-voltage neon lime accents guide instant physical action during intense training intervals.
- **Atmosphere & Tone:** Technical, athletic, energetic, decisive, and uncompromising.
- **Emotional Response:** Empowers the athlete with a sense of readiness, relentless focus, and forward momentum.

## Colors

The palette is engineered for maximum legibility in low-light and high-movement workout environments:

- **Primary (`#C6F432`):** Hyper-saturated kinetic lime. Used exclusively for primary calls-to-action, active workout states, completed repetitions, selected tabs, and critical focus zones. Text rendered atop this color must use `#0F0F12` for optimal contrast.
- **Canvas / Root Background (`#0F0F12`):** Ultra-deep, warm obsidian backdrop minimizing battery consumption on OLED displays and eliminating eye fatigue.
- **Surface Level 1 (`#18181E`):** Standard container background for cards, list items, workout block trays, and bottom sheets.
- **Surface Level 2 (`#22222A`):** Interactive resting states, nested containers, metric chips, and subtle divider fills.
- **Surface Level 3 (`#343440`):** Hover, pressed, and highlighted state containers.
- **Text & Iconography:**
  - **High-Emphasis Title (`#FFFFFF`):** Reserved for primary headings, large timer numerals, and active metric reads.
  - **Medium-Emphasis Content (`#E2E2EA`):** Body copy, routine notes, and unselected prominent labels.
  - **Subtle / Secondary Meta (`#9E9EA8`):** Set details, timestamps, equipment tags, and inactive icons.
- **Borders & Dividers:** Subtle translucent stroke (`rgba(255, 255, 255, 0.08)`) to structure surfaces without adding visual noise.

## Typography

Typography pairs technical geometric performance with robust multi-density readability:

- **Headlines & Metric Data (Space Grotesk):** Chosen for its mechanical precision, open apertures, and punchy geometric presence. Used on all major headers, routine module titles, reps/weight metrics, and timers to deliver immediate split-second information capture.
- **Body & Longform Descriptions (Inter):** Neutral, utilitarian sans-serif ensuring effortless comprehension across exercise instructions, setup tips, and physiological guidance.
- **Tabular Figures:** All numeric displays (stopwatches, countdowns, heart rate telemetry, sets/reps) must render with tabular figures (`tnum`) enabled to eliminate shifting text baselines during dynamic workouts.

## Layout & Spacing

A mobile-first fluid layout built to accommodate high-velocity interaction where touch targets must remain distinct and accessible while in motion.

- **Grid Architecture:** 4-column layout on mobile devices expanding to 8-column layout on tablet/foldable viewports.
- **Touch Targets:** Minimum touch zone of 48×48px across all clickable elements, with standard workout control buttons expanding to a height of 56px to ensure accessibility while moving.
- **Spacing Cadence:** Follows a strict 8pt base grid rhythm (4px increments for micro-spacing). Generous padding within cards (`space-md` to `space-lg`) gives individual workout circuits clear visual boundaries.
- **Safe Areas:** Adheres strictly to bottom navigation bar clearances and dynamic islands/notches, using `margin` to maintain generous breathing space along outer edges.

## Elevation & Depth

Rather than relying on heavy drop shadows which soften visual impact, this system conveys depth through tonal surface layering, ultra-fine borders, and selective neon luminescence:

- **Tonal Stepping:**
  - Base layer: `#0F0F12`
  - Grouping surface / Card: `#18181E`
  - Elevated modal / Floating bar: `#22222A`
- **Linear Boundaries:** Surfaces feature a 1px border stroke using `rgba(255, 255, 255, 0.08)` to maintain sharp geometric separation against the near-black background.
- **Active Glow:** Active workout states, active play/pause timers, and current round indicators apply a neon focal glow: `0px 0px 24px rgba(198, 244, 50, 0.28)`, creating an energetic kinetic halo around key training actions.
- **Glass Accents:** Sticky bottom bars and floating timer headers use a dark glass overlay (`background: rgba(15, 15, 18, 0.82)` with `backdrop-filter: blur(16px)`) allowing scrolling routines to bleed subtly underneath.

## Shapes

The physical design language is unified around a 16px (`rounded-lg`) corner radius, balancing modern softness with high-performance industrial engineering:

- **Cards & Modules:** 16px (`1rem`) border radius on all exercise cards, circuit wrappers, and summary stat panels.
- **Action Buttons & Inputs:** 16px (`1rem`) radius matching card curvature for visual cohesion.
- **Status Badges & Chips:** Fully pill-rounded (`9999px`) or scaled to 8px (`0.5rem`) for compact tags, differentiating categorical indicators from operational cards.
- **Media Previews & Video Loops:** Nested media matches container rounding minus inner padding (typically 12px / `0.75rem`).

## Components

### Buttons
- **Primary Kinetic Action:** Fill `#C6F432`, text `#0F0F12` (`label-lg`), height 56px, radius 16px. Active tap scale down to `0.98`. Glow effect on persistent CTAs.
- **Secondary Surface Action:** Fill `#22222A`, text `#FFFFFF`, 1px border `rgba(255, 255, 255, 0.08)`, height 56px, radius 16px.
- **Ghost Action:** Transparent background, text `#9E9EA8`, hover/active color `#FFFFFF`.

### Chips & Filter Badges
- **Inactive:** Fill `#18181E`, text `#9E9EA8`, border 1px `rgba(255, 255, 255, 0.06)`, pill radius.
- **Active / Selected:** Fill `rgba(198, 244, 50, 0.12)`, text `#C6F432`, border 1px `#C6F432`, pill radius.

### Workout List & Circuit Cards
- Background `#18181E`, border 1px `rgba(255, 255, 255, 0.08)`, radius 16px, padding `16px`.
- Left-aligned numeric set/rep badge in `#22222A` with `#FFFFFF` text.
- Active exercise highlighting: Left 4px border accent in `#C6F432` with an ambient card glow.

### Form Inputs & Number Spinners
- Background `#18181E`, text `#FFFFFF`, border 1px `rgba(255, 255, 255, 0.12)`, radius 16px.
- Focused state: Border changes to `#C6F432` with subtle lime ambient shadow. Placeholder text set to `#9E9EA8`.

### Checkboxes & Set Completions
- 24×24px square with 6px border radius.
- Inactive: Border 2px `#343440`, transparent interior.
- Completed: Fill `#C6F432`, checkmark icon in `#0F0F12`.

### Interval Timer HUD
- Full-width modular bar pinned dynamically above workout controls.
- Space Grotesk tabular timer digits at `#FFFFFF`. Progress bar uses a dual-tone track (`#22222A`) with a filled kinetic lime indicator (`#C6F432`).