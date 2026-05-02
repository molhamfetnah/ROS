git() {
  local real_git tracker tracked_root cmd
  real_git="${REAL_GIT_BIN:-/usr/bin/git}"
  tracker="${TRACKER_SCRIPT:-/mnt/data/ros/scripts/track-git-status.sh}"
  tracked_root="/mnt/data/ros"
  cmd="${1:-}"

  if [[ "$cmd" == "status" || "$cmd" == "st" ]]; then
    local top
    top="$("$real_git" rev-parse --show-toplevel 2>/dev/null || true)"

    if [[ "$top" == "$tracked_root" ]]; then
      local tracking_dir branch porcelain_file
      tracking_dir="$top/.tracking"
      branch="$("$real_git" -C "$top" branch --show-current 2>/dev/null || printf 'unknown')"
      porcelain_file="$tracking_dir/.git-status-porcelain.$$.$RANDOM"

      mkdir -p "$tracking_dir"
      if ! "$real_git" -C "$top" status --porcelain=v1 >"$porcelain_file" 2>/dev/null; then
        : >"$porcelain_file"
      fi

      if ! "$tracker" \
        --repo-root "$top" \
        --branch "$branch" \
        --porcelain-file "$porcelain_file" \
        --tracking-dir "$tracking_dir" \
        >/dev/null 2>&1; then
        printf '[tracking-warning] failed to write tracking artifacts\n' >&2
      fi

      rm -f "$porcelain_file"
    fi
  fi

  "$real_git" "$@"
}
