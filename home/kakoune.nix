{
  flake,
  config,
  pkgs,
  home-manager,
  ...
}: {
  programs.kakoune = {
    enable = true;

    extraConfig = ''
      colorscheme gruvbox-dark
      set-option global autoreload yes

      declare-option -hidden bool init_done
      evaluate-commands %sh{
          $kak_opt_init_done && exit
          printf '
set global windowing_modules ""
require-module tmux
require-module tmux-repl
add-highlighter global/ number-lines -relative
declare-user-mode split
'
      }
      eval %sh{
          $kak_opt_init_done && exit
          kak-lsp --kakoune -s $kak_session
      }
      set-option global init_done true
  
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

      hook global WinClose .* %{
         echo "Winclosed!"
         tmux selectl "even-vertical"
      }

      # Source a local project kak config if it exists
      # Make sure it is set as a kak filetype
      hook global BufCreate (.*/)?(\.kakrc\.local) %{
          set-option buffer filetype kak
      }
      try %{ source .kakrc.local }

      map global user l %{:enter-user-mode lsp<ret>} -docstring "LSP mode"
      map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
      map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
      map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
      map global object e '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
      map global object k '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
      map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
      map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

      map global insert <c-w> '<left><a-;>B<a-;>d' -docstring "Delete word before cursor"

      define-command -override -hidden -params 1.. tmux %{
          echo %sh{
              tmux=''${kak_client_env_TMUX}
              pane=''${kak_client_env_TMUX_PANE}
              if [ -z "$tmux" ]; then
                  echo "fail 'This command is only available in a tmux session'"
                  exit
              fi
              eval TMUX_PANE=$pane TMUX=$tmux tmux ''${@}
          }
      }
      define-command -override -params 0.. split %{
          tmux split-window -t %val{client_env_TMUX_PANE} kak -c %val{session} %val{buffile}
      }
      alias global sp split
      map global normal <c-w> %{:enter-user-mode split<ret>} -docstring "Navigate splits"
      map global split j %{:tmux select-pane -t "{down-of}"<ret>} -docstring "Down"
      map global split k %{:tmux select-pane -t "{up-of}"<ret>} -docstring "Up"
      map global split h %{:tmux select-pane -t "{left-of}"<ret>} -docstring "Left"
      map global split l %{:tmux select-pane -t "{right-of}"<ret>} -docstring "Right"
      map global split = %{:tmux select-layout even-vertical<ret>} -docstring "Balance"
      map global split o %{:tmux kill-pane -a<ret>} -docstring "Only"

    '';

    plugins = with pkgs.kakounePlugins; [
      kak-lsp
    ];
  };
}
