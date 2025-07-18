; Initialisation -*- lexical-binding: t -*-

(defun set-font ()
  (progn
    (set-face-attribute 'default nil :family "Iosevka Term SS07" :height 135)
    (set-face-attribute 'fixed-pitch nil :family "Iosevka Term SS07")
    (set-face-attribute 'variable-pitch nil :family "IBM Plex Serif")))

(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'set-font)
  (set-font))

(if (eq system-type 'windows-nt)
    (when (member "Noto Emoji" (font-family-list))
      (set-fontset-font t
                        'emoji
                        (font-spec :family "Noto Emoji" :size 18)))
  (when (member "Noto Color Emoji" (font-family-list))
    (set-fontset-font t
                      'emoji
                      (font-spec :family "Noto Color Emoji" :size 18))))

(setq inhibit-startup-echo-area-message "qak")

;; == ELPACA INITIALISATION ==

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (setq use-package-always-ensure t)
  (elpaca-use-package-mode))

;; == CORE PACKAGES (EAGERLY LOADED) ==

(use-package doom-themes
  :ensure t
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config (load-theme 'modus-vivendi t))

(use-package doom-modeline :hook (elpaca-after-init . doom-modeline-mode))

;; (use-package monokai-theme
;;   :custom (monokai-foreground "#FCFCFC")
;;   :config (load-theme 'monokai t))

(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

;; (use-package fixed-pitch
;;   :ensure (fixed-pitch :type git :host github :repo "cstby/fixed-pitch-mode")
;;   :custom
;;   (fixed-pitch-whitelist-hooks
;;    '(which-key-faces markdown-code-face markdown-inline-code-face))
;;   (fixed-pitch-use-extended-default t))

(use-package which-key
  :custom
  (which-key-idle-delay 0.05)
  (which-key-add-column-padding 0)
  (which-key-show-docstrings t)
  (which-key-max-description-length 54)
  (which-key-allow-evil-operator t)
  :config (which-key-mode 1))

(defvar-keymap emaxx/window-map
  :doc "Window keybinds"
  "r" #'split-window-right
  "d" #'split-window-below
  "b" #'balance-windows
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right
  "x" #'delete-window)

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("?" . meow-cheatsheet)
   (cons "w" emaxx/window-map)
   (cons "p" project-prefix-map))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :after which-key
  :config
  (meow-setup)
  (meow-global-mode 1))

(use-package meow-tree-sitter
  :after meow
  :hook (meow-mode . meow-tree-sitter-register-defaults))

(elpaca-wait) ;; Forces elpaca to eagerly load preceding packages

;; == TWEAKS ==

(use-package emacs
  :ensure nil
  :hook
  (text-mode . display-line-numbers-mode)
  (prog-mode . (lambda ()
                 (display-line-numbers-mode)
                 (hl-line-mode)
                 (electric-pair-mode)
                 (indent-tabs-mode -1)
                 (setq-default tab-width 4)))
  :custom
  ;; === BACKUP FILES CONFIG ===
  (backup-by-copying t)                           ; don't clobber symlinks
  (backup-directory-alist '(("." .
                             (file-name-concat
                              (getenv "HOME")
                              ".emacs-saves/")))) ; don't litter my fs tree
  (delete-old-versions t)
  (kept-new-versions 6)
  (kept-old-versions 2)
  (version-control t)                             ; use versioned backups

  ;; Autosave files config
  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))
  :bind (("C-+" . text-scale-increase)
         ("C--" . text-scale-decrease)
         ("C-<wheel-up>" . text-scale-increase)
         ("C-<wheel-down>" . text-scale-decrease)
         ("C-<tab>" . tab-line-switch-to-next-tab)
         ("C-<iso-lefttab>" . tab-line-switch-to-prev-tab))
  :config
  (global-auto-revert-mode)
  (global-tab-line-mode)
  (window-divider-mode))

(use-package fixed-pitch
  :ensure (fixed-pitch :type git :host github :repo "cstby/fixed-pitch-mode"))

;; == MINIBUFFER CONFIGURATION ==

(use-package vertico
  :demand t
  :custom
  (vertico-cycle 1)
  (vertico-resize nil)
  :config (vertico-mode 1)
  :bind ( :map vertico-map
          ("M-j" . vertico-next)
          ("M-k" . vertico-previous)))

(use-package marginalia
  :demand t
  :config (marginalia-mode 1))

(use-package orderless
  :demand t
  :config (setq completion-styles '(orderless basic)))

(use-package consult
  :demand t
  :config (setq completion-in-region-function 'consult-completion-in-region))

;; == EDITOR ==

(use-package treesit-auto
  :demand t
  :custom (treesit-auto-install 'p)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package ligature
  :config
  (ligature-set-ligatures
   'prog-mode
   '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
     ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
     "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
     "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
     "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
     "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
     "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
     "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
     ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
     "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
     "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
     "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
     "\\\\" "://"))
  (global-ligature-mode t))

(use-package hl-todo
  :demand t
  :hook (prog-mode . hl-todo-mode))

(use-package consult-todo
  :demand t
  :bind ("C-c t" . consult-todo-project))

;; == COMPLETION FRAMEWORK + LANGUAGE SUPPORT ==

(use-package company
  :custom (company-tooltip-align-annotations t)
  :bind ( :map company-active-map
          ("M-j"   . #'company-select-next)
          ("M-k"   . #'company-select-previous)
          ("<tab>" . #'company-complete-selection))
  :config (global-company-mode))

(use-package company-box
  :after company
  :hook (company-mode . company-box-mode))

(use-package yasnippet :hook (prog-mode . yas-minor-mode))

(use-package yasnippet-snippets)

(use-package inheritenv
  :if (eq system-type 'gnu/linux)
  :ensure ( :wait t))

(use-package envrc
  :if (eq system-type 'gnu/linux)
  :ensure ( :wait t)
  :hook (elpaca-after-init . envrc-global-mode)
  :config (meow-leader-define-key (cons "e" envrc-command-map)))

(use-package lsp-mode
  :custom
  (lsp-keymap-prefix "C-l")
  (lsp-idle-delay 0.5)
  (lsp-nix-nil-formatter ["alejandra"])
  :hook (lsp-mode . lsp-enable-which-key-integration)
  :commands (lsp-mode lsp lsp-deferred))

(use-package lsp-ui :commands lsp-ui-mode)

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))
(advice-add (if (progn (require 'json)
                       (fboundp 'json-parse-buffer))
                'json-parse-buffer
              'json-read)
            :around
            #'lsp-booster--advice-json-parse)

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
        (progn
          (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
            (setcar orig-result command-from-exec-path))
          (message "Using emacs-lsp-booster for %s!" orig-result)
          (cons "emacs-lsp-booster" orig-result))
      orig-result)))
(advice-add 'lsp-resolve-final-command :around #'lsp-booster--advice-final-command)

(use-package dap-mode)

(add-hook 'c-ts-mode-hook
          (lambda ()
            (setq-default c-ts-mode-indent-style #'linux) ; A rough approximation of the LLVM style, `clang-format' can deal with it anyways
            (setq c-ts-mode-indent-offset 4)
            (lsp-deferred)))

(add-hook 'c++-ts-mode-hook
          (lambda ()
            (setq-default c++-ts-mode-indent-style #'linux)
            (setq c++-ts-mode-indent-offset 4)
            (lsp-deferred)))

(add-hook 'js-ts-mode-hook         #'lsp-deferred)
(add-hook 'typescript-ts-mode-hook #'lsp-deferred)

(use-package nix-ts-mode
  :if (eq system-type 'gnu/linux)
  :mode "\\.nix\\'"
  :hook (nix-ts-mode . lsp-deferred))

(use-package rust-mode
  :init (setq rust-mode-treesitter-derive t)
  :hook (rust-ts-mode . lsp-deferred))

(use-package tuareg
  :hook
  (tuareg-mode . (lambda()
                   (setq-local comment-style 'multi-line)
                   (setq-local comment-continue "   ")
                   (when (functionp 'prettify-symbols-mode)
                     (prettify-symbols-mode))
                   (lsp-deferred))))

(use-package haskell-ts-mode
  :mode "\\.hs\\'"
  :custom (haskell-ts-highlight-signature t)
  :hook
  (haskell-ts-mode . lsp-deferred)
  (haskell-ts-mode . prettify-symbols-mode))

(use-package zig-ts-mode
  :mode "\\.zig\\'"
  :hook (zig-ts-mode . lsp-deferred))

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :custom (markdown-fontify-code-blocks-natively t))

(add-hook 'asm-mode-hook #'lsp-deferred)

(use-package nasm-mode
  :mode "\\.nasm\\'"
  :hook (nasm-mode . lsp-deferred))

;; === MAGIT ===

(use-package transient)

(use-package magit
  :bind ("C-c v" . magit))
