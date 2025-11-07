;; I abandoned this approach due to the many vagaries of assigning keys in
;; Emacs. The mappings are not orthogonal, and carry a heavy burden to legacy
;; terminal compatibility.  I will instead attempt to define a custom keyboard
;; layout with chords and macros, and re-assign the keys from that layer.
;;

;;  the sake of sanity...
;;
(global-set-key (kbd "C-z") nil) ;; turn off the poison C-z key.  Use C-x C-z or the command suspend-emacs
(global-set-key (kbd "C-v") nil) ;; tempting to put paste (yank) for a common typo, but at least lets not jump down the page
;; would be nice to clear C-c but minor modes redefine it

;;--------------------------------------------------------------------------------
(when t ; key-matrix minor mode

  (defadvice add-to-ordered-list (around key-matrix-add-to-ordered-list-advice activate)
    "Ensure that `key-matrix-mode` always has precedence."
    (if (eq (ad-get-arg 0) 'minor-mode-map-alist)
        (let (
               (key-matrix-mode-pair (assoc 'key-matrix-mode minor-mode-map-alist))
               )
          (when key-matrix-mode-pair
            (setq minor-mode-map-alist (delq key-matrix-mode-pair minor-mode-map-alist))
            (setq minor-mode-map-alist (cons key-matrix-mode-pair minor-mode-map-alist))))
      ad-do-it))

  (defun key-matrix-make-minor-mode (mode-name)
    "Make a custom minor mode with MODE-NAME."
    (let* (
            (mode-symbol (intern (concat mode-name "-mode")))
            (lighter (concat " " mode-name))
            (keymap (make-sparse-keymap))
            )
      (eval `(define-minor-mode ,mode-symbol
               ,(concat "A minor mode for " mode-name " key bindings.")
               :init-value t
               :lighter ,lighter
               :keymap ',keymap))
      (eval `(,mode-symbol 1))
      mode-symbol))
)

;;--------------------------------------------------------------------------------
(when t ; key-matrix support functions

  (defun key-matrix-dimensions (matrix)
    "Return the dimensions of MATRIX as a list of two positive integers [rows, columns]."
    (let ((rows (length matrix))
          (cols (if matrix (length (car matrix)) 0)))
      (list rows cols)))

  (defun key-matrix-access (matrix row col)
    "Return the value at the given coordinates (ROW, COL) from the provided MATRIX."
    (if (and (>= row 0) (< row (length matrix))
             (>= col 0) (< col (length (nth row matrix))))
        (nth col (nth row matrix))
      (error "Coordinates out of range")))

  (defun key-matrix-make-wrapper-matrix (wrapper-function button-matrix filter-list)
  "Return a matrix of lambdas that call 'wrapper-function' with BUTTON-MATRIX and coordinates, filtered by FILTER-LIST."
  (let* ((dimensions (key-matrix-dimensions button-matrix))
         (rows (car dimensions))
         (cols (cadr dimensions))
         (wrapper-matrix (make-vector rows nil)))
    (message "key-matrix-make-wrapper-matrix dimensions: %d %d" rows cols)
    (dotimes (i rows)
      (aset wrapper-matrix i (make-vector cols nil))
      (dotimes (j cols)
        (let ((button-function (key-matrix-access button-matrix i j)))
          (when (or (not filter-list) (member button-function filter-list))
            (aset (aref wrapper-matrix i) j
                  `(lambda ()
                     (interactive)
                     (message "Calling wrapper-function %s with button-function %s"
                              ',wrapper-function ',button-function)
                     (,wrapper-function ',button-function)))))))
    wrapper-matrix))

  ;; (defun key-matrix-make-wrapper-matrix (wrapper-function button-matrix filter-list)
  ;;   "Return a matrix of lambdas that call 'wrapper-function' with BUTTON-MATRIX and coordinates, filtered by FILTER-LIST."
  ;;   (let* ((dimensions (key-matrix-dimensions button-matrix))
  ;;          (rows (car dimensions))
  ;;          (cols (cadr dimensions))
  ;;          (wrapper-matrix (make-vector rows nil)))
  ;;     (dotimes (i rows)
  ;;       (aset wrapper-matrix i (make-vector cols nil))
  ;;       (dotimes (j cols)
  ;;         (let ((button-function (key-matrix-access button-matrix i j)))
  ;;           (when (or (not filter-list) (member button-function filter-list))
  ;;             (aset (aref wrapper-matrix i) j
  ;;                   `(lambda ()
  ;;                      (interactive)
  ;;                      (,wrapper-function ,button-function)))))))
  ;;     wrapper-matrix))

  (defun key-matrix-get-minor-mode-keymap (mode-symbol)
    "Get the keymap of the minor mode specified by MODE-SYMBOL."
    (cdr (assoc mode-symbol minor-mode-map-alist)))

  (defun key-matrix-bind (keymap button-matrix function-matrix &optional modifiers)
  "Bind keys based on BUTTON-MATRIX and FUNCTION-MATRIX with optional MODIFIERS, string such as \"C-\" for Control, \"M-\" for Meta, etc.
KEYMAP specifies the keymap to use for these bindings."
  (let ((rows (length button-matrix))
        (cols (if button-matrix (length (car button-matrix)) 0)))
    (dotimes (i rows)
      (dotimes (j cols)
        (let ((button (nth j (nth i button-matrix)))
              (function (nth j (nth i function-matrix))))
          (when function
            (let ((key-binding
                   (if (and (string= button "m") (string= modifiers "C-"))
                       (kbd "<f13>")
                     (kbd (concat (or modifiers "") (if (stringp button) button (symbol-name button)))))))
              (when t ; Change to nil to disable debugging
                (message "Binding key %s to function %s in keymap %s"
                         (key-description key-binding)
                         function
                         keymap))
              (define-key keymap key-binding function))))))))


)

;;--------------------------------------------------------------------------------
(when t ; places emacs functions into categories
  (defun key-matrix-get-function-categories-alist ()
    "Return an associative list of function category lists."
    (list
     (cons 'navigation-function
           '( forward-char backward-char forward-word backward-word
              beginning-of-line end-of-line next-line previous-line
              beginning-of-buffer end-of-buffer forward-sentence backward-sentence
              forward-paragraph backward-paragraph forward-page backward-page
              forward-list backward-list beginning-of-defun end-of-defun ))
     (cons 'search-function
           '( isearch-backward isearch-backward-regexp isearch-forward
              isearch-forward-regexp re-search-backward re-search-forward
              search-backward search-forward word-search-backward
              word-search-forward query-replace replace-string ))
     (cons 'edit-function
           '( backward-kill-word capitalize-word comment-region
              delete-backward-char delete-char downcase-region downcase-word
              fill-paragraph indent-region join-line kill-line kill-region
              kill-whole-line kill-word transpose-chars transpose-lines
              transpose-words uncomment-region undo undo-tree-redo upcase-region
              upcase-word yank ))
     (cons 'buffer-function
           '( switch-to-buffer kill-buffer save-buffer revert-buffer list-buffers
              next-buffer previous-buffer rename-buffer clone-indirect-buffer ))
     (cons 'file-function
           '( find-file write-file save-some-buffers delete-file copy-file
              rename-file set-visited-file-name ))
     (cons 'window-function
           '( split-window-right split-window-below delete-window
              delete-other-windows other-window previous-window select-window
              enlarge-window shrink-window enlarge-window-horizontally
              shrink-window-horizontally save-window-excursion
              window-configuration-to-register jump-to-register balance-windows
              balance-windows-area windmove-right windmove-left windmove-up
              windmove-down toggle-frame-fullscreen maximize-window minimize-window
              ))
     (cons 'frame-functions
           '( make-frame-command delete-frame other-frame toggle-frame-fullscreen
              frame-configuration-to-register jump-to-register
              ))
     ))

  (when nil
    (let ((categories (key-matrix-get-function-categories-alist)))
      (dolist (category categories)
        (set (car category) (cdr category))))

    (message "Navigation Functions: %S" navigation-function)
    (message "Search Functions: %S" search-function)
    (message "Edit Functions: %S" edit-function)
    (message "Buffer Functions: %S" buffer-function)
    (message "File Functions: %S" file-function)
    (message "Window Functions: %S" window-function)
    (message "Frame Functions: %S" frame-functions)
    )
  )

