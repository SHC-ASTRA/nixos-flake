{ pkgs, host, ... }:
# only install firefox browser if we have a graphical system
if host.isGraphical then
  (
    let
      lock-false = {
        # Presets for preferences
        Value = false;
        Status = "locked";
      };
      lock-true = {
        Value = true;
        Status = "locked";
      };
    in
    {
      programs.firefox = {
        enable = true;

        nativeMessagingHosts = [ pkgs.firefoxpwa ];

        policies = {
          AutoFillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          DisableAppUpdate = true;
          DisableFeedbackCommands = true;
          DisableFirefoxStudies = true;
          DontCheckDefaultBrowser = true;
          NoDefaultBookmarks = true;
          OfferToSaveLogins = true;
          DisableSetDesktopBackground = true;

          SearchEngines = {
            Add = [
              {
                "Name" = "Unduck";
                "URLTemplate" = "https://s.dunkirk.sh?q={searchTerms}";
                "Method" = "GET";
                "IconURL" = "https://s.dunkirk.sh/favicon.ico";
                "Alias" = "undk";
                "Description" = "ddg bangs pwa";
              }
            ];
            Default = "Unduck";
            PreventInstalls = true;
          };

          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              # ublock
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
              installation_mode = "force_installed";
            };
            "addon@darkreader.org" = {
              # DarkReader
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
              installation_mode = "force_installed";
            };
            "keepassxc-browser@keepassxc.org" = {
              # Keepassxc
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc_browser/latest.xpi";
              installation_mode = "force_installed";
            };
          };

          Preferences = {
            "browser.warnOnQuitShortcut" = lock-false;
            "browser.ctrlTab.sortByRecentlyUsed" = lock-true;
            "browser.newtabpage.activity-stream.trendingSearch.defaultSearchEngine" = {
              "Value" = "Unduck";
              "Status" = "locked";
            };
            "browser.urlbar.suggest.clipboard" = lock-false;

            "dom.security.https_only_mode" = lock-true;

            "layers.acceleration.disabled" = lock-true;
          };
        };
      };
    }
  )
else
  { }
