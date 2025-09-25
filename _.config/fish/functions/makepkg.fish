function makepkg --wraps makepkg --description 'Run makepkg with systemd-inhibit'
  systemd-inhibit --what=shutdown:idle --why="Building a package" makepkg $argv
        
end
