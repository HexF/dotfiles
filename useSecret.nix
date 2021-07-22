{
    file ? ./secrets.json,
    default,    # Value if not unlocked
    callback    # Function which will get called with the contents of secrets
}:
let
    unlocked = builtins.readFile ./unlocked;
in
    if unlocked != "false"
    then callback (builtins.fromJSON (builtins.readFile file))
    else default


