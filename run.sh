#!/usr/bin/env bash
# One-command run: ensure Ollama server is up, optionally ensure model, then run the agent.
# Usage: ./run.sh   (or: OLLAMA_MODEL=llama3.2:1b ./run.sh)

set -e

OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
OLLAMA_MODEL="${OLLAMA_MODEL:-llama3.2:1b}"
CHECK_URL="${OLLAMA_HOST}/api/tags"
TIMEOUT=30

if ! command -v ollama &> /dev/null; then
  echo "Ollama is not on PATH. Install from https://ollama.com"
  exit 1
fi

if ! command -v curl &> /dev/null; then
  echo "curl is not installed or not on PATH. Install curl to use this script (needed to check Ollama server)."
  exit 1
fi

ollama_up() {
  curl -s -o /dev/null -w "%{http_code}" "$CHECK_URL" 2>/dev/null | grep -q 200
}

if ! ollama_up; then
  echo "Ollama server not reachable. Starting 'ollama serve' in the background..."
  nohup ollama serve &> /dev/null &
  WAITED=0
  while [ "$WAITED" -lt "$TIMEOUT" ]; do
    if ollama_up; then
      echo "Ollama server is ready."
      break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
  done
  if ! ollama_up; then
    echo "Ollama did not start in time (${TIMEOUT}s). Check 'ollama serve' manually."
    exit 1
  fi
fi

# Ensure the default model is available (first request would pull anyway; this makes it explicit)
ollama pull "$OLLAMA_MODEL" 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/ollama-agent.py"
