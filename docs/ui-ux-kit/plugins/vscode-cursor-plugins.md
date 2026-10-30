# Editor and Cursor Plugin Recommendations

Verify each publisher, identifier, permissions, and current compatibility in the marketplace before installing.

| Tool / extension | Referenced publisher or ID | Best use |
|---|---|---|
| Figma | Official Figma extension/MCP workflow | Pull design context and variables from source files |
| Gantry | `mifxch.gantry` | Browse components/tokens and check design-system drift |
| Tailgrids MCP | `tailgrids.tailgrids-mcp` | Discover reusable Tailwind React components when no internal catalog exists |
| Piny visual editor | Verify current listing | Visual iteration and editing workflow, where supported |
| Cursor | Cursor editor | Agent-based coding and project rules |
| Tailwind CSS IntelliSense | Official Tailwind Labs extension | Class completion and diagnostics |
| shadcn/ui snippets | Verify current listing | Faster component authoring; do not let snippets replace the system |
| Lucide icon search | Verify current listing | Find consistent Lucide icons by name |

## Install through VS Code

1. Open Extensions with `Ctrl+Shift+X`, or open the command palette with `Ctrl+P`.
2. Search the exact extension identifier, for example `ext install mifxch.gantry` where supported.
3. Verify publisher and permissions before installing.
4. Restart/reload the editor if prompted.
5. Confirm the tool is available and that its permissions match the intended workflow.

## Recommended context combination

- **Figma** for source design intent and variables.
- **Design-system documentation** for token semantics and component rules.
- **Storybook/Gantry** for approved component behavior, variants, previews, and drift checks.
- **Tailgrids** only for gaps in the catalog, followed by normalization into the house system.

Run the Gantry health scan in CI if the installed version supports a documented CI/CLI workflow. Treat the score as one quality signal, not a replacement for accessibility tests, visual review, or product validation.
