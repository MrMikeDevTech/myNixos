{ pkgs, lib, ... }:

{
  home.activation.linkNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.config/nvim" ]; then
      ln -s "$HOME/myNixos/dotfiles/nvim" "$HOME/.config/nvim"
    fi
  '';

  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.NVIM_TSDK = "${pkgs.typescript}/lib/node_modules/typescript/lib";

  home.packages = with pkgs; [
    neovim
    gnumake
    ripgrep
    fd
    tree-sitter
    go
    gopls
    clang-tools
    nodejs
    pnpm
    typescript
    typescript-language-server
    astro-language-server
    pyright
    ruff
    lua-language-server
    stylua
    nil
    nixfmt
    taplo
    vscode-langservers-extracted
    prettier
    eslint_d
    prisma-language-server
    marksman
    tailwindcss-language-server
    yaml-language-server
    bash-language-server
    dockerfile-language-server
    docker-compose-language-service
    tinymist
    typst
    typstyle
    lazygit
    trash-cli
    glib
    websocat
  ];
}
