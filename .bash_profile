source ~/.bash/git-prompt
export PS1="$AF2[\A] $AF1\w $AF4\$(parse_git_branch)\n$AF7\$ $FINISH"

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

alias sub="open -a '/Applications/Sublime Text.app'"

alias inbox='cd ~/Desktop/Inbox'
alias outbox='cd ~/Desktop/Outbox'
alias archive='cd ~/Desktop/Archive'
alias ech='cd ~/echo360'

function npmdo { (PATH=$(npm bin):$PATH; eval $@;) }
alias serv='python -m SimpleHTTPServer 8888'

# Temporary stuff
alias afp-home='ssh -f jonathan@jmacqueen.duckdns.org -L 15548:192.168.1.129:548 sleep 360'
alias ytdl="youtube-dl -f 'bestvideo[height<=721]+bestaudio/best[height<=721]' --merge-output-format mp4"
alias ytdl-audio="youtube-dl -x --proxy http://192.168.9.128:8118 --restrict-filenames --audio-format mp3"

# command history
HISTFILESIZE=1000000
HISTSIZE=1000000
HISTCONTROL=ignoreboth
HISTIGNORE='l[stl]:[bf]g:history:exit:logout:clear'

shopt -s histverify

# save history after every command
PROMPT_COMMAND='history -a'

# Docker Commands
alias dcl="docker-compose logs -f --tail=100"
alias dcd="docker-compose down"
alias dcu="docker-compose up -d"
alias dcs="docker-compose stop"
alias dcr="docker-compose run --rm"
function dcid { docker ps | grep $1 | awk '{print $1}'; }

alias running="ps ax | grep java | awk -f ~/.bash/awk-portmap"

alias cp='cp -i'
alias mv='mv -i'

alias which='type -a'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

alias ls='ls -lah'

export CLICOLOR=true
export LSCOLORS="DxFxCxDxcxegedabagacad"

# Quick way to rebuild the Launch Services database and get rid
# of duplicates in the Open With submenu.
alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'

# Echo360
alias activator="/usr/local/bin/activator -J-Xmx6G -J-Xms2G -J-Xss1M -J-XX:+CMSClassUnloadingEnabled -J-XX:+UseCodeCacheFlushing -J-XX:+UseConcMarkSweepGC ${@}"

# bash_completion!
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

[[ -s ~/.bash_profile-local ]] && source ~/.bash_profile-local
[[ -s ~/.bashrc ]] && source ~/.bashrc
