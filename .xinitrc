#!/bin/sh
# vim: set syntax=sh

source $HOME/.profile
rm /usr/local/share/dzen/{dmpipe,gpipe}

# if [ -z "`ps -e | grep remind | grep -v grep`" ]; then
#   remind -z '-kgxmessage %s &' ~/.reminders &!
# fi

if [ -z "`ps -e | grep dbus | grep session | grep -v grep`" ]; then
  launchctl load -w /Library/LaunchAgents/org.freedesktop.dbus-session.plist
fi

if [ -z "`ps -e | grep dbus | grep system | grep -v grep`" ]; then
  launchctl load -w /Library/LaunchDaemons/org.freedesktop.dbus-system.plist
fi

xset -b b off
xset b 0 0 0
xsetroot -solid black
xset +fp /opt/local/share/fonts
xset fp rehash
fc-cache

xrdb -l ~/.Xresources
xrdb -m ~/.Xdefaults
xmodmap ~/.Xmodmap

export DBUS_LAUNCHD_SESSION_BUS_SOCKET=`launchctl getenv DBUS_LAUNCHD_SESSION_BUS_SOCKET`
eval `ssh-agent`
eval `/usr/local/bin/gpg-agent --launchd --write-env-file --use-standard-socket`

export RXVT_SOCKET=$HOME/.rxvt_socket
/usr/local/bin/urxvtd -q -o &

if [[ "$USERWM" == "xmonad" ]]; then
    quartz-wm --only-proxy 2>| /dev/null 1>| /dev/null &
    /usr/local/bin/xmonad 2>| /dev/null 1>| /dev/null & 
    # > /usr/local/share/dzen/dmpipe 
    # /usr/local/bin/urxvt &
    # /usr/local/share/dzen/scripts/dzen_status.sh &
    # /usr/local/share/dzen/scripts/dzen_wifi2.zsh &
    # /usr/local/share/dzen/scripts/dzendate.zsh &
    # /usr/local/share/dzen/scripts/dzen_xmonad.zsh &
    # /usr/local/share/dzen/scripts/dzen_mail.zsh &
    /usr/local/share/dzen/scripts/workspaces.zsh 2>| /dev/null 1>| /dev/null &
    /usr/local/share/dzen/scripts/gadgetbar.zsh 2>| /dev/null 1>| /dev/null &

elif [[ "$USERWM" == "awesome" ]]; then
    # no quartz
    /opt/local/bin/awesome
elif [[ "$USERWM" == "none" ]]; then
    quartz-wm &
    /usr/local/bin/urxvt
fi

wait
