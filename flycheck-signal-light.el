;;; flycheck-signal-light.el --- Made flycheck's mode-line as a signal light  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  Taiki Sugawara

;; Author: Taiki Sugawara <buzz.taiki@gmail.com>
;; Keywords: convenience
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1") (flycheck "31"))
;; URL: https://github.com/buzztaiki/flycheck-signal-light

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides custom `flycheck-mode-line' function `flycheck-signal-light'.
;; To use it, add the following to your init file:
;;
;;      (flycheck-signal-light-mode 1)

;;; Code:

(require 'flycheck)

(defgroup flycheck-signal-light nil
  "Made flycheck's mode-line as a signal light"
  :prefix "flycheck-signal-light-"
  :group 'flychek
  :link '(url-link "https://github.com/buzztaiki/flycheck-signal-light"))

(defcustom flycheck-signal-light-count-separator " "
  "A text to separate error count."
  :group 'flycheck-signal-light
  :type 'string)

(defcustom flycheck-signal-light-error-levels '(error warning info)
  "A list of error level to display in the mode line."
  :group 'flycheck-signal-light
  :type '(repeat (choice (const error)
                         (const warning)
                         (const info))))

(defface flycheck-signal-light-error
  '((t . (:inherit flycheck-error-list-error)))
  "Face for error count."
  :group 'flycheck-signal-light)

(defface flycheck-signal-light-warning
  '((t . (:inherit flycheck-error-list-warning)))
  "Face for warning count."
  :group 'flycheck-signal-light)

(defface flycheck-signal-light-info
  '((t . (:inherit flycheck-error-list-info)))
  "Face for info count."
  :group 'flycheck-signal-light)

;;;###autoload
(defun flycheck-signal-light-mode-line ()
  "Get a text describing `flycheck-last-status-change' for use in the mode line."
  (let ((status flycheck-last-status-change))
    (format " %s[%s]"
            flycheck-mode-line-prefix
            (if (not (eq status 'finished))
                (capitalize (symbol-name status))
              (mapconcat #'flycheck-signal-light--error-count flycheck-signal-light-error-levels
                         flycheck-signal-light-count-separator)))))

(defun flycheck-signal-light--error-count (level)
  (propertize
   (int-to-string (alist-get level (flycheck-count-errors flycheck-current-errors) 0))
   'face (pcase level
           (`error 'flycheck-signal-light-error)
           (`warning 'flycheck-signal-light-warning)
           (`info 'flycheck-signal-light-info))
   'help-echo (format "number of flycheck %ss" level)))

(defvar flycheck-signal-light--original-mode-line nil)

;;;###autoload
(define-minor-mode flycheck-signal-light-mode
  "Made `flycheck''s mode-line as a signal light"
  :group 'flycheck-signal-light
  :global t
  (if flycheck-signal-light-mode
      (setq flycheck-signal-light--original-mode-line flycheck-mode-line
            flycheck-mode-line '(:propertize (:eval (flycheck-signal-light-mode-line))))
    (setq flycheck-mode-line flycheck-signal-light--original-mode-line)))

(provide 'flycheck-signal-light)
;;; flycheck-signal-light.el ends here
