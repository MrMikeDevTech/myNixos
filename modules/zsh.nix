{ pkgs, lib, ... }:

{
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    defaultKeymap = "emacs";

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    plugins = [
      {
        name = "zsh-shift-select";
        src = pkgs.fetchFromGitHub {
          owner = "jirutka";
          repo = "zsh-shift-select";
          rev = "da460999b7d31aef0f0a82a3e749d70edf6f2ef9";
          hash = "sha256-ekA8acUgNT/t2SjSBGJs2Oko5EB7MvVUccC6uuTI/vc=";
        };
        file = "zsh-shift-select.plugin.zsh";
      }
    ];

    sessionVariables = {
      WINEPREFIX = "~/.wine-games";
    };

    shellAliases = {
      # nix
      rebuild = "git -C ~/myNixos add . && sudo nixos-rebuild switch --flake ~/myNixos#mrmikedevs-nixos && clear && fastfetch";
      rebuild-boot = "git -C ~/myNixos add . && sudo nixos-rebuild boot --flake ~/myNixos#mrmikedevs-nixos && clear && fastfetch";
      update = "cd ~/myNixos && nix flake update";
      nixconf = "cd ~/myNixos && nvim .";
      gens = "sudo nixos-rebuild list-generations";
      clean = "sudo nix-collect-garbage -d";

      # navegación
      ".." = "cd ..";
      "..." = "cd ../..";
      ls = "lsd";
      ll = "ls -lah";
      la = "ls -A";
      tree = "tree -a -I '.git'";

      # reemplazos
      spoti = "spotify_player";
      cat = "bat";
      vim = "nvim";
      vi = "nvim";

      # git
      gs = "git status";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --decorate";
      gd = "git diff";

      # tailscale
      trans-on = "sudo tailscale up";
      trans-off = "sudo tailscale down";
      trans-status = "tailscale status";

      # utils
      ns = "tv";
      cls = "clear";
      ff = "clear && fastfetch";
      reroll-ff = "wallpaper-logo --exclude-current && clear && fastfetch";
      conf = "(cd ~/myNixos && nvim)";
      noodle = "/home/mrmikedev/.local/bin/noodle";

      # ssh
      ssh = "kitten ssh";
      ssh-vps = "ssh mrmikedev@mrmikedev-vps";
    };

    initContent = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^H" backward-kill-word
      bindkey "^[[3;5~" kill-word

      # Home/End no venían atados en el keymap emacs, y como Ctrl+A pasa a ser
      # "seleccionar todo" (abajo), sin esto no quedaría forma de ir al inicio
      # de la línea. ^[OH/^[OF es lo que manda kitty; ^[[H/^[[F por si acaso.
      bindkey "^[OH" beginning-of-line
      bindkey "^[OF" end-of-line
      bindkey "^[[H" beginning-of-line
      bindkey "^[[F" end-of-line

      # Ctrl+A: seleccionar toda la línea, como en un editor gráfico. Esto pisa
      # el "ir al inicio de línea" clásico de emacs; para eso queda la tecla Home.
      function shift-select::select-all() {
        (( ''${#BUFFER} )) || return 0
        MARK=0
        CURSOR=''${#BUFFER}
        REGION_ACTIVE=1
        # entrar al keymap del plugin para que Supr/Retroceso borren la
        # selección y Ctrl+Shift+X la corte, igual que en un editor
        zle -K shift-select
        zle redisplay
      }
      zle -N shift-select::select-all

      # Ctrl+Shift+X: cortar lo seleccionado (sin selección corta la línea
      # entera). Va al portapapeles del sistema y al kill-ring de zsh, así que
      # se puede pegar con Ctrl+Shift+V fuera o con Ctrl+Y aquí mismo.
      function shift-select::cut-region() {
        local start end texto
        if (( REGION_ACTIVE )); then
          (( start = MARK < CURSOR ? MARK : CURSOR ))
          (( end   = MARK > CURSOR ? MARK : CURSOR ))
        else
          start=0
          end=''${#BUFFER}
        fi
        (( end > start )) || return 0
        texto="''${BUFFER[start+1,end]}"
        CUTBUFFER="$texto"
        print -rn -- "$texto" | ${pkgs.wl-clipboard}/bin/wl-copy 2>/dev/null
        BUFFER="''${BUFFER[1,start]}''${BUFFER[end+1,-1]}"
        CURSOR=$start
        REGION_ACTIVE=0
        zle -K main
      }
      zle -N shift-select::cut-region

      # se registran en ambos keymaps: "emacs" es el normal, y "shift-select"
      # es el que activa el plugin mientras hay una selección viva
      for _km in emacs shift-select; do
        bindkey -M $_km '^A' shift-select::select-all
        bindkey -M $_km '^[[120;6u' shift-select::cut-region
      done
      unset _km

      # Esc Esc: agrega/quita "sudo " al inicio de la línea (o a la del
      # historial si está vacía). Copiado tal cual del plugin "sudo" de
      # ohmyzsh (plugins/sudo/sudo.plugin.zsh) para no reinventar los casos
      # raros (cursor a medio comando, $EDITOR -> sudo -e, etc).
      __sudo-replace-buffer() {
        local old=$1 new=$2 space=''${2:+ }
        if [[ $CURSOR -le ''${#old} ]]; then
          BUFFER="''${new}''${space}''${BUFFER#$old }"
          CURSOR=''${#new}
        else
          LBUFFER="''${new}''${space}''${LBUFFER#$old }"
        fi
      }

      sudo-command-line() {
        [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"

        local WHITESPACE=""
        if [[ ''${LBUFFER:0:1} = " " ]]; then
          WHITESPACE=" "
          LBUFFER="''${LBUFFER:1}"
        fi

        {
          local EDITOR=''${SUDO_EDITOR:-''${VISUAL:-$EDITOR}}

          if [[ -z "$EDITOR" ]]; then
            case "$BUFFER" in
              sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "" ;;
              sudo\ *) __sudo-replace-buffer "sudo" "" ;;
              *) LBUFFER="sudo $LBUFFER" ;;
            esac
            return
          fi

          local cmd="''${''${(Az)BUFFER}[1]}"
          local realcmd="''${''${(Az)aliases[$cmd]}[1]:-$cmd}"
          local editorcmd="''${''${(Az)EDITOR}[1]}"

          if [[ "$realcmd" = (\$EDITOR|$editorcmd|''${editorcmd:c}) \
            || "''${realcmd:c}" = ($editorcmd|''${editorcmd:c}) ]] \
            || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
            __sudo-replace-buffer "$cmd" "sudo -e"
            return
          fi

          case "$BUFFER" in
            $editorcmd\ *) __sudo-replace-buffer "$editorcmd" "sudo -e" ;;
            \$EDITOR\ *) __sudo-replace-buffer '$EDITOR' "sudo -e" ;;
            sudo\ -e\ *) __sudo-replace-buffer "sudo -e" "$EDITOR" ;;
            sudo\ *) __sudo-replace-buffer "sudo" "" ;;
            *) LBUFFER="sudo $LBUFFER" ;;
          esac
        } always {
          LBUFFER="''${WHITESPACE}''${LBUFFER}"
          zle && zle redisplay
        }
      }
      zle -N sudo-command-line
      bindkey -M emacs '\e\e' sudo-command-line
      bindkey -M vicmd '\e\e' sudo-command-line
      bindkey -M viins '\e\e' sudo-command-line

      # autocompletado de rutas sin importar mayúsculas/minúsculas (ej: "do"+Tab -> Downloads)
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # selecciona un paquete en tv y entra a un nix shell con él para probarlo
      # NST_PKG queda en el prompt (ver programs.starship) mientras dura la shell
      nst() {
        local pkg
        pkg=$(tv nixpkgs | sed -E 's|^[a-zA-Z_-]+/[[:space:]]*||')
        [[ -z "$pkg" ]] && return 1
        NST_PKG="$pkg" nix shell "nixpkgs#$pkg"
      }

      # fastfetch (para mostrar información del sistema); se salta dentro de nst,
      # ya que ahí solo se quiere el shell del paquete, no la pantalla de bienvenida
      if [[ -o interactive && -z "$NST_PKG" ]]; then
        fastfetch
      fi
    '';
  };

  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
      "--disable-ai"
    ];
    settings = {
      update_check = false;
      style = "compact";
      inline_height = 25;
      show_preview = true;
      search_mode = "fuzzy";
      filter_mode = "global";
    };
  };

  home.activation.atuinImport = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.local/share/atuin/.hm-import-done" ]; then
      mkdir -p "$HOME/.local/share/atuin"
      HISTFILE="$HOME/.zsh_history" ${pkgs.atuin}/bin/atuin import zsh || true
      touch "$HOME/.local/share/atuin/.hm-import-done"
    fi
  '';

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      env_var.NST_PKG = {
        symbol = "📦 ";
        style = "bold yellow";
        format = "[$symbol$env_value]($style) ";
      };
    };
  };
}
