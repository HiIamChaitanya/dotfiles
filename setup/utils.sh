#!/bin/bash

cmd_exists() {
    command -v "$1" &>/dev/null
}

execute() {
    local -r CMDS="$1"
    local -r MSG="${2:-$1}"
    local -r TMP_FILE="$(mktemp /tmp/XXXXX)"

    local exitCode
    local cmdsPID=""

    trap "kill $cmdsPID 2>/dev/null" EXIT

    # Execute commands in background and redirect both stdout and stderr
    eval "$CMDS" &>"$TMP_FILE" &
    cmdsPID=$!

    show_spinner "$cmdsPID" "$CMDS" "$MSG"

    wait "$cmdsPID" 2>/dev/null
    exitCode=$?

    print_result "$exitCode" "$MSG"
    if ((exitCode != 0)); then
        print_error_stream <"$TMP_FILE"
    fi

    rm -rf "$TMP_FILE"

    return "$exitCode"
}

set_trap() {
    trap -p "$1" | grep -q "$2" || trap "$2" "$1"
}

get_answer() {
    printf "%s" "$REPLY"
}

get_os() {
    local os=""
    local kernelName=""

    kernelName="$(uname -s)"

    if [[ "$kernelName" == "Darwin" ]]; then
        os="macos"
    elif [[ "$kernelName" == "Linux" ]] && [[ -e "/etc/os-release" ]]; then
        . /etc/os-release
        printf "%s" "$ID"
        os="$ID"
    else
        os="$kernelName"
    fi

    printf "%s" "$os"
}

print_error() {
    local message="$1"
    local details="${2:-}"
    if [[ -n "$details" ]]; then
        message="$message: $details"
    fi
    print_formatted "  [✖]" "$message" 1 # Red color code
}

print_in_color() {
    local text="$1"
    local colorCode="$2"
    printf "%b" "$(tput setaf "$colorCode" 2>/dev/null)" "$text" "$(tput sgr0 2>/dev/null)"
}

print_formatted() {
    local prefix="$1"
    local message="$2"
    local colorCode="$3" # Optional color code
    local formattedPrefix=""

    if [[ -n "$colorCode" ]]; then
        formattedPrefix="$(print_in_color "$prefix" "$colorCode")"
    else
        formattedPrefix="$prefix"
    fi

    printf "  %s %s\n" "$formattedPrefix" "$message"
}

print_in_green() {
    print_formatted "[✔]" "$1" 2 # Green color code
}

print_in_purple() {
    print_formatted "[?]" "$1" 5 # Purple color code (used for questions now)
}

print_in_red() {
    print_formatted "[✖]" "$1" 1 # Red color code
}

print_in_yellow() {
    print_formatted "[!]" "$1" 3 # Yellow color code (used for warnings now)
}

print_question() {
    print_formatted "[?]" "$1" 3 # Using yellow for questions
}

print_result() {
    local exitCode="$1"
    local message="$2"
    if (("$exitCode" == 0)); then
        print_success "$message"
    else
        print_error "$message"
    fi
    return "$exitCode"
}

print_success() {
    print_in_green "$1"
}

print_warning() {
    print_in_yellow "$1"
}

show_spinner() {
    local -r FRAMES='/-\|'
    local -r NUMBER_OR_FRAMES=${#FRAMES}
    local -r CMDS="$2"
    local -r MSG="$3"
    local -r PID="$1"

    local i=0
    local frameText=""

    if [[ "${TRAVIS:-false}" != "true" ]]; then
        printf "\n\n\n"
        tput cuu 3 2>/dev/null
        tput sc
    fi

    while kill -0 "$PID" &>/dev/null; do
        frameText="  [$(print_in_purple "${FRAMES:i++%NUMBER_OR_FRAMES:1}")] $MSG" # Use purple for spinner
        if [[ "${TRAVIS:-false}" != "true" ]]; then
            printf "%s\n" "$frameText"
        else
            printf "%s" "$frameText"
        fi
        sleep 0.2
        if [[ "${TRAVIS:-false}" != "true" ]]; then
            tput rc
        else
            printf "\r"
        fi
    done
}

# Function to get the currently logged-in username
get_username() {
    whoami
}

