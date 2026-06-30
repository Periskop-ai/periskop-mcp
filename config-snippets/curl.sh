#!/usr/bin/env bash
# Raw MCP call to Periskop over Streamable HTTP (JSON-RPC 2.0 over HTTP POST).
#
# Auth: Periskop uses the standard MCP scheme  ->  Authorization: Bearer <key>
#       (NOT an "X-API-Key" header). API keys look like dp_...
#       Get a key at https://periskop.ai/developer
#
# Usage:  PERISKOP_API_KEY=dp_xxx ./curl.sh

set -euo pipefail

: "${PERISKOP_API_KEY:?Set PERISKOP_API_KEY to your dp_... key (https://periskop.ai/developer)}"
ENDPOINT="https://mcp.periskop.ai/v1/mcp"

# 1) List the available tools.
curl -sS -X POST "$ENDPOINT" \
  -H "Authorization: Bearer ${PERISKOP_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

echo

# 2) Run a shopping discovery.
curl -sS -X POST "$ENDPOINT" \
  -H "Authorization: Bearer ${PERISKOP_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/call",
    "params": {
      "name": "run_shopping_discovery",
      "arguments": {
        "prompt": "wireless noise-cancelling headphones for travel under 200€",
        "mode": "best"
      }
    }
  }'

echo
