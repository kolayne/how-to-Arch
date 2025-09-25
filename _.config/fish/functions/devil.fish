function devil --wraps='sudo -Ebu $USER' --description 'Start a process in the background'
  if type -P $argv[1] &>/dev/null
    command $argv &>/dev/null & disown
  else
    echo devil: $argv[1]: no such file or directory >&2
    return 1
  end
end
