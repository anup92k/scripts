#!/bin/bash
version="0.4"

# --------------------------------------------------------
# Script to send Nagios notification with Gotify
# --------------------------------------------------------


# Menu generated with https://argbash.io/ and some elbow grease

# End the process
# Args:
#   $1: The exit message (print to stderr)
#   $2: The exit code (default is 1)
# if env var _PRINT_HELP is set to 'yes', the usage is print to stderr (prior to $1)
die()
{
  local _ret=$2
  test -n "$_ret" || _ret=1
  test "$_PRINT_HELP" = yes && print_help >&2
  echo "$1" >&2
  exit ${_ret}
}


# Evaluates whether a value passed to it begins by a character
begins_with_short_option()
{
  local first_option all_short_options='hv'
  first_option="${1:0:1}"
  test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}


# The positional args array has to be reset before the parsing, because it may already be defined
_positionals=()

# Call for Help !
print_help()
{
  printf '%s\n' "Nagios Gotify help"
  printf 'Usage: %s [-h|--help] [-v|--version] <token> <url> <object_type> <notification_type> <state> <host_name> <description> <output>\n' "$0"
  printf '\t%s\n' "<token>: Gotify app token"
  printf '\t%s\n' "<url>: Gotify URL"
  printf '\t%s\n' "<object_type>: 'Host' or 'Service'"
  printf '\t%s\n' "-h, --help: Prints help"
  printf '\t%s\n' "-v, --version: Prints version"
}


# The parsing of the command-line
parse_commandline()
{
  _positionals_count=0
  while test $# -gt 0
  do
    _key="$1"
    case "$_key" in
      # The help argurment doesn't accept a value,
      # we expect the --help or -h, so we watch for them.
      -h|--help)
        print_help
        exit 0
        ;;
      -h*)
        print_help
        exit 0
        ;;
      -v|--version)
        echo "Nagios Gotify v$version"
        exit 0
        ;;
      -v*)
        echo "Nagios Gotify v$version"
        exit 0
        ;;
      *)
        _last_positional="$1"
        _positionals+=("$_last_positional")
        _positionals_count=$((_positionals_count + 1))
        ;;
    esac
    shift
  done
}


# Return 0 if everything is OK, 1 if we have too little arguments
# and 2 if we have too much arguments
handle_passed_args_count()
{
  local _required_args_string="'token', 'url', 'object_type', 'notification_type', 'state', 'host_name', 'description' and 'output'"
  test "${_positionals_count}" -ge 8 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 8 (namely: $_required_args_string), but got only ${_positionals_count}." 1
  test "${_positionals_count}" -le 8 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 8 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


# Take arguments that we have received, and save them in variables of given names.
# The 'eval' command is needed as the name of target variable is saved into another variable.
assign_positional_args()
{
  local _positional_name _shift_for=$1
  # We have an array of variables to which we want to save positional args values.
  # This array is able to hold array elements as targets.
  # As variables don't contain spaces, they may be held in space-separated string.
  _positional_names="_arg_token _arg_url _arg_object_type _arg_notification_type _arg_state _arg_host_name _arg_description _arg_output "

  shift "$_shift_for"
  for _positional_name in ${_positional_names}
  do
    test $# -gt 0 || break
    eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
    shift
  done
}

# Call all the functions defined above that are needed to get the job done
parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"

# End of menu


# 'object_type' value should be 'host' or 'service'
if [[ !($_arg_object_type = "Host" || $_arg_object_type = "Service") ]]; then
  _PRINT_HELP=yes die "FATAL ERROR: Wrong object_type value - we require 'Host' or 'Service', but got ${_arg_object_type}." 3
fi


## At this point, all values are stored in values
## Uncomments for debug
#echo "token : $_arg_token"
#echo "url : $_arg_url"
#echo "object_type : $_arg_object_type"
#echo "notification_type : $_arg_notification_type"
#echo "state : $_arg_state"
#echo "host_name : $_arg_host_name"
#echo "description : $_arg_description" # host address or service description
#echo "output : $_arg_output"


# Do you have cURL ?
if [[ $(command -v curl >/dev/null 2>&1) ]]; then
  _PRINT_HELP=no die "FATAL ERROR: This script require cURL !" 4
fi


# Argument `state` (`$_arg_state`) made into icons !
# Icons from https://www.emojicopy.com
case "$_arg_state" in
  UP)
    _icon="✅"
  ;;
  DOWN)
    _icon="🆘"
  ;;
  UNREACHABLE)
    _icon="💫"
  ;;
  OK)
    _icon="🆗"
  ;;
  WARNING)
    _icon="⚠️"
  ;;
  CRITICAL)
    _icon="❌"
  ;;
  UNKNOWN)
    _icon="❓"
  ;;
  *)
    _icon=""
  ;;
esac


# Processing notification content
## Title
_title="$_icon "
_title+="$_arg_object_type "
_title+="$_arg_host_name: "
_title+="$_arg_description - "
_title+="$_arg_state"
## Message
_message="$_arg_notification_type : "
_message+="$_arg_output"


# Finally cURLing !
curl_http_result=$(curl "${_arg_url}/message?token=${_arg_token}" -F "title=${_title}" -F "message=${_message}" -F "priority=10" --output /dev/null --silent --write-out %{http_code})
if [[ $? -ne 0 ]]; then
  _PRINT_HELP=no die "FATAL ERROR: cURL command failed !" 5
fi

# Check HTTP return code ("200" is OK)
if [[ $curl_http_result -ne 200 ]]; then
  _PRINT_HELP=no die "FATAL ERROR: API call failed ! Return code is $curl_http_result instead of 200." 6
fi


exit 0