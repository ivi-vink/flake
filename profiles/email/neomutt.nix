{
  inputs,
  config,
  pkgs,
  ...
}: {
  hm = {
    programs.msmtp = {
      enable = true;
    };

    xdg.configFile."neomutt/mailcap" = {
      text = ''
        text/plain; $EDITOR %s ;
        text/html; openfile %s ; nametemplate=%s.html
        text/html; lynx -assume_charset=%{charset} -display_charset=utf-8 -dump -width=1024 %s; nametemplate=%s.html; copiousoutput;
        image/*; openfile %s ;
        video/*; setsid mpv --quiet %s &; copiousoutput
        audio/*; mpv %s ;
        application/pdf; openfile %s ;
        application/pgp-encrypted; gpg -d '%s'; copiousoutput;
        application/pgp-keys; gpg --import '%s'; copiousoutput;
        application/x-subrip; $EDITOR %s ;
      '';
    };

    programs.neomutt = {
      enable = true;
      sort = "reverse-date";
      sidebar = {
        enable = true;
      };
      extraConfig = ''
        set use_threads=yes
        set send_charset="us-ascii:utf-8"
        set mailcap_path = $HOME/.config/neomutt/mailcap
        set mime_type_query_command = "file --mime-type -b %s"
        set date_format="%y/%m/%d %I:%M%p"
        set index_format="%2C %Z %?X?A& ? %D %-15.15F %s (%-4.4c)"
        set smtp_authenticators = 'gssapi:login'
        set query_command = "abook --mutt-query '%s'"
        set rfc2047_parameters = yes
        set sleep_time = 0		# Pause 0 seconds for informational messages
        set markers = no		# Disables the `+` displayed at line wraps
        set mark_old = no		# Unread mail stay unread until read
        set mime_forward = no	# mail body is forwarded as text
        set forward_attachments = yes	# attachments are forwarded with mail
        set wait_key = no		# mutt won't ask "press key to continue"
        set fast_reply			# skip to compose when replying
        set fcc_attach			# save attachments with the body
        set forward_format = "Fwd: %s"	# format of subject when forwarding
        set forward_quote		# include message in forwards
        set reverse_name		# reply as whomever it was to
        set include			# include message in replies
        set mail_check=0 # to avoid lags using IMAP with some email providers (yahoo for example)
        auto_view text/html		# automatically show html (mailcap uses lynx)
        auto_view application/pgp-encrypted
        #set display_filter = "tac | sed '/\\\[-- Autoview/,+1d' | tac" # Suppress autoview messages.
        alternative_order text/plain text/enriched text/html

        set sidebar_visible = yes
        set sidebar_width = 20
        set sidebar_short_path = yes
        set sidebar_next_new_wrap = yes
        set mail_check_stats
        set sidebar_format = '%D%?F? [%F]?%* %?N?%N/? %?S?%S?'
        bind index,pager \Ck sidebar-prev
        bind index,pager \Cj sidebar-next
        bind index,pager \Co sidebar-open
        bind index,pager \Cp sidebar-prev-new
        bind index,pager \Cn sidebar-next-new
        bind index,pager B sidebar-toggle-visible

        # Default index colors:
        color index yellow default '.*'
        color index_author red default '.*'
        color index_number blue default
        color index_subject cyan default '.*'

        # New mail is boldened:
        color index brightyellow black "~N"
        color index_author brightred black "~N"
        color index_subject brightcyan black "~N"

        # Tagged mail is highlighted:
        color index brightyellow blue "~T"
        color index_author brightred blue "~T"
        color index_subject brightcyan blue "~T"

        # Flagged mail is highlighted:
        color index brightgreen default "~F"
        color index_subject brightgreen default "~F"
        color index_author brightgreen default "~F"

        # Other colors and aesthetic settings:
        mono bold bold
        mono underline underline
        mono indicator reverse
        mono error bold
        color normal default default
        color indicator brightblack white
        color sidebar_highlight red default
        color sidebar_divider brightblack black
        color sidebar_flagged red black
        color sidebar_new green black
        color error red default
        color tilde black default
        color message cyan default
        color markers red white
        color attachment white default
        color search brightmagenta default
        color status brightyellow black
        color hdrdefault brightgreen default
        color quoted green default
        color quoted1 blue default
        color quoted2 cyan default
        color quoted3 yellow default
        color quoted4 red default
        color quoted5 brightred default
        color signature brightgreen default
        color bold black default
        color underline black default

        # Regex highlighting:
        color header brightmagenta default "^From"
        color header brightcyan default "^Subject"
        color header brightwhite default "^(CC|BCC)"
        color header blue default ".*"
        color body brightred default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
        color body brightblue default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
        color body green default "\`[^\`]*\`" # Green text between ` and `
        color body brightblue default "^# \.*" # Headings as bold blue
        color body brightcyan default "^## \.*" # Subheadings as bold cyan
        color body brightgreen default "^### \.*" # Subsubheadings as bold green
        color body yellow default "^(\t| )*(-|\\*) \.*" # List items as yellow
        color body brightcyan default "[;:][-o][)/(|]" # emoticons
        color body brightcyan default "[;:][)(|]" # emoticons
        color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
        color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
        color body red default "(BAD signature)"
        color body cyan default "(Good signature)"
        color body brightblack default "^gpg: Good signature .*"
        color body brightyellow default "^gpg: "
        color body brightyellow red "^gpg: BAD signature from.*"
        mono body bold "^gpg: Good signature"
        mono body bold "^gpg: BAD signature from.*"
        color body red default "([a-z][a-z0-9+-]*://(((([a-z0-9_.!~*'();:&=+$,-]|%[0-9a-f][0-9a-f])*@)?((([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?|[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)(:[0-9]+)?)|([a-z0-9_.!~*'()$,;:@&=+-]|%[0-9a-f][0-9a-f])+)(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*(/([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*(;([a-z0-9_.!~*'():@&=+$,-]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?(#([a-z0-9_.!~*'();/?:@&=+$,-]|%[0-9a-f][0-9a-f])*)?|(www|ftp)\\.(([a-z0-9]([a-z0-9-]*[a-z0-9])?)\\.)*([a-z]([a-z0-9-]*[a-z0-9])?)\\.?(:[0-9]+)?(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*(/([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*(;([-a-z0-9_.!~*'():@&=+$,]|%[0-9a-f][0-9a-f])*)*)*)?(\\?([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?(#([-a-z0-9_.!~*'();/?:@&=+$,]|%[0-9a-f][0-9a-f])*)?)[^].,:;!)? \t\r\n<>\"]"
    '';
      binds = [
        { map = ["index" "pager"]; key = "x"; action = "modify-labels"; }
        { map = ["index" "pager"]; key = "i"; action = "noop"; }
        { map = ["index" "pager"]; key = "g"; action = "noop"; }
        { map = ["index"]; key = "\\Cf"; action = "noop"; }
        { map = ["index" "pager"]; key = "M"; action = "noop"; }
        { map = ["index" "pager"]; key = "C"; action = "noop"; }
        { map = ["index"]; key = "gg"; action = "first-entry"; }
        { map = ["index"]; key = "j"; action = "next-entry"; }
        { map = ["index"]; key = "k"; action = "previous-entry"; }
        { map = ["attach"]; key = "<return>"; action = "view-mailcap"; }
        { map = ["attach"]; key = "l"; action = "view-mailcap"; }
        { map = ["editor"]; key = "<space>"; action = "noop"; }
        { map = ["index"]; key = "G"; action = "last-entry"; }
        { map = ["pager" "attach"]; key =  "h"; action = "exit"; }
        { map = ["pager"]; key = "j"; action = "next-line"; }
        { map = ["pager"]; key = "k"; action = "previous-line"; }
        { map = ["pager"]; key = "l"; action = "view-attachments"; }
        { map = ["index"]; key = "U"; action = "undelete-message"; }
        { map = ["index"]; key = "L"; action = "limit"; }
        { map = ["index"]; key = "h"; action = "noop"; }
        { map = ["index"]; key = "l"; action = "display-message"; }
        { map = ["index" "query"]; key =  "<space>"; action = "tag-entry"; }
        { map = ["index" "pager"]; key =  "H"; action = "view-raw-message"; }
        { map = ["browser"]; key = "l"; action = "select-entry"; }
        { map = ["browser"]; key = "gg"; action = "top-page"; }
        { map = ["browser"]; key = "G"; action = "bottom-page"; }
        { map = ["pager"]; key = "gg"; action = "top"; }
        { map = ["pager"]; key = "G"; action = "bottom"; }
        { map = ["index" "pager" "browser"]; key = "d"; action = "half-down"; }
        { map = ["index" "pager" "browser"]; key = "u"; action = "half-up"; }
        { map = ["index" "pager"]; key =  "\\Cr"; action = "group-reply"; }
        { map = ["index" "pager"]; key =  "R"; action = "group-chat-reply"; }
        { map = ["index"]; key = "\031"; action = "previous-undeleted"; }
        { map = ["index"]; key = "\005"; action = "next-undeleted"; }
        { map = ["pager"]; key = "\031"; action = "previous-line"; }
        { map = ["pager"]; key = "\005"; action = "next-line"; }
        { map = ["editor"]; key = "<Tab>"; action = "complete-query"; }
      ];
      macros = [
        { map = ["index"]; key = "X"; action = "<save-message>=Spam<enter>y"; }
        { map = ["index"]; key = "A"; action = "<modify-labels-then-hide>+archive -unread -inbox<enter><mark-message>z<enter><change-folder>^<enter>'z"; }
        { map = ["index"]; key = "h"; action = "<mark-message>z<enter><change-folder>^<enter>'z"; }
        { map = ["index"]; key = "D"; action = "<delete-message>"; }
        { map = ["index" "pager"]; key =  "S"; action = "<sync-mailbox>!notmuch-hook &<enter>"; }
        { map = ["index"]; key = "c"; action = "<change-vfolder>?"; }
        { map = ["index"]; key = "\\\\"; action = "<vfolder-from-query>"; }
        { map = ["browser"]; key = "h"; action = "<change-dir><kill-line>..<enter>"; }
      ];
    };
  };
}
