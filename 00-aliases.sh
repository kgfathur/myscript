#!/bin/bash
alias gsa='f(){ gnome-screenshot -a "$@";  unset -f f; }; f'
alias gsi='f(){ gnome-screenshot -i "$@";  unset -f f; }; f'
alias gss='f(){ gnome-screenshot "$@";  unset -f f; }; f'
alias gsw='f(){ gnome-screenshot -w "$@";  unset -f f; }; f'
alias gsaf='f(){ gnome-screenshot -a -f $1.png;  unset -f f; }; f'
alias gsif='f(){ gnome-screenshot -i -f $1.png;  unset -f f; }; f'
alias gssf='f(){ gnome-screenshot -f $1.png;  unset -f f; }; f'
alias gswf='f(){ gnome-screenshot -w -f $1.png;  unset -f f; }; f'
alias git-create='f(){ curl -u $1 https://api.github.com/user/repos -d "{\"name\":\"$2\"}";  unset -f f; }; f'
alias grepe='grep -ve ^# -e ^$'


