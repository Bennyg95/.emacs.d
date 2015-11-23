(require 'package)
(package-initialize)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)


;; General Configuration

;; customize window title
(setq frame-title-format "GRIT")
(global-auto-complete-mode t)
(add-to-list 'ac-modes 'sql-mode 'c++-mode)
(setq ac-modes '(c++-mode sql-mode))
;; highlights parenthesis
(global-hl-line-mode)
;; easier navigating through windows
(winner-mode t)
(show-paren-mode)
;;
(windmove-default-keybindings)
;; No startup message
(setq inhibit-startup-message t)
;; UTF-8 encoding for everything
(prefer-coding-system 'utf-8)
;; No tool bar
(tool-bar-mode -1)
;; No menu bar
(menu-bar-mode -1)
;; Show column number
(column-number-mode t)
;; No backups
(setq make-backup-files nil)
;; Mouse scroll one line at a time
(setq mouse-wheel-follow-mouse 't)
;; Keyboard scroll one line at a time
(setq scroll-step 1)
;; Line numbers
(global-linum-mode 1)
;; Clean white spaces on save
(add-hook 'before-save-hook 'whitespace-cleanup)
;; Tabs for makefiles
(add-hook 'makefile-mode 'indent-tabs-mode)
(windmove-default-keybindings)
(setq windmove-wrap-around t)
;; Stop curso from jumping into minibuffer by itself
(setq minibuffer-prompt-properties
	  (quote (read-only t point-entered minibuffer-avoid-prompt
			face minibuffer-prompt)))

;; Transparent emacs
 ;;(set-frame-parameter (selected-frame) 'alpha '(<active> [<inactive>]))
 (set-frame-parameter (selected-frame) 'alpha '(85 85))
 (add-to-list 'default-frame-alist '(alpha 85 85))

 (eval-when-compile (require 'cl))
 (defun toggle-transparency ()
   (interactive)
   (if (/=
	(cadr (frame-parameter nil 'alpha))
	100)
	   (set-frame-parameter nil 'alpha '(100 100))
	 (set-frame-parameter nil 'alpha '(85 50))))
 (global-set-key (kbd "C-c t") 'toggle-transparency)

 ;; Set transparency of emacs
 (defun transparency (value)
   "Sets the transparency of the frame window. 0=transparent/100=opaque"
   (interactive "nTransparency Value 0 - 100 opaque:")
   (set-frame-parameter (selected-frame) 'alpha value))

;;; yasnippet
;;; should be loaded before auto complete so that they can work together
(require 'yasnippet)
 (yas-global-mode 1)

;;; auto complete mod
;;; should be loaded after yasnippet so that they can work together
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
(ac-config-default)
;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, auto-complete will
(ac-set-trigger-key "TAB")
(ac-set-trigger-key "<tab>")

(require 'auto-complete-clang)

(require 'tempo)
(setq tempo-interactive t)

(defvar c-tempo-tags nil
  "Tempo tags for C mode")

(defvar c++-tempo-tags nil
  "Tempo tags for C++ mode")

(defvar c-tempo-keys-alist nil
  "")

(defun my-tempo-c-cpp-bindings ()
  ;;(local-set-key (read-kbd-macro "<f8>") 'tempo-forward-mark)
  (local-set-key (read-kbd-macro "C-<return>")   'tempo-complete-tag)
  (local-set-key (read-kbd-macro "<f5>")   'tempo-complete-tag)
  (tempo-use-tag-list 'c-tempo-tags)
  (tempo-use-tag-list 'c++-tempo-tags))

(add-hook 'c-mode-hook   '(lambda () (my-tempo-c-cpp-bindings)))
(add-hook 'c++-mode-hook '(lambda () (my-tempo-c-cpp-bindings)))

;; the following macros allow to set point using the ~ character in tempo templates

(defvar tempo-initial-pos nil
   "Initial position in template after expansion")
 (defadvice tempo-insert( around tempo-insert-pos act )
3   "Define initial position."
   (if (eq element '~)
	 (setq tempo-initial-pos (point-marker))
	 ad-do-it))
 (defadvice tempo-insert-template( around tempo-insert-template-pos act )
   "Set initial position when defined. ChristophConrad"
   (setq tempo-initial-pos nil)
   ad-do-it
   (if tempo-initial-pos
	   (progn
	 (put template 'no-self-insert t)
	 (goto-char tempo-initial-pos))
	(put template 'no-self-insert nil)))

;;; Preprocessor Templates (appended to c-tempo-tags)
(tempo-define-template "c-include"
			   '("#include <" r ".h>" > n
			 )
			   "include"
			   "Insert a #include <> statement"
			   'c-tempo-tags)

(tempo-define-template "c-define"
			   '("#define " r " " > n
			 )
			   "define"
			   "Insert a #define statement"
			   'c-tempo-tags)

(tempo-define-template "c-ifdef"
			   '("#ifdef " (p "ifdef-condition: " clause) > n> p n
			 "#else /* !(" (s clause) ") */" n> p n
			 "#endif // " (s clause) n>
			 )
			   "ifdef"
			   "Insert a #ifdef #else #endif statement"
			   'c-tempo-tags)

(tempo-define-template "c-ifndef"
			   '("#ifndef " (p "ifndef-clause: " clause) > n
			 "#define " (s clause) n>

			 "/** " > n>
			 "* " > n>
			 "* Filename: " n>
			 "* " > n>
			 "* Classname: " n>
			 "* " > n>
			 "* Description: " n>
			 "* " > n>
			 "* " > n>
			 "**/" > n>
			 " " > n> p n
			 "#endif // " (s clause) n>
			 )
			   "ifndef"
			   "Insert a #ifndef #define #endif statement"
			   'c-tempo-tags)

(tempo-define-template "c-main"
			   '(> "/** " > n>
			   "* Filename: " > n>
			   "* " n>
			   "* Author: Benito Sanchez" > n>
			   "* " > n>
			   "* Description " > n>
			   "* " > n>
			   "* Date: " > n>
			   "* " > n>
			   "**/" > n>
			   > n>
			 "#include <iostream>" > n>
			 "#include <cstdlib>" > n>
			   "using namespace std;" > n>
			   > n>
			 "int main() {" >  n>
			 > r n
			 "return EXIT_SUCCESS;" > n
			 "}" > n>
			 )
			   "main"
			   "Insert a C main statement"
			   'c-tempo-tags)

(tempo-define-template "c-switch"
			   '(> "switch(" (p "variable to check: " clause) ") {" >  n>
			 "case " > (p "first value: ") ": " ~ > n>
			 " break;" > n>
			 >"default:" > n>
			 "}" > n>
			 )
			   "switch"
			   "Insert a C switch statement"
			   'c-tempo-tags)

(tempo-define-template "c-case"
			   '("case " (p "value: ") ":" ~ > n>
			   "break;" > n>
			)
			   "case"
			   "Insert a C case statement"
			   'c-tempo-tags)

;;;C++-Mode Templates
(setq max-lisp-eval-depth 500)

(tempo-define-template "c++-class"
			'(
			  "class " (p "classname: " class) " {" > n>




			  "    public:" > n>
			  > n>
			  "    // ****************************************************************" n>
			  "    "(s class) "(); " n>
			  "    // ****************************************************************" n>

			  > n>

			  "    /* Accessors */" > n>
			  > n>

			  "    /* Mutators */" > n>
			  > n>
			  "    // ****************************************************************" n>

			  > n>
			  > n>

			  "    private:" > n>


			 "};\t// end of class " (s class) > n>
			 )
			   "class"
			   "Insert a class skeleton"
			   'c++-tempo-tags)


(provide 'tempo-c-cpp)
;;; tempo-c-cpp.el ends here

(require 'cc-mode)
(setq-default c-basic-offset 4 c-default-style "linux")
(setq-default tab-width 4 indent-tabs-mode t)
(define-key c-mode-base-map (kbd "RET") 'newline-and-indent)

(require 'autopair)
(autopair-global-mode 1)
(setq autopair-autowrap t)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(custom-enabled-themes (quote (manoj-dark)))
 '(custom-safe-themes (quote ("b3775ba758e7d31f3bb849e7c9e48ff60929a792961a2d536edec8f68c671ca5" "7bde52fdac7ac54d00f3d4c559f2f7aa899311655e7eb20ec5491f3b5c533fe8" "90d329edc17c6f4e43dbc67709067ccd6c0a3caa355f305de2041755986548f2" default)))
 '(linum-format " %7i "))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
