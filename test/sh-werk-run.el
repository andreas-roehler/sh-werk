;;; run.el --- -*- lexical-binding: t; -*-

;; Copyright (C) 2016 Emacs User Group Berlin

;; Author: Emacs User Group Berlin <emacs-berlin@emacs-berlin.org>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(defun sh-werk-runs-this-script-p ()
  t)

(defun sh-werk-run-tests-main ()
  "Main entry point of the test runner."
  (let* ((load-prefer-newer t)
         (current-file (if load-in-progress load-file-name (buffer-file-name)))
         (current-dir (file-name-directory current-file))
         (source-directory (locate-dominating-file current-file "Cask"))
         (pkg-rel-dir (format ".cask/%s/elpa" emacs-version)))
    (setq package-user-dir (expand-file-name pkg-rel-dir source-directory))
    (package-initialize)

    (message "Running tests on Emacs %s, built at %s"
             emacs-version (format-time-string "%F" emacs-build-time))

    (let ((debug-on-error t)
          (tests (list
		  "sh-werk-ert-tests.el"
		  )))
      (load (expand-file-name "sh-werk" source-directory))

      (load (expand-file-name "sh-werk-setup-ert-tests" current-dir))

      (dolist (test-file tests)
        (load (expand-file-name test-file current-dir))))

    (let ((debug-on-error t)
          (ert-selector (pop argv)))
      (ert-run-tests-batch-and-exit (and "sh-werk-" ert-selector)))))

(when (and noninteractive (sh-werk-runs-this-script-p))
  (sh-werk-run-tests-main))

(provide 'run)
;;; run.el ends here
