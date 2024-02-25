{pkgs,config,...}: {
  hm.home.packages = [pkgs.ueberzug pkgs.lf];
  hm.xdg.configFile = {
    "lf/icons".text = ''
    di	📁
    fi	📃
    tw	🤝
    ow	📂
    ln	⛓
    or	❌
    ex	🎯
    *.txt	✍
    *.mom	✍
    *.me	✍
    *.ms	✍
    *.avif	🖼
    *.png	🖼
    *.webp	🖼
    *.ico	🖼
    *.jpg	📸
    *.jpe	📸
    *.jpeg	📸
    *.gif	🖼
    *.svg	🗺
    *.tif	🖼
    *.tiff	🖼
    *.xcf	🖌
    *.html	🌎
    *.xml	📰
    *.gpg	🔒
    *.css	🎨
    *.pdf	📚
    *.djvu	📚
    *.epub	📚
    *.csv	📓
    *.xlsx	📓
    *.tex	📜
    *.md	📘
    *.r	    📊
    *.R	    📊
    *.rmd	📊
    *.Rmd	📊
    *.m	    📊
    *.mp3	🎵
    *.opus	🎵
    *.ogg	🎵
    *.m4a	🎵
    *.flac	🎼
    *.wav	🎼
    *.mkv	🎥
    *.mp4	🎥
    *.webm	🎥
    *.mpeg	🎥
    *.avi	🎥
    *.mov	🎥
    *.mpg	🎥
    *.wmv	🎥
    *.m4b	🎥
    *.flv	🎥
    *.zip	📦
    *.rar	📦
    *.7z	📦
    *.tar	📦
    *.z64	🎮
    *.v64	🎮
    *.n64	🎮
    *.gba	🎮
    *.nes	🎮
    *.gdi	🎮
    *.1	    ℹ
    *.nfo	ℹ
    *.info	ℹ
    *.log	📙
    *.iso	📀
    *.img   📀
    *.bib   🎓
    *.ged   👪
    *.part  💔
    *.torrent 🔽
    *.jar   ♨
    *.java	♨
    '';
    "lf/cleaner".text = ''
    #!/bin/sh
    if [ -n "$FIFO_UEBERZUG" ]; then
      printf '{"action": "remove", "identifier": "PREVIEW"}\n' > "$FIFO_UEBERZUG"
    fi
    '';
    "lf/scope".source = config.lib.meta.mkMutableSymlink /mut/lf/scope;
    "lf/lfrc".source = config.lib.meta.mkMutableSymlink /mut/lf/lfrc;
  };
}
