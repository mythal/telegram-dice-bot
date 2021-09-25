{
  description = "Telegram Dice Bot";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, utils }: (utils.lib.eachSystem [ "x86_64-linux" ] (system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
    pythonEnv = pkgs.python3.withPackages(packages: with packages; [
      python-telegram-bot python-dotenv pypeg2 faker
    ]);
    telegram-dice-bot = with pkgs.python3Packages; buildPythonPackage {
      pname = "telegram-dice-bot";
      version = "1.0";
      propagatedBuildInputs = [ python-telegram-bot python-dotenv mcrcon ];
      src = ./.;
    };
  in {
    packages = {
      pythonEnv = pythonEnv;
      telegram-dice-bot = telegram-dice-bot;
    };
    defaultApp = utils.lib.mkApp {
      drv = telegram-dice-bot;
      exePath = "/bin/bot.py";
    };
    defaultPackage = telegram-dice-bot; # If you want to juist build the environment
    devShell = pythonEnv.env; # We need .env in order to use `nix develop`
  }));
}
