;; jde-mvn.el -- Use Maven to build your JDE projects


;; Copyright (C) 2013 by Wolfgang cr. Ko
;; Author: Wolfgang cr. Ko | crazia@gmail.com
;; Created: 28 June 2013
;; Version 0.0.1

;; This file is not part of Emacs

(require 'compile)


(defgroup jde-mvn nil
  "JDE Maven"
  :group 'jde
  :prefix "jde-mvn-")


(defcustom jde-mvn-program "mvn"
  "*Specifies name of mvn program."
 :group 'jde-mvn
 :type 'string)


(defcustom jde-mvn-working-directory ""
  "*Path of the working directory to use in 'mvn' build mode. This
string must end in a slash, for example, c:/foo/bar/ or ./  .
If this string is empty, the 'mvn' build mode uses the current file
location as its working directory."
  :group 'jde-mvn
  :type 'string)


(defcustom jde-mvn-enable-find nil
"*Specify whether jde-mvn find the pom.xml based on your current
directory. If non-nil, we will search up the directory hierarchy from the
current directory for the build definition file. Also note that, if non-nil,
this will relax the requirement for an explicit jde project file."
   :group 'jde-mvn
   :type 'boolean)

(defcustom jde-mvn-args "install"
  "*Specifies arguments to be passed to make program."
  :group 'jde-mvn
  :type 'string)

(defcustom jde-mvn-finish-hook
  '(jde-compile-finish-refresh-speedbar jde-compile-finish-update-class-info)
  "List of functions to be invoked when compilation of a
Java source file terminates. Each function should accept
two arguments: the compilation buffer and a string
describing how the compilation finished."
  :group 'jde-mvn
  :type 'hook)

(defvar jde-interactive-mvn-args ""
"String of compiler arguments entered in the minibuffer.")

(defcustom jde-read-mvn-args nil
"*Specify whether to prompt for additional mvn arguments.
If this variable is non-nil, and if `jde-build-use-mvn' is non nil
the jde-build command prompts you to enter additional mvn
arguments in the minibuffer. These arguments are appended to those
specified by customization variables. The JDE maintains a history
list of arguments entered in the minibuffer."
  :group 'jde-mvn
  :type 'boolean
)

(defun jde-make-mvn-command (more-args)
  "Constructs the java compile command as: jde-compiler + options + buffer file name."
  (concat jde-mvn-program " " jde-mvn-args
	  (if (not (string= more-args ""))
	      (concat " " more-args))
	  " "))


(defun jde-mvn-find-build-file (dir)
  "Find the next pom.xml upwards in the directory tree from DIR.
Returns nil if it cannot find a project file in DIR or an ascendmake directory."
  (let ((file (find "pom.xml"
		    (directory-files dir) :test 'string=)))

    (if file
	(setq file (expand-file-name file dir))
      (if (not (jde-root-dir-p dir))
	  (setq file (jde-mvn-find-build-file (concat dir "../")))))

    file))

;;;###autoload
(defun jde-mvn ()
  "Run the make program specified by `jde-mvn-program' with the
command-line arguments specified by `jde-mvn-args'. If
`jde-read-mvn-args' is nonnil, this command also prompts you to enter
mvn arguments in the minibuffer and passes any arguments that you
enter to the mvn program along with the arguments specified by
`jde-mvn-args'."
  (interactive)
  (if jde-read-mvn-args
      (setq jde-interactive-mvn-args
	      (read-from-minibuffer
	       "mvn args: "
	       jde-interactive-mvn-args
	       nil nil
	       '(jde-interactive-mvn-arg-history . 1)))
    (setq jde-interactive-mvn-args ""))

  (let ((mvn-command
	 (jde-make-mvn-command
	  jde-interactive-mvn-args))
	(save-default-directory default-directory)
	(default-directory
	  (if (string= jde-mvn-working-directory "")
	      (if jde-mvn-enable-find
            (let ((jde-mvn-buildfile
                   (jde-mvn-find-build-file default-directory)))
              (if jde-mvn-buildfile
                  (file-name-directory jde-mvn-buildfile)
                default-directory))
          default-directory)
	    (jde-normalize-path 'jde-mvn-working-directory))))


    ;; Force save-some-buffers to use the minibuffer
    ;; to query user about whether to save modified buffers.
    ;; Otherwise, when user invokes jde-make from
    ;; menu, save-some-buffers tries to popup a menu
    ;; which seems not to be supported--at least on
    ;; the PC.
    (if (and (eq system-type 'windows-nt)
             (not jde-xemacsp))
        (let ((temp last-nonmenu-event))
	  ;; The next line makes emacs think that jde-make
	  ;; was invoked from the minibuffer, even when it
	  ;; is actually invoked from the menu-bar.
          (setq last-nonmenu-event t)
          (save-some-buffers (not compilation-ask-about-save) nil)
          (setq last-nonmenu-event temp))
      (save-some-buffers (not compilation-ask-about-save) nil))

    (setq compilation-finish-functions
          (lambda (buf msg)
            (run-hook-with-args 'jde-mvn-finish-hook buf msg)
            (setq compilation-finish-functions nil)))

    (cd default-directory)
    (compilation-start mvn-command)
    (cd save-default-directory)))



;;;###autoload
(defun jde-mvn-show-options ()
  "Show the JDE mvn Options panel."
  (interactive)
  (customize-apropos "jde-mvn" 'groups))

;; Register and initialize the customization variables defined
;; by this package.
(jde-update-autoloaded-symbols)





(provide 'jde-mvn)
