{
  description = "Telegram Dice Bot";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system: 
  let 
    pkgs = nixpkgs.legacyPackages.${system};
    telegram-dice-bot = with pkgs.python3Packages; buildPythonPackage {
      pname = "telegram-dice-bot";
      version = "1.0";
      propagatedBuildInputs = [ python-telegram-bot python-dotenv pypeg2 faker ];
      src = ./.;
    };
    python = pkgs.python3.withPackages(ps: [ telegram-dice-bot ]);
  in {
    overlay = prev: self: {
      inherit telegram-dice-bot;
    };
    packages = {
      inherit telegram-dice-bot;
    };
    defaultApp = utils.lib.mkApp {
      drv = telegram-dice-bot;
      exePath = "/bin/bot.py";
    };
    nixosModule = { config, lib, ... }:
    with lib;
    let 
      cfg = config.services.telegram-dice-bot;
    in {
      options = {
        services.telegram-dice-bot = {
          enable = mkEnableOption "telegram dice bot service";
          token = mkOption { type = types.str; };
        };
      };
      config = mkIf cfg.enable {
        systemd.services.telegram-dice-bot = {
          enable = true;
          requires = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            User = "telegram-dice-bot";
            Group = "telegram-dice-bot";
            DynamicUser = true;
            MemoryMax = "128M";
          };
          environment = {
            TOKEN = cfg.token;
          };
          script = "${telegram-dice-bot}/bin/bot.py";
        };
      };
    };
    defaultPackage = telegram-dice-bot;
    devShell = python.env;
  });
}
