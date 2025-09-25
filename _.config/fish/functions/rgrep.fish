function rgrep --wraps='grep -Rn' --description 'alias rgrep=grep -Rn'
  grep -Rn $argv
        
end
