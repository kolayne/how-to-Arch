function waitpgrep --description 'Wait for the output of pgrep to change' --wraps='pgrep'
    watch -g pgrep $argv
end
