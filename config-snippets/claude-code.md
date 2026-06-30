# Claude Code — add Periskop

Periskop is a remote Streamable-HTTP MCP server. Add it with one command (replace
`YOUR_PERISKOP_API_KEY` — get one at https://periskop.ai/developer):

```bash
claude mcp add --transport http periskop https://mcp.periskop.ai/v1/mcp \
  --header "Authorization: Bearer YOUR_PERISKOP_API_KEY"
```

Verify it connected and list its tools:

```bash
claude mcp list
```

You should see `periskop` with tools including `run_shopping_discovery`,
`discover_supported_stores`, `get_discovery_result`, `report_result_feedback`, and
`suggest_store_coverage`.

To remove it:

```bash
claude mcp remove periskop
```
