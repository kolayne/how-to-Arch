function topgrade --wraps topgrade --description 'Run topgrade with tweaks'
    # When yay shows diffs of AUR packages to be updated (via `git diff`),
    # enable paging even when diffs fit on screen, so that nothing is missed.
    # Also, display each diff separately.
    # (git's default is -FRX, -F is --quit-if-one-screen, -X is --no-init,
    #  preventing the termcap initialization/deinitialization strings)
    set --local --export LESS -R
    # Inhibit shutdown and idleness
    systemd-inhibit --what=shutdown:idle --why="System upgrade" topgrade $argv
end
