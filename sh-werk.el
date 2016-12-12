;;; sh-werk.el --- Something for C-M-a, C-M-e, M-a and M-e in shell-script-mode -*- lexical-binding: t; -*- 

;; Copyright (C) 2015  Andreas Röhler

;; Author: Andreas Röhler <andreas.roehler@easy-emacs.de>

;; Keywords: languages

;; This file is free software; you can redistribute it
;; and/or modify it under the terms of the GNU General
;; Public License as published by the Free Software
;; Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the
;; implied warranty of MERCHANTABILITY or FITNESS FOR A
;; PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.

;; You should have received a copy of the GNU General
;; Public License along with GNU Emacs; see the file
;; COPYING.  If not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;; Major changes to previous version:
;; use beginning-of-defun, set beginning-of-defun-function

;;; Commentary:

;; M-p, M-n: jump to the beginning or end of a
;; top-level-form

;; C-M-a, C-M-e: jump to the beginning or end of a
;; function in sh-mode - "Shell-script"-mode.

;; M-a, M-e: jump to the beginning or end of statement in
;; a given line, forward or backward next beginning or
;; end.  With argument do this as many times.

;;; Code:

(require 'ar-subr)
(require 'ar-navigate)

(require 'sh-script)
;; (require 'shw-alias)

(defgroup sh-werk nil
  "Navigate blocks in shell-script"
  :group 'languages
  :prefix "shw-")



(defvar shw-function-re "[[:alpha:]_]+\(\) *{\\|function +[[:alpha:]_]+ {"
  "Matches the start of a function in shell. ")
(setq shw-function-re "[[:alpha:]_]+() *{\\|function +[[:alpha:]_]+ *{")

(defcustom shw-function-re "[[:alpha:]_]+() *{\\|function +[[:alpha:]_]+ ()+{"
  "Matches the start of a function in shell. "
  :type 'regexp
  :tag "shw-function-re"
  :group 'sh-werk)

(defconst shw-beginning-sh-struct-atpt
  (concat
   "[ \t]*\\_<\\("
   (mapconcat 'identity
              (list
               "case"
               "for"
               "if"
               "select"
	       shw-function-re
               "until"
               "while"
               )
              "\\|"
              )
              "\\)\\_>[ \t]*"))

(defconst shw-clause-re
  (concat
   "[ \t]*\\_<\\("
   (mapconcat 'identity
              (list
               "elif"
               "else"
               )
              "\\|"
              )
              "\\)\\_>[ \t]+"))

;; (defcustom shw-beginning-sh-struct-atpt "\\bcase\\b\\|\\bfor\\b\\|\\bfunction\\b\\|\\bif\\b\\|\\bselect\\b\\|\\buntil\\b\\|\\bwhile\\b"
;;   "Specify the sh-struct beginning."
;;   :type 'regexp
;;   :group 'sh-werk)

(defvar ar-end-sh-struct-atpt "\\bdone\\b\\|\\besac\\b\\|\\bfi\\b\\|\n}\\|;}"
  "Detect the end of a maybe nested shell programming construct")

(setq ar-end-sh-struct-atpt "\\bdone\\b\\|\\besac\\b\\|\\bfi\\b\\|\n}\\|;}")
(setq sh-match-paren-char "%")

(setq shw-beginning-of-function-regexp "^[A-Za-z_][A-Za-z_0-9]* *() *{")

(defcustom shw-beginning-of-function-regexp "^[A-Za-z_][A-Za-z_0-9]* *() *{"
  "Regexp indicating the beginning of a function to edit."
  :type 'regexp
  :group 'sh-werk)

(defcustom shw-hs-minor-mode-p nil
 "If hide-show mode should be non-nil. Default is nil. "

:type 'boolean
:group 'sh-werk)

(defcustom shw-end-of-function-regexp "^}[ \t]*$\\|;}[ \t]*$"
  "Regexp indicating the end of a function to edit."
  :type 'regexp
  :group 'sh-werk)

(defcustom shw-verbose-p nil
  "If functions should report results.

Default is nil. "

  :type 'boolean
  :group 'sh-werk)

(setq shw-verbose-p t)

(add-hook 'sh-werk-mode-hook '(lambda () (set (make-local-variable 'beginning-of-defun-function) 'shw-backward-function)))

(add-hook 'sh-werk-mode-hook '(lambda () (set (make-local-variable 'end-of-defun-function) 'shw-end-of-function)))

(defvar shw-string-delim-re "\\(\"\\|'\\)"
  "When looking at beginning of string. ")

(defconst shw-indent-offset 4)
(defconst shw-no-outdent-re
  (concat
   "[ \t]*\\_<\\("
   (mapconcat 'identity
              (list
               "while"
               "for"
               "if"
               "elif"
               "else"
               )
              "\\|"
              )
   "\\)\\_>[( \t]+.*:[( \t]\\_<\\("
   (mapconcat 'identity
              (list
               "break"
               "continue"
               "pass"
               )
              "\\|"
              )
              "\\)\\_>[ )\t]*$")
  "Regular expression matching lines not to augment indent after.")

(defconst shw-assignment-re "\\_<\\w+\\_>[ \t]*\\(=\\|+=\\|*=\\|%=\\|&=\\|^=\\|<<=\\|-=\\|/=\\|**=\\||=\\|>>=\\|//=\\)"
  "If looking at the beginning of an assignment. ")

(defun shw-mark-function ()
  " "
  (interactive)
  (shw-backward-form)
  (push-mark (point) t t)
  (shw-forward-form)
  (kill-new (buffer-substring-no-properties (mark) (point))))

(defun shw-kill-function ()
  " "
  (interactive)
  (shw-backward-form)
  (pushw-mark (point) t t)
  (shw-forward-form)
  (kill-region (mark) (point)))

(defun shw-backward-block ()
  "Goto opening of a programming structure at current level. "
  (interactive)
  (unless (bobp)
    (let ((orig (point))
	  (cui (current-indentation)))
      (back-to-indentation)
      (unless (and (< (point) orig)(looking-at shw-beginning-sh-struct-atpt))
	(while (and
		(not (bobp))
		(progn (ar-backward-line)(< cui (current-indentation)))))
	(unless (or (and (eq 0 (current-column)) (not (looking-at ar-end-sh-struct-atpt)))(looking-at shw-beginning-sh-struct-atpt))
	  (shw-backward-block))))))

(defun shw--end-of-block-downward ()
  (while (and (re-search-forward shw-beginning-sh-struct-atpt nil 'move 1)(or (nth 8 (parse-partial-sexp (point-min) (point)))(back-to-indentation))))
  (when (looking-at shw-beginning-sh-struct-atpt)
    (setq erg (end-of-form-base shw-beginning-sh-struct-atpt ar-end-sh-struct-atpt nil t))))

(defun neu-shw-forward-block ()
  (interactive)
  (ar-forward-block))  

(defun shw-forward-block (&optional orig)
  "Goto closing of a programming structure at ARG's level.

With optional ARG that many times. "
  (interactive)
  (unless (eobp)
    (let ((orig (or orig (point)))
	  (pps (parse-partial-sexp (point-min) (point)))
	  (cui (current-indentation))
	  erg done)
      (message "%s" (current-buffer) )
      (message "%s" (point) )
      (cond ((and
	       ;; (looking-at shw-beginning-sh-struct-atpt)
		  (not (ar-in-string-p)) (not (ar-in-comment-p)))
	     (end-of-form-base shw-beginning-sh-struct-atpt ar-end-sh-struct-atpt nil t)
	     (unless (< orig (point))
	       (goto-char orig)
	       (while (and (not (eobp)) (ar-forward-line) (not (looking-at ar-end-sh-struct-atpt))))))
	    ((progn (shw-backward-block)(looking-at shw-beginning-sh-struct-atpt))
	     (end-of-form-base shw-beginning-sh-struct-atpt ar-end-sh-struct-atpt nil t)
	     (unless (< orig (point))
	       (shw--end-of-block-downward)))
	    (t (goto-char orig)
	       (shw--end-of-block-downward)))
      (when (< orig (point))
	(setq erg (point))
	(when (and shw-verbose-p (interactive-p)) (message "%s" erg))
	erg))))

(defun shw-backward-function (&optional arg)
  "Goto opening of a functions definition.

With optional ARG that many times. "
  (interactive "p")
  (let ((counter (or arg 1)))
    (while (< 0 counter)
      (beginning-of-form-base sh-beginning-of-function-regexp)
      (setq counter (1- counter)))))

(defun shw-forward-function (&optional arg)
  "Goto end of a functions definition.

With optional ARG that many times.
"
  (interactive "p")
  (let ((counter (or arg 1)))
    (while (< 0 counter)
      (end-of-form-base nil shw-end-of-function-regexp)
      (setq counter (1- counter)))))

(defvar shw-match-paren-key-char "%")

(defun shw-match-paren ()
  "Go to the matching opening/closing.
First to opening, unless cursor is already there. "
  (interactive)
  (if (looking-at shw-beginning-sh-struct-atpt)
      (shw-forward-block)
    (shw-backward-block)))

(defalias 'shw-backward-statement 'ar-backward-statement)
(defalias 'shw-forward-statement 'ar-forward-statement)

;; (defun shw-backward-statement (&optional orig done)
;;   "Go to the initial line of a simple statement.

;; For beginning of compound statement use sh-beginning-of-block.
;; For beginning of clause sh-beginning-of-clause.

;; Referring python program structures see for example:
;; http://docs.python.org/reference/compound_stmts.html
;; "
;;   (interactive)
;;   (let ((orig (or orig (point)))
;;         (cui (current-indentation))
;;         (pps (syntax-ppss))
;;         (done done)
;;         erg in-function)
;;     (unless (bobp)
;;       (cond
;;        ((empty-line-p)
;;         (skip-chars-backward " \t\r\n\f")
;;         (shw-backward-statement orig done))
;;        ;; in comment
;;        ((nth 4 pps)
;;         (sh-beginning-of-comment pps)
;;         (shw-backward-statement orig done))
;;        ((and (looking-at "[ \t]*#")(looking-back "^[ \t]*"))
;;         (skip-chars-backward " \t\r\n\f")
;;         (shw-backward-statement orig done))
;;        ((looking-at "[ \t]*#")
;;         (skip-chars-backward (concat "^" comment-start) (line-beginning-position))
;;         (back-to-indentation)
;;         (unless (bobp)
;;           (shw-backward-statement orig done)))
;;        ((nth 8 pps)
;;         (and (nth 3 pps) (setq done t))
;;         (goto-char (nth 8 pps))
;;         (shw-backward-statement orig done))
;;        ;; in list
;;        ((and (nth 1 pps) (or (< 1 (nth 0 pps))
;;                              ;; discard list making up body of function
;;                              (not (save-excursion (goto-char (nth 1 pps))(and (looking-at "{")(setq in-function (point)))))))
;;         (goto-char (nth 1 pps))
;;         (setq done t)
;;         (shw-backward-statement orig done))
;;        ((ar--preceding-line-backslashed-p)
;;         (forward-line -1)
;;         (back-to-indentation)
;;         (setq done t)
;;         (shw-backward-statement orig done))
;;        ((looking-at ar-string-delim-re)
;;         (unless done
;;           (when (< 0 (abs (skip-chars-backward " \t\r\n\f")))
;;             (setq done t))
;;           (back-to-indentation)
;;           (shw-backward-statement orig done)))
;;        ((and (not (eq (point) orig))(looking-back "^[ \t]*"))
;;         (setq erg (point)))
;;        ((and (not done) (not (eq 0 (skip-chars-backward " \t\r\n\f"))))
;;         ;; (setq done t)
;;         (shw-backward-statement orig done))
;;        ((not (eq (current-column) (current-indentation)))
;;         (if (< 0 (abs (skip-chars-backward "^\t\r\n\f")))
;;             (progn
;;               (setq done t)
;;               (back-to-indentation)
;;               (shw-backward-statement orig done))
;;           (back-to-indentation)
;;           (setq done t)
;;           (shw-backward-statement orig done))))
;;       ;; no valid result if looking at space, tab,
;;       ;; newline or comment
;;       (unless (member (char-after) '(32 9 10 35))
;;         (when (< (point) orig)(setq erg (point))))
;;       (when (and ar-verbose-p (interactive-p)) (message "%s" erg))
;;       erg)))

;; (defun shw-forward-statement (&optional orig done origline)
;;   "Go to the last char of current statement.

;; To go just beyond the final line of the current statement, use `sh-down-statement-bol'. "
;;   (interactive)
;;   (unless (eobp)
;;     (let ((pps (syntax-ppss))
;;           (origline (or origline (sh-count-lines)))
;;           (orig (or orig (point)))
;;           erg this
;;           ;; use by scan-lists
;;           parse-sexp-ignore-comments
;;           forward-sexp-function
;;           stringchar stm)
;;       (cond
;;        ;; in string
;;        ((and (nth 8 pps)(nth 3 pps))
;;         (goto-char (nth 8 pps))
;;         (unless (looking-back "^[ \t]*")
;;           (setq stm t))
;;         (when (looking-at "'")
;;           (sh-eos-handle-singlequoted-string-start this))
;;         (when (looking-at "\"")
;;           (sh-eos-handle-doublequoted-string-start this))
;;         (when stm (setq done t))
;;         (setq stm nil)
;;         (unless (nth 3 (syntax-ppss))
;;           (shw-forward-statement orig done origline)))
;;        ((looking-at "'")
;;         (sh-eos-handle-singlequoted-string-start this)
;;         ;; string not terminated
;;         (unless (nth 3 (syntax-ppss))
;;           (shw-forward-statement orig done origline)))
;;        ((looking-at "\"")
;;         (sh-eos-handle-doublequoted-string-start this)
;;         ;; string not terminated
;;         (unless (nth 3 (syntax-ppss))
;;           (shw-forward-statement orig done origline)))
;;        ((looking-at sh-string-delim-re)
;;         (sh-eos-handle-string-start this)
;;         (shw-forward-statement orig done origline))
;;        ;; in comment
;;        ((nth 4 pps)
;;         (unless (eobp)
;;           (skip-chars-forward (concat "^" comment-start) (line-end-position))
;;           (forward-comment 99999)
;;           (sh-handle-eol)
;;           (shw-forward-statement orig done origline)))
;;        ((and (not done)(looking-at "[ \t]*#"))
;;         (sh-eos-handle-comment-start)
;;         (shw-forward-statement orig done origline))
;;        ;; in list
;;        ((and (not done)(nth 1 pps))
;;         (when (< orig (point))
;;           (setq orig (point)))
;;         (goto-char (nth 1 pps))
;;         (let ((parse-sexp-ignore-comments t))
;;           (if (and
;;                ;; do not pass function definitions
;;                (not (looking-at "{"))
;;                (ignore-errors (forward-list)))
;;               (progn
;;                 (when (looking-at ":[ \t]*$")
;;                   (forward-char 1))
;;                 (setq done t)
;;                 (skip-chars-forward (concat "^" comment-start) (line-end-position))
;;                 (skip-chars-backward " \t\r\n\f" (line-beginning-position))
;;                 (shw-forward-statement orig done origline))
;;             (goto-char orig)
;;             (while (sh-current-line-backslashed-p)
;;               (forward-line 1))
;;             (if (looking-at "[ \t]*$")
;;                 (progn
;;                   (forward-line 1)
;;                   (shw-forward-statement orig done origline))
;;               (end-of-line)
;;               (if (nth 8 (syntax-ppss))
;;                   (shw-forward-statement orig done origline)
;;                 (setq done t)
;;                 (sh-handle-eol))))))
;;        ((sh-current-line-backslashed-p)
;;         (end-of-line)
;;         (skip-chars-backward " \t\r\n\f" (line-beginning-position))
;;         (while (and (eq (char-before (point)) ?\\ )
;;                     (sh-escaped))
;;           (forward-line 1)
;;           (end-of-line)
;;           (skip-chars-backward " \t\r\n\f" (line-beginning-position)))
;;         (unless (eobp)
;;           (shw-forward-statement orig done origline)))

;;        ((and (looking-at sh-no-outdent-re)(not (nth 8 pps)))
;;         (end-of-line)
;;         (sh-handle-eol))
;;        ((and (looking-at "[[:alpha:][:alnum:]_]+") (member (match-string-no-properties 0) (sh-feature sh-leading-keywords)))
;;         (goto-char (match-end 0)))
;;        ((and (eq (point) orig) (< (current-column) (current-indentation)))
;;         (back-to-indentation)
;;         (shw-forward-statement orig done origline))
;;        ((and (not done)
;;              (or (eq (current-column) (current-indentation))
;;                  (eq origline (sh-count-lines)))
;;              (< 0 (abs (skip-chars-forward "^#"  (line-end-position)))))
;;         (sh-handle-eol)
;;         ;; with trailing whitespaces at orig
;;         (if (and (< orig (point)) (not (progn (setq pps (syntax-ppss))(or (nth 8 pps)(and (not (looking-back "{")) (nth 1 pps))))))
;;             (setq done t)
;;           (if (or (nth 8 pps)(nth 1 pps))
;;               (shw-forward-statement orig done origline)
;;             (forward-line 1)
;;             (sh-handle-eol)))
;;         (shw-forward-statement orig done origline))
;;        ((and (not done)
;;              (or (eq (current-column) (current-indentation))
;;                  (eq origline (sh-count-lines)))
;;              (< 0 (skip-chars-forward " \t\r\n\f")))
;;         (when (looking-at "[ \t]*#")
;;           (sh-eos-handle-comment-start))
;;         (shw-forward-statement orig done origline))
;;        ((and (not done) (eq (point) orig)(looking-at ";"))
;;         (skip-chars-forward ";" (line-end-position))
;;         (when (< 0 (skip-chars-forward (concat "^" comment-start) (line-end-position)))
;;           (sh-beginning-of-comment)
;;           (skip-chars-backward " \t\r\n\f")
;;           (setq done t))
;;         (shw-forward-statement orig done origline))
;;        ((bolp)
;;         (end-of-line)
;;         (sh-beginning-of-comment)
;;         (skip-chars-backward " \t\r\n\f")
;;         (setq done t)
;;         (shw-forward-statement orig done origline))
;;        ((and (not (ignore-errors (eq (point) done)))(looking-back sh-string-delim-re) (progn (goto-char (match-beginning 0))(and (nth 8 (syntax-ppss))(nth 3 (syntax-ppss)))))
;;         (end-of-line)
;;         (sh-beginning-of-comment)
;;         (skip-chars-backward " \t\r\n\f")
;;         (setq done (point))
;;         (shw-forward-statement orig done origline))
;;        ((and done (eq (current-column) (current-indentation)))
;;         (skip-chars-forward (concat "^" comment-start) (line-end-position))
;;         (skip-chars-backward " \t\r\n\f")
;;         (sh-beginning-of-comment)
;;         (skip-chars-backward " \t\r\n\f" (line-beginning-position))
;;         (setq done t)
;;         (shw-forward-statement orig done origline)))
;;       (unless
;;           (or
;;            (eq (point) orig)
;;            (empty-line-p))
;;         (setq erg (point)))
;;       (when (and ar-verbose-p (interactive-p)) (message "%s" erg))
;;       erg)))

(defvar sh-werk-mode-map nil
    "Keymap used in Sh-Werkstatt mode.")
(setq sh-werk-mode-map
      ;; (let ((map (make-sparse-keymap)))
    (let ((map sh-mode-map))
      ;; (define-key map "\M-a" 'shw-backward-block)
    ;; (define-key map "\M-e" 'shw-forward-block)
    ;; (define-key map "\M-p" 'shw-backward-form)
    ;; (define-key map "\M-n" 'shw-forward-form)
    ;; (define-key map "\C-p" 'shw-backward-statement)
    ;; (define-key map "\C-n" 'shw-forward-statement)
    (and (ignore-errors (require 'easymenu) t)
         (easy-menu-define
           shw-menu map "Werk Mode menu"
           `("Sh-Werk"
             ;; ("Move"
              ["Sh beginning of statement" shw-backward-statement
               :help " `shw-backward-statement'

Go to the initial line of a simple statement. "]

              ["Sh end of statement" shw-forward-statement
               :help " `shw-forward-statement'

Go to the last char of current statement. "]

              ["Sh beginning of form" shw-backward-block
               :help " `shw-backward-block'
Goto opening of a programming structure at ARG's level. " ]

              ["Sh end of form" shw-forward-block
               :help " `shw-forward-block'
Goto closing of a programming structure at ARG's level. "]

              )))

    map))

;; (define-derived-mode sh-werk sh-mode "Sh-Werk"
(define-derived-mode sh-werk sh-mode "shW"
  ;; (kill-all-local-variables)
  ;; (setq major-mode 'sh-werk
        ;; mode-name "Sh-Werkstatt")
  (use-local-map sh-werk-mode-map)
  (and shw-hs-minor-mode-p
       (add-hook 'sh-werk-mode-hook 'hs-minor-mode))
  ;; (when shw-menu
    ;; (easy-menu-add shw-menu)
    )

(setq ar-block-re shw-beginning-sh-struct-atpt)
(setq ar-clause-re shw-clause-re)

(add-to-list 'auto-mode-alist '("\\.sh\\'" . sh-werk))


(provide 'sh-werk)
;;; sh-werk.el ends here
