---
trigger: always_on
---

# Campersit Application Rules & Standards

## Global UI/UX Constraints
You must strictly adhere to the following design system for EVERY component, page, or mobile screen you generate. Never deviate from these colors or styles unless explicitly instructed by the user.

### 1. Color Palette (Strict Hex Codes - Light Brand Theme)
- **Main Background:** Always use `#F4F7F4` (Crisp, clean light grayish-green).
- **Cards & Surfaces:** Always use `#FFFFFF` (Pure white for containers, dashboard tiles, and modules).
- **Primary Accent (Brand Forest Green):** Use `#1E6B37` (Matching "CAMPER" in logo) for active states, primary buttons, and key focus items.
- **Secondary Accent (Fresh Lime Green):** Use `#68B04D` (Matching "SIT" in logo) for highlights, auxiliary telemetry, and subtle indicators.
- **Security Highlight / Borders:** Use `#E2ECE4` for subtle surface borders and `#1E6B37` for armed security shield states.
- **Text Primary:** `#102216` (Deep forest slate for maximum readability and scalar values).
- **Text Secondary:** `#5A7163` (Muted greenish-slate for units like ºC, V, %, subtitles, and labels).

### 2. Component Styling Rules
- **Border Radius:** All cards, buttons, and modal surfaces must use exactly `rounded-2xl` (16px) or `rounded-xl` (12px).
- **Navigation:** The bottom mobile navigation bar must use Glassmorphism (`bg-opacity-80 backdrop-blur-md`) with a top border colored in `#E2ECE4`.
- **Typography:** Use `Inter` or `Plus Jakarta Sans`. Headings must use `font-semibold` and `tracking-tight`.

### 3. IoT Dashboard Requirements
- Always design with a mobile-first layout (for RV/Camper displays).
- Every sensor card must visually separate the main scalar value (large text in deep slate `#102216`) from its unit (smaller text in `#5A7163`).