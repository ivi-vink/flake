def load-posix-env [p: string] {
    bash -c $"source ($p) && env"
        | lines
        | parse "{n}={v}"
        | filter { |x| ($x.n not-in $env) or $x.v != ($env | get $x.n) }
        | where n not-in ["_", "LAST_EXIT_CODE", "DIRS_POSITION"]
        | transpose --header-row
        | into record
        | load-env
}

load-posix-env /etc/profile
# load-posix-env $"($env.HOME)/.profile"
$env.PATH = $env.PATH ++ [$"($env.HOME)/.local/bin"]
