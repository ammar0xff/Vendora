# Tailgrids MCP

## Purpose

Tailgrids MCP is positioned as a searchable source of Tailwind/React UI components and page sections. The referenced catalog contains 600+ components; confirm the current count, endpoint, plan requirements, and supported tools in vendor documentation.

## Useful workflows

- Search by component name or natural-language intent.
- Retrieve TSX and prop information.
- Validate component usage.
- Audit accessibility.
- Scaffold full-page sections.

Referenced VS Code extension identifier: `tailgrids.tailgrids-mcp`. Verify publisher and current package identity before installing.

## When to use it

Use Tailgrids as a component source when a project has no established in-house design system or when exploring a pattern quickly. Search for a focused component—such as a filter toolbar or empty state—instead of copying an entire unrelated landing page.

## Migration path

1. Select only patterns that solve the page contract.
2. Review semantics, keyboard behavior, responsiveness, and licensing/usage terms.
3. Normalize classes to the project's semantic tokens.
4. Convert repeated patterns into typed components.
5. Migrate mature shared patterns into the team's shadcn/ui-owned source and Gantry catalog.
6. Stop importing new external patterns once an approved in-house component exists.

## Guardrails

- Do not assume retrieved code is production-ready.
- Check package dependencies, accessibility, responsive behavior, and data assumptions.
- Remove arbitrary colors, magic values, placeholder copy, and decorative motion.
- Do not introduce a second design system by copying components wholesale.
