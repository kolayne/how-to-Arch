#!/bin/sh
SLEEPTIME=${1:-21}  # Screen will be off for at most this time
type light >/dev/null || exit $?

trap true HUP INT TERM QUIT
trap "light -I" EXIT
light -O
light -S "$(light -P)"
sleep "$SLEEPTIME" & wait
