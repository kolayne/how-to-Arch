function alert --description 'Play sound and send notification when the previous command completes. Return with the $status of the previous command'
    set -l STATUS "$status"

    if test "$STATUS" -eq 0
        paplay /usr/share/sounds/linux-a11y/stereo/complete.oga & disown
        notify-send Success (status current-commandline)
    else
        paplay ~/.config/fish/oof.mp3 & disown
        notify-send Failed (status current-commandline)
    end

    return "$STATUS"

end
