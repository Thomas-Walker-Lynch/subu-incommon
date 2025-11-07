;;--------------------------------------------------------------------------------
;; gdb
;; use gud-gdb instead of gdb and we won't need this.
;; fix 'feature' of broken gdb where it takes control of an
;; emacs window, and locks the user out from switching from it
(when t
  (defun unlock-window ()
    "Turns off window dedication."
    (interactive)
    (set-window-dedicated-p (get-buffer-window (current-buffer)) nil)
    )
  )

;;--------------------------------------------------------------------------------
;; shell
;;
(when t
  (setq sh-basic-offset 2)
  )

;;--------------------------------------------------------------------------------
;; json
(when t
  (setq json-encoding-pretty-print t)
  (setq json-encoding-lisp-style-closings t)
  ;(setq json-encoding-lisp-style-closings nil)
  (defun wrap-comma ()
    "wrap end of line comma to first of next line"
    (interactive) 
    (while (re-search-forward "\\(.*\\), *\n\\( *\\)" nil t) (replace-match "\\1\n\\2,"))
    )
  )

;;--------------------------------------------------------------------------------
;; rust
;;
;; (require 'package)
;; (add-to-list 'package-archives
;;            '("melpa-stable" . "https://stable.melpa.org/packages/"))
;; (package-initialize)
;; (package-refresh-contents)
;;
;;;  (setq rust-indent-offset 2)
;;;  (require 'rust-mode)

;;--------------------------------------------------------------------------------
;; python
(when t
  (add-hook 'python-mode-hook '(lambda () (setq python-indent 2)))
  )

;;--------------------------------------------------------------------------------
;; Web page development
(when t
  ;(setq browse-url-browser-function 'browse-url-firefox)
  ;(setq browse-url-browser-function 'browse-url-chrome)
  ;(setq browse-url-browser-function 'browse-url-chromium)

(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program "firefox")

  (setq js-indent-level 2)
  (setq css-indent-offset 2)    
  (add-to-list 'auto-mode-alist '("\\.php\\'" . html-mode))
  )

;;--------------------------------------------------------------------------------
;; C
;;
(when t
  (setq c-basic-offset 2)
  (setq c-offsets-alist '((label . 2)))
  (add-hook 'c-mode-hook (lambda () (modify-syntax-entry ?· "_")))
  ; in customer variables '(c-offsets-alist (quote ((label . 2))))
  (add-to-list 'auto-mode-alist '("\\.isq\\'" . c-mode))
  )


;;--------------------------------------------------------------------------------
;; lisp
;;
  (setq-default lisp-indent-offset 2)    ; Set indentation for Lisp modes

;;--------------------------------------------------------------------------------
;; groovy
;;

  ;; Configure NeoTree
  (with-eval-after-load 'groovy-mode
    (setq groovy-indent-offset 2)
    )

  ;; Enable Groovy mode for files with `#!/usr/bin/env groovy` shebang
  (add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))
