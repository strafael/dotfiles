(setq user-full-name "Rafael Santos"
      user-mail-address "rafael.santos@electric.ai")

(setq confirm-kill-emacs nil)

(use-package doom-themes
  :ensure t
  :config
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-dracula t)

  (custom-set-faces!
    '(font-lock-comment-face :slant italic))) ; Show comments in italic
;; custom-set-faces must be used *after* the theme is loaded

(setq doom-font (font-spec :family "SauceCodePro Nerd Font Mono" :style 'Regular :size 15)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 15)
      doom-big-font (font-spec :family "DejaVuSansMono Nerd Font Mono" :size 24))

(setq display-line-numbers-type 'relative)
(map! :leader
      :desc "Truncate lines"
      "t t" #'toggle-truncate-lines)

(use-package lsp-mode
  :ensure t
  :config
  (use-package lsp-ui
    :ensure t
    :config
    (setq lsp-ui-doc-max-height 30
          lsp-ui-doc-max-width 150
          lsp-ui-doc-use-childframe t
          lsp-ui-doc-enable nil)))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.venv\\'"))
