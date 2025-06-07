setopt autocd
# setopt correct
# setopt noclobber
setopt PROMPT_SUBST
stty -ixon

##########
# HISTORY
##########

HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt INC_APPEND_HISTORY # Immediately append to history file:
setopt EXTENDED_HISTORY # Record timestamp in history:
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history:
setopt HIST_IGNORE_DUPS # Dont record an entry that was just recorded again:
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate:
setopt HIST_FIND_NO_DUPS # Do not display a line previously found:
setopt HIST_IGNORE_SPACE # Dont record an entry starting with a space:
setopt HIST_SAVE_NO_DUPS # Dont write duplicate entries in the history file:
setopt SHARE_HISTORY # Share history between all sessions:
# unsetopt HIST_VERIFY # Execute commands using history (e.g.: using !$) immediatel:

# history search based on prefix
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Load version control information
autoload -Uz vcs_info
precmd() { vcs_info && print -Pn "\e]2;%n - %~\a"} # also update pwd in window title
# precmd() { vcs_info }

# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '%{%F{green}%B%}!%{%b%f%}'
zstyle ':vcs_info:*' stagedstr '%{%F{green}%B%}+%{%b%f%}'

zstyle ':vcs_info:git:*' formats '%u%c %F{green}[%b]'
zstyle ':vcs_info:git:*' actionformats '%F{red}(%a) %u%c %F{green}[%b]'


if [[ $SHLVL -gt 1 ]]
then
	PHEAD=""
	# PHEAD=⍜
else
	PHEAD=""
fi
NEWLINE=$'\n'
DIM='%{\033[2m%}'
RESET='%{\033[0m%}'
HORIZONTAL_RULE="$(printf '%*s' "$(tput cols)" '' | tr ' ' '─')"

PROMPT='${NEWLINE}${PHEAD}%F{yellow}[%T] %F{blue}%~ ${vcs_info_msg_0_}${NEWLINE}%F{yellow}>>%f '
# RPROMPT='${vcs_info_msg_0_}'

alias serv='python -m SimpleHTTPServer 8888'

# Temporary stuff
alias afp-home='ssh -f jonathan@jmacqueen.duckdns.org -L 15548:192.168.1.129:548 sleep 360'
alias ytdl="yt-dlp -S res,ext:mp4:m4a --proxy http://192.168.9.133:8118 --recode mp4"
alias ytdl-audio="yt-dlp -x --proxy http://192.168.9.133:8118 --restrict-filenames --audio-format mp3"

# Docker Commands
alias dcl="docker-compose logs -f --tail=100"
alias dcd="docker-compose down"
alias dcu="docker-compose up -d"
alias dcs="docker-compose stop"
alias dcr="docker-compose run --rm"
function dcid { docker ps | grep $1 | awk '{print $1}'; }

alias cp='cp -i'
alias mv='mv -i'
alias path='echo -e ${PATH//:/\\n}'

alias which='type -a'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'

alias du='du -kh'    # Makes a more readable output.
alias df='df -kTh'

alias ll='ls -Glah'
alias srcenv='set -a; source .env; set +a'

# Use ack to locate TOD* and FIXM* lines in current folder tree
alias todos='ack --nobreak --nocolor "(TODO|FIXME):"|sed -E "s/(.*:[[:digit:]]+):.*((TODO|FIXME):.*)/\2 :>> \1/"|grep -E --color=always ":>>.*:\d+"'

# git delete local branches that aren't on origin
alias clean-local-branches='git remote prune origin && git branch --merged origin/master | grep -Ev "master|qa|production" | xargs git branch -d && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -D'

# activate and configure completion
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# use jq to find all keys in a JSON with array root
alias jsonkeys="jq 'select(objects)|=[.] | map(paths(scalars))| map( map(select(numbers)=\"[]\") | join(\".\") ) | unique'"

# keep checking a website for a string
alias pagechecker='for i in `seq 1 40`; do curl -s "https://corehomefitness.com/products/adjustable-dumbbell-set" | grep "Default Title - Sold Out" && echo "`date` Still Sold Out" || echo "Get in there! `date`\a\a\a\a\a"; sleep 900; done'

# functions
# color contrast
constrast () {
	if [[ $1 == '-h' ]] || [[ $1 == '' ]]
	then
		echo "USAGE: contrast foreground background"
    echo "colors are hex codes, with no #"
    echo "e.g. 12a432"
	else
    echo "Foreground: #$1"
    echo "Background: #$2"
    curl -s "https://webaim.org/resources/contrastchecker/?fcolor=$1&bcolor=$2&api" | jq .
	fi
}

# search for imports in a JS project
grepImports () {
	if [[ $1 == '-l' ]]
	then
		ack --range-start='(^import|require\()' --range-end=';' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' -lc $2
	elif [[ $1 == '-c' ]]
	then
		ack --range-start='(^import|require\()' --range-end=';' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' -l $2 | wc -l
	else
		ack --range-start='(^import|require\()' --range-end=';' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' $1
	fi
}

# search for prop usage in a JS project, breaks for props containing components
grep-prop-usage () {
	if [[ $1 == '-l' ]]
	then
		ack --range-start="<$2" --range-end='/>$' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' -lc --match $3
	elif [[ $1 == '-c' ]]
        then
		ack --range-start="<$2" --range-end='/>$' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' -l --match $3 | wc -l
	elif [[ $1 == '-h' ]]
	then
		echo "USAGE: grep-prop-usage [OPTIONS] componentName prop"
		echo "-l : list files including count of matches per file"
		echo "-c : count of matching files"
	else
		ack --range-start="<$1" --range-end='/>$' --ignore-dir='dist' --type='js' --ignore-file='match:.spec.js' --match $2
	fi
}

# run git grep in all subdirectories
ggrep-all () {
        for i in ./*/; do ( cd $i; pwd; git grep $1 HEAD ); done
}

autoload -Uz compinit
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate # enable approximate matches for completion

eval "$(fzf --zsh)" # fzf shell integration
alias fshow="~/scripts/fshow.sh"

export PATH="/Users/jonathan/.local/bin:$PATH

[[ -s ~/.zshrc-local ]] && source ~/.zshrc-local

