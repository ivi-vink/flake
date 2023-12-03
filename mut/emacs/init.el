;; do autoload stuff here
(package-initialize)
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(defun seq-keep (function sequence)
  "Apply FUNCTION to SEQUENCE and return the list of all the non-nil results."
  (delq nil (seq-map function sequence)))

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
   ((eq system-type 'windows-nt) "Consolas-13")
   (t "mono-13")))
(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(rc/require 'ansi-color)

(rc/require 'ido 'ido-completing-read+ 'smex 'corfu)
(ido-mode t)
(ido-everywhere t)
(ido-ubiquitous-mode t)
(global-corfu-mode)

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

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(setq completion-auto-select 'second-tab)
(setq completions-format 'one-column)
(setq completions-max-height 20)
(define-key completion-in-region-mode-map (kbd "M-p") #'minibuffer-previous-completion)
(define-key completion-in-region-mode-map (kbd "M-n") #'minibuffer-next-completion)
;; (rc/require 'consult 'vertico 'orderless)
;; (setq completion-in-region-function #'completion--)


(rc/require
 'nix-mode
 'go-mode
 'auctex
 'yaml-pro
 'rust-mode)


(require 'lsp-mode)
(add-hook 'rust-mode-hook #'lsp-deferred)
(add-hook 'go-mode-hook #'lsp-deferred)
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
(lsp-register-custom-settings
 '(("gopls.hints.assignVariableTypes" t t)
   ("gopls.hints.compositeLiteralFields" t t)
   ("gopls.hints.compositeLiteralTypes" t t)
   ("gopls.hints.constantValues" t t)
   ("gopls.hints.functionTypeParameters" t t)
   ("gopls.hints.parameterNames" t t)
   ("gopls.hints.rangeVariableTypes" t t)))

(rc/require-theme 'gruber-darker)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(gruber-darker))
 '(custom-safe-themes
   '("ba4ab079778624e2eadbdc5d9345e6ada531dc3febeb24d257e6d31d5ed02577" "a9dc7790550dcdb88a23d9f81cc0333490529a20e160a8599a6ceaf1104192b5" "5f128efd37c6a87cd4ad8e8b7f2afaba425425524a68133ac0efd87291d05874" "5b9a45080feaedc7820894ebbfe4f8251e13b66654ac4394cb416fef9fdca789" "9013233028d9798f901e5e8efb31841c24c12444d3b6e92580080505d56fd392" "6adeb971e4d5fe32bee0d5b1302bc0dfd70d4b42bad61e1c346599a6dc9569b5" "8d3ef5ff6273f2a552152c7febc40eabca26bae05bd12bc85062e2dc224cde9a" "75b2a02e1e0313742f548d43003fcdc45106553af7283fb5fad74359e07fe0e2" "b9761a2e568bee658e0ff723dd620d844172943eb5ec4053e2b199c59e0bcc22" "9d29a302302cce971d988eb51bd17c1d2be6cd68305710446f658958c0640f68" "f053f92735d6d238461da8512b9c071a5ce3b9d972501f7a5e6682a90bf29725" "dc8285f7f4d86c0aebf1ea4b448842a6868553eded6f71d1de52f3dcbc960039" "38c0c668d8ac3841cb9608522ca116067177c92feeabc6f002a27249976d7434" "162201cf5b5899938cfaec99c8cb35a2f1bf0775fc9ccbf5e63130a1ea217213" "ff24d14f5f7d355f47d53fd016565ed128bf3af30eb7ce8cae307ee4fe7f3fd0" "da75eceab6bea9298e04ce5b4b07349f8c02da305734f7c0c8c6af7b5eaa9738" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "631c52620e2953e744f2b56d102eae503017047fb43d65ce028e88ef5846ea3b" "88f7ee5594021c60a4a6a1c275614103de8c1435d6d08cc58882f920e0cec65e" "dfb1c8b5bfa040b042b4ef660d0aab48ef2e89ee719a1f24a4629a0c5ed769e8" "e13beeb34b932f309fb2c360a04a460821ca99fe58f69e65557d6c1b10ba18c7" default))
 '(package-selected-packages
   '(doom-themes corfu yaml-pro smex rust-mode nix-mode multiple-cursors magit lsp-ui ido-completing-read+ gruber-darker-theme go-mode editorconfig direnv dash-functional auctex)))
(custom-set-faces)
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.

