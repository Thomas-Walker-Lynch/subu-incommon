;;--------------------------------------------------------------------------------     
;; Tramp
;;
;;;https://www.gnu.org/software/emacs/manual/html_node/tramp/Frequently-Asked-Questions.html
;;


;; remote shells with Tramp always come up in sh, not bash.  
;; This tries to convince tramp to use bash.
(when t

  ;; this does nothing in fact
  (with-eval-after-load 'tramp
    ;; Use bash for remote commands, and treat them as login (-l) so profile/rc files run.
    (setq tramp-remote-shell "/bin/bash")
    (setq tramp-remote-shell-args '("-lc")))  ;; login + run command

  ;; this should force all shells to be bash
  (defun shell-make (dir buffer-name)
    (let* ((default-directory dir)
           (buffer (get-buffer-create buffer-name)))
      (with-current-buffer buffer
        ;; Force bash for this shell buffer (remote or local)
        (setq-local explicit-shell-file-name "/bin/bash")
        (setq-local shell-file-name "/bin/bash")
        ;; Login shell; interactive because comint allocates a pty
        (setq-local explicit-bash-args '("-l"))
        ;; Avoid echoed input in TRAMP shells
        (setq-local comint-process-echoes t))
      (shell buffer)))

  ;; maybe this would do it
  (with-eval-after-load 'tramp
    (connection-local-set-profile-variables
     'rt/remote-bash
     '((explicit-shell-file-name . "/bin/bash")
       (shell-file-name . "/bin/bash")
       (explicit-bash-args . ("-l"))
       (comint-process-echoes . t)))

    ;; Apply to all SSH TRAMP connections
    (connection-local-set-profiles '(:application tramp :protocol "ssh") 'rt/remote-bash))

)

(when t

  ;; trap wants to write to /tmp, but when logged in as root it causes failures and pop up new frames with warnings
  ;;
  ;; --> this is causing it to leave emacs droppings all over:
  ;; (add-to-list 'backup-directory-alist (cons tramp-file-name-regexp nil))

  (setq tramp-completion-reread-directory-timeout nil)

  (defun shell-make (dir buffer-name)
    (let* (
           (default-directory dir)
           (buffer (get-buffer-create buffer-name))
           )
      (set-buffer buffer)
      (shell buffer)
      ))

  (defun shell~       () (interactive) (shell-make "~" "shell~"))
  (defun shell-root   () (interactive) (shell-make "/sudo::/root" "shell-root"))

  (defun shell-rt-Thomas () (interactive) (shell-make "/ssh:rt-Thomas:~" "shell-rt"))
  (defun shell-rt-root   () (interactive) (shell-make "/ssh:rt-root:~"   "shell-rt-root"))

  (defun shell-x6-Thomas () (interactive) (shell-make "/ssh:x6-Thomas:~" "shell-x6-Thomas"))
  (defun shell-x6-root   () (interactive) (shell-make "/ssh:x6-root:~"   "shell-x6-root"))


;;  (defun shell-rt     () (interactive) (shell-make "/ssh:thomas_lynch@reasoningtechnology.com:~" "shell-rt"))
;;  (defun shell-rt-root() (interactive) (shell-make "/ssh:root@reasoningtechnology.com:~" "shell-rt-root"))

  ;;(defun shell-rt-root() (interactive) (shell-make "/ssh:thomas_lynch@reasoningtechnology.com|sudo:reasoningtechnology.com:" "shell-rt-root"))
  ;;(defun shell-rt-root() (interactive) (shell-make "/ssh:reasoningtechnology-root:~" "shell-rt-root"))
  ;;(defun shell-rt-root() (interactive) (shell-make "/ssh:root@35.194.71.194:~" "shell-rt-root"))


  (defun shell-LFS      () (interactive) (shell-make "/ssh:lfs@192.168.122.115:~" "shell-LFS"))
  (defun shell-LFS-root () (interactive) (shell-make "/ssh:root@192.168.122.115:~" "shell-LFS-root"))

  (defun shell-Shihju () (interactive) (shell-make "/sudo:Shihju@localhost:/home/Shihju" "shell-Shihju"))
  (defun shell-Wendell () (interactive) (shell-make "/ssh:Morpheus@Wendell:~" "shell-Wendell"))
  (defun shell-Wendell-root () (interactive) (shell-make "/ssh:Morpheus@Wendell|sudo:Wendell:" "shell-Wendell-root"))
  (defun shell-Wendell-Shihju () (interactive) (shell-make "/ssh:Morpheus@Wendell|sudo:Shihju@Wendell:" "shell-Wendell-Shihju"))

  (defun shell-Pi 
    () 
    (interactive) 
    (shell-make "/ssh:piuser@Pi:~" "shell-Pi")
    )

  (defun shell-Pi-root
    () 
    (interactive) 
    (shell-make 
      "/ssh:piuser@Pi|sudo:root@Pi:" 
      "shell-Pi-root"
      ))



  (defun dired-rt ()
    (interactive)
    (dired "/ssh:thomas_lynch@reasoningtechnology.com:")
    )

  (defun dired-rt-root ()
    (interactive)
    (dired "/ssh:thomas_lynch@reasoningtechnology.com|sudo:reasoningtechnology.com:")
    )

)
