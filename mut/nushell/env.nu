# Nushell Environment Config File
#
# version = "0.99.1"

def create_left_prompt [] {
    let dir = match (do --ignore-errors { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (if (is-admin) { ansi light_red_bold } else { ansi light_green_bold })
    let path_segment = $"($path_color)($dir)(ansi reset)"

    $path_segment | str replace --all (char path_sep) $"($separator_color)(char path_sep)($path_color)"
}

def create_right_prompt [] {
    # create a right prompt in magenta with green separators and am/pm underlined
    let time_segment = ([
        (ansi reset)
        (ansi magenta)
        (date now | format date '%x %X') # try to respect user's locale
    ] | str join | str replace --regex --all "([/:])" $"(ansi green)${1}(ansi magenta)" |
        str replace --regex --all "([AP]M)" $"(ansi magenta_underline)${1}")

    let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
        (ansi rb)
        ($env.LAST_EXIT_CODE)
    ] | str join)
    } else { "" }

    ([$last_exit_code, (char space), $time_segment] | str join)
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "> " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

# If you want previously entered commands to have a different prompt from the usual one,
# you can uncomment one or more of the following lines.
# This can be useful if you have a 2-line prompt and it's taking up a lot of space
# because every command entered takes up 2 lines instead of 1. You can then uncomment
# the line below so that previously entered commands show with a single `🚀`.
# $env.TRANSIENT_PROMPT_COMMAND = {|| "🚀 " }
# $env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
# $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
# $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
# $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
    "PATH": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
    "Path": {
        from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
        to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
    }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# To load from a custom file you can use:
# source ($nu.default-config-dir | path join 'custom.nu')

let darwin: bool = (uname | get operating-system) == "Darwin"
let nix: bool = "/nix" | path exists

if $darwin and $nix {
  $env.__NIX_DARWIN_SET_ENVIRONMENT_DONE = 1

  $env.PATH = [
      $"($env.HOME)/.nix-profile/bin"
      $"/etc/profiles/per-user/($env.USER)/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
      "/usr/local/bin"
      "/usr/bin"
      "/usr/sbin"
      "/bin"
      "/sbin"
  ]
  $env.EDITOR = "VIM"
  $env.NIX_PATH = [
      $"darwin-config=($env.HOME)/.nixpkgs/darwin-configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
  ]
  $env.NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt"
  $env.PAGER = "less -R"
  $env.TERMINFO_DIRS = [
      $"($env.HOME)/.nix-profile/share/terminfo"
      $"/etc/profiles/per-user/($env.USER)/share/terminfo"
      "/run/current-system/sw/share/terminfo"
      "/nix/var/nix/profiles/default/share/terminfo"
      "/usr/share/terminfo"
  ]
  $env.XDG_CONFIG_DIRS = [
      $"($env.HOME)/.nix-profile/etc/xdg"
      $"/etc/profiles/per-user/($env.USER)/etc/xdg"
      "/run/current-system/sw/etc/xdg"
      "/nix/var/nix/profiles/default/etc/xdg"
  ]
  $env.XDG_DATA_DIRS = [
      $"($env.HOME)/.nix-profile/share"
      $"/etc/profiles/per-user/($env.USER)/share"
      "/run/current-system/sw/share"
      "/nix/var/nix/profiles/default/share"
  ]
  $env.TERM = $env.TERM
  $env.NIX_USER_PROFILE_DIR = $"/nix/var/nix/profiles/per-user/($env.USER)"
  $env.NIX_PROFILES = [
      "/nix/var/nix/profiles/default"
      "/run/current-system/sw"
      $"/etc/profiles/per-user/($env.USER)"
      $"($env.HOME)/.nix-profile"
  ]

  if ($"($env.HOME)/.nix-defexpr/channels" | path exists) {
      $env.NIX_PATH = ($env.PATH | split row (char esep) | append $"($env.HOME)/.nix-defexpr/channels")
  }

  if (false in (ls -l `/nix/var/nix`| where type == dir | where name == "/nix/var/nix/db" | get mode | str contains "w")) {
      $env.NIX_REMOTE = "daemon"
  }
}

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# $env.PATH = ($env.PATH | split row (char esep) | prepend '/some/path')
# An alternate way to add entries to $env.PATH is to use the custom command `path add`
# which is built into the nushell stdlib:
use std "path add"
# $env.PATH = ($env.PATH | split row (char esep))
# path add /some/path
# path add ($env.CARGO_HOME | path join "bin")
try {
  if $darwin {
    $env.PATH = ["/opt/homebrew/bin" "/opt/X11/bin" "/opt/local/bin" "/opt/local/sbin"] ++ $env.PATH
  }
}
path add ($env.HOME | path join ".local" "bin")
$env.PATH = ($env.PATH | uniq)

$env.XDG_CACHE_HOME  = "~/.cache" | path expand
$env.XDG_DATA_HOME   = "~/.local/share" | path expand
$env.XDG_CONFIG_HOME = "~/.config" | path expand

if (which carapace | is-not-empty) {
  $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional
  carapace _carapace nushell | save --force ~/.cache/carapace.nu
}
if (which zoxide | is-not-empty) {
  zoxide init nushell --cmd=cd | save --force ~/.cache/zoxide.nu
}
if (which starship | is-not-empty) {
  starship init nu | save --force ~/.cache/starship.nu
}

if (not ("/var/run/docker.sock" | path exists)) and (not darwin) {
    $env.DOCKER_HOST = $"unix://($env | default $"/run/($env.USER)" XDG_RUNTIME_DIR | get XDG_RUNTIME_DIR)/docker.sock"
}

# if not ("/.dockerenv" | path exists) {
# do --env {
#     let ssh_agent_file = (
#         $nu.temp-path | path join $"ssh-agent-($env.USER).nuon"
#     )
#
#     if ($ssh_agent_file | path exists) {
#         let ssh_agent_env = open ($ssh_agent_file)
#         if (ps | where pid == ($ssh_agent_env.SSH_AGENT_PID | into int) | is-not-empty) {
#             load-env $ssh_agent_env
#             return
#         } else {
#             rm $ssh_agent_file
#         }
#     }
#
#     let ssh_agent_env = ssh-agent -c
#         | lines
#         | first 2
#         | parse "setenv {name} {value};"
#         | transpose --header-row
#         | into record
#     load-env $ssh_agent_env
#     $ssh_agent_env | save --force $ssh_agent_file
# }
# }
