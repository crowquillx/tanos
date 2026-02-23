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
      tcli rebuild [switch|build|test|boot] [host]
      tcli update [host]
      tcli gc
      tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]
      tcli nh home [switch|build] [host] [-- <nh-args...>]
      tcli nh clean [-- <nh-args...>]

    Notes:
      - Host defaults to current hostname.
      - Flake path defaults to current repo root; override with TANOS_FLAKE_DIR.
      - Rebuild always runs BOTH:
        1) nixos-rebuild for system modules
        2) home-manager for home modules
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

    run_rebuild() {
      local action="$1"
      local host="$2"
      local flake_ref="$3"

      case "$action" in
        switch|build|test|boot) ;;
        *) die "invalid rebuild action: $action (expected switch|build|test|boot)" ;;
      esac

      printf '==> Rebuilding NixOS (%s) for host %s\n' "$action" "$host"
      sudo nixos-rebuild "$action" --flake "''${flake_ref}#''${host}"

      local hm_action="switch"
      case "$action" in
        build) hm_action="build" ;;
        test) hm_action="switch" ;;
        boot)
          hm_action="build"
          printf '==> Home Manager has no boot mode; using build\n'
          ;;
      esac

      printf '==> Rebuilding Home Manager (%s) for host %s\n' "$hm_action" "$host"
      run_home_manager "$hm_action" "$host" "$flake_ref"
    }

    run_home_manager() {
      local hm_action="$1"
      local host="$2"
      local flake_ref="$3"
      local hm_target="''${flake_ref}#''${host}"

      if command -v home-manager >/dev/null 2>&1; then
        home-manager "$hm_action" --flake "$hm_target"
        return
      fi

      printf '==> home-manager command not found; using activationPackage fallback\n'
      case "$hm_action" in
        build)
          nix build "''${flake_ref}#homeConfigurations.''${host}.activationPackage"
          ;;
        switch)
          nix build "''${flake_ref}#homeConfigurations.''${host}.activationPackage"
          ./result/activate
          ;;
        *)
          die "unsupported home-manager fallback action: $hm_action"
          ;;
      esac
    }

    run_update() {
      local host="$1"
      local flake_ref="$2"

      printf '==> Updating flake inputs\n'
      nix flake update --flake "$flake_ref"
      run_rebuild "switch" "$host" "$flake_ref"
    }

    run_gc() {
      local hm_profile="/nix/var/nix/profiles/per-user/$USER/home-manager"

      printf '==> Deleting old system generations\n'
      sudo nix-collect-garbage -d

      if [[ -L "$hm_profile" || -e "$hm_profile" ]]; then
        printf '==> Deleting old Home Manager generations\n'
        nix-env --delete-generations old --profile "$hm_profile"
      fi

      printf '==> Deleting old user generations\n'
      nix-collect-garbage -d
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
      nh os "$action" "''${flake_ref}#''${host}" "$@"
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
      nh home "$action" "''${flake_ref}#''${host}" "$@"
    }

    run_nh_clean() {
      printf '==> nh clean all\n'
      nh clean all "$@"
    }

    main() {
      local cmd="''${1-}"
      [[ -n "$cmd" ]] || {
        usage
        exit 1
      }
      shift || true

      local flake_dir flake_ref host action nh_scope
      flake_dir="$(resolve_flake_dir)"
      flake_ref="path:''${flake_dir}"

      case "$cmd" in
        rebuild)
          action="switch"
          if [[ "''${1-}" =~ ^(switch|build|test|boot)$ ]]; then
            action="$1"
            shift
          fi
          host="$(resolve_host "''${1-}")"
          [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
          run_rebuild "$action" "$host" "$flake_ref"
          ;;
        update)
          host="$(resolve_host "''${1-}")"
          [[ -d "''${flake_dir}/hosts/''${host}" ]] || die "unknown host ''${host} in ''${flake_dir}/hosts"
          run_update "$host" "$flake_ref"
          ;;
        gc)
          run_gc
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
              run_nh_clean "$@"
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
  };

  programs.fish.shellAliases = {
    fu = "tcli update";
    fr = "tcli rebuild";
    ncg = "tcli gc";
  };
}
