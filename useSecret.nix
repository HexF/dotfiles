{
    file ? ./secrets.json,
    default ? throw "Secret Not Found!",
    callback    # Function which will get called with the contents of secrets
}:
    if builtins.pathExists file
    then callback (builtins.fromJSON (builtins.readFile file))
    else default


