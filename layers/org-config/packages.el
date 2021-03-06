;;; packages.el --- org-config layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author:  liu233w
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `org-config-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `org-config/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `org-config/pre-init-PACKAGE' and/or
;;   `org-config/post-init-PACKAGE' to customize the package as it is loaded.

;;; Summary:
;; 这是我用来管理 org 相关配置的 layer。由于 org 过于庞大，可配置内容太多，故将
;; 此layer 独立出来

;;; Code:

(defconst org-config-packages
  '(
    org
    (ego :location (recipe :fetcher github :repo "liu233w/EGO-steady"))
    ob-ipython
    (org-table-move-single-cell :location local)
    )
  "The list of Lisp packages required by the org-config layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The following values are legal:

      - The symbol `elpa' (default) means PACKAGE will be
        installed using the Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa
        recipe.  See: https://github.com/milkypostman/melpa#recipe-format")

(defun org-config/post-init-org ()
  (with-eval-after-load 'org
    ;;org-mode 和 org-mobile 的文件夹
    (setf org-directory "~/documents/org-mode/host/"
          ;; org-mobile-directory "~/documents/org-mode/"
          ;; org-mobile-inbox-for-pull "~/documents/org-mode/index.org"
          )

    ;; 完成状态
    (setf org-todo-keywords
          '((sequence "TODO(t!)" "NEXT(n)" "WAITTING(w)" "SOMEDAY(s)" "|" "DONE(d@/!)" "ABORT(a@/!)")
            ))

    ;; 用来检测 md5 的程序
    ;; (defcustom org-mobile-checksum-binary
    ;;   (or (executable-find "md5sums") (executable-find "md5sum"))
    ;;   ' "Executable used for computing checksums of agenda files."
    ;;     ':group 'org-mobile
    ;;     ' :type 'string)

    ;;org 的捕获列表
    (setq org-capture-templates
          '(("t" "TODO" entry (file+headline  "~/documents/org-mode/tasks.org" "_TODO")
             "* TODO %?\n %i\n %a")
            ("s" "SOMEDAY" entry (file+headline  "~/documents/org-mode/tasks.org" "_SOMEDAY")
             "* SOMEDAY %?\n %i\n %a")
            ("n" "Notes" entry (file+datetree "~/documents/org-mode/notes.org")
             "* %?\nEntered on %U\n %i\n %a")))

    ;; org-agenda 的全局文件
    (setf org-agenda-files (list "~/documents/org-mode/tasks.org"
                                 "~/documents/org-mode/notes.org"))

    ;; 在下一级任务的完成度达到 100%时自动将上一级设置为 DONE
    ;; from http://www.cnblogs.com/holbrook/archive/2012/04/14/2447754.html
    (add-hook 'org-after-todo-statistics-hook 'liu233w/org-summary-todo)

    ;; 可以在 org 中自动加载的库（稍后可以直接在 src_block 里面执行代码）
    (org-babel-do-load-languages
     'org-babel-load-languages
     '((sh         . t)
       ;; (js         . t)
       (emacs-lisp . t)
       ;; (perl       . t)
       ;; (scala      . t)
       ;; (clojure    . t)
       (python     . t)
       (ipython . t)
       ;; (ruby       . t)
       ;; (dot        . t)
       ;; (css        . t)
       ;; (plantuml   . t)
       (C . t)
       ))
    ;; 执行 src_block 里的代码时不询问
    (setq org-confirm-babel-evaluate nil)

    ;; 使用 super-sender 来做 org-ctrl-c-ctrl-c
    (evil-quick-sender-add-command 'org-mode 'org-ctrl-c-ctrl-c 'normal)

    ;; 防止 fci-mode 使得 org 输出 HTML 时在代码结尾处产生乱码
    ;; learn from here:
    ;; https://github.com/alpaker/Fill-Column-Indicator/issues/45#issuecomment-108911964
    (defun fci-mode-override-advice (&rest args))
    (advice-add 'org-html-fontify-code :around
                (lambda (fun &rest args)
                  (advice-add 'fci-mode :override #'fci-mode-override-advice)
                  (let ((result  (apply fun args)))
                    (advice-remove 'fci-mode #'fci-mode-override-advice)
                    result)))

    ;; 修改 org 中的标题图标
    ;; from https://emacs-china.org/t/topic/250/3?u=liu233w
    (setq org-bullets-bullet-list '("⓪" "①" "②" "③"
                                    "④" "⑤" "⑥" "⑦"
                                    "⑧" "⑨" "⑩" "⑪"
                                    "⑫" "⑬" "⑭"
                                    "⑮" "⑯" "⑰"
                                    "⑱" "⑲" "⑳"))
    )
  )

(defun org-config/init-ego ()
  (use-package ego
    :defer t                            ;延迟加载
    :init                               ;在 package 加载之前求值，用于设置快捷键
    (spacemacs/declare-prefix "op" "EGO")
    (spacemacs/set-leader-keys
      "opp" 'ego-do-publication
      "opn" 'ego-new-post)
    :config                             ;在 package 加载之后才会求值
    (progn
      (require 'ego)
      (ego-add-to-alist 'ego-project-config-alist
                        `(("my-blog" ; 站点工程的名字
                           :repository-directory "~/documents/blog/" ; 站点的本地目录
                           :site-domain  "http://liu233w.github.io/"; 站点的网址
                           :site-main-title  "科学君的不科学博客"; 站点的标题
                           :site-sub-title  "by 不科学的科学君"; 站点的副标题
                           :theme (light-color default) ; 使用的主题
                           ;; 导航栏的设置，有 category 和 summary 两种
                           :summary (("所有文章" :year :updates 10)
                                     ("按标签索引" :tags) )
                           :retrieve-category-function ego--get-file-category
                           :default-category "blog"
                           :source-browse-url ("Github" "https://github.com/liu233w/liu233w.github.io") ; 你的工程源代码所在的位置
                           :personal-disqus-shortname "liu233w" ; 使用 disqus 评论功能的话，它的短名称
                           :personal-duoshuo-shortname "liu233w"
                           :confound-email t ; 是否保护邮件名称呢？t 是保护，nil 是不保护，默认是保护
                           :web-server-docroot "~/webRoot/liu233w.github.io" ; 本地测试的目录
                           :web-server-port 5432; 本地测试的端口
                           :personal-avatar "https://raw.githubusercontent.com/Liu233w/liu233w.github.io/source/avatar.jpg"
                           :repository-org-branch "source"
                           :repository-html-branch "master"
                           )
                          ;; 你可以在此添加更多的站点设置
                          ))
      ;;设置 category
      (setf ego--category-config-alist
            '(("blog"
               :show-meta t
               :show-comment t
               :uri-template "/blog/%y/%m/%d/%f/"
               :uri-generator ego--generate-uri
               :sort-by :date     ;; how to sort the posts
               :category-index t) ;; generate category index or not
              ("acm"
               :show-meta t
               :show-comment t
               :uri-template "/acm/%y/%m/%d/%f/"
               :uri-generator ego--generate-uri
               :sort-by :date     ;; how to sort the posts
               :category-index t)
              ("index"
               :show-meta nil
               :show-comment nil
               :uri-generator ego--generate-uri
               :uri-template "/"
               :sort-by :date
               :category-index nil)
              ("about"
               :show-meta nil
               :show-comment nil
               :uri-generator ego--generate-uri
               :uri-template "/about/"
               :sort-by :date
               :category-index nil)
              )))

    (require 'nadvice)
    ;; 改变默认的元数据模板，使插入的 URL 为 "category/%y/%m/%d/%f/"
    (defun org-config//advice-of-ego--insert-options-template (args)
      (setf (second args)
            (replace-regexp-in-string "%t/ Or .*$" "%f/"
                                      (second args)))
      args)

    (advice-add 'ego--insert-options-template :filter-args
                'org-config//advice-of-ego--insert-options-template
                )
    ))

