function topgrade --wraps topgrade --description 'Run topgrade with systemd-inhibit'
  systemd-inhibit --what=shutdown:idle --why="System upgrade" topgrade $argv
        
end
