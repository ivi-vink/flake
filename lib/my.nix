lib: with lib; let
  modules = [
    {
      config = {
        _module.freeformType = with types; attrs;

        username = "ivi";
        githubUsername = "mvinkio";
        realName = "Mike Vink";
        domain = "vinkland.xyz";
        email = "mike1994vink@gmail.com";
      };
    }
  ];
in (evalModules { inherit modules; }).config
