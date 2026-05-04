#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=""
BRANCH=""
PORCELAIN_FILE=""
TRACKING_DIR=""
TRACKING_MAX_BYTES_RAW="${TRACKING_MAX_BYTES:-}"
if [[ "$TRACKING_MAX_BYTES_RAW" =~ ^[0-9]+$ ]]; then
  MAX_BYTES="$TRACKING_MAX_BYTES_RAW"
else
  MAX_BYTES="10485760"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    --porcelain-file)
      PORCELAIN_FILE="$2"
      shift 2
      ;;
    --tracking-dir)
      TRACKING_DIR="$2"
      shift 2
      ;;
    *)
      echo "Unknown arg: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REPO_ROOT" || -z "$BRANCH" || -z "$PORCELAIN_FILE" || -z "$TRACKING_DIR" ]]; then
  echo "Missing required args" >&2
  exit 2
fi

mkdir -p "$TRACKING_DIR"
LATEST_JSON="$TRACKING_DIR/latest.json"
HISTORY="$TRACKING_DIR/history.ndjson"
LATEST_TXT="$TRACKING_DIR/latest.txt"
LOCK_FILE="$TRACKING_DIR/.history.lock"

UNTRACKED=()
MODIFIED=()
DELETED=()
RENAMED=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue

  if [[ "$line" == '?? '* ]]; then
    UNTRACKED+=("${line:3}")
    continue
  fi

  status="${line:0:2}"
  path="${line:3}"
  x="${status:0:1}"
  y="${status:1:1}"

  if [[ "$x" == "R" || "$y" == "R" ]]; then
    RENAMED+=("$path")
  fi
  if [[ "$x" == "D" || "$y" == "D" ]]; then
    DELETED+=("$path")
  fi
  if [[ "$x" == "M" || "$y" == "M" ]]; then
    MODIFIED+=("$path")
  fi
done < "$PORCELAIN_FILE"

to_json_array() {
  if [[ $# -eq 0 ]]; then
    printf '[]'
  else
    printf '%s\n' "$@" | jq -Rsc 'split("\n")[:-1]'
  fi
}

json="$(jq -cn \
  --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg repo "$REPO_ROOT" \
  --arg branch "$BRANCH" \
  --argjson untracked "$(to_json_array "${UNTRACKED[@]}")" \
  --argjson modified "$(to_json_array "${MODIFIED[@]}")" \
  --argjson deleted "$(to_json_array "${DELETED[@]}")" \
  --argjson renamed "$(to_json_array "${RENAMED[@]}")" \
  '{timestamp:$ts,repo_root:$repo,branch:$branch,untracked:$untracked,modified:$modified,deleted:$deleted,renamed:$renamed}')"

{
  flock -x 9

  if [[ -f "$HISTORY" ]]; then
    size="$(wc -c < "$HISTORY" | tr -d '[:space:]')"
    if [[ "$size" -gt "$MAX_BYTES" ]]; then
      rotation_ts="$(date -u +%Y%m%dT%H%M%SZ)"
      rotation_ns="$(date -u +%N)"
      rotation_base="$TRACKING_DIR/history.${rotation_ts}.${rotation_ns}.$$"
      rotation_target="${rotation_base}.ndjson"
      rotation_index=0
      while [[ -e "$rotation_target" ]]; do
        rotation_index=$((rotation_index + 1))
        rotation_target="${rotation_base}.${rotation_index}.ndjson"
      done

      if [[ -f "$HISTORY" ]]; then
        if ! mv "$HISTORY" "$rotation_target"; then
          if [[ -f "$HISTORY" ]]; then
            exit 1
          fi
        fi
      fi
    fi
  fi

  printf '%s\n' "$json" > "$LATEST_JSON"
  printf '%s\n' "$json" >> "$HISTORY"
} 9>>"$LOCK_FILE"

{
  echo "timestamp: $(jq -r '.timestamp' "$LATEST_JSON")"
  echo "repo: $(jq -r '.repo_root' "$LATEST_JSON")"
  echo "branch: $(jq -r '.branch' "$LATEST_JSON")"
  echo "untracked: $(jq -r '.untracked | length' "$LATEST_JSON")"
  echo "modified: $(jq -r '.modified | length' "$LATEST_JSON")"
  echo "deleted: $(jq -r '.deleted | length' "$LATEST_JSON")"
  echo "renamed: $(jq -r '.renamed | length' "$LATEST_JSON")"
} > "$LATEST_TXT"
