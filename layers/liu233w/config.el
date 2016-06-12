(require 'cl-lib)

;; For my language code setting (UTF-8)
(set-language-environment "chinese-GBK")
(prefer-coding-system 'utf-8-auto)

;;设置窗口大小
 (when (spacemacs/system-is-mswindows)
   (defun reset-frame-size ()
     (interactive)
     (set-frame-width (selected-frame) 80)
     (set-frame-height (selected-frame) 30))
   (reset-frame-size))

;;setting Font
(cond
 ((spacemacs/system-is-mswindows)
  ;; Setting English Font
  (unless (search "Source Code Pro" (frame-parameter nil 'font))
    (set-face-attribute
     'default nil :font "Consolas 18"))
  ;; Chinese Font
  (dolist (charset '(kana han cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font)
                      charset
                      (font-spec :family "Microsoft Yahei" :size 22))))
 ((spacemacs/system-is-linux)
  (set-default-font "文泉驿等宽微米黑-18"))
 )

(display-time-mode 1)
(setq display-time-24hr-format t)
;;显示时间的格式
(setq display-time-format "%H:%M")

;;add auto format paste code
(dolist (command '(yank yank-pop))
  (eval
   `(defadvice ,command (after indent-region activate)
      (and (not current-prefix-arg)
           (member major-mode
                   '(emacs-lisp-mode
                     lisp-mode
                     clojure-mode
                     scheme-mode
                     haskell-mode
                     ruby-mode
                     rspec-mode
                     python-mode
                     c-mode
                     c++-mode
                     objc-mode
                     latex-mode
                     js-mode
                     plain-tex-mode))
           (let ((mark-even-if-inactive transient-mark-mode))
             (indent-region (region-beginning) (region-end) nil))))))

;; when save a buffer, the directory is not exsits, it will ask you to create the directory
;; from zilongshanren
(add-hook 'before-save-hook
          (lambda ()
            (when buffer-file-name
              (let ((dir (file-name-directory buffer-file-name)))
                (when (and (not (file-exists-p dir))
                           (y-or-n-p (format "Directory %s does not exist. Create it?" dir)))
                  (make-directory dir t))))))

;; http://emacs.stackexchange.com/questions/13970/fixing-double-capitals-as-i-type
(defun dcaps-to-scaps ()
  "Convert word in DOuble CApitals to Single Capitals."
  (interactive)
  (and (= ?w (char-syntax (char-before)))
       (save-excursion
         (and (if (called-interactively-p)
                  (skip-syntax-backward "w")
                (= -3 (skip-syntax-backward "w")))
              (let (case-fold-search)
                (looking-at "\\b[[:upper:]]\\{2\\}[[:lower:]]"))
              (capitalize-word 1)))))

(define-minor-mode dubcaps-mode
  "Toggle `dubcaps-mode'.  Converts words in DOuble CApitals to
Single Capitals as you type."
  :init-value nil
  :lighter (" DC")
  (if dubcaps-mode
      (add-hook 'post-self-insert-hook #'dcaps-to-scaps nil 'local)
    (remove-hook 'post-self-insert-hook #'dcaps-to-scaps 'local)))

;;Don’t ask me when close emacs with process is running
;;from zilongshanren
(defadvice save-buffers-kill-emacs (around no-query-kill-emacs activate)
  "Prevent annoying \"Active processes exist\" query when you quit Emacs."
  (flet ((process-list ())) ad-do-it))

;;Don’t ask me when kill process buffer
;;from zilongshanren
(setq kill-buffer-query-functions
      (remq 'process-kill-buffer-query-function
            kill-buffer-query-functions))

(menu-bar-mode t)

(add-to-list 'auto-mode-alist '("\\.mm\\'" . objc-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c++-mode))

;;c++缩进
(add-hook 'c++-mode-hook
          '(lambda ()
             (interactive)
             (setq default-tab-width 4)
             (setq-default indent-tabs-mode nil)
             (setq c-basic-offset 4)

             (c-set-style "google")
                         ))

;;When enter the shell buffer, evil state will be switched to emacs-state,
;;C-z can switch between emacs-mode and normal-mode
(add-hook 'shell-mode-hook '(lambda ()
                              (evil-normal-state)
                              (evil-emacs-state)))
