;; do autoload stuff here
(package-initialize)
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(defvar rc/package-contents-refreshed nil)

(defun rc/package-refresh-contents-once ()
  (when (not rc/package-contents-refreshed)
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))

(defun rc/require-one-package (package)
  (when (not (package-installed-p package))
    (rc/package-refresh-contents-once)
    (package-install package)))

(defun rc/require (&rest packages)
  (dolist (package packages)
    (rc/require-one-package package)))

(defun rc/require-theme (theme)
  (let ((theme-package (->> theme
                            (symbol-name)
                            (funcall (-flip #'concat) "-theme")
                            (intern))))
    (rc/require theme-package)
    (load-theme theme t)))


(rc/require 'dash)
(require 'dash)
(rc/require 'dash-functional)
(require 'dash-functional)

(defun rc/get-default-font ()
  (cond
   ((eq system-type 'windows-nt) "Consolas-13")))
(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(rc/require 'ansi-color)

(rc/require 'ido)
(rc/require 'ido-completing-read+)
(rc/require 'smex)
(ido-mode t)
(ido-everywhere t)
(ido-ubiquitous-mode t)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x. p
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

(setq-default inhibit-splash-screen t
              make-backup-files nil
              tab-width 4
              indent-tabs-mode nil
              compilation-scroll-output t
              visible-bell (equal system-type 'windows-nt))

(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))
(setq split-width-threshold 9999)

(defun rc/duplicate-line ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(global-set-key (kbd "M-J") 'text-scale-decrease)
(global-set-key (kbd "M-K") 'text-scale-increase)

(global-set-key (kbd "M-c") 'rc/duplicate-line)
(global-set-key (kbd "C-c p") 'find-file-at-point)
(global-display-line-numbers-mode)
(setq next-line-add-newlines t)
(setq display-line-numbers-type 'relative)

(rc/require 'direnv 'editorconfig 'multiple-cursors)
(editorconfig-mode 1)
(electric-pair-mode)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-.") 'mc/mark-all-in-region)

(rc/require 'cl-lib 'magit)
(setq magit-auto-revert-mode nil)
(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")

;; stolen from: https://emacs.stackexchange.com/questions/24698/ansi-escape-sequences-in-compilation-mode
(rc/require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))
(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

(rc/require
 'nix-mode
 'yaml-pro
 )

(rc/require-theme 'gruber-darker)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruber-darker))
 '(custom-safe-themes
   '("e13beeb34b932f309fb2c360a04a460821ca99fe58f69e65557d6c1b10ba18c7" default))
 '(package-selected-packages
   '(paredit nix-mode direnv gruber-darker-theme magit multiple-cursors ido-completing-read+ editorconfig smex)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
