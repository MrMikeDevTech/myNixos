# myNixos

Configuración de NixOS del host **mrmikedevs-nixos**, gestionada con [flakes](https://nixos.wiki/wiki/Flakes) y [Home Manager](https://github.com/nix-community/home-manager) (integrado como módulo de NixOS, no standalone).

## Stack

- **WM**: [niri](https://github.com/YaLTeR/niri) (compositor en mosaico para Wayland), vía [niri-flake](https://github.com/sodiboo/niri-flake)
- **Shell/panel**: [noctalia](https://github.com/noctalia-dev/noctalia-shell) — barra, control center, launcher, lockscreen, idle/auto-lock, wallpaper
- **Display manager**: greetd + tuigreet (login en TUI, arranca `niri-session`)
- **GPU**: NVIDIA híbrida (PRIME offload con Intel, VAAPI vía `intel-media-driver`)
- **Terminal**: kitty
- **Shell**: zsh + starship + zoxide + atuin
- **Editor**: Neovim (config propia en [`dotfiles/nvim`](dotfiles/nvim), enlazada por symlink, lazy.nvim)
- **Tema**: Catppuccin Mocha (kitty, bat, Neovim) + cursor `pixloen-manhattan-cafe`
- **VPN**: Tailscale
- **Virtualización**: Docker, Steam

## Estructura

```
.
├── flake.nix                          # Entrypoint del flake e inputs (nixpkgs, home-manager, niri-flake, noctalia)
├── flake.lock
├── hosts/
│   └── mrmikedevs-nixos/
│       ├── configuration.nix          # Config a nivel de sistema (NixOS)
│       └── hardware-configuration.nix # Generada por nixos-generate-config
├── config/                            # Módulos de sistema (NixOS), importados desde configuration.nix
│   ├── fonts.nix                      # Fuentes del sistema
│   ├── nvidia.nix                     # Drivers NVIDIA + PRIME offload + VAAPI
│   ├── packages.nix                   # Paquetes a nivel de sistema
│   ├── tailscale.nix                  # VPN Tailscale
│   └── users.nix                      # Definición del usuario mrmikedev
├── modules/                           # Módulos de Home Manager, importados vía modules/default.nix
│   ├── default.nix                    # Entrypoint de Home Manager
│   ├── audio.nix                      # EasyEffects
│   ├── bat.nix                        # `cat` con syntax highlighting + tema Catppuccin
│   ├── cursor.nix                     # Tema de cursor pixloen-manhattan-cafe
│   ├── displays.nix                   # Multi-monitor: script `display-mode` + nwg-displays
│   ├── fastfetch-logo.nix             # Logo dinámico de fastfetch según wallpaper
│   ├── fastfetch.nix                  # System info personalizado en terminal
│   ├── kitty.nix                      # Terminal
│   ├── niri.nix                       # Binds, layout, window-rules y spawn-at-startup de niri
│   ├── noctalia.nix                   # Barra, idle/lock, power-profiles
│   ├── nvim.nix                       # Symlink a dotfiles/nvim + LSPs/herramientas
│   ├── television.nix                 # Buscador difuso de paquetes de Nix (`tv`/`ns`)
│   ├── yazi.nix                       # File manager en terminal
│   └── zsh.nix                        # Shell, keybinds estilo GUI, aliases, atuin, starship, zoxide
└── dotfiles/                          # Configs que se enlazan por symlink o se referencian a $HOME
    ├── nvim/                          # Config de Neovim (Lua, lazy.nvim)
    ├── wallpapers/                    # Wallpapers, enlazados a ~/Pictures/Wallpapers
    ├── fastfetch/logos/               # Logos de fastfetch, uno por categoría de wallpaper
    └── cursors/                       # Tema de cursor pixloen-manhattan-cafe
```

## Compositor: niri

Configurado en [`modules/niri.nix`](modules/niri.nix) y [`modules/displays.nix`](modules/displays.nix).

- Layout: gaps de 24px, borde morado en la ventana activa, sin barra de foco, `center-focused-column = never`.
- `prefer-no-csd` y overlay de atajos oculto al arrancar.
- Capturas de pantalla a `~/Pictures/Screenshots/`.

### Window rules

- Todas las ventanas con esquinas redondeadas (radio 14).
- Toasts de notificación (`notificationtoasts_*_desktop`) flotan sin decoración, en la esquina inferior derecha.
- **Picture-in-Picture de Brave/Chromium** (`title = "Pantalla en pantalla"`, sin `app-id`) flota en la esquina inferior derecha en vez de tilearse en el workspace. *(Nota: por diseño de niri, una ventana en pantalla completa siempre cubre a las flotantes — el PiP no puede quedar por encima de un fullscreen.)*

### Atajos de teclado

| Atajo | Acción |
| --- | --- |
| `Mod+Return` | Abrir kitty |
| `Alt+Space` | Launcher de noctalia |
| `Mod+Q` | Cerrar ventana |
| `Mod+Shift+E` | Salir de niri |
| `Mod+L` | Bloquear sesión |
| `Mod+←/→` | Cambiar foco de columna |
| `Mod+Ctrl+↑/↓` | Cambiar foco de ventana (dentro de columna) |
| `Alt+Tab` | Ventana enfocada anteriormente |
| `Mod+Shift+←/→` | Mover columna |
| `Mod+Shift+Ctrl+↑/↓` | Mover ventana dentro de columna |
| `Mod+C` | Control center de noctalia |
| `Mod+Comma` | Settings de noctalia |
| `Mod+V` | Panel de portapapeles |
| `Mod+W` | Selector de wallpaper |
| `Mod+P` | Panel de sesión (power) |
| `Mod+N` | Notificaciones |
| `Mod+M` | Panel de media |
| `Mod+Grave` | Mute de micrófono |
| `Mod+B` | Abrir Brave |
| `Mod+Tab` | Overview |
| `Mod+↑/↓` | Cambiar de workspace |
| `Mod+Shift+↑/↓` / `Mod+Ctrl+Page↑/↓` | Mover columna a otro workspace |
| `Mod+1..4` | Ir a workspace por número |
| `Mod+F` | Maximizar columna |
| `Mod+Shift+F` | Fullscreen |
| `Mod+R` | Ciclar ancho de columna preset |
| `Mod+Shift+S` / `Print` | Screenshot (selección/pantalla) |
| `Ctrl+Print` | Screenshot de pantalla completa |
| `Alt+Print` | Screenshot de ventana |
| `Mod+F1/F2/F3` | Multi-monitor: solo pantalla / espejo / extender |
| `Mod+Shift+D` | Abrir `nwg-displays` (acomodo gráfico de monitores) |
| Teclas de función | Volumen, brillo y multimedia (mapeadas a comandos de noctalia) |

### Multi-monitor (`displays.nix`)

Script `display-mode <screen-only|mirror|extend>`: detecta el monitor interno (`eDP-*`) y uno externo vía `niri msg --json outputs`, y:

- **screen-only**: apaga el monitor externo.
- **extend**: lo enciende y lo posiciona a la derecha del principal.
- **mirror**: además, lanza `wl-mirror` para espejar el contenido.

## Panel: noctalia

Configurado en [`modules/noctalia.nix`](modules/noctalia.nix).

- Tema oscuro, fuente JetBrainsMono Nerd Font, color derivado del wallpaper.
- Widget de red: oculta el SSID, deja solo el ícono.
- Widget de batería: ícono + porcentaje (`display_mode = glyph`).
- **Sistema de idle nativo** (reemplaza a un `swayidle` externo que antes corría desincronizado): bloquea la sesión a los 5 min de inactividad y apaga pantalla a los 10 min — esto es lo que hace que el toggle **"Cafeína"** del control center realmente inhiba el auto-lock.
- `services.upower.enable` y `services.power-profiles-daemon.enable` (en `configuration.nix`) son lo que le da datos reales al widget de batería y funcionalidad al toggle **"Energía"** del control center.
- Corre como `systemd.user` service.

## Terminal & shell

### kitty ([`modules/kitty.nix`](modules/kitty.nix))

Tema Catppuccin Mocha, fondo con 92% de opacidad, `cursor_trail`, tab bar estilo powerline. Keybinds para navegación/selección de palabras estilo GUI (`Ctrl+←/→`, `Shift+←/→`, `Ctrl+Shift+←/→`, `Ctrl+Backspace/Delete`) y `Ctrl+Shift+X` para cortar.

### zsh ([`modules/zsh.nix`](modules/zsh.nix))

- `defaultKeymap = "emacs"` + plugin [`zsh-shift-select`](https://github.com/jirutka/zsh-shift-select): `Shift+←/→` selecciona texto como en un editor gráfico.
- `Ctrl+A`: seleccionar toda la línea. `Ctrl+Shift+X`: cortar la selección (o la línea completa) al portapapeles del sistema (`wl-copy`) y al kill-ring.
- **`Esc Esc`**: antepone/quita `sudo ` al comando actual (o al último del historial si la línea está vacía) — puerto directo del plugin `sudo` de oh-my-zsh.
- **[atuin](https://atuin.sh/)** reemplaza la búsqueda de historial nativa (`Ctrl+R`): historial sincronizado con contexto, importado automáticamente del `.zsh_history` existente en la primera activación.
- **[television](https://github.com/alexpasmantier/television) (`tv`) + [nix-search-tv](https://github.com/3timeslazy/nix-search-tv)**: buscador difuso de paquetes de Nix en terminal, canal `nixpkgs` en `~/.config/television/cable/nixpkgs.toml`.
  - `ns` → abre `tv` en el canal `nixpkgs` para explorar/copiar el nombre de un paquete.
  - `nst` → selecciona un paquete y entra directo a `nix shell nixpkgs#<paquete>` para probarlo. Mientras estás dentro, el prompt de starship muestra `📦 <paquete>` (vía un módulo `env_var`) y fastfetch no se dispara de nuevo al abrir esa shell.
- Autocompletado de rutas insensible a mayúsculas/minúsculas.
- `fastfetch` se ejecuta al abrir una shell interactiva normal (se salta dentro de `nst`).

#### Alias

| Alias | Acción |
| --- | --- |
| `rebuild` | `git add .` + `nixos-rebuild switch` con este flake + `fastfetch` |
| `rebuild-boot` | Igual, pero aplica en el próximo boot |
| `update` | `nix flake update` |
| `nixconf` / `conf` | Abrir este repo en Neovim |
| `gens` | Listar generaciones de NixOS |
| `clean` | `nix-collect-garbage -d` |
| `..` / `...` | Subir uno/dos directorios |
| `ls` / `ll` / `la` | `lsd` con distintas flags |
| `tree` | `tree -a` ignorando `.git` |
| `spoti` | `spotify_player` |
| `cat` | `bat` |
| `vim` / `vi` | `nvim` |
| `gs` / `ga` / `gc` / `gp` / `gl` / `gd` | Atajos de `git` |
| `trans-on` / `trans-off` / `trans-status` | Tailscale up/down/status |
| `ns` | `tv` (buscador de paquetes de Nix) |
| `nst` | Función: elegir paquete en `tv` → `nix shell` con él |
| `cls` | `clear` |
| `ff` | `fastfetch && clear` |
| `reroll-ff` | Nuevo logo aleatorio de fastfetch (excluyendo el actual) |
| `ssh` | `kitten ssh` |
| `ssh-vps` | SSH al VPS |

También: `starship` (prompt), `zoxide` (`cd` inteligente).

## Editor: Neovim

[`modules/nvim.nix`](modules/nvim.nix) enlaza `dotfiles/nvim` a `~/.config/nvim` (symlink creado una sola vez vía `home.activation`) e instala todas las herramientas de LSP/formateo que la config de Lua espera encontrar en el `PATH`:

- **LSPs**: TypeScript/JS, Astro, Prisma, Tailwind CSS, ESLint (`eslint_d`), YAML, Bash, Docker(-compose), Lua, Nix (`nil`), Python (`pyright` + `ruff`), Go (`gopls`), Markdown (`marksman`), Typst (`tinymist`).
- **Formateo**: `prettier`, `stylua`, `nixfmt`, `typstyle`.
- **Otros**: `ripgrep`/`fd` (Telescope), `tree-sitter`, `lazygit`, `trash-cli`, `websocat`.

### Plugins destacados (`dotfiles/nvim/lua/plugins`)

- `lazy.nvim` como gestor de plugins.
- **Telescope** (fuzzy finder) y **neo-tree** (explorador de archivos).
- **Treesitter**, con un parche propio (`config/treesitter-fix.lua`) que evita un crash conocido de Neovim 0.12 al parsear inyecciones de sintaxis (ej. bloques de código en Markdown).
- **markdown-preview.nvim** y **markview.nvim** para previsualización de Markdown.
- **supermaven-nvim**: autocompletado con IA (`Tab` para aceptar, `Ctrl+J` para aceptar palabra).
- **presence.nvim**: Discord Rich Presence en español ("Editando en Neovim", "Editando %s", etc).
- **Catppuccin**, dashboard de inicio, resaltado de colores inline, auto-cierre de tags/paréntesis (`ts-autotag`, `mini-pairs`).
- Formateo al guardar y diagnósticos configurados explícitamente (`vim.diagnostic.config`, ya que Neovim 0.12 trae `virtual_text` desactivado por defecto).

### Keybinds estilo GUI (`config/keymaps.lua`)

`Ctrl+S` guardar · `Ctrl+Z` / `Ctrl+Shift+Z` deshacer/rehacer · `Ctrl+A` seleccionar todo · `Ctrl+Shift+X` cortar · `Shift+←/→` y `Ctrl+Shift+←/→` seleccionar por carácter/palabra · `Ctrl+←/→` moverse por palabra.

## Fastfetch

[`modules/fastfetch.nix`](modules/fastfetch.nix): layout personalizado con separadores tipo caja, paleta Catppuccin y encabezado `MrMikeDev // <host>`.

[`modules/fastfetch-logo.nix`](modules/fastfetch-logo.nix): el logo (`~/.cache/fastfetch-logo.png`) es dinámico según el wallpaper activo:

- `wallpaper-logo [--exclude-current] [ruta]`: detecta a qué categoría de personaje pertenece el wallpaper actual (`komi`, `doto`, `cafe`, `nishi`, `yotsuba`, `maomao`, `alya`, `rebecca`, `reze`, cada una con ~10 imágenes PNG en `dotfiles/fastfetch/logos/<categoría>/`) y elige una imagen al azar de esa carpeta.
- `wallpaper-logo-watch`: servicio `systemd.user` que vigila `~/.local/state/noctalia/settings.toml` y llama a `wallpaper-logo` automáticamente cada vez que cambia el wallpaper.
- `wall <ruta-a-imagen>`: pone el wallpaper con noctalia, elige el logo correspondiente y ajusta el modo claro/oscuro del tema según la luminancia de la imagen.

## Cursor

[`modules/cursor.nix`](modules/cursor.nix): tema `pixloen-manhattan-cafe` empaquetado desde `dotfiles/cursors/`, aplicado a GTK y X11, tamaño 24.

## Audio

[`modules/audio.nix`](modules/audio.nix): [EasyEffects](https://github.com/wwmm/easyeffects) habilitado.

## Explorador de archivos

[`modules/yazi.nix`](modules/yazi.nix): oculta archivos ocultos por defecto, orden natural con directorios primero. Incluye `ffmpeg`, `p7zip`, `poppler-utils` e `imagemagick` para previsualizar video, archivos comprimidos, PDFs e imágenes.

## `bat`

[`modules/bat.nix`](modules/bat.nix): tema Catppuccin Mocha, estilo `numbers,changes,header`.

## Sistema (nivel NixOS, `config/`)

- **[`fonts.nix`](config/fonts.nix)**: JetBrainsMono Nerd Font.
- **[`nvidia.nix`](config/nvidia.nix)**: GPU híbrida — driver NVIDIA estable (no `open`) + PRIME offload sobre la Intel integrada, `intel-media-driver` para aceleración VAAPI.
- **[`tailscale.nix`](config/tailscale.nix)**: VPN con firewall abierto y DNS aceptado.
- **[`users.nix`](config/users.nix)**: usuario `mrmikedev`, shell `zsh`, grupos `networkmanager`, `wheel`, `bluetooth`, `docker`.
- **[`packages.nix`](config/packages.nix)**: paquetes a nivel de sistema —
  - *CLI*: `wget`, `fastfetch`, `bat`, `lsd`, `zip/unzip/rar/unrar`, `figlet`, `just`, `cmatrix`, `tree`, `cava`, `btop`, `libva-utils`, `nix-search-tv`, `television`, `noodle`.
  - *Desarrollo*: `git`, `cargo`, `gcc`, `python3`+`pip`, `bun`, `claude-code`, `docker`+`docker-compose`.
  - *Terminal/Wayland*: `kitty`, `xwayland-satellite`.
  - *Navegador/comunicación*: `brave`, `discord-ptb`.
  - *Multimedia*: `spotify-player`, `spotify`, `easyeffects`, `vlc`, `obs-studio`, `audacity`.
  - *Gaming*: `steam`, `snes9x` (emulador SNES).

  [`noodle`](https://github.com/wilfredinni/noodle) (cliente HTTP de terminal) no está en nixpkgs: se empaqueta
  como una derivación propia dentro de `packages.nix` que descarga el binario prebuilt de la release de GitHub
  (fijado a una versión concreta + sha256) y le parchea el intérprete dinámico a la libc de nixpkgs con
  `patchelf`. Solo se toca el intérprete (sin `autoPatchelfHook`/strip): el binario es un ejecutable de Bun con
  el script empaquetado adentro, y stripearlo corrompe esos bytes embebidos y hace que corra como `bun` a secas
  en vez de `noodle`.

Otros ajustes de [`hosts/mrmikedevs-nixos/configuration.nix`](hosts/mrmikedevs-nixos/configuration.nix):

- Bootloader `systemd-boot` (máximo 2 generaciones), flakes activadas.
- **GC automático semanal** (`nix.gc`, borra generaciones >30 días) y **`nix.optimise`** semanal (hardlinks de archivos duplicados en el store).
- Locale `es_MX.UTF-8`, zona horaria `America/Mexico_City`.
- `NIXOS_OZONE_WL=1` (Electron/Chromium sobre Wayland) y `LIBVA_DRIVER_NAME=iHD`.
- Docker y Steam habilitados; Bluetooth con `powerOnBoot` y perfiles experimentales.
- Login: **greetd + tuigreet**, arranca `niri-session`, recuerda el último usuario.
- `gnome-keyring`, `gvfs`, `upower`, `power-profiles-daemon`, portal XDG (`gtk`/`gnome`, file chooser vía GTK, screencast vía GNOME).
- `nixpkgs.config.allowUnfree = true` (Spotify, Discord, drivers NVIDIA, etc).

## Uso

### Aplicar cambios

```bash
rebuild        # nixos-rebuild switch con la config de este flake
rebuild-boot   # igual, pero aplica en el próximo boot
```

Ambos alias (definidos en [`zsh.nix`](modules/zsh.nix)) hacen `git add .` antes de reconstruir, ya que `nixos-rebuild` con flakes solo ve archivos trackeados por git.

Ver la tabla completa de alias más arriba, en [Terminal & shell](#terminal--shell).

### Instalación en sistema limpio

1. **Activar flakes** (si el ISO/instalación no las trae activas). En
   `/etc/nixos/configuration.nix` agregar:

   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```

   y correr `sudo nixos-rebuild switch` una vez con la config del sistema
   base antes de usar este flake.

2. **Clonar el repo**:

   ```bash
   git clone <url-de-este-repo> ~/myNixos
   ```

3. **Hardware de la máquina nueva**: `hardware-configuration.nix` es
   específico de cada equipo (discos, UUIDs, módulos de kernel). Generar uno
   nuevo y reemplazar el del repo:

   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/myNixos/hosts/mrmikedevs-nixos/hardware-configuration.nix
   ```

   Si el hostname del equipo nuevo es distinto de `mrmikedevs-nixos`, renombrar
   la carpeta `hosts/mrmikedevs-nixos/`, actualizar `networking.hostName` en
   `configuration.nix` y el nombre `mrmikedevs-nixos` en `flake.nix`
   (`nixosConfigurations.<host>` y `home-manager.users.<usuario>` si el
   usuario también cambia). Si la máquina no tiene GPU NVIDIA híbrida, ajustar
   o quitar [`config/nvidia.nix`](config/nvidia.nix) de los imports.

4. **Primer rebuild**: como `nixos-rebuild` con flakes solo ve archivos
   trackeados por git, hay que stagear el repo antes:

   ```bash
   cd ~/myNixos
   git add .
   sudo nixos-rebuild switch --flake .#mrmikedevs-nixos
   ```

5. **Pasos manuales antes/relacionados con la primera activación**:
   - Los `home.activation` de [`niri.nix`](modules/niri.nix) y
     [`nvim.nix`](modules/nvim.nix) solo crean los symlinks
     (`~/Pictures/Wallpapers` → `dotfiles/wallpapers`, `~/.config/nvim` →
     `dotfiles/nvim`) si el destino **no existe todavía**. En un sistema
     recién instalado no debería haber conflicto, pero si el usuario ya tiene
     `~/.config/nvim` o `~/Pictures/Wallpapers` de otra instalación, hay que
     moverlos o borrarlos antes del primer `rebuild` para que el symlink se
     cree.
   - `home.activation.atuinImport` en [`zsh.nix`](modules/zsh.nix) importa
     `~/.zsh_history` a atuin una sola vez (marcador en
     `~/.local/share/atuin/.hm-import-done`).
   - El usuario del sistema (`mrmikedev`) se define en
     [`config/users.nix`](config/users.nix); si es un usuario distinto,
     ajustar ese archivo y `home-manager.users.<usuario>` en `flake.nix`.

## Notas

- El usuario del sistema es `mrmikedev`; Home Manager está integrado como módulo de NixOS (`home-manager.users.mrmikedev`), no standalone.
- `nixpkgs.config.allowUnfree` está activo (Spotify, Discord, drivers NVIDIA, etc).
- La config de Neovim vive en `dotfiles/nvim` y se enlaza a `~/.config/nvim` automáticamente vía `home.activation` en [`nvim.nix`](modules/nvim.nix).
- El PIN de flake (`flake.nix`) fija `nixpkgs` a un commit concreto; `update` (`nix flake update`) lo mueve a la última revisión de cada input.