;;--------------------------------------------------------------------------------
(when t ; these functions can also be bound to keys

  (defun deactivate-mark-command ()
    "Deactivate the mark."
    (interactive)
    (deactivate-mark))

  (defun toggle-picture-mode ()
    "Toggle between picture mode and the current mode."
    (interactive)
    (if (derived-mode-p 'picture-mode)
        (picture-mode-exit)
      (picture-mode)))

  (defun switch-to-previous-buffer ()
    "Switch to the previous buffer."
    (interactive)
    (switch-to-buffer (other-buffer (current-buffer) 1)))

  (defun switch-to-next-buffer ()
    "Switch to the next buffer."
    (interactive)
    (bury-buffer)
    (switch-to-buffer (other-buffer (current-buffer) 1)))

  (defun start-scope ()
    "Move to the start of the current scope or paragraph."
    (interactive)
    (if (derived-mode-p 'prog-mode)
        (progn
          (condition-case nil
              (backward-up-list)
            (error (beginning-of-defun))))
      (scroll-up-command)))

  (defun end-scope ()
    "Move to the start of the current scope or paragraph."
    (interactive)
    (if (derived-mode-p 'prog-mode)
        (progn
          (condition-case nil
              (backward-down-list)
            (error (beginning-of-defun))))
      (scroll-up-command)))

  (defun delete-region-using-navigation (navigation-function)
    "Set the mark, call the NAVIGATION-FUNCTION, then delete the resulting region."
    (interactive)
    (if navigation-function
        (progn
          (save-excursion
            (let ((region (region-active-p)))
              (unless region
                (set-mark-command nil))
              (call-interactively navigation-function)
              (kill-region (mark) (point))
              (when region
                (activate-mark)))))
      (message "No function defined at the specified coordinates.")))
)

;;--------------------------------------------------------------------------------
(when t ; button matrices
  (defun key-matrix-get-button-matrices-alist ()
    "Return an associative list of button matrices."
    (list
     (cons 'button-matrix-keypad
           '(
             ("kp-add"        "kp-subtract" "<f13>")  ; from numlock: xmodmap -e "keycode 77 = F13"
             ("kp-home"       "kp-up"      "kp-prior")
             ("kp-left"       "kp-begin"   "kp-right")
             ("kp-end"        "kp-down"    "kp-next")
             ("kp-insert"     "kp-delete"  "kp-enter")
             ))
     (cons 'button-matrix-qwerty-right
           '(
             ("7" "8" "9" "0")
             ("u" "i" "o" "p")
             ("j" "k" "l" ";")
             ("m" "," "." "/")
             ))
     (cons 'button-matrix-workman-right
           '(
             ("7" "8" "9" "0")
             ("y" "u" "o" "i")
             ("n" "e" "a" ";")
             ("k" "," "." "/")
             ))))

  (when nil
    (let ((button-matrices (key-matrix-get-button-matrices-alist)))
      (dolist (matrix button-matrices)
        (set (car matrix) (cdr matrix))))

    (message "Keypad Button Matrix: %S" button-matrix-keypad)
    (message "QWERTY Right Button Matrix: %S" button-matrix-qwerty-right)
    (message "Workman Right Button Matrix: %S" button-matrix-workman-right)
    )
)

