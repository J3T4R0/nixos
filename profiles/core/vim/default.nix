{ config, lib, pkgs, ... }:

{
  environment.sessionVariables.EDITOR = "nvim";

  programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      configure = {
        customRC =
          ''
            " set SPC as leader key
            " access git via SPC M
            " easy comment with SPC c c
            let mapleader="\<SPACE>"
            " Add spaces after comment delimiters by default
            let g:NERDSpaceDelims = 1
            nmap <leader>cc <plug>NERDCommenterToggle
            xmap <leader>cc <plug>NERDCommenterToggle
            nmap <leader>cC <plug>NERDCommenterComment
            xmap <leader>cC <plug>NERDCommenterComment
          '';
        packages.myVimPackage = with pkgs.vimPlugins; {
          # loaded on launch
          start = [
            vimagit
            dracula-vim
            vim-nix
            deoplete-nvim
            deoplete-zsh
            deoplete-lsp
            nerdcommenter
          ];
          # manually loadable by calling `:packadd $plugin-name`
          # opt = [ ];
        };
      };
    };
}
