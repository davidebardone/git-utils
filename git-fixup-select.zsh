#!/usr/bin/env zsh
#
# git-fixup.zsh
# Navigate current branch commits with arrow keys, press Enter to create new fixup commit.
#

# import helpers functions
source "${0:A:h}/_git_helpers.zsh"

check_is_git_repo || exit 1

typeset -a commits=()
typeset -i active_idx=0

# get branch commits
while IFS= read -r line; do
    line="${line#"${line%%[^ ]*}"}"  # strip leading spaces only
    commits+=("$line")
done < <(git log $(git merge-base --fork-point main HEAD 2>/dev/null)..HEAD --oneline)

if (( ${#commits[@]} == 0 )); then
    printf '\r\e[2K\e[1m\e[31m  ❌ Error: No commits found.\e[0m\n' >&2
    exit 1
fi

# Define draw function for this command
draw() {
    declare highlight_idx="$1"
    draw_options commits "📌 Select a commit to fixup:" "" "$highlight_idx"
}

hide_cursor

reserve_screen_space "commits"

trap reset_terminal EXIT INT TERM

draw "$active_idx"

run_input_loop "commits" "active_idx" "draw" 'git commit --fixup "${chosen%% *}" --no-edit'

if (( $? == 0 )); then
    # Show newly created commit hash
    new_hash=$(git rev-parse --short HEAD)
    printf "\n🚀 Created a new fixup commit: \e[1m\e[32m%s\e[0m\n" "$new_hash"
else
    printf "\n❌ No fixup commit has been created.\n" >&2
fi

exit $?
