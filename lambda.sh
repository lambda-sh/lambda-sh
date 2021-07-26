#!/bin/bash
# The lambda utility script. This file is to serve as a "header" file for making
# writing bash scripts bit easier. This has been built and tested with
# bash 5.0.18
#
# Some notes about this file:
# * Variables and functions that match __LAMBDA* should not be used externally.
# * This is still highly experimental and hasn't been used/tested across
#   multiple shells and platforms.
# * the compile_and_run.sh script holds very good example usage and is integral
#   in the script itself.

# ---------------------------------- COLORS ------------------------------------

__LAMBDA_COLOR_BLACK=0
__LAMBDA_COLOR_RED=1
__LAMBDA_COLOR_GREEN=2
__LAMBDA_COLOR_YELLOW=3
__LAMBDA_COLOR_BLUE=4
__LAMBDA_COLOR_MAGENTA=5
__LAMBDA_COLOR_CYAN=6
__LAMBDA_COLOR_WHITE=7
__LAMBDA_COLOR_NOT_USED=8
__LAMBDA_COLOR_DEFAULT=9

# Checks if the term variable is set.
__LAMBDA_TERM_IS_SET() {
    if [[ -z ${TERM} ]]; then
        return 1
    else
        return 0
    fi
}

# Make output bold.
__LAMBDA_TERM_SET_BOLD() {
    if __LAMBDA_TERM_IS_SET; then
        tput bold
    fi
}

# Make output underlined.
__LAMBDA_TERM_SET_UNDERLINE() {
    if __LAMBDA_TERM_IS_SET; then
        tput smul
    fi
}

# Make the output blink.
__LAMBDA_TERM_SET_BLINK() {
    if __LAMBDA_TERM_IS_SET; then
        tput blink
    fi
}

# Make the output standout.
__LAMBDA_TERM_SET_STANDOUT() {
    if __LAMBDA_TERM_IS_SET; then
        tput blink
    fi
}

# Clear all attributes.
__LAMBDA_TERM_CLEAR_ATTRIBUTES() {
    if __LAMBDA_TERM_IS_SET; then
        tput sgr0
    fi
}

# Set the foreground color.
__LAMBDA_TERM_SET_FOREGROUND() {
    if __LAMBDA_TERM_IS_SET; then
        tput setaf $1
    fi
}

# Reset the foreground to it's default.
__LAMBDA_TERM_CLEAR_FOREGROUND() {
    if __LAMBDA_TERM_IS_SET; then
        tput setaf $__LAMBDA_COLOR_DEFAULT
    fi
}

# Set the background color.
__LAMBDA_TERM_SET_BACKGROUND() {
    if __LAMBDA_TERM_IS_SET; then
        tput setab $1
    fi
}

# Clear the background.
__LAMBDA_TERM_CLEAR_BACKGROUND() {
    if __LAMBDA_TERM_IS_SET; then
        tput setab $__LAMBDA_COLOR_NOT_USED
    fi
}

# Clear the entire screen.
__LAMBDA_TERM_CLEAR_SCREEN() {
    if __LAMBDA_TERM_IS_SET; then
        tput clear
    fi
}

# --------------------------------- TYPES ------------------------------------

LAMBDA_TYPE_NUMBER="number"
LAMBDA_TYPE_STRING="string"
LAMBDA_TYPE_LIST="list"

# --------------------------------- LOGGING ------------------------------------

# Log a trace/debug message.
# Example usage:
# LAMBDA_TRACE "This is an trace message."j
LAMBDA_LOG_TRACE() {
    __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_WHITE
    __LAMBDA_TERM_SET_BACKGROUND $__LAMBDA_COLOR_BLACK
    __LAMBDA_TERM_SET_BOLD
    printf "[TRACE][%s][%s]:" $(date +"%F") $(date +"%T")
    __LAMBDA_TERM_CLEAR_ATTRIBUTES
    printf " $1\n"
}

# Log an info message.
# Example usage:
# LAMBDA_WARN "This is an informational message."j
LAMBDA_LOG_INFO() {
    __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_BLACK
    __LAMBDA_TERM_SET_BACKGROUND $__LAMBDA_COLOR_GREEN
    __LAMBDA_TERM_SET_BOLD
    printf "[INFO][%s][%s]:" $(date +"%F") $(date +"%T")
    __LAMBDA_TERM_CLEAR_ATTRIBUTES
    printf " $1\n"
}

