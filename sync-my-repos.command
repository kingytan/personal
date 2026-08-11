#!/bin/bash
#
#  Sync My Repos
#  =============
#  Double-click this file. It finds every GitHub project on this Mac,
#  saves whatever you've changed, uploads it, and downloads anything new.
#
#  It will never delete or overwrite your work. If something needs a human
#  decision, it leaves that project untouched and tells you at the end.
#

bold=$'\033[1m'; dim=$'\033[2m'; grn=$'\033[32m'; ylw=$'\033[33m'; red=$'\033[31m'; rst=$'\033[0m'

# Folders to look in. Add your own here if your projects live somewhere else.
SEARCH_DIRS="$HOME/Documents $HOME/Desktop $HOME/Developer $HOME/Projects $HOME/Code $HOME/repos $HOME/git $HOME/src"

# Everything on your GitHub account, so we can spot anything not yet on this Mac.
ALL_REPOS="kingytan/personal
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
kingytan/project"

STAMP="$(date '+%Y-%m-%d %H:%M')"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
: > "$WORK/problems" ; : > "$WORK/slugs" ; : > "$WORK/style"

CLONE_INTO="$HOME/Documents"

label() {
  pad="$1"
  while [ ${#pad} -lt 26 ]; do pad="$pad."; done
  printf '  %s ' "$pad"
}
note() { echo "  • $1" >> "$WORK/problems"; }

# Turn git's actual error into plain English. Never guess at a cause —
# a wrong explanation sends you chasing the wrong fix.
explain() {
  case "$1" in
    *Authentication*|*"could not read Username"*|*"Permission denied"*|*"access rights"*|*"terminal prompts disabled"*)
      echo "GitHub wouldn't let us in. Sign in to GitHub on this Mac, then run this again." ;;
    *"Could not resolve host"*|*"unable to access"*|*"Connection refused"*|*"timed out"*)
      echo "couldn't reach GitHub. Check your internet and run this again." ;;
    *"already exists"*)
      echo "there's already a folder with that name that isn't linked to GitHub. Rename it, then run this again." ;;
    *"Repository not found"*|*"not found"*)
      echo "GitHub says this project doesn't exist any more, or your account can't see it." ;;
    *"non-fast-forward"*|*"fetch first"*|*rejected*)
      echo "GitHub has newer work than this Mac does. Run this again and it should sort itself out." ;;
    *)
      echo "GitHub said: $(printf '%s' "$1" | grep -v -e '^Cloning' -e '^To ' -e '^remote:' | head -1)" ;;
  esac
}

clear
echo
echo "${bold}Syncing your GitHub projects${rst}   ${dim}$STAMP${rst}"
echo

# --------------------------------------------------- one-time first-run setup
if ! command -v git >/dev/null 2>&1; then
  echo "  ${red}Git isn't installed on this Mac yet.${rst}"
  echo "  A window should pop up offering to install it — say yes, then run this again."
  echo
  xcode-select --install >/dev/null 2>&1
  echo "${dim}You can close this window.${rst}"; echo
  exit 1
fi

if [ -z "$(git config --global user.email 2>/dev/null)" ] || [ -z "$(git config --global user.name 2>/dev/null)" ]; then
  echo "  ${ylw}First time running this — two quick questions, then never again.${rst}"
  echo "  ${dim}Your saved work gets stamped with these so you know who changed what.${rst}"
  echo
  printf "  Your name: "
  read -r setup_name
  printf "  Your email: "
  read -r setup_email
  if [ -z "$setup_name" ] || [ -z "$setup_email" ]; then
    echo
    echo "  ${red}Both are needed. Run this again when you're ready.${rst}"
    echo; echo "${dim}You can close this window.${rst}"; echo
    exit 1
  fi
  git config --global user.name "$setup_name"
  git config --global user.email "$setup_email"
  echo
  echo "  ${grn}Saved. Carrying on...${rst}"
  echo
fi

# ---------------------------------------------------------------- find repos
: > "$WORK/dirs"
for base in $SEARCH_DIRS; do
  [ -d "$base" ] || continue
  find "$base" -maxdepth 4 -type d -name .git \
       -not -path '*/node_modules/*' -not -path '*/Library/*' 2>/dev/null >> "$WORK/dirs"
done
sort -u "$WORK/dirs" -o "$WORK/dirs"

if [ ! -s "$WORK/dirs" ]; then
  echo "  ${ylw}No GitHub projects found on this Mac yet.${rst}"
  echo "  ${dim}Looked in Documents, Desktop, Developer, Projects, Code, repos, git, src${rst}"
  echo
fi