;;--------------------------------------------------------------------------------
(when t ; function matrices

  (defun key-matrix-get-function-matrices-alist ()
    "Return an associative list of function matrices."
    (let* ((categories (key-matrix-get-function-categories-alist))
           (navigation-function (cdr (assoc 'navigation-function categories)))
           (function-matrix-navigation
            '(
              (keyboard-quit       set-mark-command  exchange-point-and-mark    nil)
              (backward-word       forward-word      start-scope                end-scope)
              (backward-char       forward-char      previous-line              next-line)
              (beginning-of-line   end-of-line       beginning-of-buffer        end-of-buffer)
              )))
      (list
       (cons 'function-matrix-keypad-default
             '(
               ('+                   '-              num-lock)     
               (beginning-of-buffer previous-line  scroll-down)  
               (backward-char       recenter       forward-char) 
               (end-of-buffer       next-line      scroll-up)    
               (nil                 delete-char    newline)      
               ))
       (cons 'function-matrix-navigation function-matrix-navigation)
       (cons 'function-matrix-navigation-deletion
             (key-matrix-make-wrapper-matrix 'delete-region-using-navigation function-matrix-navigation navigation-function))
       (cons 'function-matrix-edit
             '(
               (comment-region  uncomment-region upcase-region  downcase-region)
               (indent-region   fill-paragraph   nil              nil)
               (copy-region     cut-region       paste-region    delete-region)
               (undo            redo             nil              nil)
               ))
       (cons 'function-matrix-search
             '(
               (nil               nil                   nil                   nil)
               (query-replace    replace-string       replace-regexp       nil)
               (isearch-forward  isearch-forward-regexp search-forward    re-search-forward)
               (isearch-backward isearch-backward-regexp search-backward  re-search-backward)
               ))
       (cons 'function-matrix-buffer-file
             '(
               (nil nil nil nil)
               (save-buffer         rename-buffer   kill-buffer      revert-buffer)
               (next-buffer         previous-buffer switch-to-buffer list-buffers)
               (find-file           write-file      nil nil)
               ))
       (cons 'function-matrix-window
             '(
               (toggle-frame-fullscreen  other-frame  make-frame-command  delete-frame)
               (nil nil nil nil)
               (ace-window            aw-delete-window      delete-other-windows   balance-windows)
               (split-window-right    split-window-below     nil                   nil)
               )))))

  (when nil
    (let (
          (function-matrices (key-matrix-get-function-matrices-alist))
          )
      (dolist (matrix function-matrices)
        (set (car matrix) (cdr matrix))))

    (message "Keypad Default Function Matrix: %S" function-matrix-keypad-default)
    (message "Navigation Function Matrix: %S" function-matrix-navigation)
    (message "Navigation Deletion Function Matrix: %S" function-matrix-navigation-deletion)
    (message "Edit Function Matrix: %S" function-matrix-edit)
    (message "Search Function Matrix: %S" function-matrix-search)
    (message "Buffer File Function Matrix: %S" function-matrix-buffer-file)
    (message "Window Function Matrix: %S" function-matrix-window)
    )
)

