function edevil --wraps devil --description "Run the process in background and exit"
    devil $argv && exit
end
