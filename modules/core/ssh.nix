{
  den.aspects.ssh = {
    includes = [

    ];

    nixos = {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
          X11Forwarding = true;
          X11UseLocalhost = true;
        };
      };
    };

    homeManager = {

    };
  };
}