;;--------------------------------------------------------------------------------
(when t ; does the key binding

  (defun key-matrix-main (mode-name)
    "Bind keys based on matrices and ensure they are set in a custom minor mode."

    ;; Translate C-m to F13 using key codes
    (define-key input-decode-map (kbd "C-m") (kbd "<f13>"))

    (let (
          (button-matrices (key-matrix-get-button-matrices-alist))
          (function-matrices (key-matrix-get-function-matrices-alist))
          (mode-symbol (key-matrix-make-minor-mode mode-name))
          )
      (let (
            (keymap (key-matrix-get-minor-mode-keymap mode-symbol))
            (button-matrix-qwerty-right (cdr (assoc 'button-matrix-qwerty-right button-matrices)))
            (navigation (cdr (assoc 'function-matrix-navigation function-matrices)))
            (deletion   (cdr (assoc 'function-matrix-deletion function-matrices)))
            (edit       (cdr (assoc 'function-matrix-edit     function-matrices)))
            (search     (cdr (assoc 'function-matrix-search   function-matrices)))
            (file       (cdr (assoc 'function-matrix-file     function-matrices)))
            (window     (cdr (assoc 'function-matrix-window   function-matrices)))
            )
        ;;(message "QWERTY Right Button Matrix: %S" button-matrix-qwerty-right)
        ;;(message "Keymap for %s: %s" mode-name keymap)
        ;; Bind keys from the matrix
        (key-matrix-bind keymap button-matrix-qwerty-right navigation "C-")
        (key-matrix-bind keymap button-matrix-qwerty-right deletion   "S-A-")
        (key-matrix-bind keymap button-matrix-qwerty-right edit       "A-")
        (key-matrix-bind keymap button-matrix-qwerty-right search     "S-C-")
        (key-matrix-bind keymap button-matrix-qwerty-right file       "S-C-A-")
        (key-matrix-bind keymap button-matrix-qwerty-right window     "C-A-")
        )))

  (defun key-matrix-disable-mode (mode-name)
    "Disable the specified custom minor mode."
    (let ((mode-symbol (intern (concat mode-name "-mode"))))
      ;; Deactivate the minor mode
      (when (boundp mode-symbol) (funcall mode-symbol 0))
      ;; Reset keyboard translation
      (define-key input-decode-map (kbd "C-m") (kbd "RET"))
      (message "Matrix key mode %s disabled." mode-name)))

  )

  ;; Call key-matrix-main
  ;; (key-matrix-main "RT-keys")

  ;; Example call to disable the custom key mode
  ; (key-matrix-disable-mode "RT-keys")

;; 1. navigation
;; 2. deletion
;; 3. edit
;; 4. search
;; 5. file
;; 6. window 


;; Shift Control Alt Window (super)
;; supper is currently the compose key, so avoiding it.
;; SCAW
;; 0000 x
;; 1000 x
;; 0100 navigation
;; 1100 search
;; 0010 edit
;; 1010 deletion
;; 0110 window
;; 1110 file
;; 0001
;; 1001
;; 0101
;; 1101
;; 0011
;; 1011
;; 0111
;; 1111
