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
;; 这是我用来管理org相关配置的layer。由于org过于庞大，可配置内容太多，故将此layer独立出来

;;; Code:

(defconst org-config-packages
  '(
    org
    ego
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
  ;;org-mode和org-mobile的文件夹
  (setf org-directory "~/documents/org-mode/host/"
        org-mobile-directory "~/documents/org-mode/"
        org-mobile-inbox-for-pull "~/documents/org-mode/index.org")

  ;; 完成状态
  (setf org-todo-keywords
        '((sequence "TODO(t!)" "NEXT(n)" "WAITTING(w)" "SOMEDAY(s)" "|" "DONE(d@/!)" "ABORT(a@/!)")
          ))

  ;; 用来检测md5的程序
  (defcustom org-mobile-checksum-binary
    (or (executable-find "md5sums") (executable-find "md5sum"))
    ' "Executable used for computing checksums of agenda files."
      ':group 'org-mobile
      ' :type 'string)

  ;;org的捕获列表
  (setq org-capture-templates
        '(("t" "TODO" entry (file+headline  "~/documents/org-mode/host/tasks.org" "_TODO")
           "* TODO %?\n %i\n %a")
          ("s" "SOMEDAY" entry (file+headline  "~/documents/org-mode/host/tasks.org" "_SOMEDAY")
           "* SOMEDAY %?\n %i\n %a")
          ("n" "Notes" entry (file+datetree "~/documents/org-mode/host/notes.org")
           "* %?\nEntered on %U\n %i\n %a")))

  ;; org-agenda的全局文件
  (setf org-agenda-files (list "~/documents/org-mode/host/tasks.org"
                               "~/documents/org-mode/host/notes.org"))

  ;; 在下一级任务的完成度达到100%时自动将上一级设置为DONE
  ;; from http://www.cnblogs.com/holbrook/archive/2012/04/14/2447754.html
  (add-hook 'org-after-todo-statistics-hook 'liu233w/org-summary-todo)
  )

(defun org-config/init-ego ()
  (use-package "ego")
  (require 'ego)
  (ego-add-to-alist 'ego-project-config-alist
               `(("my-blog" ; 站点工程的名字
                  :repository-directory "~/documents/blog/" ; 站点的本地目录
                  :site-domain  "http://liu233w.github.io/"; 站点的网址
                  :site-main-title  "科学君的不科学博客"; 站点的标题
                  :site-sub-title  "by 不科学的科学君"; 站点的副标题
                 :theme (default) ; 使用的主题
                 :summary (("文章标签" :tags) ("按年度分类" :year :updates 10)) ; 导航栏的设置，有 category 和 summary 两种
                 :retrieve-category-function ego--get-file-category
                 :default-category "blog"
                 :source-browse-url ("Github" "https://github.com/liu233w/liu233w.github.io") ; 你的工程源代码所在的位置
                 :personal-disqus-shortname "liu233w" ; 使用 disqus 评论功能的话，它的短名称
                 :confound-email t ; 是否保护邮件名称呢？t 是保护，nil 是不保护，默认是保护
                 :web-server-docroot "~/webRoot/liu233w.github.io" ; 本地测试的目录
                 :web-server-port 5432; 本地测试的端口
                 :personal-avatar "https://raw.githubusercontent.com/Liu233w/liu233w.github.io/source/avatar.jpg"
                 :repository-org-branch "source"
                 :repository-html-branch "master"
                 )
                 ;; 你可以在此添加更多的站点设置
                 ))

  ;;设置category
  (setf ego--category-config-alist
        '(("blog"
          :show-meta t
          :show-comment t
          :uri-generator ego--generate-uri
          :uri-template "/blog/%y/%m/%d/%t/"
          :sort-by :date     ;; how to sort the posts
          :category-index t) ;; generate category index or not
         ("acm"
          :show-meta t
          :show-comment t
          :uri-generator ego--generate-uri
          :uri-template "/blog/%y/%m/%d/%t/"
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
         ))

  (evil-leader/set-key
    "opp" 'ego-do-publication
    "opn" 'ego-new-post)
  )

;;; packages.el ends here