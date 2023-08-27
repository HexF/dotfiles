{config, lib, pkgs, ...}:
with pkgs;
let
    fetchFirefoxAddonNM = callPackage ../../modules/fetchFirefoxAddonNM {};
    customFirefox = wrapFirefox firefox-esr-unwrapped {
        nixExtensions = [
            (fetchFirefoxAddonNM {
                name = "learn-pdf-auto-opener";
                url = "https://tfinlay.github.io/WebExtensions/learn_pdf_helper/latest.xpi";
                sha256 = "sha256-B2BJlzB+rmTCdCFMtq7ZqbVktLH/JqCiI69SGvKBQgc=";
                addonId = "@learn_pdf_helper";
            })
            (fetchFirefoxAddonNM {
                name="ublock";
                url = "https://addons.mozilla.org/firefox/downloads/file/3806442/ublock_origin-1.36.2-an+fx.xpi";
                sha256 = "sha256-MfjCEmo/Tjz+PvY1ULhCpdTwcewcblqjd8LymxH/FBU=";
                addonId = "uBlock0@raymondhill.net";
            })
            (fetchFirefoxAddonNM {
                name = "react-dev-tools";
                url = "https://addons.mozilla.org/firefox/downloads/file/3811140/react_developer_tools-4.14.0-fx.xpi";
                sha256 = "sha256-r6cylBrIvGvtzceZW6r++C1khYUXmfN2aSjr08pjLsI=";
                addonId = "@react-devtools";
            })
            (fetchFirefoxAddonNM {
                name = "redux-dev-tools";
                url = "https://addons.mozilla.org/firefox/downloads/file/1509811/redux_devtools-2.17.1-fx.xpi";
                sha256 = "sha256-ZJ14DRkgGyYHNHxPV7W1eyN2JLLA7TIq+Vdc95HM4yY=";
                addonId = "extension@redux.devtools";
            })
            (fetchFirefoxAddonNM {
                name = "honey";
                url = "https://addons.mozilla.org/firefox/downloads/file/3731265/honey-12.8.4-fx.xpi";
                sha256 = "sha256-GrxBs9gYeehodpa7CE7M60Dt7JX/pbRRathhheExFMs=";
                addonId = "jid1-93CWPmRbVPjRQA@jetpack";
            })
            (fetchFirefoxAddonNM {
                name = "cors-everywhere";
                url = "https://addons.mozilla.org/firefox/downloads/file/1148493/cors_everywhere-18.11.13.2043-fx.xpi";
                sha256 = "sha256-EjKQbh+mK3s3asrah0rlJ1753YFoCIhme68BrqVPiE8=";
                addonId = "cors-everywhere@spenibus";
            })
            (fetchFirefoxAddonNM {
                name = "keepassxc-browser";
                url = "https://addons.mozilla.org/firefox/downloads/file/3758952/keepassxc_browser-1.7.8.1-fx.xpi";
                sha256 = "sha256-wJEIS1rFrL9GUr1gAzpp4Q0bHj5f890faPxir+pjaz0=";
                addonId = "keepassxc-browser@keepassxc.org";
            })

            
        ];

        extraPolicies = {
            CaptivePortal = false;
            DisableFirefoxStudies = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFirefoxAccounts = true;
            FirefoxHome = {
                Pocket = false;
                Snippets = false;
            };
            UserMessaging = {
                ExtensionRecommendations = false;
                SkipOnboarding = true;
            };
        };

        extraPrefs = ''
        // Show more ssl cert infos
        lockPref("security.identityblock.show_extended_validation", true);
        '';
    };
in
{
    home.packages = [customFirefox];
}
