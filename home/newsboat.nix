{...}: {
  programs.newsboat = {
    enable = true;
    autoReload = true;
    urls = [
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
    ];
    extraConfig = ''
      # general settings
      cleanup-on-quit no
      max-items 100

      # unbind keys
      unbind-key ENTER
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K

      # bind keys - vim style
      bind-key j down
      bind-key k up
      bind-key l open
      bind-key h quit

      # solarized
      color background         default   default
      color listnormal         default   default
      color listnormal_unread  default   default
      color listfocus          black     cyan
      color listfocus_unread   black     cyan
      color info               default   black
      color article            default   default

      # highlights
      highlight article "^(Title):.*$" blue default
      highlight article "https?://[^ ]+" red default
      highlight article "\\[image\\ [0-9]+\\]" green default
    '';
  };
}
