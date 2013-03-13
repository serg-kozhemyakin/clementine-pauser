(use dbus)
(use posix)
(use (prefix dbus dbus:))

(define screensaver-context (dbus:make-context
                             service: 'org.gnome.ScreenSaver
                             path: '/org/gnome/ScreenSaver
                             interface: 'org.gnome.ScreenSaver ))

(define clementine-context (dbus:make-context
                            service: 'org.mpris.clementine
                            path: '/Player
                            interface: 'org.freedesktop.MediaPlayer ))

(define (control-clementine state)
  (cond
    [(eq? state 'play) (dbus:call clementine-context "Play")]
    [(eq? state 'pause) (dbus:call clementine-context "Pause")]))

(define (play-pause state)
  (if state (control-clementine 'pause)
      (control-clementine 'play)))

(dbus:register-signal-handler screensaver-context 'ActiveChanged play-pause)

(dbus:enable-polling-thread! enable: #f)

(let loop ()
  (dbus:poll-for-message )
  (sleep 1)
  (loop))
