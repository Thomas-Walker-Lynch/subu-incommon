;;   ;; The rest of your appearance settings...
;; )

;; (when t
;;   (setq ansi-color-names-vector
;;       ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
;;   (setq custom-enabled-themes '(wheatgrass deeper-blue))

;;   (custom-set-faces
;;     '(default ((t (:family "Noto Sans Mono" :foundry "GOOG" :slant normal :weight normal :height 98 :width normal))))
;;     '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 2.0)))))


;;--------------------------------------------------------------------------------
;; appearance 
(when t
  (setq ansi-color-names-vector
      ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
  
  (custom-set-faces
    '(default ((t (:family "Noto Sans Mono" :foundry "GOOG" :slant normal :weight normal :height 98 :width normal))))
    '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 2.0)))))

  (load-theme 'wheatgrass t)

  (setq inhibit-startup-screen t)

  (setq ring-bell-function 'ignore)
  (setq visible-bell nil)

  (setq column-number-mode t)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)

  )

;;--------------------------------------------------------------------------------
;; basic settings
(when t
  (setq-default indent-tabs-mode nil) ;; stop the 'tab' character pollution
  (put 'narrow-to-region 'disabled nil)
  (put 'downcase-region 'disabled nil)
  (put 'set-goal-column 'disabled nil)
  (put 'erase-buffer 'disabled nil)
  (put 'upcase-region 'disabled nil)
  (set-language-environment "UTF-8")
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode)
  (setq ispell-dictionary "en_US") 
  (setq fill-column 80) 
  )

;;--------------------------------------------------------------------------------
;; prevent repo pollution
;; (when t
;;   ;; so that lock files do not end up in the repo
;;   (setq create-lockfiles nil) 

;;   ;; use a backrevs dir rather than leaving ~file droppings everywhere
;;   (setq backup-directory-alist `(("." . "~/emacs_backrevs")))
;;   (setq backup-by-copying t)
;;   )

;;--------------------------------------------------------------------------------
;; prevent repo pollution (localize all backups/autosaves, incl. TRAMP)
(when t
  (setq create-lockfiles nil)  ;; avoid .# lock files anywhere (esp. remote)

  (let* ((backrevs (expand-file-name "~/emacs_backrevs/"))
         (autosave (expand-file-name "~/emacs_backrevs/auto-save/"))
         (tramp-as (expand-file-name "~/emacs_backrevs/tramp-auto-save/")))
    (dolist (d (list backrevs autosave tramp-as))
      (unless (file-directory-p d) (make-directory d t)))

    ;; Backups (~ files) go to backrevs, for both local and TRAMP
    (setq backup-by-copying t
          version-control t
          delete-old-versions t
          kept-new-versions 10
          kept-old-versions 2
          backup-directory-alist `(("." . ,backrevs))
          tramp-backup-directory-alist `(("." . ,backrevs)))

    ;; Autosaves (#…#) go to autosave dirs (TRAMP separate)
    (setq auto-save-default t
          auto-save-include-big-deletions t
          auto-save-file-name-transforms `((".*" ,autosave t))
          tramp-auto-save-directory tramp-as)))

    (setq backup-by-copying-when-linked t)


;;--------------------------------------------------------------------------------
;; tell emacs to write customizations stuff back into the users .emacs file
;; without this it will try to write them here, and fail
(when t
  (setq custom-file nil) ; using '.emacs' causes a 'ciruclar reference error' .. why? dunno.
  )

;;--------------------------------------------------------------------------------
;; dired
(when t
  (defun dired-open-shell ()
    "Open a shell in the directory associated with the current buffer."
    (interactive)
    (let* (
            (dir-dired (dired-current-directory))
            (buffer-shell-name (concat "shell-" (replace-regexp-in-string "/" "-" dir-dired) "*"))
            )
      (if dir-dired
        (progn
          (kill-buffer (current-buffer))
          (switch-to-buffer buffer-shell-name)
          (shell (current-buffer))
          (cd dir-dired)
          ))))

  (eval-after-load "dired"
    '(define-key dired-mode-map "1" 'dired-open-shell)
    )
  )

;;--------------------------------------------------------------------------------
;; emacs shell
(when t
  ;; get the pwd in shell mode from the prompt rather than guessing by
  ;; watching the commands typed .. yes! now shell variables and source
  ;; scripts will work
  ;;   in bashrc: export PS1='\n$(/usr/local/bin/Z)\u@\h§\w§\n> '
  ;;

  ;;  (setq dirtrack-list '("§\\(.*\\)§\n[>#] " 1))
  (setq dirtrack-list '("§\\([^§]*\\)§" 1))

  (add-hook 'shell-mode-hook
            (lambda ()
              (shell-dirtrack-mode -1)
              (dirtrack-mode 1)
              (comint-send-input) ;; send an input at the shell start so it will boot the dir track
              ))

  (add-hook 'dirtrack-directory-change-hook
            (lambda ()
              (message default-directory)))

  )

