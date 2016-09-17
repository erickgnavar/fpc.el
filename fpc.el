;;; fpc.el --- Find python class

;; Copyright © 2016 Erick Navarro

;; Author: Erick Navarro <erick@navarro.io>
;;; Commentary:
;; Find python class by name and show the results using Helm

;;; Code:

(require 'f)
(require 'helm)
(require 'projectile)

(defconst fpc--db "fpc.csv")
(defconst fpc--ast-analyzer-path (concat (file-name-directory load-file-name) "ast_analyzer.py"))

(defun fpc--read-db ()
  "Read generated db."
  (let ((data (f-read-text (concat (projectile-project-root) fpc--db))))
    (split-string data "\n")))

(defun fpc--build-db ()
  "Build db file using AST analyzer."
  (if (projectile-project-p)
      (shell-command (format "python %s %s" fpc--ast-analyzer-path (projectile-project-root)))
    (message "Could not find the project root.")))

(defun fpc--open-file-class (candidate)
  "Open buffer with selected file as CANDIDATE."
  (let ((path (car (split-string candidate ";")))
        (line (car (cdr (split-string candidate ";")))))
    (find-file-existing path)
    (forward-line (string-to-number line))))

(defun pfc--transformer (candidate)
  "Format candidate as CANDIDATE."
  (let ((splited (split-string candidate ";")))
    (let ((name (car (last splited)))
          (path (f-relative (car splited) (projectile-project-root))))
      (format "%s:%s" name (replace-regexp-in-string ".py" "" (replace-regexp-in-string "/" "." path))))))

(defun fpc--python-class-names-source ()
  "Python class source."
  (helm-build-sync-source "class names"
    :candidates (lambda ()
                  (fpc--read-db))
    :real-to-display 'pfc--transformer
    :action '(("Show this buffer `C-c'" . fpc--open-file-class))))

(defun fpc-rebuild-db ()
  "Rebuild python classes db."
  (interactive)
  (fpc--build-db))

(defun fpc-find-class ()
  "Find python classes by name."
  (interactive)
  (let ((filepath (concat (projectile-project-root) fpc--db)))
    (progn
      (if (not (f-exists? filepath))
          (fpc--build-db))
      (if (f-exists? filepath)
          (helm :sources (fpc--python-class-names-source)
                :buffer "*helm for search python class*")))))

(provide 'fpc)

;;; fpc.el ends here
