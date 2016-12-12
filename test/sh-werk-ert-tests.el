;;; sh-werk-ert-tests.el ---

;;; Code:

(setq shw-verbose-p t)

(setq shw-verbose-p t)

(ert-deftest shw-backward-statement-test-1 ()
  (shw-test-with-temp-buffer "
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
}

"
    (shw-backward-statement)
    (should (eq (char-after) ?}))))

(ert-deftest shw-backward-statement-test-2 ()
  (shw-test-with-temp-buffer "
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
}

"
      (search-backward "}")
    (shw-backward-statement)
    (should (eq (char-after) ?r))))

(ert-deftest shw-backward-statement-test-3 ()
  (shw-test-with-temp-buffer "
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
}

"
      (search-backward "workon_home_dir")
    (shw-backward-statement)
    (should (eq (char-after) ?e))))

(ert-deftest shw-backward-statement-test-4 ()
  (shw-test-with-temp-buffer "
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
}

"
      (search-backward "workon_home_dir" nil t 2)
    (shw-backward-statement)
    (should (eq (char-after) ?w))))

(ert-deftest shw-forward-statement-test-1 ()
  (shw-test-with-temp-buffer-point-min "
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
}

"
    (shw-forward-statement)
    (should (eq 49 (point)))
    (shw-forward-statement)
    (should (eq 92 (point)))
    (shw-forward-statement)
    (should (eq 239 (point)))
    (shw-forward-statement)
    (should (eq 248 (point)))
    (shw-forward-statement)
    (should (eq 293 (point)))
    (shw-forward-statement)
    (should (eq 300 (point)))
    (shw-forward-statement)
    (should (eq 475 (point)))

    ))

(ert-deftest shw-forward-block-test-1 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (search-backward "if")
    (shw-forward-block)
    (should (looking-back "fi"))
    ))

(ert-deftest shw-forward-block-test-2 ()
  (shw-test-with-temp-buffer-point-min
      shw-test-string2
    (search-forward "for" nil t 2)
    (shw-forward-block)
    (should (looking-back "done"))))


(ert-deftest shw-forward-block-test-3 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (re-search-backward "^vorhanden" nil t)
    (shw-forward-block)
    (should (eq (char-before) ?}))
    ))

;; http://emacs.stackexchange.com/questions/28343/sh-script-alignment-issues

;; MULTIFORM=$(
;;     curl -k -A http://foo.com |
;;     grep -m1 multiform |
;;     tr '=' '\n' |
;;     tail -1 |
;;     cut -d "'" -f 2
;; )

(ert-deftest shw-indent-pipe-test-1 ()
  (shw-test-with-temp-buffer
      "MULTIFORM=$(
curl -k -A http://foo.com |"
      (indent-according-to-mode)
    (should (eq 4  (current-indentation)))))

(ert-deftest shw-indent-pipe-test-2 ()
  (shw-test-with-temp-buffer
      "MULTIFORM=$(
    curl -k -A http://foo.com |
grep -m1 multiform |"
      (indent-according-to-mode)
    (should (eq 8  (current-indentation)))))


(ert-deftest shw-indent-pipe-test-3 ()
  (shw-test-with-temp-buffer
      "MULTIFORM=$(
    curl -k -A http://foo.com |
        grep -m1 multiform |
tr '=' '\\n' |"
      (indent-according-to-mode)
    (should (eq 8  (current-indentation)))))

(ert-deftest shw-backward-block-test-1 ()
  (shw-test-with-temp-buffer
   shw-test-string2
   (search-backward "done")
   (shw-backward-block)
   (should (looking-at "for"))))

(ert-deftest shw-backward-block-test-2 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (search-backward "fi")
    (shw-backward-block)
    (should (looking-at "if"))))

(ert-deftest shw-backward-block-test-3 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (search-backward "esac")
    (shw-backward-block)
    (should (looking-at "case"))))

(ert-deftest shw-backward-block-test-4 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (search-backward "exit")
    (shw-backward-block)
    (should (looking-at "case"))))

(ert-deftest shw-backward-block-test-5 ()
  (shw-test-with-temp-buffer
      shw-test-string2
      (search-backward "Fortsetzung")
    (shw-backward-block)
    (should (looking-at "case"))))

(ert-deftest shw-backward-block-test-6 ()
  (shw-test-with-temp-buffer-point-min
      shw-test-string2
      (search-forward "vorhanden")
      (search-forward "for")
    (shw-backward-block)
    (shw-backward-block)
    (should (looking-at "vorhanden"))))

(ert-deftest shw-backward-block-test-7 ()
  (shw-test-with-temp-buffer
      "if [ $# == 0 ]; then
    # some comment (note: for compatibility)
    set \\\"\\\" `find .  -maxdepth 1 -type f -name \\\"*.txt\\\" | sed 's/..\\\\(.*\\\\)/\\\\1/'`

    if $ASD; then
	:
    else
	:
    fi

fi
"
      (search-backward "fi" nil t 2)
    (shw-backward-block)
    (should (looking-at "if $ASD; then"))))

