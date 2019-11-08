{ config, pkgs, ... }:

let
  pkgsWithOverlay = import <nixpkgs-unstable> {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      }))
    ];
  };

  orgAgendaView = import ./emacs-org-agenda.nix;

  packageRepos = ''
    (require 'package) ;; You might already have this line
    (let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                        (not (gnutls-available-p))))
           (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
      (add-to-list 'package-archives (cons "melpa" url) t)
      (add-to-list 'package-archives
                 '("org" . "http://orgmode.org/elpa/") t)
    )
    (when (< emacs-major-version 24)
      ;; For important compatibility libraries like cl-lib
      (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
    (package-initialize)
  '';

# How to make emacs stop creating “backup~” files or “#autosave#” files?
# http://ergoemacs.org/emacs/emacs_set_backup_into_a_directory.html
  turnOffBackup = ''
    (setq make-backup-files nil) ; stop creating backup~ files
    (setq auto-save-default nil) ; stop creating #autosave# files
  '';

  evilMode = ''
    ;; Evil Mode
    (require 'evil)
    (evil-mode 1)
    ;; (require 'evil-org)
    ;; (add-hook 'org-mode-hook 'evil-org-mode)
    ;; (evil-org-set-key-theme '(navigation insert textobjects additional calendar))
    ;; (require 'evil-org-agenda)
    ;; (evil-org-agenda-set-keys)
  '';

  goMode = ''
    (setq godoc-and-godef-command "go doc") ;godoc has no cli support any more, thats go doc now
    (add-to-list 'exec-path "~/go/bin")
    (add-hook 'go-mode-hook
    (lambda ()
      (setq-default)
      (setq tab-width 2)
      (setq standard-indent 2)
      (setq indent-tabs-mode nil)
    ))
  '';

  ido = ''
    (require 'ido)
    (ido-mode t)
  '';

  magit = ''
    (global-set-key (kbd "C-x g") 'magit-status) ; "Most Magit commands are commonly invoked from the status buffer"

    (with-eval-after-load 'magit
      (require 'forge))
  '';

  windowCosmetics = ''
    (menu-bar-mode -1)
    (tool-bar-mode -1)                  ; Disable the button bar atop screen
    (scroll-bar-mode -1)                ; Disable scroll bar
    (toggle-scroll-bar -1)
    (setq inhibit-startup-screen t)     ; Disable startup screen with graphics
    (setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
    (setq default-tab-width 2)          ; Two spaces is a tab
    (setq tab-width 2)                  ; Four spaces is a tab
    (setq visible-bell nil)             ; Disable annoying visual bell graphic
    (setq ring-bell-function 'ignore)   ; Disable super annoying audio bell
  '';

  orgMode = ''
    (add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\|txt\\)$" . org-mode))
    (global-set-key "\C-cl" 'org-store-link)
    (global-set-key "\C-ca" 'org-agenda)
    (global-set-key "\C-cb" 'org-iswitchb)
    (global-set-key "\C-c L" 'org-insert-link-global)
    (global-set-key "\C-c o" 'org-open-at-point-global)
    (setq org-link-frame-setup '((file . find-file))) ; open link in same frame.
    (if (boundp 'org-user-agenda-files)
      (setq org-agenda-files org-user-agenda-files)
      (setq org-agenda-files (quote ("~/projects/notes_privat")))
    )
  '';

  theme = ''
    (load-theme 'monokai-alt t)
    (load-theme 'whiteboard t)
    (disable-theme 'monokai-alt)
    (disable-theme 'whiteboard)

    (defun mh/load-whiteboard-theme ()
      "load whiteboard theme"
      (interactive)
      (message "whiteboard loaded")
      (disable-theme 'monokai-alt)
      (enable-theme 'whiteboard)
    )

    (defun mh/load-monokai-theme ()
      "load monokai theme"
      (interactive)
      (message "monokai loaded")
      (disable-theme 'whiteboard)
      (enable-theme 'monokai-alt)
    )

    (global-set-key "\C-ctw" 'mh/load-whiteboard-theme)
    (global-set-key "\C-ctm" 'mh/load-monokai-theme)
  '';

  # Configuration for rust development
  # inspired by
  # https://github.com/bbatsov/prelude/blob/master/modules/prelude-rust.el
  #
  # This requires rls and racer to be installed on the system
  rustDevelopment = ''
    (add-hook 'rust-mode-hook #'racer-mode)
    (add-hook 'rust-mode-hook (lambda()
      (local-set-key (kbd "C-c C-d") 'racer-describe)
      (local-set-key (kbd "C-c .") 'racer-find-definition)
      (local-set-key (kbd "C-c ,") 'pop-tag-mark))
    )
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (add-hook 'racer-mode-hook #'company-mode)
    (require 'rust-mode)
    (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
    (setq company-tooltip-align-annotations t)
  '';

  recentFiles = ''
    (recentf-mode 1)
    (setq recentf-max-menu-items 25)
    (global-set-key "\C-x\ \C-r" 'recentf-open-files)
  '';

  myFunctionKeys = ''
    (fset 'kill-actual-buffer
      [?\C-x ?k return])

    (defun mh/open-term-and-rename (name)
      "open a new bash and rename it"
      (interactive "sName of new terminal: ")
      (term "/run/current-system/sw/bin/bash")
      (rename-buffer name)
    )
    (global-set-key (kbd "M-<f8>") 'kill-actual-buffer)

    (global-set-key (kbd "<f5>") 'mh/open-term-and-rename)
    (global-set-key (kbd "<f6>") 'other-window)
    (global-set-key (kbd "<f7>") 'split-window-right)
    (global-set-key (kbd "<f8>") 'delete-other-windows)
  '';

  webMode = ''
    (setq js-indent-level 2)
  '';

  trailingWhitespaces = ''
    (add-hook 'before-save-hook 'delete-trailing-whitespace)
  '';

  dotEmacs = pkgs.writeText "dot-emacs" ''
    ${packageRepos}
    ${turnOffBackup}

    ${evilMode}
    ${goMode}
    ${ido}
    ${magit}
    ${orgMode}
    ${recentFiles}
    ${rustDevelopment}
    ${theme}
    ${windowCosmetics}

    ${orgAgendaView}
    ${myFunctionKeys}
    ${webMode}
    ${trailingWhitespaces}
  '';

  #emacsWithCustomPackages
  emacsPkgs= epkgs: [
#testing
    epkgs.melpaPackages.gitlab
    epkgs.melpaPackages.forge
    epkgs.melpaPackages.helm

# emacs convenience
    epkgs.melpaPackages.ag
    epkgs.melpaPackages.company
    epkgs.melpaPackages.direnv
    epkgs.melpaPackages.evil
    epkgs.melpaPackages.google-this
    epkgs.melpaPackages.monokai-alt-theme

# development
    epkgs.melpaPackages.magit
    epkgs.melpaPackages.nix-mode
    epkgs.melpaPackages.haskell-mode
    epkgs.melpaPackages.projectile

# go development
    epkgs.melpaPackages.go-mode
    epkgs.melpaPackages.company-go
    epkgs.melpaPackages.go-eldoc
    epkgs.melpaPackages.gotest
    epkgs.melpaPackages.go-projectile

    # epkgs.melpaPackages.flycheck-rust # currently broken

# rust
    epkgs.melpaPackages.rust-mode
    epkgs.melpaPackages.flycheck-rust
    epkgs.melpaPackages.racer

# python
    epkgs.melpaPackages.elpy

# org-mode
    epkgs.elpaPackages.bbdb
    epkgs.orgPackages.org-plus-contrib
    epkgs.melpaPackages.smex
    epkgs.melpaPackages.org-mime

    epkgs.elpaPackages.which-key
  ];
emacsWithOverlay = (pkgsWithOverlay.emacsWithPackagesFromUsePackage {
      config = builtins.readFile dotEmacs; # builtins.readFile ./emacs.el;
      # Package is optional, defaults to pkgs.emacs
      package = pkgsWithOverlay.emacsGit;
      # Optionally provide extra packages not in the configuration file
      extraEmacsPackages = emacsPkgs;
    });

  myEmacs = pkgs.writeDashBin "my-emacs" ''
    exec ${emacsWithOverlay}/bin/emacs -q -l ${dotEmacs} "$@"
  '';

  myEmacsWithDaemon = pkgs.writeDashBin "my-emacs-daemon" ''
    exec ${emacsWithOverlay}/bin/emacs -q -l ${dotEmacs} --daemon
  '';

  myEmacsClient = pkgs.writeDashBin "meclient" ''
    exec ${emacsWithOverlay}/bin/emacsclient --create-frame
  '';
in {
  environment.systemPackages = [
    myEmacs myEmacsWithDaemon myEmacsClient
  ];
}
