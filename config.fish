export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
if status is-interactive
    # Commands to run in interactive sessions can go here
end
if type -q exa
    alias ll "exa -l -g --icons"
    alias lla "ll -a"
    . ~/.config/bashScripts/aliases.sh
end
