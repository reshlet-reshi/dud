# shellcheck shell=sh

# SEE src/for-agents/docs/sh.md#safety-pattern
die() {
  echo "cleanup-merged-pr: $*" >&2
  exit 1
}

# SEE src/for-agents/docs/sh.md#safety-pattern
run() {
  echo "+ $*"
  "$@"
}

require_tools() {
  command -v git >/dev/null 2>&1 || die "git is required"
  command -v gh >/dev/null 2>&1 || die "gh is required"
}

enter_repo_root() {
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null) ||
    die "not inside a git repository"

  cd "$repo_root" || die "failed to enter repository root $repo_root"
}

require_clean_worktree() {
  if [ -n "$(git status --porcelain)" ]; then
    git status --short --branch >&2
    die "working tree must be clean before cleanup"
  fi
}

require_codex_gh_login() {
  login=$(gh api user --jq .login) ||
    die "failed to read active GitHub user with gh"

  if [ "$login" != "reshi-codex" ]; then
    die "expected gh active account reshi-codex, got $login"
  fi
}

load_merged_pr() {
  pr_number=$1

  pr_info=$(gh pr view "$pr_number" \
    --json state,baseRefName,headRefName,headRefOid \
    --template '{{.state}} {{.baseRefName}} {{.headRefName}} {{.headRefOid}}') ||
    die "failed to read PR #$pr_number"

  # SEE src/for-agents/docs/sh.md#field-parsing
  # Intentionally split fixed gh template fields into positional parameters.
  # shellcheck disable=SC2086
  set -- $pr_info

  if [ "$#" -ne 4 ]; then
    die "unexpected PR metadata for #$pr_number: $pr_info"
  fi

  pr_state=$1
  base_branch=$2
  head_branch=$3
  head_oid=$4

  if [ "$pr_state" != "MERGED" ]; then
    die "PR #$pr_number is $pr_state, not MERGED"
  fi

  if [ "$base_branch" != "main" ]; then
    die "PR #$pr_number targets $base_branch, not main"
  fi

  case "$head_branch" in
    main|master)
      die "refusing to clean protected branch $head_branch"
      ;;
  esac

  echo "PR #$pr_number is merged:"
  echo "  base: $base_branch"
  echo "  head: $head_branch"
  echo "  head oid: $head_oid"
}

delete_local_pr_branch() {
  if git show-ref --verify --quiet "refs/heads/$head_branch"; then
    local_oid=$(git rev-parse "$head_branch") ||
      die "failed to read local branch $head_branch"

    if [ "$local_oid" != "$head_oid" ]; then
      die "local $head_branch is $local_oid, expected merged PR head $head_oid"
    fi

    if ! git branch -d "$head_branch"; then
      run git branch -D "$head_branch"
    fi
  else
    echo "local branch $head_branch does not exist; nothing local to delete"
  fi
}

delete_remote_pr_branch_if_present() {
  remote_ref=$(git ls-remote --heads origin "$head_branch") ||
    die "failed to check remote branch $head_branch"

  if [ -n "$remote_ref" ]; then
    # SEE src/for-agents/docs/sh.md#field-parsing
    # Intentionally split ls-remote output into object id and ref name.
    # shellcheck disable=SC2086
    set -- $remote_ref
    remote_oid=$1

    if [ "$remote_oid" != "$head_oid" ]; then
      die "remote $head_branch is $remote_oid, expected merged PR head $head_oid"
    fi

    run git push origin --delete "$head_branch"
  else
    echo "remote branch $head_branch is already absent; nothing remote to delete"
  fi
}

cleanup_merged_pr() {
  require_tools
  enter_repo_root
  require_clean_worktree
  require_codex_gh_login
  load_merged_pr "$1"

  run git switch main
  run git pull --ff-only

  delete_local_pr_branch
  delete_remote_pr_branch_if_present

  run git fetch --prune
  run git status --short --branch
  run git branch -a
}
