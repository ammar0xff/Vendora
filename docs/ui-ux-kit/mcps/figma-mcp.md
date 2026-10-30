# Figma MCP

## Purpose

Figma MCP can provide an AI coding agent with design context—node structure, variables, assets, screenshots, and design-system information—so generated UI is grounded in the source design rather than invented.

**Remote endpoint:** `https://mcp.figma.com/mcp` (remote server is the recommended starting point where supported). Figma also offers desktop/local workflows in some setups; confirm the currently supported setup and authentication in official Figma documentation.

## Commonly referenced tools

Tool names and availability can change by server version and plan. Verify the live tool list before relying on a name.

### Read/context tools
- `get_design_context`
- `get_variable_defs`
- `get_motion_context`
- `get_metadata`
- `search_design_system`
- `get_libraries`
- `get_screenshot`
- `download_assets`

### Write/design tools
- `create_new_file`
- `generate_figma_design`
- `html_to_figma`
- `send_code_to_figma`
- `create_generative_plugin`
- `create_shader`

### MCP prompt
- `create_design_system_rules`

These names are an integration checklist, not a guarantee that every account/server version exposes every tool.

## Workflow

1. Open the target frame or component in Figma.
2. Copy the node link using Figma's share/copy-link flow.
3. Paste the link into the coding agent with a request to inspect the exact node.
4. Ask the agent to retrieve design context, variables, component/library references, and a screenshot where available.
5. Compare retrieved structure with the page contract and existing component catalog.
6. Implement using the project's tokens and components; document any intentional deviation.
7. Validate at target responsive widths; a single frame is not a substitute for responsive design.

## Prompt for an agent

> Inspect the supplied Figma node before coding. Retrieve its design context, variable definitions, relevant library components, and screenshot if available. Map source values to existing project tokens. Do not invent missing design details or blindly copy raw values into components. Report mismatches between the Figma source, page contract, and repository design system before implementation.

## Remote vs desktop

- **Remote:** useful for a hosted MCP connection and consistent access where supported.
- **Desktop/local:** may provide a workflow tied to the running Figma desktop app or local plugin. Setup and exposed tools can differ.
- Do not assume a desktop server is available in headless environments.
- Keep access scoped to the files and actions required.

## Rate limits and client plugin

Figma API/MCP usage may be subject to rate limits, permissions, plan constraints, or tool-specific quotas. Batch reads when possible, cache stable context where appropriate, and handle throttling gracefully. A Figma plugin may be needed for particular client-side workflows such as sending generated UI/design data back into a file; verify the current official workflow before installation.

## Security

Do not paste secrets into prompts or commit tokens. Review any write-capable tool call before applying changes to shared design files.
