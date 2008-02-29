#!/bin/sh
set -eu
USAGE="[<signal>] <profile>"
LONG_USAGE="Bring <profile> connection down.

When <sig> is given, kill the process with the signal specified. The default
signal is -TERM.

This command exits with 1 when the command does not come down
properly, 2 when the connection is already is already down, and 0 if
sucessful."

# Bring in basic sh configuration
. hem-sh-setup
need_config

# Parse arguments
sig="-TERM"
while [ $# -gt 0 ]
do
    case "$1" in
        -[A-Z]*|-[0-9]*)   sig="$1";;
        -*)                usage;;
        *)                 break;;
    esac
    shift
done

# Grab profile or die
profile_name="$1"
test -z "$profile_name" && usage
shift

# Die if more than one profile provided
test $# -gt 0 && usage

# Bring in profile settings
profile_with $profile_name

# Check that connection isn't already running.
pid=$("$execdir/hem-status" --pid $profile_name)
if [ -z "$pid" ] ; then
    info "$profile_name is already down"
    exit 2
fi

info "taking down: $profile_name (pid: $pid) with $sig"
log "taking down $profile_name (pid: $pid) with $sig"

command="kill $sig $pid"
log "+ kill $sig $pid"
if $command ; then
    exit 0
else
    result=$?
    log "kill failed with $result"
    die "kill failed with $result"
fi
