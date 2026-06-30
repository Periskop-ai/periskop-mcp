# Periskop — Product Discovery for AI Agents

Product discovery for AI agents. One MCP call turns a natural-language shopping
intent into structured, ranked product results — best picks, alternatives,
bundles, caveats, prices, and merchant links — from across independent stores on
the open merchant web.

Periskop is a hosted, remote MCP server (closed source). You connect over the
public HTTPS endpoint with a Periskop API key — nothing to install or run. It's
the discovery layer for agentic commerce: an agent asks in natural language and
Periskop returns ranked products with links back to the merchant. It stops at
discovery — no checkout, no payments, no orders.

- **Website:** https://periskop.ai
- **Developer portal / get an API key:** https://periskop.ai/developer
- **Docs:** https://periskop.ai/developer/docs
- **MCP endpoint:** `https://mcp.periskop.ai/v1/mcp` (Streamable HTTP, JSON-RPC 2.0)

## Who it's for

Any product that needs to turn intent into reliable product results without
owning checkout — agent platforms and orchestrators, AI worker platforms, AI
shopping assistants, browser agents, commerce copilots, recommendation systems,
procurement and B2B sourcing workflows, price and deal monitors, restock/reorder
bots, gifting apps, resale and arbitrage workflows, and accessibility shopping
tools. Concretely: an agent that plans a camping trip and returns the gear, a
procurement copilot comparing options across suppliers, or a voice assistant
surfacing the right product from a single sentence.

## What it does (and does not) do

Periskop returns product **results and merchant links only**. It **does not complete
checkout, create merchant carts, process payment, reserve inventory, or purchase items.**
The user always completes any purchase on the merchant's own website. Every response
carries a `purchase_boundary` block restating this.

## Connection

| | |
|---|---|
| **Endpoint** | `https://mcp.periskop.ai/v1/mcp` |
| **Transport** | Streamable HTTP — JSON-RPC 2.0 over HTTP POST (one JSON response per POST; no SSE) |
| **Wire protocol** | `2024-11-05` |
| **Auth** | `Authorization: Bearer <YOUR_PERISKOP_API_KEY>` (keys look like `dp_…`) |
| **Get a key** | https://periskop.ai/developer |

Unauthenticated requests receive `401` with a `WWW-Authenticate: Bearer` header.

> Note: Periskop also supports OAuth 2.1 (Authorization Code + PKCE) for hosts that prefer
> it (tokens look like `dpo_…`). API key is the simplest path and is all you need for the
> configs below.

## Tools

All tools take a single JSON object argument. Schemas below are the public tool surface.

### `run_shopping_discovery`
Find, choose, browse, recommend, get the best product, or build a bundle from a
natural-language request. The only required field is `prompt`.

| Field | Type | Required | Notes |
|---|---|---|---|
| `prompt` | string | ✅ | Natural-language shopping intent |
| `mode` | string \| null | | `auto` \| `browse` \| `recommend` \| `best` \| `bundle` (default `auto`) |
| `store` | string \| null | | `auto`, a store id, or a store name/hint |
| `country` | string \| null | | e.g. `PT`, `ES` |
| `currency` | string \| null | | e.g. `EUR` |
| `language` | string \| null | | e.g. `en`, `pt` |
| `max_results` | integer \| null | | Cap on returned products |
| `response_format` | string \| null | | `full` (default) \| `simple` |

### `get_discovery_result`
Retrieve a previous result by `result_id`. Results are temporary and may expire.

| Field | Type | Required |
|---|---|---|
| `result_id` | string | ✅ |
| `response_format` | string \| null | |

### `discover_supported_stores`
Inspect the public stores Periskop can use. Returns public store capabilities only.

| Field | Type | Required |
|---|---|---|
| `country` | string \| null | |
| `category` | string \| null | |
| `capability` | string \| null (`search` \| `bundle` \| `product_links`) | |

### `report_result_feedback`
Report whether a result was good, bad, or mixed.

| Field | Type | Required |
|---|---|---|
| `result_id` | string | ✅ |
| `rating` | string (`good` \| `bad` \| `mixed`) | ✅ |
| `reason` | string \| null | |
| `selected_product_id` | string \| null | |
| `freeform_feedback` | string \| null | |

### `suggest_store_coverage`
Suggest a store/merchant/marketplace Periskop should support in the future. **Non-billable.**
Does not search or scrape the store and does not guarantee future support.

| Field | Type | Required |
|---|---|---|
| `store_name` | string | ✅ |
| `store_url` | string \| null | |
| `country` / `region` / `category` | string \| null | |
| `context` | string \| null (e.g. `unsupported_store`, `no_match`) | |

## Example

### Request (JSON-RPC `tools/call`)
```bash
curl -sS -X POST https://mcp.periskop.ai/v1/mcp \
  -H "Authorization: Bearer YOUR_PERISKOP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "run_shopping_discovery",
      "arguments": { "prompt": "wireless noise-cancelling headphones for travel under 200€", "mode": "best" }
    }
  }'
```

### Response (trimmed — sample/fake data, not real)
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"result_id\":\"res_example_8f2a1c\",\"mode_used\":\"best\",\"products\":[{\"title\":\"SampleAudio Aero NC\",\"price\":\"€179.00\",\"currency\":\"EUR\",\"merchant\":\"Example Store\",\"url\":\"https://store.example/p/aero-nc\",\"role\":\"best_pick\"},{\"title\":\"Acme Quietline 2\",\"price\":\"€149.00\",\"currency\":\"EUR\",\"merchant\":\"Example Store\",\"url\":\"https://store.example/p/quietline-2\",\"role\":\"alternative\"}],\"caveats\":[\"Prices and availability may change on the merchant site.\"],\"purchase_boundary\":{\"checkout_created\":false,\"payment_processed\":false,\"stock_reserved\":false,\"user_must_complete_purchase_on_merchant_site\":true}}"
      }
    ]
  }
}
```

The structured payload is returned as text in `result.content[0].text`. Every response and
the `X-Request-ID` response header carry a per-call request id.

## Pricing (summary)

Prepaid wallet, billed only on **successful** discovery requests. Auth errors, malformed
requests, internal/runtime failures, rate limits, and hard no-match are **never billed**.
See the live rate at https://periskop.ai/developer/billing.

## Client setup

Copy-paste configs are in [`config-snippets/`](./config-snippets/): Cursor
(`.cursor/mcp.json`), Claude Desktop, Claude Code, and a raw `curl` example.
