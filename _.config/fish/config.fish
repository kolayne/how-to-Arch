if status is-interactive
    abbr --add '``' --position anywhere --set-cursor=% '(%)'

    abbr --add gco git checkout
    abbr --add --set-cursor=% gcl git clone --recursive git@github.com:%

    abbr --add vpna wg-quick up amsterdam
    abbr --add vpnad wg-quick down amsterdam

    abbr --add umnt udisksctl mount -b
    abbr --add uumnt udisksctl unmount -b

    abbr --add inhib --set-cursor=% systemd-inhibit --what=%handle-lid-switch

    function show_run_time --on-event fish_postexec
        if test "$CMD_DURATION" -lt 5000
            return
        end

        set --local millis "$CMD_DURATION"
        set --local secs "$(math -s 0 $millis / 1000)"
        set --local mins "$(math -s 0 $secs / 60)"
        set --local hours "$(math -s 0 $mins / 60)"
        set --local days "$(math -s 0 $hours / 24)"

        echo -ne "\\033[90mRan in "
        if test "$days" -gt 0
            echo -n "$days""d"
        end
        if test "$hours" -gt 0
            echo -n "$(math -s 0 "$hours" % 24)h"
        end
        if test "$mins" -gt 0
            echo -n "$(math -s 0 "$mins" % 60)m"
        end
        if test "$secs" -gt 0
            echo -n "$(math -s 0 "$secs" % 60)s"
        end
        if test "$millis" -gt 0
            echo -n "$(math -s 0 "$millis" % 1000)ms"
        end

        # Carriage return
        echo
    end
end
