#!/usr/bin/env bash
# Reconcile local git repos against GitHub.
#
#   ./sync-repos.sh [ROOT_DIR]      report + fast-forward pull only (safe, default)
#   PUSH=1 ./sync-repos.sh          also push branches that are purely ahead
#   CLONE=1 ./sync-repos.sh         also clone any GitHub repo missing locally
#
# Never force-pushes, never commits for you, never discards work.

set -uo pipefail

ROOT="${1:-$HOME/Documents}"
PUSH="${PUSH:-0}"
CLONE="${CLONE:-0}"

REMOTE_REPOS=(
  kingytan/personal
  kingytan/kingtan-com-au
  kingytan/LLM-Wiki
  kingytan/Business
  kingytan/job-hunting
  kingytan/Obsidian-Vault
  kingytan/claude-code
  kingytan/ellies-reading-quest
  kingytan/shutter-beast-joey
  kingytan/digi-flyer-qc
  kingytan/sveltia-cms-auth
  kingytan/project
)

bold=$'\e[1m'; red=$'\e[31m'; grn=$'\e[32m'; ylw=$'\e[33m'; dim=$'\e[2m'; rst=$'\e[0m'

declare -a NEEDS_ATTENTION=()
declare -a SEEN_SLUGS=()

echo "${bold}Scanning $ROOT${rst}"
echo

while IFS= read -r gitdir; do
  d="$(dirname "$gitdir")"
  name="$(basename "$d")"

  printf '%-32s' "$name"

  if ! git -C "$d" remote get-url origin >/dev/null 2>&1; then
    echo "${dim}no origin remote — skipped${rst}"
    continue
  fi

  # Record which GitHub repo this checkout corresponds to.
  origin_url="$(git -C "$d" remote get-url origin)"
  slug="$(sed -E 's#^.*github\.com[:/]##; s#\.git$##' <<<"$origin_url")"
  SEEN_SLUGS+=("$slug")

  if ! git -C "$d" fetch --all --prune --quiet 2>/dev/null; then
    echo "${red}fetch failed${rst} ${dim}(auth or network)${rst}"
    NEEDS_ATTENTION+=("$name: fetch failed")
    continue
  fi

  branch="$(git -C "$d" rev-parse --abbrev-ref HEAD)"
  dirty="$(git -C "$d" status --porcelain)"

  if ! upstream="$(git -C "$d" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"; then
    echo "${ylw}$branch has no upstream${rst}"
    NEEDS_ATTENTION+=("$name: '$branch' tracks nothing — git push -u origin $branch")
    continue
  fi

  read -r behind ahead < <(git -C "$d" rev-list --left-right --count "$upstream...HEAD" | tr '\t' ' ')

  status=""
  [[ -n "$dirty" ]] && status+="${ylw}$(wc -l <<<"$dirty" | tr -d ' ') uncommitted${rst} "

  if (( behind > 0 && ahead > 0 )); then
    echo "${status}${red}diverged${rst} ${dim}($ahead ahead, $behind behind)${rst}"
    NEEDS_ATTENTION+=("$name: '$branch' diverged — $ahead ahead, $behind behind. Rebase or merge by hand.")

  elif (( behind > 0 )); then
    if [[ -n "$dirty" ]]; then
      echo "${status}${ylw}$behind behind, not pulling${rst} ${dim}(dirty tree)${rst}"
      NEEDS_ATTENTION+=("$name: $behind behind but working tree dirty — commit or stash, then pull.")
    elif git -C "$d" merge --ff-only "$upstream" --quiet 2>/dev/null; then
      echo "${grn}pulled $behind${rst}"
    else
      echo "${red}ff-only pull refused${rst}"
      NEEDS_ATTENTION+=("$name: fast-forward refused — resolve by hand.")
    fi

  elif (( ahead > 0 )); then
    if [[ "$PUSH" == "1" ]]; then
      if git -C "$d" push --quiet 2>/dev/null; then
        echo "${status}${grn}pushed $ahead${rst}"
      else
        echo "${status}${red}push failed${rst}"
        NEEDS_ATTENTION+=("$name: push failed.")
      fi
    else
      echo "${status}${ylw}$ahead unpushed${rst}"
      NEEDS_ATTENTION+=("$name: $ahead commit(s) unpushed on '$branch' — rerun with PUSH=1")
    fi

  else
    if [[ -n "$dirty" ]]; then
      echo "${status}${dim}in sync${rst}"
      NEEDS_ATTENTION+=("$name: in sync with origin, but has uncommitted changes.")
    else
      echo "${grn}in sync${rst}"
    fi
  fi
done < <(find "$ROOT" -maxdepth 4 -type d -name .git -not -path '*/node_modules/*' 2>/dev/null | sort)

# --- repos on GitHub with no local checkout ---
echo
missing=()
for slug in "${REMOTE_REPOS[@]}"; do
  found=0
  slug_lc="$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]')"
  for seen in ${SEEN_SLUGS[@]+"${SEEN_SLUGS[@]}"}; do
    seen_lc="$(printf '%s' "$seen" | tr '[:upper:]' '[:lower:]')"
    [[ "$seen_lc" == "$slug_lc" ]] && { found=1; break; }
  done
  (( found == 0 )) && missing+=("$slug")
done

if (( ${#missing[@]} > 0 )); then
  echo "${bold}On GitHub but not in $ROOT:${rst}"
  for slug in "${missing[@]}"; do
    if [[ "$CLONE" == "1" ]]; then
      printf '  cloning %-30s' "$slug"
      if git -C "$ROOT" clone --quiet "git@github.com:$slug.git" 2>/dev/null; then
        echo "${grn}done${rst}"
      else
        echo "${red}failed${rst}"
      fi
    else
      echo "  ${ylw}$slug${rst}"
    fi
  done
  [[ "$CLONE" != "1" ]] && echo "  ${dim}rerun with CLONE=1 to clone these${rst}"
  echo
fi

# --- summary ---
if (( ${#NEEDS_ATTENTION[@]} > 0 )); then
  echo "${bold}Needs your attention:${rst}"
  printf '  %s\n' "${NEEDS_ATTENTION[@]}"
else
  echo "${grn}${bold}Everything in sync.${rst}"
fi
