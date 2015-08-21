;;; jq-mode.el --- Edit and interactively evaluate SPARQL queries.

;; Copyright (C) 2015 Bjarte Johansen

;; Author: Bjarte Johansen <Bjarte dot Johansen at gmail dot com>
;; Homepage: https://github.com/ljos/jq-mode
;; Version: 0.0.1

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with jq-mode. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Mode for editing jq queries.

;; Usage:

;; Add to your Emacs config:

;;  (add-to-list 'load-path "/path/to/jq-mode-dir")
;;  (autoload 'sparql-mode "jq-mode.el"
;;   "Major mode for editing jq files" t)
;;  (add-to-list 'auto-mode-alist '("\\.jq$" . jq-mode))

(defgroup jq nil
  "Major mode for editing jq queries."
  :group 'languages)

(defcustom jq-indent-offset 2
  "*Indentation offset for `jq-mode'."
  :group 'jq
  :type 'integer)

(defconst jq--keywords
  '("as"
    "break"
    "catch"
    "def"
    "elif" "else" "end"
    "foreach"
    "if" "import" "include"
    "label"
    "module"
    "reduce"
    "then" "try"))

(defun jq-indent-line ()
  "Indent current line as a jq-script."
  (interactive)
  (skip-chars-forward "[:space:]")
  (let ((indent-column 0)
	(current (current-indentation)))
    (save-excursion
      (if (> 0 (forward-line -1))
	  (setq indent-column (current-indentation))
	(end-of-line)
	(or (search-backward ";" (line-beginning-position) t)
	    (back-to-indentation))
	(skip-chars-forward "[:space:]" (line-end-position))
	(when (looking-at-p
	       (concat (regexp-opt (remove "end" jq--keywords)) "\\b"))
	  (setq indent-column (+ indent-column jq-indent-offset)))))
    (save-excursion
      (back-to-indentation)
      (save-excursion
	(ignore-errors
	  (up-list -1)
	  (when (looking-at-p "(\\|{\\|\\[")
	    (setq indent-column (1+ (current-column))))))
      (when (looking-at-p "|")
	(setq indent-column (+ indent-column jq-indent-offset)))
      (indent-line-to indent-column))))

(defconst jq--builtins
  '("add" "all" "and" "any" "arrays" "asci_upcase" "ascii_downcase"
    "booleans" "bsearch"
    "capture" "combinations" "contains"
    "debug" "del"
    "empty" "endswith" "env" "error" "explode"
    "finites" "first" "flatten" "floor" "from_entries" "fromdate"
    "fromdateiso8601" "fromjson" "fromstream"
    "getpath" "gmtime" "group_by" "gsub"
    "has"
    "implode" "in" "index" "indicies" "infinite" "input" "input_filename"
    "input_line_number" "inputs" "inside" "isfinite" "isinfinite" "isnan"
    "isnormal" "iterables"
    "join"
    "keys" "keys_unsorted"
    "last" "leaf_paths" "length" "limit" "ltrimstr"
    "map" "map_values" "match" "max" "max_by" "min" "min_by" "mktime"
    "modulemeta"
    "nan" "normals" "not" "now" "nth" "nulls" "numbers"
    "objects" "or"
    "path" "paths"
    "range" "recurse" "recurse_down" "reverse" "rindex" "rtrimstr"
    "scalars" "scan" "select" "setpath" "sort" "sort_by" "split" "split"
    "splits" "sqrt" "startswith" "strftime" "strings" "strptime" "sub"
    "test" "to_entries" "todate" "todateiso8601" "tojson" "tonumber" "tostream"
    "tostring" "transpose" "truncate_stream" "type"
    "unique" "unique_by" "until"
    "values"
    "walk" "while" "with_entries"))

(defconst jq--escapings
  '("text" "json" "html" "uri" "csv" "tsv" "sh" "base64"))

(defconst jq-font-lock-keywords
  (eval-when-compile
    `(;; Variables
      ("\\$\\w+" 0 font-lock-variable-name-face)
      ;; Format strings and escaping
      (,(concat "@" (regexp-opt jq--escapings) "\\b") . font-lock-type-face)
      ;; Keywords
      ,(concat "\\b" (regexp-opt jq--keywords) "\\b"))))


(defvar jq-mode-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for `jq-mode'.")

(define-derived-mode jq-mode prog-mode "jq"
  "Major mode for jq scripts.
\\{jq-mode-map}"
  :group 'jq-mode
  (setq-local indent-line-function #'jq-indent-line)
  (setq-local font-lock-defaults '(jq-font-lock-keywords))
  (when (boundp 'company-mode)
    (add-to-list 'company-keywords-alist
		 `(jq-mode . ,(append jq--keywords
				      jq--builtins)))))

;; jq-mode.el ends here
