#!/usr/bin/env zsh
#
# git-branch-select.zsh
# Navigate branches with arrow keys, press Enter to checkout.
#

# import helpers functions
source "${0:A:h}/_git_helpers.zsh"

check_is_git_repo || exit 1

declare -a branches=()
declare current_branch=""
declare -i active_idx=0

# collect branches (and the current one)
while IFS= read -r line; do
    line="${line## }"
    if [[ "$line" == \** ]]; then
        current_branch="${line#\* }"
        branches+=("$current_branch")
    else
	line="${line#"${line%%[^ ]*}"}"  # strip leading spaces only
        branches+=("$line")
    fi
done < <(git branch 2>/dev/null)

if (( ${#branches[@]} == 0 )); then
    printf '\r\e[2K\e[1m\e[31m  ❌ Error: No branches found.\e[0m\n' >&2
    exit 1
fi

# Start with current branch selected
for i in {1..${#branches[@]}}; do
    [[ "${branches[$i]}" == "$current_branch" ]] && active_idx=$((i - 1)) && break
done

# Define draw function for this command
draw() {
    declare highlight_idx="$1"
    draw_options branches "🌿 Select a Branch:" "$current_branch" "$highlight_idx"
}

hide_cursor

reserve_screen_space "branches"

trap reset_terminal EXIT INT TERM

draw "$active_idx"

run_input_loop "branches" "active_idx" "draw" 'git switch "$chosen"'

exit $?
