if not pgrep -u "$USER" ssh-agent >/dev/null
    ssh-agent -c -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
end
source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
