(map! :leader
      :desc "Dired"
      "d d" #'dired
      :leader
      :desc "Dired jump to current"
      "d j" #'dired-jump
      (:after dired
        (:map dired-mode-map
         :leader
         :desc "Peep-dired image previews"
         "d p" #'peep-dired
         :leader
         :desc "Dired view file"
         "d v" #'dired-view-file)))
;; Make 'h' and 'l' go back and forward in dired. Much faster to navigate the directory structure!
(evil-define-key 'normal dired-mode-map
  (kbd "h") 'dired-up-directory
  (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
;; If peep-dired is enabled, you will get image previews as you go up/down with 'j' and 'k'
(evil-define-key 'normal peep-dired-mode-map
  (kbd "j") 'peep-dired-next-file
  (kbd "k") 'peep-dired-prev-file)
(add-hook 'peep-dired-hook 'evil-normalize-keymaps)
;; Get file icons in dired
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
;; With dired-open plugin, you can launch external programs for certain extensions
;; For example, I set all .png files to open in 'sxiv' and all .mp4 files to open in 'mpv'
(setq dired-open-extensions '(("gif" . "sxiv")
                              ("jpg" . "sxiv")
                              ("png" . "sxiv")
                              ("mkv" . "mpv")
                              ("mp4" . "mpv")))

(setq doom-theme 'doom-dracula)

;; (setq doom-font (font-spec :family "DejaVu Sans Mono" :size 16)
(setq doom-font (font-spec :family "SauceCodePro Nerd Font Mono" :size 16 :style 'Medium)
      doom-variable-pitch-font (font-spec :family "Ubuntu" :size 15)
      doom-big-font (font-spec :family "DejaVu Sans Mono" :size 24))

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

;; Show comments in italic
(custom-set-faces!
  '(font-lock-comment-face :slant italic))

(setq display-line-numbers-type 'relative)
(map! :leader
      :desc "Truncate lines"
      "t t" #'toggle-truncate-lines)

(require 'mu4e)
(require 'org-mu4e)
(require 'org-mime)
(require 'mu4e-contrib)

(setq mu4e-html2text-command 'mu4e-shr2text)
(setq shr-color-visible-luminance-min 60)
(setq shr-color-visible-distance-min 5)
(setq shr-use-colors nil)
(advice-add #'shr-colorize-region :around (defun shr-no-colourise-region (&rest ignore)))

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")

(setq mu4e-maildir (expand-file-name "~/Maildir"))

;; get mail
(setq mu4e-get-mail-command "mbsync -c ~/.config/mu4e/mbsyncrc -a"
      mu4e-view-prefer-html t
      mu4e-update-interval 300
      mu4e-index-update-in-background t
      mu4e-headers-auto-update t
      mu4e-compose-signature-auto-include nil
      mu4e-compose-format-flowed t
      mu4e-view-use-gnus nil
      mu4e-headers-time-format "%H:%M")

;; to view selected message in the browser, no signin, just html mail
(add-to-list 'mu4e-view-actions
             '("ViewInBrowser" . mu4e-action-view-in-browser) t)

;; enable inline images
(setq mu4e-view-show-images t)
;; use imagemagick, if available
(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))

;; every new email composition gets its own frame!
(setq mu4e-compose-in-new-frame t)

;; don't save message to Sent Messages, IMAP takes care of this
(setq mu4e-sent-messages-behavior 'delete)

(add-hook 'mu4e-view-mode-hook #'visual-line-mode)

;; <tab> to navigate to links, <RET> to open them in browser
(add-hook 'mu4e-view-mode-hook
          (lambda()
            ;; try to emulate some of the eww key-bindings
            (local-set-key (kbd "<RET>") 'mu4e~view-browse-url-from-binding)
            (local-set-key (kbd "<tab>") 'shr-next-link)
            (local-set-key (kbd "<backtab>") 'shr-previous-link)))

(add-hook 'mu4e-headers-mode-hook
          (defun my/mu4e-change-headers ()

            ;; from https://www.reddit.com/r/emacs/comments/bfsck6/mu4e_for_dummies/elgoumx
            (add-hook 'mu4e-headers-mode-hook
                      (defun my/mu4e-change-headers ()
                        (interactive)
                        (setq mu4e-headers-fields
                              `((:human-date . 25) ;; alternatively, use :date
                                (:flags . 6)
                                (:from . 22)
                                (:thread-subject . ,(- (window-body-width) 70)) ;; alternatively, use :subject
                                (:size . 7)))))))

;; spell check
(add-hook 'mu4e-compose-mode-hook
          (defun my-do-compose-stuff ()
            "My settings for message composition."
            (visual-line-mode)
            (org-mu4e-compose-org-mode)
            (use-hard-newlines -1)
            (flyspell-mode)))

(require 'smtpmail)
;;rename files when moving
;;NEEDED FOR MBSYNC
(setq mu4e-change-filenames-when-moving t)

;;set up queue for offline email
;;use mu mkdir  ~/Maildir/acc/queue to set up first
(setq smtpmail-queue-mail nil)  ;; start in normal mode

;;from the info manual
(setq mu4e-attachment-dir  "~/Downloads")

(setq message-kill-buffer-on-exit t)
(setq mu4e-compose-dont-reply-to-self t)

(require 'org-mu4e)

;; convert org mode to HTML automatically
(setq org-mu4e-convert-to-html t)

;;from vxlabs config
;; show full addresses in view message (instead of just names)
;; toggle per name with M-RET
(setq mu4e-view-show-addresses 't)

;; don't ask when quitting
(setq mu4e-confirm-quit nil)

;; start with the first (default) context;
(setq mu4e-context-policy 'pick-first)

;; compose with the current context is no context matches;
;; default is to ask
(setq mu4e-compose-context-policy nil)

;; Disable “HTML over plain text” heuristic.
(setq mu4e-view-html-plaintext-ratio-heuristic most-positive-fixnum)

(setq mu4e-contexts
      (list
       (make-mu4e-context
        :name "rafael-ar"
        :enter-func (lambda () (mu4e-message "Entering context rafael@aurearobotics.com"))
        :leave-func (lambda () (mu4e-message "Leaving context rafael@aurearobotics.com"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:from :to :cc :bcc) "rafael@aurearobotics.com")))
        :vars '((user-mail-address . "rafael@aurearobotics.com")
                (user-full-name . "Rafael Santos")
                (mu4e-sent-folder . "/rafael-aurearobotics/Sent Mail")
                (mu4e-drafts-folder . "/rafael-aurearobotics/drafts")
                (mu4e-trash-folder . "/rafael-aurearobotics/Trash")
                (mu4e-compose-signature . (concat
                                           "Rafael Santos\n"
                                           "Cel: (21) 968.585.115\n"
                                           "Aurea Robotics\n"
                                           "Rua do Passeio 38, Setor 2, 15º andar | Centro | Rio de Janeiro | RJ | 20021-290"))
                (mu4e-compose-format-flowed . t)
                (smtpmail-queue-dir . "~/Maildir/rafael-aurearobotics/queue/cur")
                (message-send-mail-function . smtpmail-send-it)
                (smtpmail-smtp-user . "rafael@aurearobotics.com")
                (smtpmail-starttls-credentials . (("smtp.zoho.com" 587 nil nil)))
                (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (smtpmail-default-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-service . 587)
                (smtpmail-debug-info . t)
                (smtpmail-debug-verbose . t)
                (mu4e-maildir-shortcuts . ( ("/rafael-aurearobotics/INBOX"      . ?i)
                                            ("/rafael-aurearobotics/Sent Mail"  . ?s)
                                            ("/rafael-aurearobotics/Trash"      . ?t)
                                            ("/rafael-aurearobotics/All Mail"   . ?a)
                                            ("/rafael-aurearobotics/Starred"    . ?r)
                                            ("/rafael-aurearobotics/drafts"     . ?d)
                                            ))))
       (make-mu4e-context
        :name "suporte-ar"
        :enter-func (lambda () (mu4e-message "Entering context suporte@aurearobotics.com"))
        :leave-func (lambda () (mu4e-message "Leaving context suporte@aurearobotics.com"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:from :to :cc :bcc) "suporte@aurearobotics.com")))
        :vars '((user-mail-address . "suporte@aurearobotics.com")
                (user-full-name . "Suporte")
                (mu4e-sent-folder . "/suporte-aurearobotics/Sent Mail")
                (mu4e-drafts-folder . "/suporte-aurearobotics/drafts")
                (mu4e-trash-folder . "/suporte-aurearobotics/Trash")
                (mu4e-compose-signature . (concat
                                           "Suporte\n"
                                           "Aurea Robotics\n"
                                           "Rua do Passeio 38, Setor 2, 15º andar | Centro | Rio de Janeiro | RJ | 20021-290"))
                (mu4e-compose-format-flowed . t)
                (smtpmail-queue-dir . "~/Maildir/suporte-aurearobotics/queue/cur")
                (message-send-mail-function . smtpmail-send-it)
                (smtpmail-smtp-user . "suporte@aurearobotics.com")
                (smtpmail-starttls-credentials . (("smtp.zoho.com" 587 nil nil)))
                (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (smtpmail-default-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-service . 587)
                (smtpmail-debug-info . t)
                (smtpmail-debug-verbose . t)
                (mu4e-maildir-shortcuts . ( ("/suporte-aurearobotics/INBOX" . ?i)
                                            ("/suporte-aurearobotics/Sent Mail" . ?s)
                                            ("/suporte-aurearobotics/Trash"     . ?t)
                                            ("/suporte-aurearobotics/All Mail"  . ?a)
                                            ("/suporte-aurearobotics/Starred"   . ?r)
                                            ("/suporte-aurearobotics/drafts"    . ?d)
                                            ))))
       (make-mu4e-context
        :name "contato-ar"
        :enter-func (lambda () (mu4e-message "Entering context contato@aurearobotics.com"))
        :leave-func (lambda () (mu4e-message "Leaving context contato@aurearobotics.com"))
        :match-func (lambda (msg)
                      (when msg
                        (mu4e-message-contact-field-matches
                         msg '(:from :to :cc :bcc) "contato@aurearobotics.com")))
        :vars '((user-mail-address . "contato@aurearobotics.com")
                (user-full-name . "Contato")
                (mu4e-sent-folder . "/contato-aurearobotics/Sent Mail")
                (mu4e-drafts-folder . "/contato-aurearobotics/drafts")
                (mu4e-trash-folder . "/contato-aurearobotics/Trash")
                (mu4e-compose-signature . (concat
                                           "Rafael Santos\n"
                                           "Cel: (21) 968.585.115\n"
                                           "Aurea Robotics\n"
                                           "Rua do Passeio 38, Setor 2, 15º andar | Centro | Rio de Janeiro | RJ | 20021-290"))
                (mu4e-compose-format-flowed . t)
                (smtpmail-queue-dir . "~/Maildir/contato-aurearobotics/queue/cur")
                (message-send-mail-function . smtpmail-send-it)
                (smtpmail-smtp-user . "contato@aurearobotics.com")
                (smtpmail-starttls-credentials . (("smtp.zoho.com" 587 nil nil)))
                (smtpmail-auth-credentials . (expand-file-name "~/.authinfo.gpg"))
                (smtpmail-default-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-server . "smtp.zoho.com")
                (smtpmail-smtp-service . 587)
                (smtpmail-debug-info . t)
                (smtpmail-debug-verbose . t)
                (mu4e-maildir-shortcuts . ( ("/contato-aurearobotics/INBOX"      . ?i)
                                            ("/contato-aurearobotics/Sent Mail"  . ?s)
                                            ("/contato-aurearobotics/Trash"      . ?t)
                                            ("/contato-aurearobotics/All Mail"   . ?a)
                                            ("/contato-aurearobotics/Starred"    . ?r)
                                            ("/contato-aurearobotics/drafts"     . ?d)
                                            ))))))

(after! neotree
  (setq neo-window-fixed-size nil))

(map! :leader
      :desc "Edit agenda file"
      "a" #'(lambda () (interactive) (find-file "~/org/todo.org")))

(setq shell-file-name "/bin/bash"
      eshell-aliases-file "~/.doom.d/aliases"
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "htop" "ssh" "zsh")
      vterm-max-scrollback 5000)

(after! org
  (setq org-agenda-files '("~/org/"
                           "~/org/aurearobotics"
                           "~/org/aurearobotics/firjan"
                           "~/org/aurearobotics/brunel")))

(after! org
    (define-key org-mode-map (kbd "C-c [") nil)
    (define-key org-mode-map (kbd "C-c ]") nil))

(after! org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@/!)" "|" "DONE(d)" "CANCELLED(c@/!)" "PHONE" "MEETING"))))
        ;; Antes de mudar as cores, dar um describe nesta variavel e só entao adaptar a partir dela
        ;; org-todo-keyword-faces
        ;; '(("TODO" :foreground "red" :weight bold)
        ;;    ("NEXT" :foreground "blue" :weight bold)
        ;;    ("DONE" :foreground "forest green" :weight bold)
        ;;    ("WAITING" :foreground "orange" :weight bold)
        ;;    ("HOLD" :foreground "magenta" :weight bold)
        ;;    ("CANCELLED" :foreground "forest green" :weight bold)
        ;;    ("MEETING" :foreground "forest green" :weight bold)
        ;;    ("PHONE" :foreground "forest green" :weight bold))))

(setq org-use-fast-todo-selection t)

(setq org-treat-S-cursor-todo-selection-as-state-change nil)

(after! org
  (setq org-directory "~/org"
        org-default-notes-file "~/org/inbox.org"
        +org-capture-todo-file "~/org/inbox.org"
        +org-capture-journal-file "~/org/journal.org"))

;; I use C-c c to start capture mode
(global-set-key (kbd "C-c c") 'org-capture)

(after! org
  (setq org-capture-templates
        '(("t" "Todo" entry (file +org-capture-todo-file)
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
          ("r" "Responder Email" entry (file +org-capture-todo-file)
               "* NEXT Respond %:from on %:subject\nSCHEDULED: %t\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n" :immediate-finish t)
          ("n" "Note" entry (file org-default-notes-file)
               "* %? :NOTE:\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n" :clock-in t :clock-resume t)
          ("j" "Journal" entry (file+olp-datetree +org-capture-journal-file)
               "* %U %?\n" :clock-in t :clock-resume t)
          ("w" "org-protocol" entry (file +org-capture-todo-file)
               "* TODO Review %c\n:CREATED: %U\n:END:\n" :immediate-finish t)
          ("m" "Meeting" entry (file +org-capture-notes-file)
               "* MEETING with %?\n:CREATED: %U\n:END:\n" :clock-in t :clock-resume t)
          ("p" "Phone call" entry (file +org-capture-notes-file)
               "* PHONE call with %?\n:CREATED: %U\n:END:\n" :clock-in t :clock-resume t))))

; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(after! org
  (setq org-refile-targets '((nil :maxlevel . 9) (org-agenda-files :maxlevel . 9))
        ; Use full outline paths for refile targets - we file directly with IDO
        org-refile-use-outline-path t
        ; Targets complete directly with IDO
        org-outline-path-complete-in-steps nil
        ; Allow refile to create parent tasks with confirmation
        org-refile-allow-creating-parent-nodes (quote confirm)))

; Exclude DONE state tasks from refile targets
(defun sr/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(after! org
  (setq org-refile-target-verify-function 'sr/verify-refile-target))

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

;; Custom agenda command definitions
(setq org-agenda-custom-commands
      '(("N" "Notes" tags "NOTE"
         ((org-agenda-overriding-header "Notes")
          (org-tags-match-list-sublevels t)))
        ("h" "Habits" tags-todo "STYLE=\"habit\""
         ((org-agenda-overriding-header "Habits")
          (org-agenda-sorting-strategy
           '(todo-state-down effort-up category-keep))))
        (" " "Agenda"
         ((agenda "" nil)
          (tags "REFILE"
                ((org-agenda-overriding-header "Tasks to Refile")
                 (org-tags-match-list-sublevels nil))))
         nil)))

(after! org
  (require 'org-bullets)
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-ellipsis " ▼ "
        org-log-done 'time
        org-hide-emphasis-markers t
        calendar-week-start-day 1
        ))
