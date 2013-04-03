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

(define prop-context (dbus:make-context
                      service: 'org.mpris.clementine
                      path: '/org/mpris/MediaPlayer2
                      interface: 'org.freedesktop.DBus.Properties ))

(define paused-by-pauser #f)

(define (clementine-playing?)
  (string=? "Playing"
            (variant-data
             (car (dbus:call prop-context "Get" "org.mpris.MediaPlayer2.Player" "PlaybackStatus")))))

(define (control-clementine state)
  (cond
    [(eq? state 'play)
     (if paused-by-pauser
         (dbus:call clementine-context "Play"))]
    [(eq? state 'pause)
     (if (set! paused-by-pauser (clementine-playing?))
           (dbus:call clementine-context "Pause"))]
    ))

(define (play-pause state)
  (if state (control-clementine 'pause)
      (control-clementine 'play)))

(dbus:enable-polling-thread! enable: #f)

(dbus:register-signal-handler screensaver-context 'ActiveChanged play-pause)

(let loop ()
  (dbus:poll-for-message )
  (sleep 1)
  (loop))
