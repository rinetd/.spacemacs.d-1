;;; -*- lexical-binding: t -*-

;;; multiple-micro-state.el --- 在生成micro-state的同时对每个命令生成对应的函数。

;; 函数的参数和调用方式可以和原来的命令相同，在执行命令之后自动进入micro-state

;; Copyright (c) 2016 Liu233w
;;
;; Author: Liu233w <wwwlsmcom@outlook.com>
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(require 'core-micro-state)
(require 'nadvice)

(defun mms//generate-micro-state-name (name)
  "生成micro-state的名字，将返回一个symbol。
参数name是一个symbol"
  (intern (format "%s:micro-state" name)))

(defun mms//generate-function-name (name func)
  "生成micro-state的各个函数的名称，返回一个symbol。
参数name和func都是symbol"
  (intern (format "%s:%s-then-enter-micro-state" name func)))

(defun mms//get-function-key-list (lst)
  "接受一个plist，返回一个在:bindings中的列表里面每个子列表的前两项组成的形如
`(键绑定 . 函数名)' 的列表"
  (mapcar #'(lambda (item) (cons (first item) (second item)))
          (spacemacs/mplist-get lst :bindings)))

(defun mms//generate-document (lst)
  "接受一个含有键绑定和函数名的cons的列表，返回一个字符串，含有键绑定和对应的函数名"
  (mapconcat #'(lambda (item) (format "`%s' %s " (car item) (cdr item)))
             lst " "))

(defun mms//generate-function-defination (name func state-name)
  "生成函数的定义。
name是micro-state的名字，func是函数名，state-name是之前生成的micro-state
的名字，都是symbol。
生成的函数与原来的函数有相同的形参列表和interactive，在执行完原有函数的功能之后
会启动相应的micro-state。"
  (let ((func-name (mms//generate-function-name name func)))
    ;; `(progn
    ;;    (defalias (quote ,func-name) (quote ,func)
    ;;      ,(format "A function generated from %s by `mms|define-multiple-micro-state'"
    ;;               func))
    ;;    (advice-add (quote ,func-name) :after '(lambda (&rest rest) (,state-name))))
    `(defun ,func-name (&rest rest)
       ,(format "Call `%s' then call `%s'" func state-name)
       ,(or (interactive-form func)
            '(interactive))
       (apply (function ,func) rest)
       (,state-name))))

(defmacro mms|define-multiple-micro-state (name &rest props)
  "使用`spacemacs|define-micro-state'来生成micro-state，同时对每个命令生成一个函数，
调用函数会执行相应的命令并进入micro-state。

参数列表详见`spacemacs|define-micro-state'
对于micro-state的`:doc'参数如果传入auto，则根据键绑定和命令名自动生成doc"
  (let ((state-name (mms//generate-micro-state-name name))
        (binding-list (mms//get-function-key-list props)))
    (when (eql (plist-get props :doc) 'auto)
      (setq props (plist-put props :doc (mms//generate-document binding-list))))
    `(progn
       (spacemacs|define-micro-state ,name ,@props)
       (defalias (quote ,state-name) (quote ,(spacemacs//micro-state-func-name name)))
       ,@(mapcar #'(lambda (item)
                     (mms//generate-function-defination name (cdr item) state-name))
                 binding-list))))

(provide 'multiple-micro-state)

;;; multiple-micro-state.el ends here