(ert-deftest ar-backward-line-test-1 ()
  (ar-test-with-shell-script-buffer
   ar-subr-test-string2
   ;; (font-lock-fontify-buffer)
   (ar-backward-line)
   (should (eq (char-after) ?}))
   (ar-backward-line)
   (should (eq (char-after) ?d))
   (ar-backward-line)
   (should (eq (char-after) ?f))
   (ar-backward-line)
   (should (eq (char-after) ?e))
   (ar-backward-line)
   (should (eq (char-after) ?e))
   (ar-backward-line)
   (should (eq (char-after) ?e))
   (ar-backward-line)
   (should (eq (char-after) ?*))
   (ar-backward-line)
   (should (eq (char-after) ?y))
   (ar-backward-line)
   (should (eq (char-after) ?c))
   (ar-backward-line)
   (should (eq (char-after) ?r))
   (ar-backward-line)
   (should (eq (char-after) ?a))
   (ar-backward-line)
   (should (eq (char-after) ?e))
   (ar-backward-line)
   (should (eq (char-after) ?i))
   (ar-backward-line)
   (should (eq (char-after) ?d))
   (ar-backward-line)
   (should (eq (char-after) ?f))
   (ar-backward-line)
   (should (eq (char-after) ?v))))



(ert-deftest ar-forward-line-test-1 ()
  (ar-test-with-shell-script-buffer-point-min
      ar-subr-test-string2
      (search-forward "vorhanden")
    (ar-forward-line)
    (should (eq (char-after) ?f))
    (ar-forward-line)
    (should (eq (char-after) ?d))
    (ar-forward-line)
    (should (eq (char-after) ?i))
    (ar-forward-line)
    (should (eq (char-after) ?e))
    (ar-forward-line)
    (should (eq (char-after) ?a))
    (ar-forward-line)
    (should (eq (char-after) ?r))
    (ar-forward-line)
    (should (eq (char-after) ?c))
    (ar-forward-line)
    (should (eq (char-after) ?y))
    (ar-forward-line)
    (should (eq (char-after) ?*))
    (ar-forward-line)
    (should (eq (char-after) ?e))
    (ar-forward-line)
    (should (eq (char-after) ?e))
    (ar-forward-line)
    (should (eq (char-after) ?e))
    (ar-forward-line)
    (should (eq (char-after) ?f))
    (ar-forward-line)
    (should (eq (char-after) ?d))
    (ar-forward-line)
    (should (eq (char-after) ?}))))

(ert-deftest ar-backward-statement-test-1 ()
  (ar-test-with-shell-script-buffer
   ar-subr-test-string2
   ;; (font-lock-fontify-buffer)
   (ar-backward-statement)
   (should (eq (char-after) ?}))
   (ar-backward-statement)
   (should (eq (char-after) ?d))
   (ar-backward-statement)
   (should (eq (char-after) ?f))
   (ar-backward-statement)
   (should (eq (char-after) ?e))
   (ar-backward-statement)
   (should (eq (char-after) ?e))
   (ar-backward-statement)
   (should (eq (char-after) ?e))
   (ar-backward-statement)
   (should (eq (char-after) ?*))
   (ar-backward-statement)
   (should (eq (char-after) ?y))
   (ar-backward-statement)
   (should (eq (char-after) ?c))
   (ar-backward-statement)
   (should (eq (char-after) ?r))
   (ar-backward-statement)
   (should (eq (char-after) ?a))
   (ar-backward-statement)
   (should (eq (char-after) ?e))
   (ar-backward-statement)
   (should (eq (char-after) ?i))
   (ar-backward-statement)
   (should (eq (char-after) ?d))
   (ar-backward-statement)
   (should (eq (char-after) ?f))
   (ar-backward-statement)
   (should (eq (char-after) ?v))))

(ert-deftest ar-forward-statement-sh-test-1 ()
  (ar-test-with-shell-script-buffer-point-min
      ar-subr-test-string2
    (ar-forward-statement)
    (should (eq (char-before) ?n))
    (ar-forward-statement)
    (should (eq (char-before) ?`))
    (ar-forward-statement)
    (should (eq (char-before) ?o))
    (ar-forward-statement)
    (should (eq (char-before) ?s))
    (ar-forward-statement)
    (should (eq (char-before) ?e))
    (ar-forward-statement)
    (should (eq (char-before) ?i))
    (ar-forward-statement)
    (should (eq (char-before) ?{))
    (ar-forward-statement)
    (should (eq (char-before) ?\;))
    (ar-forward-statement)
    (should (eq (char-before) ?o))
    (ar-forward-statement)
    (should (eq (char-before) ?n))
    (ar-forward-statement)
    (should (eq (char-before) ?\"))
    (ar-forward-statement)
    (should (eq (char-before) ?u))
    (ar-forward-statement)
    (should (eq (char-before) ?a))
    (ar-forward-statement)
    (should (eq (char-before) ?n))
    (ar-forward-statement)
    (should (eq (char-before) ?\;))
    (ar-forward-statement)
    (should (eq (char-before) ?0))
    (ar-forward-statement)
    (should (eq (char-before) ?c))
    (ar-forward-statement)
    (should (eq (char-before) ?e))
    (ar-forward-statement)
    (should (eq (char-before) ?\"))
    (ar-forward-statement)
    (should (eq (char-before) ?i))
    (ar-forward-statement)
    (should (eq (char-before) ?e))
    (ar-forward-statement)
    (should (eq (char-before) ?}))))

(provide 'sh-werk-ert-tests)
;;; sh-werk-ert-tests.el ends here
