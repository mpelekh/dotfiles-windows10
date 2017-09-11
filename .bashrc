# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "(${BRANCH}${STAT})"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# NODE
# Show current version of node.
function get_node_version {

  # Show NODE status only for JS-specific folders
  	test -f package.json || test -d node_modules || return

	# NODE_VERSION=`node -v 2>/dev/null` - such string don't work
	NODE_VERSION=$(/c/Users/Kolya/scripts/get_node_version.sh 2>/dev/null)

	# NODE
	NODE_SYMBOL="${NODE_SYMBOL:="⬢ "}"
	NODE_PROMPT="${NODE_PROMPT:=" via ${NODE_SYMBOL}${NODE_VERSION}"}"

	echo "${NODE_PROMPT}"
}

PS1='\[\033]0;Bash Prompt (Git for Windows) => ${PWD//[^[:ascii:]]/?}\007\]' # set window title
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'\[\033[35m\]'       # change to purple
PS1="$PS1"'\u'                 # user@host<space>
PS1="$PS1"'\[\033[0m\]'        # change to white
	PS1="$PS1"'@'
PS1="$PS1"'\[\033[32m\]'       # change to green
	PS1="$PS1"'\h '
PS1="$PS1"'\[\033[35m\]'       # change to purple
#PS1="$PS1"'$MSYSTEM '         # show MSYSTEM
PS1="$PS1"'\[\033[33m\]'       # change to brownish yellow
PS1="$PS1"'\w'                 # current working directory

if test -z "$WINELOADERNOEXEC"
then
	GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
	COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
	COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
	COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
	if test -f "$COMPLETION_PATH/git-prompt.sh"
	then
		. "$COMPLETION_PATH/git-completion.bash"
		. "$COMPLETION_PATH/git-prompt.sh"
		PS1="$PS1"'\[\033[36m\]'  # change color to cyan
		PS1="$PS1"'`__git_ps1`'   # bash function
	fi
fi

# PS1="$PS1"'\[\e[36m\]'       # change to green
# PS1="$PS1"'`parse_git_branch`' # get node version


PS1="$PS1"'\[\033[32m\]'       # change to green
PS1="$PS1"'`get_node_version`' # get node version

PS1="$PS1"'\[\033[0m\]'        # change color
PS1="$PS1"'\n'                 # new line
PS1="$PS1"'$ '                 # prompt: always $

if [ -f ~/.bash_aliases ]; then
. ~/.bash_aliases
fi

#export PS1
#export PS1="\[\e[36m\]\u\[\e[m\]\[\e[31m\]@\[\e[m\]\[\e[32m\]\h\[\e[m\] \[\e[33m\]\W\[\e[m\] \[\e[36m\]\`parse_git_branch\`\[\e[m\] \[\e[32m\]\`get_node_version\`\[\e[m\]\n$ "