#!/bin/bash
#
#  ex) \033[0;32m
#

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/:\1/'
}
function parse_git_tag {
  git describe --always 2>/dev/null
}
function set_git_prompt {
  PS1="\[$COLOR_CODE\]${debian_chroot:+($debian_chroot)}\u@\h:\w\[\033[00m\]\$(parse_git_branch):\$(parse_git_tag)\$ "
}
# ${var:+value} means: http://askubuntu.com/a/372876
set_git_prompt