# Log an error message.
# Example usage:
# LAMBDA_WARN "This is a warning message."j
LAMBDA_LOG_WARN() {
    __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_BLACK
    __LAMBDA_TERM_SET_BACKGROUND $__LAMBDA_COLOR_YELLOW
    __LAMBDA_TERM_SET_BOLD
    printf "[WARN][%s][%s]:" $(date +"%F") $(date +"%T")
    __LAMBDA_TERM_CLEAR_ATTRIBUTES
    printf " $1\n"
}

# Log an error message.
# Example usage:
# LAMBDA_ERROR "This is an error message."j
LAMBDA_LOG_ERROR() {
    __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_BLACK
    __LAMBDA_TERM_SET_BACKGROUND $__LAMBDA_COLOR_RED
    __LAMBDA_TERM_SET_BOLD
    printf "[ERROR][%s][%s]:" $(date +"%F") $(date +"%T")
    __LAMBDA_TERM_CLEAR_ATTRIBUTES
    printf " $1\n"
}

# Log a fatal message and quit.
# Example usage:
# LAMBDA_LOG_FATAL "Couldn't load a file, exiting the script."
LAMBDA_LOG_FATAL() {
    __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_BLACK
    __LAMBDA_TERM_SET_BACKGROUND $__LAMBDA_COLOR_RED
    __LAMBDA_TERM_SET_BOLD
    printf "[FATAL][%s][%s]:" $(date +"%F") $(date +"%T")
    __LAMBDA_TERM_CLEAR_ATTRIBUTES
    printf " $1\n"

    if [ "$0" = "-bash" ]; then
        return 1
    else
        exit 1
    fi
}

# -------------------------------- ARG PARSING ---------------------------------

export __LAMBDA_ARGS_REGISTERED_MAP=()
export __LAMBDA_ARGS_DEFAULT_VALUES=()
export __LAMBDA_ARGS_HELP_STRINGS=()
export __LAMBDA_ARGS_IS_SET=()
export __LAMBDA_ARGS_COUNT=0


export __LAMBDA_ARGS_ADD_REGISTERED_MAP=()
export __LAMBDA_ARGS_ADD_DEFAULT_VALUES=()
export __LAMBDA_ARGS_ADD_HELP_STRINGS=()
export __LAMBDA_ARGS_ADD_IS_SET=()
export __LAMBDA_ARGS_ADD_COUNT=0

# Cached variables that is used to clean up variables after they've been 
# instantiated.
export __LAMBDA_ARGS_CACHED=()

# Parse an argument that you want to use for your script.
# Example usage looks like:
# LAMBDA_PARSE_ARG tool sandbox "The tool to compile and run."
#
# This would register an argument given the arg name (--tool),
# default value (sandbox), and lastly a help string. The arguments are then
# pushed into arrays and bounded by a key to the index they hold within all
# arrays.
#
# ARG_NAME -> The long hand name of the argument.
# HELP_STRING -> The Help string for the argument.
# DEFAULT_VALUE -> The default value of argument.
__LAMBDA_ARGS_PARSE() {
    ARG_NAME="$1"
    DESCRIPTION="$2"
    DEFAULT_VALUE="$3"

    ARG_NAME_TO_INDEX="${ARG_NAME}:${__LAMBDA_ARGS_ADD_COUNT}"
    __LAMBDA_ARGS_ADD_REGISTERED_MAP+=("$ARG_NAME_TO_INDEX")
    __LAMBDA_ARGS_ADD_DEFAULT_VALUES+=("$DEFAULT_VALUE")
    __LAMBDA_ARGS_ADD_HELP_STRINGS+=("$DESCRIPTION")
    __LAMBDA_ARGS_ADD_IS_SET+=(0)
    __LAMBDA_ARGS_ADD_COUNT=$((1 + $__LAMBDA_ARGS_ADD_COUNT))
}

