{ pkgs, inputs, ... }:
let
  homeManagerPkg =
    let
      pkgsBySystem = inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system};
    in
    pkgsBySystem.home-manager or pkgsBySystem.default;
  tcli = pkgs.writeShellScriptBin "tcli" ''
    #!/usr/bin/env bash
    set -euo pipefail

    usage() {
      cat <<'EOF'
    tcli - tanos helper for flake updates, rebuilds, and garbage collection

    Usage:
      tcli
      tcli [switch|build|test|boot] [host] [-- <nh-args...>]
      tcli rebuild [switch|build|test|boot] [host]
      tcli update [host] [-- <nh-args...>]
      tcli upgrade [host] [-- <nh-args...>]
      tcli gc [-- <nh-args...>]
      tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]
      tcli nh home [switch|build] [host] [-- <nh-args...>]
      tcli nh clean [-- <nh-args...>]

    Notes:
      - Host defaults to current hostname.
      - Flake path defaults to current repo root; override with TANOS_FLAKE_DIR.
      - Bare `tcli` defaults to `switch` on the current host.
      - Rebuilds run through `nh os`, so Home Manager is still applied via NixOS module integration.
    EOF
    }

    die() {
      printf 'tcli: %s\n' "$1" >&2
      exit 1
    }

    resolve_flake_dir() {
      if [[ -n "''${TANOS_FLAKE_DIR-}" ]]; then
        [[ -f "''${TANOS_FLAKE_DIR}/flake.nix" ]] || die "TANOS_FLAKE_DIR does not contain flake.nix: ''${TANOS_FLAKE_DIR}"
        printf '%s\n' "''${TANOS_FLAKE_DIR}"
        return
      fi

      if git_root="$(git rev-parse --show-toplevel 2>/dev/null)" && [[ -f "''${git_root}/flake.nix" ]]; then
        printf '%s\n' "''${git_root}"
        return
      fi

      if [[ -f "./flake.nix" ]]; then
        pwd
        return
      fi

      if [[ -f "$HOME/tanos/flake.nix" ]]; then
        printf '%s\n' "$HOME/tanos"
        return
      fi

      die "could not find tanos flake. Run inside the repo, or set TANOS_FLAKE_DIR."
    }

    resolve_host() {
      if [[ -n "''${1-}" ]]; then
        printf '%s\n' "$1"
        return
      fi

      if [[ -f /etc/hostname ]]; then
        tr -d '\n' </etc/hostname
        return
      fi

      hostname
    }

    run_nh_os() {
      local action="$1"
      local host="$2"
      local flake_ref="$3"
      shift 3

      case "$action" in
        switch|build|test|boot) ;;
        *) die "invalid nh os action: $action (expected switch|build|test|boot)" ;;
      esac

      printf '==> nh os %s for host %s\n' "$action" "$host"
      printf '==> Home Manager is applied via NixOS module integration (single build path)\n'
      nh os "$action" "$flake_ref" -H "$host" "$@"
    }

    run_rebuild() {
      local action="$1"
      local host="$2"
      local flake_ref="$3"
      shift 3

      case "$action" in
        switch|build|test|boot) ;;
        *) die "invalid rebuild action: $action (expected switch|build|test|boot)" ;;
      esac

      run_nh_os "$action" "$host" "$flake_ref" "$@"
    }

    run_update() {
      local host="$1"
      local flake_ref="$2"
      shift 2

      printf '==> nh os switch --update for host %s\n' "$host"
      printf '==> Updating flake inputs through nh before activation\n'
      nh os switch "$flake_ref" -H "$host" --update "$@"
    }

    run_gc() {
      printf '==> nh clean all\n'
      nh clean all "$@"
    }

    run_nh_home() {
      local action="$1"
      local host="$2"
      local flake_ref="$3"
      shift 3

      case "$action" in
        switch|build) ;;
        *) die "invalid nh home action: $action (expected switch|build)" ;;
      esac

      printf '==> nh home %s for host %s\n' "$action" "$host"
      nh home "$action" "$flake_ref" -c "$host" "$@"
    }

    main() {
      local cmd="''${1-switch}"
      if [[ $# -gt 0 ]]; then
        shift || true
      fi

      local flake_dir flake_ref host action nh_scope
      flake_dir="$(resolve_flake_dir)"
      flake_ref="''${flake_dir}"

      case "$cmd" in
        switch|build|test|boot)
          action="$cmd"
          if [[ -n "''${1-}" && "$1" != "--" ]]; then
            host="$(resolve_host "$1")"
            shift || true
          else
            host="$(resolve_host "")"
          fi
          [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
          if [[ "''${1-}" == "--" ]]; then
            shift || true
          fi
          run_rebuild "$action" "$host" "$flake_ref" "$@"
          ;;
        rebuild)
          action="switch"
          if [[ "''${1-}" =~ ^(switch|build|test|boot)$ ]]; then
            action="$1"
            shift
          fi
          if [[ -n "''${1-}" && "$1" != "--" ]]; then
            host="$(resolve_host "$1")"
            shift || true
          else
            host="$(resolve_host "")"
          fi
          [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
          if [[ "''${1-}" == "--" ]]; then
            shift || true
          fi
          run_rebuild "$action" "$host" "$flake_ref" "$@"
          ;;
        update|upgrade)
          if [[ -n "''${1-}" && "$1" != "--" ]]; then
            host="$(resolve_host "$1")"
            shift || true
          else
            host="$(resolve_host "")"
          fi
          [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
          if [[ "''${1-}" == "--" ]]; then
            shift || true
          fi
          run_update "$host" "$flake_ref" "$@"
          ;;
        gc)
          if [[ "''${1-}" == "--" ]]; then
            shift || true
          fi
          run_gc "$@"
          ;;
        nh)
          nh_scope="''${1-}"
          [[ -n "$nh_scope" ]] || die "missing nh scope (expected os|home|clean)"
          shift || true
          case "$nh_scope" in
            os)
              action="switch"
              if [[ "''${1-}" =~ ^(switch|build|test|boot)$ ]]; then
                action="$1"
                shift
              fi
              if [[ -n "''${1-}" && "$1" != "--" ]]; then
                host="$(resolve_host "$1")"
                shift || true
              else
                host="$(resolve_host "")"
              fi
              [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
              if [[ "''${1-}" == "--" ]]; then
                shift || true
              fi
              run_nh_os "$action" "$host" "$flake_ref" "$@"
              ;;
            home)
              action="switch"
              if [[ "''${1-}" =~ ^(switch|build)$ ]]; then
                action="$1"
                shift
              fi
              if [[ -n "''${1-}" && "$1" != "--" ]]; then
                host="$(resolve_host "$1")"
                shift || true
              else
                host="$(resolve_host "")"
              fi
              [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
              if [[ "''${1-}" == "--" ]]; then
                shift || true
              fi
              run_nh_home "$action" "$host" "$flake_ref" "$@"
              ;;
            clean)
              if [[ "''${1-}" == "--" ]]; then
                shift || true
              fi
              run_gc "$@"
              ;;
            *)
              die "invalid nh scope: $nh_scope (expected os|home|clean)"
              ;;
          esac
          ;;
        -h|--help|help)
          usage
          ;;
        *)
          die "unknown command: $cmd"
          ;;
      esac
    }

    main "$@"
  '';
in
{
  home.packages = [
    tcli
    homeManagerPkg
  ];

  programs.bash.shellAliases = {
    fu = "tcli update";
    fr = "tcli rebuild";
    ncg = "tcli gc";
    winblows = "systemctl reboot --boot-loader-entry=auto-windows";
    enterbios = "systemctl reboot --boot-loader-entry=auto-reboot-to-firmware-setup";
  };

  programs.fish.shellAliases = {
    fu = "tcli update";
    fr = "tcli rebuild";
    ncg = "tcli gc";
    winblows = "systemctl reboot --boot-loader-entry=auto-windows";
    enterbios = "systemctl reboot --boot-loader-entry=auto-reboot-to-firmware-setup";
  };
}
