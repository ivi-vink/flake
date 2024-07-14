{
  machine,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
  mkIf (!machine.isDarwin) {
    # TODO: what about secrets on nix-darwin...
    # secrets.mopidy.owner = lib.my.username;
    hm.home.packages = [pkgs.mpc-cli];
    hm.services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [mopidy-spotify mopidy-mpd];
      settings = {
        mpd = {
          enabled = true;
          hostname = "127.0.0.1";
          port = 6600;
          max_connections = 20;
          connection_timeout = 60;
        };
        spotify = {
          allow_cache = true;
          cache_size = 0;
        };
      };
      extraConfigFiles = [
        config.secrets.mopidy.path
      ];
    };
    secrets.mopidy.owner = my.username;

    hm.programs.ncmpcpp = {
      enable = true;
      bindings = [
        {
          key = "+";
          command = "show_clock";
        }
        {
          key = "+";
          command = "show_clock";
        }
        {
          key = "=";
          command = "volume_up";
        }
        {
          key = "j";
          command = "scroll_down";
        }
        {
          key = "k";
          command = "scroll_up";
        }
        {
          key = "ctrl-u";
          command = "page_up";
        }
        {
          key = "ctrl-d";
          command = "page_down";
        }
        {
          key = "u";
          command = "page_up";
        }
        {
          key = "d";
          command = "page_down";
        }
        {
          key = "h";
          command = "previous_column";
        }
        {
          key = "l";
          command = "next_column";
        }
        {
          key = ".";
          command = "show_lyrics";
        }
        {
          key = "n";
          command = "next_found_item";
        }
        {
          key = "N";
          command = "previous_found_item";
        }
        {
          key = "J";
          command = "move_sort_order_down";
        }
        {
          key = "K";
          command = "move_sort_order_up";
        }
        {
          key = "h";
          command = "jump_to_parent_directory";
        }
        {
          key = "l";
          command = "enter_directory";
        }
        {
          key = "l";
          command = "run_action";
        }
        {
          key = "l";
          command = "play_item";
        }
        {
          key = "m";
          command = "show_media_library";
        }
        {
          key = "m";
          command = "toggle_media_library_columns_mode";
        }
        {
          key = "t";
          command = "show_tag_editor";
        }
        {
          key = "v";
          command = "show_visualizer";
        }
        {
          key = "G";
          command = "move_end";
        }
        {
          key = "g";
          command = "move_home";
        }
        {
          key = "U";
          command = "update_database";
        }
        {
          key = "s";
          command = "reset_search_engine";
        }
        {
          key = "s";
          command = "show_search_engine";
        }
        {
          key = "f";
          command = "show_browser";
        }
        {
          key = "f";
          command = "change_browse_mode";
        }
        {
          key = "x";
          command = "delete_playlist_items";
        }
        {
          key = "P";
          command = "show_playlist";
        }
      ];
      settings = {
        ncmpcpp_directory = "~/.config/ncmpcpp";
        lyrics_directory = "~/.local/share/lyrics";
        message_delay_time = "1";
        # visualizer_type = "spectrum";
        song_list_format = "{$4%a - }{%t}|{$8%f$9}$R{$3(%l)$9}";
        song_status_format = ''$b{{$8"%t"}} $3by {$4%a{ $3in $7%b{ (%y)}} $3}|{$8%f}'';
        song_library_format = "{%n - }{%t}|{%f}";
        alternative_header_first_line_format = "$b$1$aqqu$/a$9 {%t}|{%f} $1$atqq$/a$9$/b";
        alternative_header_second_line_format = "{{$4$b%a$/b$9}{ - $7%b$9}{ ($4%y$9)}}|{%D}";
        current_item_prefix = "$(cyan)$r$b";
        current_item_suffix = "$/r$(end)$/b";
        current_item_inactive_column_prefix = "$(magenta)$r";
        current_item_inactive_column_suffix = "$/r$(end)";
        playlist_display_mode = "columns";
        browser_display_mode = "columns";
        progressbar_look = "->";
        media_library_primary_tag = "album_artist";
        media_library_albums_split_by_date = "no";
        startup_screen = "media_library";
        display_volume_level = "no";
        ignore_leading_the = "yes";
        external_editor = "nvim";
        use_console_editor = "yes";
        empty_tag_color = "magenta";
        main_window_color = "white";
        progressbar_color = "black:b";
        progressbar_elapsed_color = "blue:b";
        statusbar_color = "red";
        statusbar_time_color = "cyan:b";
        execute_on_song_change = ''"pkill -RTMIN+11 dwmblocks"'';
        execute_on_player_state_change = ''"pkill -RTMIN+11 dwmblocks"'';
        mpd_connection_timeout = 60;
      };
    };
  }
