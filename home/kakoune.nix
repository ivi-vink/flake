{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  programs.kakoune = {
    enable = true;

    config = {
      colorScheme = "gruvbox-dark";
      autoReload = "yes";
      numberLines = {
        enable = true;
        relative = true;
      };
    };
    extraConfig = ''
      # Source a local project kak config if it exists
      # Make sure it is set as a kak filetype
      hook global BufCreate (.*/)?(\.kakrc\.local) %{
          set-option buffer filetype kak
      }
      try %{ source .kakrc.local }

      eval %sh{kak-lsp --kakoune -s $kak_session}  # Not needed if you load it with plug.kak.
      hook global WinSetOption filetype=(rust|python|go|javascript|typescript|c|cpp) %{
         lsp-enable-window
         lsp-auto-signature-help-enable
         hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
         hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
         hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
         hook -once -always window WinSetOption filetype=.* %{
            remove-hooks window semantic-tokens
         }
      }

      map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
      map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
      map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
      map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
      map global object e '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
      map global object k '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
      map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
      map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

      #     Token                  Meaning
      #     {last}            !    The last (previously active) pane
      #     {next}            +    The next pane by number
      #     {previous}        -    The previous pane by number
      #     {top}                  The top pane
      #     {bottom}               The bottom pane
      #     {left}                 The leftmost pane
      #     {right}                The rightmost pane
      #     {top-left}             The top-left pane
      #     {top-right}            The top-right pane
      #     {bottom-left}          The bottom-left pane
      #     {bottom-right}         The bottom-right pane
      #     {up-of}                The pane above the active pane
      #     {down-of}              The pane below the active pane
      #     {left-of}              The pane to the left of the active pane
      #     {right-of}             The pane to the right of the active pane

      declare-user-mode split
      define-command -override -hidden -params 1.. tmux %{
          echo %sh{
              tmux=''${kak_client_env_TMUX:-$TMUX}
              if [ -z "$tmux" ]; then
                  echo "fail 'This command is only available in a tmux session'"
                  exit
              fi
              eval TMUX=$tmux tmux ''${@}
          }
      }
      
      map global normal <c-w> %{:enter-user-mode split<ret>} -docstring "Navigate splits"
      map global split j %{:tmux select-pane -t "{down-of}"<ret>} -docstring "Down"
      map global split k %{:tmux select-pane -t "{up-of}"<ret>} -docstring "Up"
      map global split h %{:tmux select-pane -t "{left-of}"<ret>} -docstring "Left"
      map global split l %{:tmux select-pane -t "{right-of}"<ret>} -docstring "Right"
      map global split = %{:tmux select-layout even-vertical<ret>} -docstring "Balance"
      map global split o %{:tmux kill-pane -a<ret>} -docstring "Only"

      map global insert <c-w> '<left><a-;>B<a-;>d' -docstring "Delete word before cursor"

      define-command -override -params 0.. split %{
          tmux split-window -t %val{client_env_TMUX_PANE} kak -c %val{session} %val{buffile}
          tmux select-layout even-vertical
      }
      alias global sp split
    '';

    plugins = with pkgs.kakounePlugins; [
      kak-lsp
    ];
  };
}