(defun org-config/init-ob-ipython ()
  "在 org 中使用 ipython"
  (use-package ob-ipython
    :defer t
    ))

(defun org-config/init-org-table-move-single-cell ()
  "用于在org文件中移动单元格。

参考：https://emacs-china.org/t/org-mode/1925/4?u=liu233w"
  (use-package org-table-move-single-cell
    :defer t
    :commands (org-table-move-single-cell-up
               org-table-move-single-cell-down
               org-table-move-single-cell-left
               org-table-move-single-cell-right)
    :init
    (with-eval-after-load 'org
      (mms|define-multiple-micro-state
       liu233w/org-table-move
       :doc auto
       :bindings
       ("<up>" org-table-move-single-cell-up)
       ("<down>" org-table-move-single-cell-down)
       ("<left>" org-table-move-single-cell-left)
       ("<right>" org-table-move-single-cell-right))
      (spacemacs/set-leader-keys-for-minor-mode 'org-mode
        "t <up>" #'liu233w/org-table-move:org-table-move-single-cell-up-then-enter-micro-state
        "t <down>" #'liu233w/org-table-move:org-table-move-single-cell-down-then-enter-micro-state
        "t <left>" #'liu233w/org-table-move:org-table-move-single-cell-left-then-enter-micro-state
        "t <right>" #'liu233w/org-table-move:org-table-move-single-cell-right-then-enter-micro-state
        )
      )))

;;; packages.el ends here