# ---------------------------------------------------------------- sync each
while IFS= read -r gitdir; do
  [ -n "$gitdir" ] || continue
  d="$(dirname "$gitdir")"
  name="$(basename "$d")"

  label "$name"

  url="$(git -C "$d" remote get-url origin 2>/dev/null)"
  if [ -z "$url" ]; then
    echo "${dim}not a GitHub project, skipped${rst}"
    continue
  fi

  echo "$url" | sed -E 's#^.*github\.com[:/]##; s#\.git$##' >> "$WORK/slugs"
  case "$url" in git@*) echo ssh > "$WORK/style" ;; esac

  branch="$(git -C "$d" rev-parse --abbrev-ref HEAD 2>/dev/null)"
  if [ "$branch" = "HEAD" ] || [ -z "$branch" ]; then
    echo "${ylw}needs a look${rst}"
    note "$name — this project is in an unusual state. Easiest fix is to open it in GitHub Desktop."
    continue
  fi

  did=""

  # 1. Save anything you've changed.
  changes="$(git -C "$d" status --porcelain 2>/dev/null | wc -l | tr -d ' ')"
  if [ "${changes:-0}" -gt 0 ]; then
    git -C "$d" add -A >/dev/null 2>&1
    if git -C "$d" commit -q -m "Sync from Mac — $STAMP" >/dev/null 2>&1; then
      if [ "$changes" = "1" ]; then did="saved 1 change"; else did="saved $changes changes"; fi
    else
      # Never silently claim success — an unsaved change is the one thing
      # you must hear about.
      echo "${red}couldn't save your changes${rst}"
      note "$name — your changes are still here but couldn't be saved. Run this again; if it keeps happening, that project needs a look in GitHub Desktop."
      continue
    fi
  fi

  # 2. Download anything new. Back out cleanly if it needs a human.
  if ! git -C "$d" fetch --quiet --prune 2>/dev/null; then
    echo "${red}couldn't reach GitHub${rst}"
    note "$name — couldn't connect to GitHub. Check your internet and run this again."
    continue
  fi

  has_upstream=no
  git -C "$d" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1 && has_upstream=yes

  if [ "$has_upstream" = "yes" ]; then
    incoming="$(git -C "$d" rev-list --count 'HEAD..@{u}' 2>/dev/null)"
    if [ "${incoming:-0}" -gt 0 ]; then
      if git -C "$d" merge --no-edit --quiet '@{u}' >/dev/null 2>&1; then
        if [ "$incoming" = "1" ]; then got="downloaded 1 update"; else got="downloaded $incoming updates"; fi
        did="${did:+$did, }$got"
      else
        git -C "$d" merge --abort >/dev/null 2>&1
        echo "${ylw}needs a look${rst}"
        note "$name — you and GitHub both changed the same file, so it needs you to pick a winner. Nothing was lost. Open it in GitHub Desktop."
        continue
      fi
    fi
  fi

  # 3. Upload.
  if [ "$has_upstream" = "no" ]; then
    if perr="$(git -C "$d" push -u origin "$branch" 2>&1)"; then
      did="${did:+$did, }uploaded"
    else
      echo "${red}couldn't upload${rst}"
      note "$name — $(explain "$perr")"
      continue
    fi
  else
    outgoing="$(git -C "$d" rev-list --count '@{u}..HEAD' 2>/dev/null)"
    if [ "${outgoing:-0}" -gt 0 ]; then
      if perr="$(git -C "$d" push 2>&1)"; then
        did="${did:+$did, }uploaded"
      else
        echo "${red}couldn't upload${rst}"
        note "$name — $(explain "$perr")"
        continue
      fi
    fi
  fi

  if [ -n "$did" ]; then echo "${grn}$did${rst}"; else echo "${dim}already up to date${rst}"; fi
done < "$WORK/dirs"

# ---------------------------------------------- download anything missing
CLONE_STYLE=https
[ -s "$WORK/style" ] && CLONE_STYLE=ssh

MISSING=""
for slug in $ALL_REPOS; do
  a="$(echo "$slug" | tr '[:upper:]' '[:lower:]')"
  hit=0
  while IFS= read -r seen; do
    b="$(echo "$seen" | tr '[:upper:]' '[:lower:]')"
    [ "$a" = "$b" ] && { hit=1; break; }
  done < "$WORK/slugs"
  [ "$hit" = "0" ] && MISSING="$MISSING $slug"
done

if [ -n "$MISSING" ]; then
  echo
  echo "${bold}On GitHub but not yet on this Mac${rst}  ${dim}downloading into Documents${rst}"
  mkdir -p "$CLONE_INTO"
  for slug in $MISSING; do
    short="$(basename "$slug")"
    label "$short"
    if [ "$CLONE_STYLE" = "ssh" ]; then
      remote="git@github.com:$slug.git"
    else
      remote="https://github.com/$slug.git"
    fi
    # Read what git actually says rather than guessing at the reason.
    if err="$(git -C "$CLONE_INTO" clone "$remote" 2>&1)"; then
      echo "${grn}downloaded${rst}"
    else
      echo "${red}couldn't download${rst}"
      case "$err" in
        *"already exists"*)
          note "$short — there's already a folder called '$short' in Documents that isn't linked to GitHub. Rename it (say, '$short-old'), then run this again." ;;
        *)
          note "$short — $(explain "$err")" ;;
      esac
    fi
  done
fi

# ---------------------------------------------------------------- summary
echo
if [ -s "$WORK/problems" ]; then
  echo "${ylw}${bold}A few need you to take a look:${rst}"
  cat "$WORK/problems"
  echo
  echo "${dim}  Nothing was deleted or overwritten in any of them.${rst}"
else
  echo "${grn}${bold}All done — everything is in sync.${rst}"
fi

echo
echo "${dim}You can close this window.${rst}"
echo