LAMBDA_ARGS_ADD() {
    __LAMBDA_ARGS_PARSE name "The name of the argument."

    __LAMBDA_ARGS_PARSE \
        description \
        "The description of the argument being created" \
        "[WARNING]: Description not set."

    __LAMBDA_ARGS_PARSE \
        default \
        "The default value of the argument (No value implies it's required)" \
        "__LAMBDA_ARGS_REQUIRED"


    LAMBDA_ARGS_COMPILE "--internal_lambda_args" "$@"

    local ARG_NAME="$LAMBDA_name"
    local DESCRIPTION="$LAMBDA_description"
    local DEFAULT_VALUE="$LAMBDA_default"

    local ARG_NAME_TO_INDEX="${ARG_NAME}:${__LAMBDA_ARGS_COUNT}"
    __LAMBDA_ARGS_REGISTERED_MAP+=("$ARG_NAME_TO_INDEX")
    __LAMBDA_ARGS_DEFAULT_VALUES+=("$DEFAULT_VALUE")
    __LAMBDA_ARG_DESCRIPTIONS+=("$DESCRIPTION")
    __LAMBDA_ARGS_IS_SET+=(0)
    __LAMBDA_ARGS_COUNT=$((1 + $__LAMBDA_ARGS_COUNT))

    unset -v LAMBDA_name
    unset -v LAMBDA_description
    unset -v LAMBDA_default
}

__LAMBDA_ARGS_SHOW_HELP_STRING() {
  __LAMBDA_TERM_SET_FOREGROUND $__LAMBDA_COLOR_GREEN
  printf "\n%-20s %-20s %-20s %-20s\n" "Arg" "Default value" "Required" "Description"
  __LAMBDA_TERM_CLEAR_ATTRIBUTES

  for ((i=0; i<"$__LAMBDA_ARGS_COUNT"; i++)); do
    IFS=':' read -ra ARG_MAP <<< "${__LAMBDA_ARGS_REGISTERED_MAP[${i}]}"

    ARG_NAME="${ARG_MAP[0]}"
    ARG_INDEX="${ARG_MAP[1]}"
    ARG_DEFAULT_VALUE="${__LAMBDA_ARGS_DEFAULT_VALUES[${ARG_INDEX}]}"
    ARG_DESCRIPTION="${__LAMBDA_ARG_DESCRIPTIONS[${ARG_INDEX}]}"
    ARG_REQUIRED="false"

    if [ -z "${__LAMBDA_ARGS_DEFAULT_VALUES[${ARG_INDEX}]}" ]; then
      ARG_REQUIRED="true"
      ARG_DEFAULT_VALUE=""
    fi

    printf "%-20s %-20s %-20s %-20s\n" \
      "--$ARG_NAME" \
      "$ARG_DEFAULT_VALUE" \
      "$ARG_REQUIRED" \
      "$ARG_DESCRIPTION"

  done
  printf "\n"
}

__lambda_args_reset() {
  local INTERNAL_USE="$1"
  if [ "$INTERNAL_USE" = 1 ]; then
    export __LAMBDA_ARGS_ADD_REGISTERED_MAP=()
    export __LAMBDA_ARGS_ADD_DEFAULT_VALUES=()
    export __LAMBDA_ARGS_ADD_HELP_STRINGS=()
    export __LAMBDA_ARGS_ADD_IS_SET=()
    export __LAMBDA_ARGS_ADD_COUNT=0
  else
    export __LAMBDA_ARGS_REGISTERED_MAP=()
    export __LAMBDA_ARGS_DEFAULT_VALUES=()
    export __LAMBDA_ARGS_HELP_STRINGS=()
    export __LAMBDA_ARGS_IS_SET=()
    export __LAMBDA_ARGS_COUNT=0
  fi
}

lambda_args_cleanup() {
    for value in "${__LAMBDA_ARGS_CACHED[@]}"; do
        unset -v "$value"
    done
}

