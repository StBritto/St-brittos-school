---
description: UI/UX design intelligence for building, reviewing, and improving professional interfaces. Apply to pages, components, responsive layout, accessibility, interaction, typography, color, motion, and visual consistency.
mode: agent
---

# UI/UX Pro Max — Project Design Workflow

Source project: nextlevelbuilder/ui-ux-pro-max-skill.

Use this workflow whenever a task changes how the interface looks, feels, moves, responds, or is interacted with. Skip it for pure backend/infrastructure work.

## Priority order
1. Accessibility: contrast, alt text, keyboard navigation, labels, visible focus.
2. Touch & interaction: usable touch targets, spacing, feedback, no hover-only behavior.
3. Performance: optimized media, lazy loading, prevent layout shift.
4. Style: keep one coherent visual language; prefer SVG/icon libraries over emoji icons.
5. Responsive layout: mobile-first, no horizontal overflow, test common breakpoints.
6. Typography & color: readable type, sufficient contrast, consistent tokens.
7. Animation: motion should communicate meaning and respect reduced-motion preferences.
8. Forms & feedback: visible labels, nearby errors, clear progress/loading states.
9. Navigation: predictable hierarchy, back behavior, clear destinations.
10. Charts/data: legends, tooltips, accessible colors, never rely on color alone.

## Project workflow
Before editing UI:
- Inspect the existing implementation and preserve working behavior.
- Identify the product type, audience, visual direction, and actual technology stack. Never assume the stack.
- For a new page or redesign, define a mini design system first: layout pattern, style, palette, typography, spacing, effects, and anti-patterns to avoid.
- Reuse existing brand assets and components where possible.

During implementation:
- Keep the design polished, trustworthy, simple to navigate, and suitable for students, parents, teachers, and staff.
- Use responsive behavior that works at approximately 375px, 768px, 1024px, and 1440px.
- Ensure essential text reflows without clipping and long labels/tokens do not break layouts.
- Use semantic HTML and accessible controls.
- Use transitions selectively; avoid unnecessary motion or layout-thrashing animation.

Before completion:
- Check keyboard navigation and focus visibility.
- Check text/background contrast.
- Check touch target usability.
- Check mobile, tablet, laptop, and desktop layout.
- Check no unintended horizontal scroll or clipped content.
- Check loading/error/empty states where applicable.
- Check existing functionality still works.
- Report what changed and what was verified.

## Full official skill
For the complete searchable UI/UX Pro Max dataset and generator, the official CLI command is:

`uipro init --ai copilot`

The full CLI install adds the searchable data and scripts under `.github/prompts/ui-ux-pro-max/`. This project-level prompt remains useful as a safe baseline even when the full local dataset is not installed.
