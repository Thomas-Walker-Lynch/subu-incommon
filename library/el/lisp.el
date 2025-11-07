;;--------------------------------------------------------------------------------
;; get the name of the file being 'visited' by the buffer
;;
(when t
  (setq lisp-indent-offset 2)
  (setq inferior-lisp-program "sbcl")      

  (modify-syntax-entry ?\[ "(]" lisp-mode-syntax-table)
  (modify-syntax-entry ?\] ")[" lisp-mode-syntax-table)
  (modify-syntax-entry ?{ "(}" lisp-mode-syntax-table)
  (modify-syntax-entry ?} "){" lisp-mode-syntax-table)

  ;; get buffer filename -- emacs does not have a builtin function for this.
  (when t
    (defun filename-get ()
      "Gets the name of the file the current buffer is based on."
      (buffer-file-name (window-buffer (minibuffer-selected-window)))
      )

    (defun filename-insert ()
      "Inserts the name of the file the current buffer is based on."
      (interactive)
      (insert (filename-get))
      )

    (global-set-key (kbd "C-c f") 'filename-insert)

    (defun filename ()
      "Gets the name of the file the current buffer is based on."
      (interactive)
      (message (filename-get))
      )

    )
  )

;;--------------------------------------------------------------------------------
;; unfill a paragraph
;;

(defun unfill-paragraph ()
  "Transform a filled paragraph into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


;;--------------------------------------------------------------------------------
;; misc
;;

  (defun mode-line () "toggles the modeline on and off"
    (interactive) 
    (setq mode-line-format
      (if (equal mode-line-format nil)
	(default-value 'mode-line-format)) )
    (redraw-display))

  ;; use set set-frame-name
  ;;
  ;; (defun frame-title (s)
  ;;   "sets the frame title"
  ;;   (interactive "stitle: ")
  ;;   (setq frame-title-format s)
  ;;   )
 
