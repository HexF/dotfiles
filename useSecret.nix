{
    default ? builtins.abort "Secrets could not be loaded! (Try setting NIX_SECRETS)",
    callback    # Function which will get called with the contents of secrets
}:
let
    secrets = builtins.getEnv "NIX_SECRETS";
in
    if secrets != ""
    then callback (builtins.fromJSON secrets)
    else default


