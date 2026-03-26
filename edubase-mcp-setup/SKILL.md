---
name: edubase-mcp-setup
description: >
  Guides setup and first-use of the EduBase MCP server — the integration that connects Claude to
  the EduBase e-learning platform. Use this skill when the user asks how to install, configure, or
  connect the EduBase MCP server; when they ask for their API credentials or integration App ID/Secret;
  when they get errors connecting Claude Desktop (or another MCP client) to EduBase; or when they
  want to verify that the integration is working. Also use at the start of any EduBase MCP session to
  orient the agent on what server is connected and how to confirm the connection is live.
---

# EduBase MCP Server — Setup & First Use

## What is this?

The EduBase MCP server connects Claude (and other MCP-compatible clients) to an EduBase account.
Once connected, the agent can create questions, manage quizzes and exams, look up users and results,
and perform any action available through the EduBase API — all through natural conversation.

GitHub: https://github.com/EduBase/MCP  
Developer docs: https://developer.edubase.net  
Step-by-step guide: https://edubase.blog/claude-mcp-integration-guide/

---

## Step 1 — Get EduBase API credentials

The user needs an **App ID** and **Secret Key** from their EduBase account:

1. Log in to EduBase → **Profile → Dashboard → Integrations**
   (Integrations may appear under *Additional elements*)
2. Click **"Add integration"** → choose type **"EduBase API, MCP"**
3. Name it anything (e.g. *"Claude MCP"*)
4. Click **Add** → the credentials appear:
   - **Application ID** (= `EDUBASE_API_APP`)
   - **Secret Key** (= `EDUBASE_API_KEY`)
   - **API URL** (= `EDUBASE_API_URL`, shown on the page)
5. Copy both values immediately — the Secret Key is not shown again

> **No "EduBase API, MCP" option?** Enter promo code `MCPGITHUB` or `MCPEduBaseBlog`
> on the integrations page, or contact info@edubase.net to request access.

The API URL format is `https://<subdomain>.edubase.net/api`.
For the default public instance it is `https://www.edubase.net/api`.

---

## Step 2 — Install the MCP server

Three installation methods. Pick whichever fits the user's environment.

### Option A — Node.js

Prerequisites: Node.js installed (https://nodejs.org)

```json
{
  "mcpServers": {
    "edubase": {
      "command": "node",
      "args": [
        "-y",
        "@edubase/mcp"
      ],
      "env": {
        "EDUBASE_API_URL": "https://www.edubase.net/api",
        "EDUBASE_API_APP": "<YOUR_APP_ID>",
        "EDUBASE_API_KEY": "<YOUR_SECRET_KEY>"
      }
    }
  }
}
```

### Option B — Docker

Prerequisites: Docker installed and running (https://docker.com)

```json
{
  "mcpServers": {
    "edubase": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "EDUBASE_API_URL",
        "-e", "EDUBASE_API_APP",
        "-e", "EDUBASE_API_KEY",
        "edubase/mcp"
      ],
      "env": {
        "EDUBASE_API_URL": "https://www.edubase.net/api",
        "EDUBASE_API_APP": "<YOUR_APP_ID>",
        "EDUBASE_API_KEY": "<YOUR_SECRET_KEY>"
      }
    }
  }
}
```

### Option C — Smithery

```bash
npx -y @smithery/cli install @EduBase/MCP --client claude
```
This handles everything automatically. Run it, then restart Claude Desktop.

### Option D — Remote MCP server (if EduBase hosts the endpoint)

If the EduBase instance exposes `/mcp` (e.g. `https://domain.edubase.net/mcp`):

```json
{
  "mcpServers": {
    "edubase": {
      "command": "npx",
      "args": [
        "mcp-remote",
        "https://domain.edubase.net/mcp",
        "--header",
        "Authorization: Bearer <BASE64(APP_ID:SECRET_KEY)>"
      ]
    }
  }
}
```

Bearer token = base64 of `APP_ID:SECRET_KEY` (colon-separated).

---

## Step 3 — Configure the claude_desktop_config.json

Config file location:
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

In Claude Desktop: **Files → Settings → Developer → Edit Config**

If the file already has other MCP servers, **merge** the `"edubase"` block into the existing
`"mcpServers"` object — do not replace the whole file.

After saving: **restart Claude Desktop** fully (quit and reopen).

---

## Step 4 — Verify the connection

Once Claude Desktop is running with the config, the agent can verify immediately:

**Quick check — call the debug tools:**
```
edubase_mcp_server_version   → should return a version string (e.g. "1.1.2")
```

**Account check — call:**
```
edubase_get_user_me          → returns the EduBase account details for the connected credentials
```

If `edubase_get_user_me` returns a name/account → the integration is live and working.

**In Claude Desktop UI:** After restart, the tool count should increase significantly
(the EduBase MCP adds ~124 tools). Click the tools icon to verify EduBase tools are listed.

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| No EduBase tools visible | Config not saved / Claude not restarted | Save config, fully quit & reopen Claude Desktop |
| `edubase_get_user_me` returns error | Wrong App ID or Secret Key | Re-check credentials on EduBase Integrations page |
| API URL error | Wrong URL format | Must be `https://domain.edubase.net/api` (with `/api`) |
| Docker: server not found | Docker not running | Start Docker Desktop first |
| "Option not available" | No MCP access on account | Use promo code `MCPGITHUB` on Integrations page |

---

## Environment variables reference

| Variable | Required | Description |
|----------|----------|-------------|
| `EDUBASE_API_URL` | Yes | Base API URL: `https://domain.edubase.net/api` |
| `EDUBASE_API_APP` | Yes* | Integration App ID from EduBase |
| `EDUBASE_API_KEY` | Yes* | Integration Secret Key from EduBase |
| `EDUBASE_SSE_MODE` | No | Set `true` to use SSE HTTP transport |
| `EDUBASE_STREAMABLE_HTTP_MODE` | No | Set `true` to use streamable HTTP transport |
| `EDUBASE_HTTP_PORT` | No | HTTP port when using SSE/streamable mode (default: 3000) |

*Not required when using remote MCP server with Bearer token auth.

---

## After setup — what the agent can do

Once connected, the agent discovers all available tools automatically from the MCP server.
No tool documentation is needed here — the agent reads tool descriptions at runtime and acts accordingly.

The EduBase hierarchy for reference:
- **Questions** → lowest level, the actual quiz items
- **Quiz sets** → named collections of questions
- **Exams** → highest level, built from quiz sets, assigned to users/classes

The agent can create, read, and manage all of these, plus users, classes, organizations, tags,
results, certificates, and more — all through the tools exposed by the connected MCP server.
