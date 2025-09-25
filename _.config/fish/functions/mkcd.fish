function mkcd --wraps=mkdir --description 'alias mkcd mkdir -p'
  mkdir -p $argv
  and cd $argv[-1]
        
end
