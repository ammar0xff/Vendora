# Product-Specific Frontend UI/UX Kit

A practical operating system for building production-grade interfaces that feel designed for a real product—not assembled from generic AI patterns.

## Recommended stack

- Next.js App Router, React, TypeScript
- Tailwind CSS v4 with CSS-first `@theme` tokens
- shadcn/ui as owned, editable component source
- Motion (`motion/react`, formerly Framer Motion) for purposeful animation
- Lucide React for consistent interface icons
- Optional context tools: Figma MCP, Gantry MCP, Tailgrids MCP

## Workflow

1. **Write the page contract** in `prompts/page-contract.md` before generating UI.
2. **Give the coding agent** `prompts/system-prompt.md` and the relevant product requirements.
3. **Bind context**: use Figma for source design context, Gantry for the team's catalog/tokens/health, and Tailgrids only when no suitable in-house component exists.
4. **Build in layers** using `architecture/layered-components.md`.
5. **Implement every real state** and responsive behavior before visual polish.
6. **Run the preflight** in `checks/preflight-checklist.md` and score the page using `checks/ai-tell-score.md`.
7. Ship only after the target score is **0 tells** and all applicable checks pass.

## Core principle

Identity comes from product-specific information, hierarchy, density, color roles, and consistent components. It does not come from gradients, trendy fonts, or animation. Repair interfaces in this order: **page contract → structure and hierarchy → shared tokens/components → states and responsive behavior → decoration**.

## Folder map

- `prompts/`: agent instructions and page contract
- `design-system/`: tokens and anti-default rules
- `architecture/`: component layering, stack, responsive behavior
- `mcps/`: setup notes for design-system context tools
- `plugins/`: recommended editor extensions
- `checks/`: pre-ship gates and scoring
- `examples/`: a concrete before/after comparison

Tool availability, endpoints, extension names, and vendor capabilities can change. Verify each vendor's current documentation before enabling tools in a production environment.
