{...}: {
  hm = {
    programs.newsboat = {
      enable = true;
      autoReload = true;
      urls = [
        {url = "https://nginx.org/index.rss";}
        {url = "https://github.com/neovim/neovim/releases.atom";}
        {url = "https://github.com/rancher/rancher/releases.atom";}
        {url = "https://github.com/istio/istio/releases.atom";}
        {url = "https://github.com/argoproj/argo-cd/releases.atom";}
        {url = "https://github.com/argoproj/argo-cd/releases.atom";}
        {url = "https://github.com/kyverno/kyverno/releases.atom";}
        {url = "https://github.com/hashicorp/terraform/releases.atom";}
        {url = "https://github.com/ansible/ansible/releases.atom";}
        {url = "https://github.com/ansible/awx/releases.atom";}
        {url = "https://kubeshark.co/rss.xml";}
        {url = "https://azurecomcdn.azureedge.net/en-us/updates/feed/?product=azure-devops";}
        {url = "https://www.hashicorp.com/blog/categories/products-technology/feed.xml";}
        {url = "https://kubernetes.io/feed.xml";}
        {url = "https://www.cncf.io/rss";}
        {url = "https://blog.alexellis.io/rss/";}
        {url = "https://www.openfaas.com/feed";}
        {url = "https://istio.io/latest/blog/feed.xml";}
        {url = "https://www.youtube.com/feeds/videos.xml?channel_id=UCUyeluBRhGPCW4rPe_UvBZQ";}
      ];
      extraConfig = ''
      #show-read-feeds no
      auto-reload yes

      external-url-viewer "urlscan -dc -r 'linkhandler {}'"

      bind-key j down
      bind-key k up
      bind-key j next articlelist
      bind-key k prev articlelist
      bind-key J next-feed articlelist
      bind-key K prev-feed articlelist
      bind-key G end
      bind-key g home
      bind-key d pagedown
      bind-key u pageup
      bind-key l open
      bind-key h quit
      bind-key a toggle-article-read
      bind-key n next-unread
      bind-key N prev-unread
      bind-key D pb-download
      bind-key U show-urls
      bind-key x pb-delete

      color listnormal cyan default
      color listfocus black yellow standout bold
      color listnormal_unread blue default
      color listfocus_unread yellow default bold
      color info red black bold
      color article white default bold

      browser linkhandler
      macro , open-in-browser
      macro t set browser "qndl" ; open-in-browser ; set browser linkhandler
      macro a set browser "tsp yt-dlp --embed-metadata -xic -f bestaudio/best --restrict-filenames" ; open-in-browser ; set browser linkhandler
      macro v set browser "setsid -f mpv" ; open-in-browser ; set browser linkhandler
      macro w set browser "lynx" ; open-in-browser ; set browser linkhandler
      macro d set browser "dmenuhandler" ; open-in-browser ; set browser linkhandler
      macro c set browser "echo %u | xclip -r -sel c" ; open-in-browser ; set browser linkhandler
      macro C set browser "youtube-viewer --comments=%u" ; open-in-browser ; set browser linkhandler
      macro p set browser "peertubetorrent %u 480" ; open-in-browser ; set browser linkhandler
      macro P set browser "peertubetorrent %u 1080" ; open-in-browser ; set browser linkhandler

      highlight all "---.*---" yellow
      highlight feedlist ".*(0/0))" black
      highlight article "(^Feed:.*|^Title:.*|^Author:.*)" cyan default bold
      highlight article "(^Link:.*|^Date:.*)" default default
      highlight article "https?://[^ ]+" green default
      highlight article "^(Title):.*$" blue default
      highlight article "\\[[0-9][0-9]*\\]" magenta default bold
      highlight article "\\[image\\ [0-9]+\\]" green default bold
      highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
      highlight article ":.*\\(link\\)$" cyan default
      highlight article ":.*\\(image\\)$" blue default
      highlight article ":.*\\(embedded flash\\)$" magenta default
    '';
    };
  };
}
