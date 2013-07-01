jdee-mvn settings for Eamcs 
========

I set this files in JDEE for Maven support



## Usage

Copy two files in ~/.emacs.d/ 

Add code to .emacs 

```elisp

(require 'jde-mvn)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(jde-build-function (quote jde-mvn))
 '(jde-global-classpath (quote ("/Users/<user-id>/work/android/sdk/platforms/android-17/android.jar" 
                                "/Users/<user-id>/.emacs.d/jdee/build/classes")))
 '(jde-mvn-enable-find t)
 '(tab-width 2))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


```


## License


Copyleft (C) 2012 crazia 

Distributed under the Eclipse Public License, the same as Clojure.

