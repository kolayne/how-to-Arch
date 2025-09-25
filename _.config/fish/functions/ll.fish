function ll --wraps=ls --wraps='lsd -al --icon never' --description 'alias ll lsd -al --icon never'
  lsd -al --icon never $argv
        
end
