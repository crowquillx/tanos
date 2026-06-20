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
      tcli check
      tcli gc [-- <nh-args...>]
      tcli nh os [switch|build|test|boot] [host] [-- <nh-args...>]
      tcli nh home [switch|build] [host] [-- <nh-args...>]
      tcli nh clean [-- <nh-args...>]

    Hardening:
      - check:             statix lint + orphan module scan + nix flake check --no-build
      - switch/boot/test:  warn if working tree has uncommitted changes
      - build/switch/test: show closure diff with added/removed service units

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

    # Print the git HEAD sha and dirty-file count for build context.
    print_git_context() {
      local flake_dir="$1"
      if (cd "$flake_dir" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
        local sha dirty_count
        sha=$(cd "$flake_dir" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")
        dirty_count=$(cd "$flake_dir" && git status --porcelain 2>/dev/null | wc -l || echo 0)
        if [[ "$dirty_count" -eq 0 ]]; then
          printf '==> Building from git %s (clean)\n' "$sha"
        else
          printf '==> Building from git %s (%s uncommitted change(s))\n' "$sha" "$dirty_count"
        fi
      fi
    }

    # After build/switch, show added/removed systemd units prominently.
    # This makes "one-line edit nuked 1 GiB of services" immediately obvious.
    summarize_closure_diff() {
      local old="$1"
      local new="$2"

      [[ -n "$old" && -n "$new" && "$old" != "$new" ]] || return 0

      local diff_output
      diff_output="$(nix store diff-closures "$old" "$new" 2>/dev/null)" || {
        printf '  (could not compute closure diff)\n'
        return 0
      }

      printf '\n==> Closure diff (service units)\n'

      echo "$diff_output" | grep -iE 'Size:' | head -1 | sed 's/^[[:space:]]*/  /'

      local units
      units=$(echo "$diff_output" | grep -E 'unit-.*\.(service|socket|timer|target)' || true)
      if [[ -n "$units" ]]; then
        echo "$units" | sed 's/^[[:space:]]*/  /'
      else
        printf '  (no service unit changes)\n'
      fi
    }

    # Warn before activating a system built from uncommitted state.
    # Catches the "lost working-tree edits" class of incident.
    check_dirty_tree() {
      local flake_dir="$1"

      (cd "$flake_dir" && git rev-parse --is-inside-work-tree >/dev/null 2>&1) || return 0

      local dirty
      dirty=$(cd "$flake_dir" && git status --porcelain 2>/dev/null || true)
      [[ -n "$dirty" ]] || return 0

      printf '\n'
      printf '  ! WARNING: working tree has uncommitted changes.\n'
      printf '    The system you are about to activate is built from\n'
      printf '    UNCOMMITTED state. If these changes are lost, future\n'
      printf '    rebuilds will produce a different system.\n'
      printf '\n'
      printf '    Uncommitted files:\n'
      echo "$dirty" | head -10 | sed 's/^/      /'
      local count
      count=$(echo "$dirty" | wc -l)
      if [[ "$count" -gt 10 ]]; then
        printf '      ... and %d more\n' "$((count - 10))"
      fi
      printf '\n  Continue? [y/N] '
      local response
      read -r response || die "aborted by user"
      case "$response" in
        y|Y|yes|YES) ;;
        *) die "aborted by user" ;;
      esac
    }

    # Find .nix files under modules/ not referenced by any other .nix file.
    # Catches modules that exist but were never added to stacks.nix or
    # imported by a parent module.
    scan_orphan_modules() {
      local flake_dir="$1"
      local orphans=0

      while IFS= read -r f; do
        local base
        base="$(basename "$f")"
        # default.nix is auto-loaded by directory imports.
        [[ "$base" == "default.nix" ]] && continue
        # stacks.nix is the manifest itself.
        [[ "$base" == "stacks.nix" ]] && continue

        local found
        found=$(grep -rl --include='*.nix' -- "$base" \
          "$flake_dir/modules" "$flake_dir/hosts" "$flake_dir/users" \
          "$flake_dir/flake.nix" 2>/dev/null \
          | grep -v "^''${f}$" || true)
        if [[ -z "$found" ]]; then
          printf '    ORPHAN: %s\n' "''${f#$flake_dir/}"
          orphans=$((orphans + 1))
        fi
      done < <(find "$flake_dir/modules/nixos" "$flake_dir/modules/home" \
                  -name '*.nix' -type f 2>/dev/null | sort)

      if [[ "$orphans" -eq 0 ]]; then
        printf '    no orphan modules detected\n'
      else
        printf '    %d orphan module(s) found - add to modules/combined/stacks.nix or import from a parent.\n' "$orphans"
      fi
      return "$orphans"
    }

    run_check() {
      local flake_dir="$1"
      local rc=0

      printf '==> statix check\n'
      if command -v statix >/dev/null 2>&1; then
        statix check "$flake_dir" || rc=1
      else
        printf '  (statix not found, skipping)\n'
      fi

      printf '==> orphan module scan\n'
      scan_orphan_modules "$flake_dir" || rc=1

      printf '==> nix flake check --no-build\n'
      nix flake check "$flake_dir" --no-build || rc=1

      return "$rc"
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

      local old_system=""
      if [[ -e /run/current-system ]]; then
        old_system="$(readlink -f /run/current-system)"
      fi

      case "$action" in
        switch|boot|test)
          check_dirty_tree "$flake_ref"
          ;;
      esac

      print_git_context "$flake_ref"
      printf '==> nh os %s for host %s\n' "$action" "$host"
      printf '==> Home Manager is applied via NixOS module integration (single build path)\n'
      nh os "$action" "$flake_ref" -H "$host" "$@"
      local nh_rc=$?

      if [[ $nh_rc -eq 0 ]]; then
        local new_system=""
        case "$action" in
          build)
            [[ -L ./result ]] && new_system="$(readlink -f ./result)"
            ;;
          switch|test)
            new_system="$(readlink -f /run/current-system)"
            ;;
        esac
        summarize_closure_diff "$old_system" "$new_system"
      fi

      return $nh_rc
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

      local old_system=""
      if [[ -e /run/current-system ]]; then
        old_system="$(readlink -f /run/current-system)"
      fi

      check_dirty_tree "$flake_ref"

      print_git_context "$flake_ref"
      printf '==> nh os switch --update for host %s\n' "$host"
      printf '==> Updating flake inputs through nh before activation\n'
      nh os switch "$flake_ref" -H "$host" --update "$@"
      local nh_rc=$?

      if [[ $nh_rc -eq 0 ]]; then
        local new_system
        new_system="$(readlink -f /run/current-system)"
        summarize_closure_diff "$old_system" "$new_system"
      fi

      return $nh_rc
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
        check)
          run_check "$flake_dir"
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
    tanime = "ssh root@192.168.0.85";
    tanmedia = "ssh tan@192.168.0.116";
  };
}
