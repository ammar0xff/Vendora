# Gantry Design-Token MCP

## What it is for

Gantry is intended to connect an AI coding workflow to a project's component catalog, design tokens, variants, previews, and health checks. The goal is to reduce design drift and prevent agents from inventing colors, radii, or near-duplicate components.

Verify the current product documentation, package name, and supported features before deployment; capabilities may evolve.

## Capability checklist

- Component browser organized by layer.
- Live preview rendered through the project toolchain.
- Variant axes and component props.
- Storybook CSF3 import.
- Health and design-system drift score from 0–100.
- Token manager supporting CSS custom properties, DTCG/Tokens Studio JSON, and Tailwind v3/v4 `@theme`.
- AI rules synchronization:
  - Cursor: `.cursor/rules/gantry.mdc`
  - Claude Code: `.gantry/gantry-rules.md` and/or `CLAUDE.md`
- CLI and CI gate for system health.

## MCP tools (as referenced by the integration)

- `find_component`
- `get_component`
- `list_components`
- `list_layers`
- `list_tokens`
- `get_health`
- `screenshot_component`

## Resources (as referenced by the integration)

- `gantry://catalog`
- `gantry://tokens`
- `gantry://health`
- `gantry://layers`
- `gantry://component/{name}`

Treat these identifiers as expected integration surfaces to verify, not a promise of availability in every release.

## Suggested workflow

1. Connect the Gantry MCP server and inspect its current tool/resource list.
2. Run `get_health` and review the current score and drift findings.
3. Search the catalog before creating a component.
4. Retrieve the exact component definition, variants, and tokens.
5. Compose the existing component; do not recreate it from a screenshot.
6. Preview in the real project toolchain and compare to the target design.
7. Run health checks locally and in CI.

## VS Code extension

Referenced extension identifier: `mifxch.gantry`. Confirm publisher, identity, version, and permissions in the VS Code Marketplace before installation.

## Why it matters

AI-generated UI drifts when every prompt invents a fresh shade, radius, spacing value, or button pattern. A catalog-backed workflow provides one source of truth, a discoverable component inventory, and a measurable health gate.

## CI guidance

Use the official Gantry CLI and documented exit-code behavior. A CI gate should fail or warn based on an agreed health threshold, token violations, and component drift. Do not invent CLI flags; confirm them from the installed version's help output.
