{config, lib, pkgs, ...}:

let 
 protonbridge-get-password = pkgs.writeShellScript "protonbridge-get-password.sh" ''
  SERVER_CONFIG="$HOME/.config/protonmail/bridge-v3/grpcServerConfig.json"
  SERVER_TOKEN="$(${pkgs.jq}/bin/jq .token $SERVER_CONFIG -r)"
  SERVER_PATH="$(${pkgs.jq}/bin/jq .fileSocketPath $SERVER_CONFIG -r)"
  PROTO_SRCS="${pkgs.protonmail-bridge.src}/internal/frontend/grpc"

  ${pkgs.grpcurl}/bin/grpcurl -H "server-token:$SERVER_TOKEN" -import-path $PROTO_SRCS -insecure -unix -proto $PROTO_SRC/bridge.proto \
    $SERVER_PATH grpc.Bridge.GetUserList | \
    jq ".users[] | select (.addresses | index('$1')) | .password" -r | ${pkgs.coreutils}/bin/base64 -d
 '';

 protonbridge-get-certificate = pkgs.writeShellScript "protonbridge-get-certificate.sh" ''
  SERVER_CONFIG="$HOME/.config/protonmail/bridge-v3/grpcServerConfig.json"
  SERVER_TOKEN="$(${pkgs.jq}/bin/jq .token $SERVER_CONFIG -r)"
  SERVER_PATH="$(${pkgs.jq}/bin/jq .fileSocketPath $SERVER_CONFIG -r)"
  PROTO_SRCS="${pkgs.protonmail-bridge.src}/internal/frontend/grpc"
  CERT_TEMP_DIR="$(${pkgs.coreutils}/bin/mktemp -d)"

  
  ${pkgs.grpcurl}/bin/grpcurl -d "\"$CERT_TEMP_DIR\"" -H "server-token:$SERVER_TOKEN" -import-path $PROTO_SRCS -insecure -unix -proto $PROTO_SRCS/bridge.proto \
    $SERVER_PATH grpc.Bridge.ExportTLSCertificates > /dev/null

  ${pkgs.openssl}/bin/openssl x509 -fingerprint -sha256 -noout -in "$CERT_TEMP_DIR/cert.pem" | ${pkgs.gawk}/bin/awk -F'=' '{print $2}'

  rm -rf $CERT_TEMP_DIR
  
 '';
 protonbridge-add-thunderbird-exception = pkgs.writeShellScript "protonbridge-add-thunderbird-exception.sh" ''
  FINGERPRINT=$(${protonbridge-get-certificate})
  CERT_OVERRIDES="$HOME/.thunderbird/main/cert_override.txt"

  for IP in "127.0.0.1:1143" "127.0.0.1:1025"
  do
    ${pkgs.gnused}/bin/sed -i -n -e '/^'"$IP:"'/!p' -e '$a'"$IP:\tOID.2.16.840.1.101.3.4.2.1\t$FINGERPRINT\t" "$CERT_OVERRIDES"
  done
 '';
in
{

  # Email
  accounts.email.accounts = {
    "thomas@hexf.me" = {
      address = "thomas@hexf.me";
      userName = "hexf_me@proton.me";
      realName = "Thomas Hobson";
      gpg.key = "9F1FD9D87950DB6F";
      gpg.signByDefault = true;

      # Use protonmail-bridge
      imap = {
        host = "127.0.0.1";
        port = 1143;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };
      
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls = {
          enable = true;
          useStartTls = true;
        };
      };

      passwordCommand = "${protonbridge-get-password} 'thomas@hexf.me'";
      primary = true;
      thunderbird.enable = true;
    };
  };

  programs.thunderbird = {
    enable = true;
    profiles."main" = {
      isDefault = true;
      withExternalGnupg = true;
    };
  };


  systemd.user.services.protonmail-bridge = {
    Unit = {
      Description = "Protonmail Bridge";
      After = [ "network.target" ];
    };

    Service = {
      Restart = "always";
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge -g --log-level debug";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.protonmail-bridge-thunderbird = {

    Install = {
      WantedBy = [ "protonmail-bridge.service" ];
    };

    Unit = {
      Description = "Protonmail Bridge Thunderbird certificate installer";
      After = ["protonmail-bridge.service" ];
    };

    Service = {
      ExecStart = "${protonbridge-add-thunderbird-exception}";
    };



  };


  
}