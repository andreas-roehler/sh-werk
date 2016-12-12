;;; sh-werk-setup-ert-tests.el --- Provide needed forms

;; Copyright (C) 2015  Andreas Röhler

;; Author: Andreas Röhler <andreas.roehler@easy-emacs.de>

;; Keywords: lisp

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

;;; Code:

(setq shw-install-directory default-directory)
(sit-for 0.1 t)

;; (require 'python-mode)

(defvar shw-debug-p nil
  "Avoid error")

(defvar shw-verbose-p t)

(defmacro shw-test-with-temp-buffer (contents &rest body)
  "Create temp buffer inserting CONTENTS.
BODY is code to be executed within the temp buffer.  Point is
 at the end of buffer."
  (declare (indent 2) (debug t))
  `(with-temp-buffer
     (let (hs-minor-mode)
       (insert ,contents)
       (shell-script-mode)
       (when shw-verbose-p
	 (switch-to-buffer (current-buffer))
	 (font-lock-fontify-buffer))

       ;; (message "ERT %s" (point))
       ,@body)))

(defmacro shw-test-with-temp-buffer-point-min (contents &rest body)
  "Create temp buffer inserting CONTENTS.
BODY is code to be executed within the temp buffer.  Point is
 at the end of buffer."
  (declare (indent 2) (debug t))
  `(with-temp-buffer
     (let (hs-minor-mode)
       (insert ,contents)
       (shell-script-mode)
       (goto-char (point-min))
       (when shw-verbose-p
	 (switch-to-buffer (current-buffer))
	 (font-lock-fontify-buffer))
       ;; (message "ERT %s" (point))
       ,@body)))

(defvar shw-test-string1 "
#!/bin/bash
 # --

function virtualenvwrapper_derive_workon_home {
    typeset workon_home_dir=\"\$WORKON_HOME\"

    # Make sure there is a default value for WORKON_HOME.
    # You can override this setting in your .bashrc.
    if [ \"\$workon_home_dir\" = \"\" ]
    then
        workon_home_dir=\"\$HOME/.virtualenvs\"
    fi

    # If the path is relative, prefix it with \$HOME
    # (note: for compatibility)
    if echo \"\$workon_home_dir\" | (unset GREP_OPTIONS; command \\grep '^[^/~]' > /dev/null)
    then
        workon_home_dir=\"\$HOME/\$WORKON_HOME\"
    fi

    # path might contain stuff to expand.
    # (it might be possible to do this in shell, but I don't know a
    # cross-shell-safe way of doing it -wolever)
    if echo \"\$workon_home_dir\" | (unset GREP_OPTIONS; command \\egrep '([\\\$~]|//)' >/dev/null)
    then
        # This will normalize the path by:
        # - Removing extra slashes (e.g., when TMPDIR ends in a slash)
        # - Expanding variables (e.g., \$foo)
        # - Converting ~s to complete paths (e.g., ~/ to /home/brian/ and ~arthur to /home/arthur)
        workon_home_dir=\"\$(virtualenvwrapper_expandpath \"\$workon_home_dir\")\"
    fi

    echo \"\$workon_home_dir\"
    return 0
}")

(defvar shw-test-string2 "#!/bin/bash
 # --

if [ \$# == 0 ]; then
    # some comment (note: for compatibility)
    set \"\" `find .  -maxdepth 1 -type f -name \"\*.txt\" | sed 's/..\\(.\*\\)/\\1/'`

    for i in \$\*; do
        # some comment (note: for compatibility)
	pass
    done

fi

vorhanden() {
    for i in \"/usr/bin/lynx\" \"/usr/bin/pdftotext\" \"/usr/bin/ps2ascii\" \"/usr/bin/abiword\";
    do
        # some comment (note: for compatibility)
	if [ ! -x \$i ]; then
	    echo \"Achtung! \$i nicht vorhanden oder nicht ausfuehrbar\\nWeitermachen?\"

	    a=nu
	    read a
	    case \$a in
                # some comment (note: for compatibility)
		y) echo \"Fortsetzung!\";;

		\*) exit 0
            # some comment (note: for compatibility)
	    esac
	else
            # some comment (note: for compatibility)
	    echo \"\$i vorhanden!\"

	fi
    # some comment (note: for compatibility)
    done
}
")

(provide 'sh-werk-setup-ert-tests)
;; sh-werk-setup-ert-tests.el ends here
