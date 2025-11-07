;;================================================================================
;; ;;----------------------------------------
;; ;; key-chord
;; ;; Example of defining key chords
;; ;; Install and configure Key Chord Mode
;; (use-package key-chord
;;   :ensure t
;;   :config
;;   (key-chord-mode 1)
;;   (setq key-chord-two-keys-delay 0.1)

;;   (defun chord-from-bin (str bin)
;;     "Return characters in STR that correspond to ones in BIN."
;;     ;;ex: (chord-from-bin "abcdef" "101001") -> "acf"
;;     (let ((result ""))
;;       (dotimes (i (min (length str) (length bin)))
;;         (when (= (aref bin i) ?1)
;;           (setq result (concat result (string (aref str i))))))
;;       result))

;;   (defun make-chord-define (str)
;;     (lambda (bin f)
;;       (let (
;;              (chord (filter-by-binary str bin))
;;              )
;;         (key-chord-define-global chord f)
;;         )))

;;   ;; str must be 4 chars
;;   (defun chord-buffer (str)
;;     (setq define-chord (make-chord-define str))
;;     ;; 0000 -
;;     ;; 1000 -
;;     ;; 0100 -
;;     ;; 1100 2 
;;     (funcall define-chord "1100" 'save-buffer)
;;     ;; 0010 -
;;     ;; 1010 2  
;;     (funcall define-chord "1010" 'kill-buffer)
;;     ;; 0110 2
;;     (funcall define-chord "0110" 'rename-buffer)
;;     ;; 1110 3
;;     (funcall define-chord "1110" 'buffer-menu)
;;     ;; 0001 -
;;     ;; 1001 2 
;;     (funcall define-chord "1001" 'ace-window)
;;     ;; 0101 2
;;     (funcall define-chord "0101" 'list-buffers)
;;     ;; 1101 3
;;     (funcall define-chord "1101" 'diff-buffer-with-file)
;;     ;; 0011 2
;;     ;; 1011 3
;;     (funcall define-chord "1011" 'revert-buffer)
;;     ;; 0111 3
;;     ;; 1111 3
;;     (funcall define-chord "1111" 'keyboard-quit)
;;     )

;;     (chord-buffer "qwer")

;;   )


