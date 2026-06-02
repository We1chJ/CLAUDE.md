#!/bin/sh
input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
short_dir=$(basename "$dir")

model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# Build status line
status="${CYAN}📂 ${short_dir}${RESET}"

if [ -n "$model" ]; then
  status="${status} | ${GREEN}★ ${model}${RESET}"
fi

# Add context bar if available
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")

  # Determine color based on usage
  if [ "$used_int" -lt 50 ]; then
    ctx_color=$GREEN
  elif [ "$used_int" -lt 70 ]; then
    ctx_color=$YELLOW
  else
    ctx_color=$RED
  fi

  # Create progress bar (10 segments)
  filled=$((used_int / 10))
  empty=$((10 - filled))

  bar=""
  i=0
  while [ $i -lt $filled ]; do
    bar="${bar}▓"
    i=$((i + 1))
  done
  while [ $i -lt 10 ]; do
    bar="${bar}░"
    i=$((i + 1))
  done

  status="${status} | ${ctx_color}Context: ${bar} ${used_int}%${RESET}"
fi

# Add plan usage if available
usage_data=$(/Users/welchj/.claude/fetch-usage.sh 2>/dev/null)
if [ -n "$usage_data" ]; then
  session=$(echo "$usage_data" | jq -r '.session // empty' 2>/dev/null)
  weekly=$(echo "$usage_data" | jq -r '.weekly // empty' 2>/dev/null)

  if [ -n "$session" ] || [ -n "$weekly" ]; then
    status="${status} |"

    # Session bar
    if [ -n "$session" ] && [ "$session" != "null" ]; then
      session_int=$(printf "%.0f" "$session")
      if [ "$session_int" -lt 50 ]; then
        session_color=$GREEN
      elif [ "$session_int" -lt 80 ]; then
        session_color=$YELLOW
      else
        session_color=$RED
      fi
      session_filled=$(((session_int + 5) / 10))
      session_bar=""
      i=0
      while [ $i -lt $session_filled ]; do
        session_bar="${session_bar}▓"
        i=$((i + 1))
      done
      while [ $i -lt 10 ]; do
        session_bar="${session_bar}░"
        i=$((i + 1))
      done
      status="${status} ${session_color}Session: ${session_bar} ${session_int}%${RESET}"
    fi

    # Weekly bar
    if [ -n "$weekly" ] && [ "$weekly" != "null" ]; then
      weekly_int=$(printf "%.0f" "$weekly")
      if [ "$weekly_int" -lt 50 ]; then
        weekly_color=$GREEN
      elif [ "$weekly_int" -lt 80 ]; then
        weekly_color=$YELLOW
      else
        weekly_color=$RED
      fi
      weekly_filled=$(((weekly_int + 5) / 10))
      weekly_bar=""
      i=0
      while [ $i -lt $weekly_filled ]; do
        weekly_bar="${weekly_bar}▓"
        i=$((i + 1))
      done
      while [ $i -lt 10 ]; do
        weekly_bar="${weekly_bar}░"
        i=$((i + 1))
      done
      status="${status} | ${weekly_color}Weekly: ${weekly_bar} ${weekly_int}%${RESET}"
    fi
  fi
fi

printf "%b\n" "$status"
