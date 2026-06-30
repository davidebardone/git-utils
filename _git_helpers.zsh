# Helper to find the absolute directory of this script
# This ensures it works even if called from another folder

check_is_git_repo() {
    # detect if we are inside a Git repository, exit otherwise
    if ! git rev-parse --git-dir &>/dev/null; then
	    printf '\r\e[2K\e[1m\e[31m  ❌ Error: Not a git repository.\e[0m\n' >&2
	    return 1
	fi
    return 0
}


hide_cursor() {
    printf '\e[?25l'  # hide cursor
}


get_lines_drawn() {
    # compute how many lines will be drawn
    # to show header, options and footer in the menu
    declare array_name="$1"
    declare -a options=("${(@P)array_name}")
    declare -i total=${#options[@]}
    print $((total + 4))  # header + branches (2 lines) + footer (2 lines)
}


reserve_screen_space() {
    # Allocate empty space on the screen for drawing the menu
    # params:
    # - name of the array that contains the options
    declare array_name="$1"
    lines_drawn=$(get_lines_drawn "$array_name")
    for (( i = 0; i < lines_drawn; i++ )); do printf '\n'; done
}


draw_options() {
    # Draw the menu
    # params:
    # - name of the array that contains the options
    # - string to be used as header
    # - name of the current option (if any)
    # - current highlight position

    declare array_name="$1"
    declare header="$2"
    declare current_selection="$3"
    declare -i active_idx="$4"

    declare -a options=("${(@P)array_name}")

    lines_drawn=$(get_lines_drawn "$array_name")
    
    declare -i total=${#options[@]}

    declare -i i
    
    # Move cursor up to redraw in place
    (( lines_drawn > 0 )) && printf '\e[%dA' "$lines_drawn"

    # Header
    printf '\r\e[2K\e[1m\e[36m  %s\e[0m\n' "$header"
    printf '\r\e[2K\n'

    # Options list
    for (( i = 0; i < total; i++ )); do
        local option="${options[$((i + 1))]}"
        printf '\r\e[2K'
        if (( i == active_idx )); then
            printf '\e[33m▶\e[0m \e[1m\e[44m %s \e[0m' "$option"
        else
            printf '   %s ' "$option"
        fi
        if [[ "$option" == "$current_selection" ]]; then
            printf ' \e[32m●\e[0m'
        fi
        printf '\n'
    done

    # Footer
    printf '\r\e[2K\n\e[2K  \e[2m↑/↓ navigate • enter select • q quit\e[0m\n'
}

run_input_loop() {
    # User input loop
    # params:
    # - name of the array that contains the options
    # - name of the variable with the current highlighted index
    # - function to be executed for re-drawing the menu at each iteration
    # - git action to be run when an item is selected

    declare array_name="$1"
    declare active_idx_name="$2"
    declare draw_func_name="$3"
    declare git_action="$4"     

    declare -i total_elements=${#${(P)array_name}[@]}

    stty -echo

    while true; do
        read -k 1 key 2>/dev/null

        if [[ "$key" == $'\e' ]]; then
            read -k 1 -t 0.05 seq1 2>/dev/null
            read -k 1 -t 0.05 seq2 2>/dev/null
            
            declare -i current_val=${(P)active_idx_name}

            case "$seq2" in
                A)  # Up
                    if (( current_val > 0 )); then
                        (( current_val-- ))
                        eval "$active_idx_name=$current_val"
                    fi
                    ;;
                B)  # Down
                    if (( current_val < total_elements - 1 )); then
                        (( current_val++ ))
                        eval "$active_idx_name=$current_val"
                    fi
                    ;;
            esac
        elif [[ "$key" == $'\n' || "$key" == $'\r' ]]; then
            printf '\e[?25h\n' 
            stty echo # Clean up terminal echo state
            
            declare -i final_val=${(P)active_idx_name}
            local chosen="${${(P)array_name}[$((final_val + 1))]}"

            # git_action can use $chosen directly (e.g. "${chosen%% *}" for hash)
            eval "$git_action"
            return $?  
        elif [[ "$key" == "q" || "$key" == "Q" ]]; then
            printf '\n'
            reset_terminal
            return 1  
        fi
        
        $draw_func_name "${(P)active_idx_name}"
    done
}

reset_terminal() {
    printf '\e[?25h'  # show cursor
    stty echo         # restore terminal echoing
}