# Compile a list of arguments that are created from LAMBDA_PARSE_ARG calls.
# Example usage:
#
# LAMBDA_PARSE_ARG tool sandbox "This is an argument help string"
# LAMBDA_COMPILE_ARGS $@
# echo $LAMBDA_tool
#
# You first register the arguments that you want your script to take in and then
# forward your scripts arguments directly into LAMBDA_COMPILE_ARGS. If nothing
# goes wrong with parsing then you'll have access to either the value or default
# value of the argument that you've passed in as shown with $LAMBDA_tool.
#
# Values that have no default values are assumed to be arguments that are
# required to be passed in by the person interacting with the script.
#
# TODO(C3NZ): This can be broken down into sub components and also has
# repetitive & potentially inefficient behaviour. While this isn't problematic
# right now, this implementation might not be concrete depending on finding an
# implementation that works better than using multiple arrays.
LAMBDA_ARGS_COMPILE() {
  if [ "$1" = "--help" ]; then
    __LAMBDA_ARGS_SHOW_HELP_STRING $0
    LAMBDA_LOG_FATAL "Script execution disabled when using --help"
    __lambda_args_reset 0
    return 1
  fi

  local ARGS_REGISTERED=("${__LAMBDA_ARGS_REGISTERED_MAP[@]}")
  local ARG_SET_LIST=("${__LAMBDA_ARGS_IS_SET[@]}")
  local ARG_DEFAULT_VALUES=("${__LAMBDA_ARGS_DEFAULT_VALUES[@]}")
  local ARG_COUNT="${__LAMBDA_ARGS_COUNT}"
  local INTERNAL_USE=0

  if [ "$1" = "--internal_lambda_args" ]; then
    ARGS_REGISTERED=("${__LAMBDA_ARGS_ADD_REGISTERED_MAP[@]}")
    ARG_SET_LIST=("${__LAMBDA_ARGS_ADD_IS_SET[@]}")
    ARG_DEFAULT_VALUES=("${__LAMBDA_ARGS_ADD_DEFAULT_VALUES[@]}")
    ARG_COUNT="${__LAMBDA_ARGS_ADD_COUNT}"
    INTERNAL_USE=1
    shift 1
  fi

  # Iterate through the arguments and parse them into variables.
  while (("$#")); do
    local FOUND=0
    for ((i=0; i < $ARG_COUNT; i++)); do
        IFS=':' read -ra ARG_MAP <<< "${ARGS_REGISTERED[${i}]}"

        ARG_NAME="${ARG_MAP[0]}"
        ARG_INDEX="${ARG_MAP[1]}"

        if [ "$1" = "--$ARG_NAME" ]; then
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                export "LAMBDA_${ARG_NAME//-/_}"="$2"
                ARG_SET_LIST[${ARG_INDEX}]=1
                FOUND=1
                shift 2
                break
            else
                LAMBDA_LOG_FATAL "No argument for flag $1"
            fi
        fi
     done

     # If the argument cannot be found, let the user know that
     # it's not an unsupported flag or a positional argument.
     if [ $FOUND = 0 ]; then
        if [[ "$1" =~ --* ]]; then
            LAMBDA_LOG_FATAL \
              "Unsupported flag: $1. Run with --help to see the flags."
        else
            LAMBDA_LOG_FATAL "No support for positional arguments."
        fi
     fi
  done

  # Add default values to any argument that wasn't given a value.
  for ((i=0; i < $ARG_COUNT; i++)); do
    IFS=':' read -ra ARG_MAP <<< "${ARGS_REGISTERED[${i}]}"

    local ARG_NAME="${ARG_MAP[0]}"
    local ARG_INDEX="${ARG_MAP[1]}"

    if [ "${ARG_SET_LIST[${ARG_INDEX}]}" = 0 ]; then
      if [ -z "${ARG_DEFAULT_VALUES[${ARG_INDEX}]}" ]; then
        LAMBDA_LOG_FATAL \
          "--$ARG_NAME has no default value and therefore cannot be left empty."
      elif [ "${ARG_DEFAULT_VALUES[${ARG_INDEX}]}" = "__LAMBDA_ARGS_REQUIRED" ]; then
        local DEFAULT_VALUE=""
        __LAMBDA_ARGS_CACHED+=("LAMBDA_${ARG_NAME//-/_}")
        export "LAMBDA_${ARG_NAME//-/_}"="$DEFAULT_VALUE"
      else
        DEFAULT_VALUE="${ARG_DEFAULT_VALUES[${ARG_INDEX}]}"
        __LAMBDA_ARGS_CACHED+=("LAMBDA_${ARG_NAME//-/_}")
        export "LAMBDA_${ARG_NAME//-/_}"="$DEFAULT_VALUE"
      fi
    fi
  done

  __lambda_args_reset "$INTERNAL_USE"
}

# -------------------------------- ASSERTIONS ----------------------------------

# Asserts whether or not the last ran command has succeeded. Expects one 
# argument that should be the message output if the assertion has failed.
LAMBDA_ASSERT_LAST_COMMAND_OK() {
    if [ $? -ne 0 ]; then
        LAMBDA_LOG_FATAL "$1"
    fi
}
