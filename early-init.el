;; Early Initialisation -*- lexical-binding: t -*-

(setq package-enable-at-startup nil
      inhibit-splash-screen t
      inhibit-startup-message t
      native-comp-async-report-warnings-errors 'silent
      byte-compile-warnings nil
      warning-minimum-level :error
      read-process-output-max (* 1024 1024))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; (add-to-list 'default-frame-alist '(foreground-color . "#FFFFFF"))
;; (add-to-list 'default-frame-alist '(background-color . "#000000"))

(set-language-environment "UTF-8")
;; Undoes `set-language-environment`'s changes
(setq default-input-method nil)
;; Windows uses UTF-16 for its clipboard, so setting UTF-8 in that case would
;; break things
(unless (eq system-type 'windows-nt)
  (setq selection-coding-system 'utf-8))
