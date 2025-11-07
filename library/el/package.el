;; Package setup
(when t
  (setq byte-compile-warnings '(cl-functions))

  ;; Ensure package archives are set up
  (require 'package)
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                            ("gnu" . "https://elpa.gnu.org/packages/")))
  (package-initialize)

  (defun update-packages ()
    "Interactively update all packages from package-archives."
    (interactive)
    (when (y-or-n-p "Do you want to refresh package contents and update missing packages?")
      (message "Refreshing package contents...")
      (package-refresh-contents)
;      (ensure-package-installed '(neotree groovy-mode ace-window adaptive-wrap))
      (ensure-package-installed 'neotree)
      (ensure-package-installed 'groovy-mode)
      (ensure-package-installed 'ace-window)
      (ensure-package-installed 'adaptive-wrap)
      (message "Package updates complete!")))

  ;; Notify on startup
  (add-hook 'emacs-startup-hook
    (lambda ()
      (message "To update packages, run M-x update-packages.")))

  (defun maybe-refresh-packages ()
    "Prompt user to refresh package contents if desired."
    (when (y-or-n-p "Refresh package contents? ")
      (package-refresh-contents)))

  (defun ensure-package-installed (pkg)
    "Ensure the given PKG is installed. Prompt to refresh packages if necessary."
    (unless (package-installed-p pkg)
      (maybe-refresh-packages)
      (unless (package-installed-p pkg)
        (package-install pkg))))


  ;; Configure NeoTree
  (with-eval-after-load 'neotree
    (setq neo-window-fixed-size nil)
    (setq neo-smart-open t)
    (setq neo-window-width 45))

  (global-set-key [f8] 'neotree-toggle)

  ;; Custom NeoTree sorting
  (defadvice neo-buffer--get-nodes
    (after neo-buffer--get-nodes-new-sorter activate)
    (setq ad-return-value
          (let ((nodes ad-return-value)
                (comparator (lambda (s1 s2) (string< (downcase (reverse-file-extension s1))
                                              (downcase (reverse-file-extension s2))))))
            (apply 'cons (mapcar (lambda (x) (sort (apply x (list nodes))
                                              comparator))
                                 '(car cdr))))))

  (defun reverse-file-extension (filename) filename)
  ;; Original categorizes by filename extension
  ;; (defun reverse-file-extension (filename)
  ;;   (mapconcat 'identity (reverse (split-string filename "\\.")) "."))

  ;; Ace Window Manager configuration
  (when (package-installed-p 'ace-window)
    (require 'ace-window)
    (global-set-key (kbd "C-x o") 'ace-window))

  ;; adaptive-wrap line mode
  (if
    (package-installed-p 'adaptive-wrap)
    (progn
      (require 'adaptive-wrap)
      (setq-default visual-line-mode-desired-column 80)
      (global-visual-line-mode 1)
      (add-hook 'visual-line-mode-hook #'adaptive-wrap-prefix-mode)
      )
    (progn
      (set-default 'truncate-lines t) ;; truncate rather than wrapping lines (use horizontal scroll to see to the right)
      (setq truncate-partial-width-windows nil)
      (setq-default fill-column 80)
      (setq fill-column 80)
      ))
)
