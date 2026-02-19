function yay --wraps yay --description 'Run yay with tweaks'
    # When yay shows diffs of AUR packages to be updated (via `git diff`),
    # enable paging even when diffs fit on screen, so that nothing is missed.
    # (git's default is -FRX, we don't want the -F)
    set --local --export LESS -RX
    # Inhibit shutdown and idleness
    systemd-inhibit --what=shutdown:idle --why="Package installation/removal/upgrade" yay $argv
end
