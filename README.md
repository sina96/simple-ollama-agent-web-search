# Ollama agent with web search

A small **intro project** to [Ollama](https://ollama.com) and its APIs: a stateless terminal agent that talks to a local Ollama model and can use **tools** (current date, DuckDuckGo web search). Good for learning the Ollama chat API, tool-calling flow, and integrating search without an API key.

## What it does

- **Chat**: Sends your question to Ollama’s `/api/chat` endpoint and prints the model’s reply.
- **Tools**: Can offer the model two tools — `get_current_date` (local) and `web_search` (DuckDuckGo via [ddgs](https://pypi.org/project/ddgs/)).
- **Tool-gate**: Only enables tools when the question looks like it needs up-to-date or dated info (e.g. “today”, “news”, “weather”). General-knowledge questions get a direct answer with no tools.
- **Stateless**: Each turn is a new conversation (no history between turns).

## Prerequisites

1. **Python 3.10+**
2. **Ollama** installed and running locally  
   - Install: [ollama.com](https://ollama.com)  
   - Start: run `ollama serve` (or start the Ollama app). The agent expects `http://localhost:11434`.
3. **A model pulled** in Ollama, e.g.:
   ```bash
   ollama pull llama3.2:1b
   ```
   The code defaults to `llama3.2:1b`; you can change `MODEL` in `ollama-agent.py`.

## Setup

```bash
# Clone or enter the project directory
cd ollama-ddgs

# Create and activate a virtual environment (recommended)
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## How to run

```bash
python ollama-agent.py
```

You’ll see a prompt like:

```
Local Ollama Agent (stateless) — type 'exit' to quit

You:
```

Type your question and press Enter. The agent will call Ollama (and optionally run tools) and print the reply. Type `exit` or `quit` to stop.

## How to use the agent

- **General knowledge** (e.g. “What does HTTP stand for?”)  
  Tools are not sent; the model answers from its knowledge. You’ll see in logs: `tool-gate: use_tools=False`, `tools=0`.

- **Dated / live info** (e.g. “What day is today?”, “Latest news about …”)  
  Tools are enabled. The model may call `get_current_date` or `web_search`. You’ll see `tool-gate: use_tools=True`, `tools=2`, and log lines for tool execution.

- **Debug logs**  
  Set `DEBUG = True` in `ollama-agent.py` (default) to see tool-gate, API calls, and tool runs. Set `DEBUG = False` for a quieter session.

- **Config**  
  Edit the top of `ollama-agent.py`: `OLLAMA_URL`, `MODEL`, `DEBUG`, `COLOR`.

## APIs used

- **Ollama**: [Chat API](https://github.com/ollama/ollama/blob/main/docs/api.md#chat) with a `messages` array and optional `tools` (OpenAI-style function definitions). The agent uses non-streaming (`stream: false`) and, when the model returns tool calls, appends tool results and calls the chat API again.
- **Search**: [ddgs](https://pypi.org/project/ddgs/) for `web_search` — no API key required.
