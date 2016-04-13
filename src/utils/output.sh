# color variables
ESC="\033["
RESET=$ESC"0m"
RED=$ESC"0;31;01m"
GREEN=$ESC"0;32;01m"
YELLOW=$ESC"0;33;01m"
BLUE=$ESC"0;34;01m"
MAGENTA=$ESC"0;35;01m"

# print funcion
output () {
    # load params
    level=${1}
    message=${2}
    case $level in
        ok)
            printf "${GREEN}[ok]${RESET} %b" "$message"
            ;;
        warn)
            printf "${BLUE}[warning]${RESET} %b" "$message"
            ;;
        info)
            printf "${BLUE}[info]${RESET} %b" "$message"
            ;;
        error)
            printf "${RED}[error]${RESET} %b" "$message"
            ;;
        debug)
            if [ -n "$DEBUG" ]; then
                printf "${MAGENTA}[debug]${RESET} %b\n" "$message" 1>&2
            fi
            ;;
        running)
            printf "${YELLOW}[running]${RESET} %b" "$message"
            ;;
        internal_error)
            printf "${RED}[internal error]${RESET} %b\n" "$message" 1>&2
            printf "    Please file an issue at https://github.com/ludat/dottle/issues\n" 1>&2
            ;;
        *)
            output internal_error "bad output level ('$level'),\n    original message: $message"
            ;;
    esac
}
