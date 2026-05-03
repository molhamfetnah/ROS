_git_tracking_resolve_real_git_bin() {
  local configured resolved
  configured="${REAL_GIT_BIN:-}"

  if [[ -n "$configured" ]]; then
    if [[ "$configured" != /* ]]; then
      printf '[tracking-warning] unsafe REAL_GIT_BIN value: %s\n' "$configured" >&2
    elif [[ ! -x "$configured" ]]; then
      printf '[tracking-warning] REAL_GIT_BIN is not executable: %s\n' "$configured" >&2
    else
      printf '%s\n' "$configured"
      return
    fi
  fi

  resolved="$(type -P git 2>/dev/null || true)"
  if [[ -z "$resolved" || ! -x "$resolved" ]]; then
    resolved="/usr/bin/git"
  fi
  printf '%s\n' "$resolved"
}

_git_tracking_effective_command() {
  local arg
  while (($#)); do
    arg="$1"
    case "$arg" in
      --)
        shift
        printf '%s\n' "${1:-}"
        return
        ;;
      -C|-c|--exec-path|--git-dir|--work-tree|--namespace|--super-prefix|--config-env)
        shift 2
        ;;
      --exec-path=*|--git-dir=*|--work-tree=*|--namespace=*|--super-prefix=*|--config-env=*|--list-cmds=*|\
      -p|--paginate|--no-pager|--no-replace-objects|--bare|--literal-pathspecs|--no-literal-pathspecs|\
      --glob-pathspecs|--noglob-pathspecs|--icase-pathspecs)
        shift
        ;;
      -*)
        shift
        ;;
      *)
        printf '%s\n' "$arg"
        return
        ;;
    esac
  done
}

_git_tracking_global_args() {
  local arg
  while (($#)); do
    arg="$1"
    case "$arg" in
      --)
        return
        ;;
      -C|-c|--exec-path|--git-dir|--work-tree|--namespace|--super-prefix|--config-env)
        printf '%s\n' "$arg"
        shift
        if (($#)); then
          printf '%s\n' "$1"
        fi
        shift
        ;;
      --exec-path=*|--git-dir=*|--work-tree=*|--namespace=*|--super-prefix=*|--config-env=*|--list-cmds=*|\
      -p|--paginate|--no-pager|--no-replace-objects|--bare|--literal-pathspecs|--no-literal-pathspecs|\
      --glob-pathspecs|--noglob-pathspecs|--icase-pathspecs)
        printf '%s\n' "$arg"
        shift
        ;;
      -*)
        printf '%s\n' "$arg"
        shift
        ;;
      *)
        return
        ;;
    esac
  done
}

git() {
  local real_git tracker tracked_root cmd
  local -a global_args
  real_git="$(_git_tracking_resolve_real_git_bin)"
  tracker="${TRACKER_SCRIPT:-/mnt/data/ros/scripts/track-git-status.sh}"
  tracked_root="/mnt/data/ros"
  cmd="$(_git_tracking_effective_command "$@")"
  mapfile -t global_args < <(_git_tracking_global_args "$@")

  if [[ "$cmd" == "status" || "$cmd" == "st" ]]; then
    local top
    top="$("$real_git" "${global_args[@]}" rev-parse --show-toplevel 2>/dev/null || true)"

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
