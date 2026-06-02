#!/bin/sh
CACHE_FILE="$HOME/.claude/usage-cache.json"
CACHE_MAX_AGE=60

# Check if cache exists and is fresh
if [ -f "$CACHE_FILE" ]; then
  cache_time=$(stat -f%m "$CACHE_FILE" 2>/dev/null || stat -c%Y "$CACHE_FILE" 2>/dev/null || echo 0)
  current_time=$(date +%s)
  age=$((current_time - cache_time))

  if [ "$age" -lt "$CACHE_MAX_AGE" ]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# Cache is stale or missing, fetch new data
TOKEN=$(security find-generic-password -s 'Claude Code-credentials' -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken' 2>/dev/null)

if [ -z "$TOKEN" ]; then
  exit 1
fi

RESPONSE=$(curl -s -X GET "https://api.anthropic.com/api/oauth/usage" \
  -H "Authorization: Bearer $TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Content-Type: application/json" 2>/dev/null)

SESSION=$(echo "$RESPONSE" | jq -r '.current_session.utilization // .session.utilization // .five_hour.utilization // empty' 2>/dev/null)
WEEKLY=$(echo "$RESPONSE" | jq -r '.weekly.utilization // .seven_day.utilization // empty' 2>/dev/null)

if [ -n "$SESSION" ] || [ -n "$WEEKLY" ]; then
  CACHE_DATA="{\"session\":${SESSION:-null},\"weekly\":${WEEKLY:-null}}"
  echo "$CACHE_DATA" > "$CACHE_FILE"
  echo "$CACHE_DATA"
fi
