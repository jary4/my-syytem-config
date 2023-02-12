# .bashrc
#!/bin/bash
iatest=$(expr index "$-" i)


# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi


# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi


# foxy ros
source /opt/ros/foxy/setup.bash

# Ignore case on auto-completion
# Note: bind used instead of sticking these in .inputrc
if [[ $iatest > 0 ]]; then bind "set completion-ignore-case on"; fi

# Show auto-completion list automatically, without double tab
if [[ $iatest > 0 ]]; then bind "set show-all-if-ambiguous On"; fi


# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500

# Don't put duplicate lines in the history and do not add lines that start with a space
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Check the window size after each command and, if necessary, update the values of LINES and COLUMNS
shopt -s checkwinsize

# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
shopt -s histappend
PROMPT_COMMAND='history -a'


prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a Git repository.
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

            # Ensure the index is up to date.
            git update-index --really-refresh -q &>/dev/null;

            # Check for uncommitted changes in the index.
            if ! $(git diff --quiet --ignore-submodules --cached); then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules --); then
                s+='!';
            fi;

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?';
            fi;

            # Check for stashed files.
            if $(git rev-parse --verify refs/stash &>/dev/null); then
                s+='$';
            fi;

        fi;

        # Get the short symbolic ref.
        # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
        # Otherwise, just give up.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

        [ -n "${s}" ] && s=" [${s}]";

        echo -e "${1}${branchName}${2}${s}";
    else
        return;
    fi;
}


#color schemes and prompt
gitstatuscolor=$(tput setaf 220);
red=$(tput setaf 1);
light_blue=$(tput setaf 111)
green=$(tput setaf 82);
yellow=$(tput setaf 220);
blue=$(tput setaf 4);
bold=$(tput bold);
rest=$(tput sgr0);

PS1="\[\033]0;\w\007\]"; # Displays current working directory as title of the terminal
PS1+="\[${bold}\]\[${red}\]\n \T\[${green}\] \W\n"
PS1+="\[${bold}\]\[${yellow}\]"
PS1+="\$(prompt_git \"\[${yellow}\] \[${gitstatuscolor}\]\" \"\[${gitstatuscolor}\]\")";
PS1+="\[${bold}\]\[${red}\] # \[${light_blue}\]"
export PS1;




#alias
#for system commands
alias c="clear";
alias q="exit";
alias og="ls --color=auto -ogrt"
alias la="ls --color=auto -alF"
alias ll="ls --color=auto -l"
alias ls="ls --color=auto -C"
alias rm='rm -vrfi --preserve-root';
alias rp='rm -rf';
alias mv='mv -vi';
alias cp='cp -vip';
alias mkdir='mkdir -vp';
alias rmdir='rmdir -vp'
alias chmod='chmod -v';
alias grep='grep -n --color=auto';
alias find='sudo find ~ -name'
alias du='du -sh';
alias df="df -h";
alias diff='diff --suppress-common-lines';
#alias rr='find . -name "*~" | xargs rm -vrf' ;

#for user commands
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

alias python='python3';
alias pip='python3 -m pip';
alias activate='source venv/bin/activate';
alias create_env='virtualenv venv && activate';
alias ping='ping 8.8.8.8';

# Search running processes
alias p="ps aux | grep "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Search files in the current folder
alias f="find . | grep "

# Count all files (recursively) in the current folder
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

# Show current network connections to the server
alias ipview="netstat -anpl | grep :80 | awk {'print \$5'} | cut -d\":\" -f1 | sort | uniq -c | sort -n | sed -e 's/^ *//' -e 's/ *\$//'"

# Show open ports
alias openports='netstat -nape --inet'

# Alias's for safe and forced reboots
alias rebootsafe='sudo shutdown -r now'
alias rebootforce='sudo shutdown -r -n now'

# Alias's to show disk space and space used in a folder
alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'

# Alias's for archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Show all logs in /var/log
alias logs="sudo find /var/log -type f -exec file {} \; | grep 'text' | cut -d' ' -f1 | sed -e's/:$//g' | grep -v '[0-9]$' | xargs tail -f"


# Extracts any archive(s) (if unp isn't installed)
extract () {
	for archive in $*; do
		if [ -f $archive ] ; then
			case $archive in
				*.tar.bz2)   tar xvjf $archive    ;;
				*.tar.gz)    tar xvzf $archive    ;;
				*.bz2)       bunzip2 $archive     ;;
				*.rar)       rar x $archive       ;;
				*.gz)        gunzip $archive      ;;
				*.tar)       tar xvf $archive     ;;
				*.tbz2)      tar xvjf $archive    ;;
				*.tgz)       tar xvzf $archive    ;;
				*.zip)       unzip $archive       ;;
				*.Z)         uncompress $archive  ;;
				*.7z)        7z x $archive        ;;
				*)           echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}


# Searches for text in all files in the current folder
ftext ()
{
	# -i case-insensitive
	# -I ignore binary files
	# -H causes filename to be printed
	# -r recursive search
	# -n causes line number to be printed
	# optional: -F treat search term as a literal, not a regular expression
	# optional: -l only print filenames and not the matching lines ex. grep -irl "$1" *
	grep -iIHrn --color=always "$1" . | less -r
}

# Copy file with a progress bar
cpp()
{
	set -e
	strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
	| awk '{
	count += $NF
	if (count % 10 == 0) {
		percent = count / total_size * 100
		printf "%3d%% [", percent
		for (i=0;i<=percent;i++)
			printf "="
			printf ">"
			for (i=percent;i<100;i++)
				printf " "
				printf "]\r"
			}
		}
	END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

# Copy and go to the directory
cpg ()
{
	if [ -d "$2" ];then
		cp $1 $2 && cd $2
	else
		cp $1 $2
	fi
}

# Move and go to the directory
mvg ()
{
	if [ -d "$2" ];then
		mv $1 $2 && cd $2
	else
		mv $1 $2
	fi
}

# Create and go to the directory
mkdirg ()
{
	mkdir -p $1
	cd $1
}

# Goes up a specified number of directories  (i.e. up 4)
up ()
{
	local d=""
	limit=$1
	for ((i=1 ; i <= limit ; i++))
		do
			d=$d/..
		done
	d=$(echo $d | sed 's/^\///')
	if [ -z "$d" ]; then
		d=..
	fi
	cd $d
}


# Show the current distribution
distribution ()
{
	local dtype
	# Assume unknown
	dtype="unknown"
	
	# First test against Fedora / RHEL / CentOS / generic Redhat derivative
	if [ -r /etc/rc.d/init.d/functions ]; then
		source /etc/rc.d/init.d/functions
		[ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
	
	# Then test against SUSE (must be after Redhat,
	# I've seen rc.status on Ubuntu I think? TODO: Recheck that)
	elif [ -r /etc/rc.status ]; then
		source /etc/rc.status
		[ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
	
	# Then test against Debian, Ubuntu and friends
	elif [ -r /lib/lsb/init-functions ]; then
		source /lib/lsb/init-functions
		[ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
	
	# Then test against Gentoo
	elif [ -r /etc/init.d/functions.sh ]; then
		source /etc/init.d/functions.sh
		[ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
	
	# For Mandriva we currently just test if /etc/mandriva-release exists
	# and isn't empty (TODO: Find a better way :)
	elif [ -s /etc/mandriva-release ]; then
		dtype="mandriva"

	# For Slackware we currently just test if /etc/slackware-version exists
	elif [ -s /etc/slackware-version ]; then
		dtype="slackware"

	fi
	echo $dtype
}


# Show the current version of the operating system
ver ()
{
	local dtype
	dtype=$(distribution)

	if [ $dtype == "redhat" ]; then
		if [ -s /etc/redhat-release ]; then
			cat /etc/redhat-release && uname -a
		else
			cat /etc/issue && uname -a
		fi
	elif [ $dtype == "suse" ]; then
		cat /etc/SuSE-release
	elif [ $dtype == "debian" ]; then
		lsb_release -a
		# sudo cat /etc/issue && sudo cat /etc/issue.net && sudo cat /etc/lsb_release && sudo cat /etc/os-release # Linux Mint option 2
	elif [ $dtype == "gentoo" ]; then
		cat /etc/gentoo-release
	elif [ $dtype == "mandriva" ]; then
		cat /etc/mandriva-release
	elif [ $dtype == "slackware" ]; then
		cat /etc/slackware-version
	else
		if [ -s /etc/issue ]; then
			cat /etc/issue
		else
			echo "Error: Unknown distribution"
			exit 1
		fi
	fi
}


# Automatically install the needed support files for this .bashrc file
install_bashrc_support ()
{
	local dtype
	dtype=$(distribution)

	if [ $dtype == "redhat" ]; then
		sudo yum install multitail tree joe
	elif [ $dtype == "suse" ]; then
		sudo zypper install multitail
		sudo zypper install tree
		sudo zypper install joe
	elif [ $dtype == "debian" ]; then
		sudo apt-get install multitail tree joe
	elif [ $dtype == "gentoo" ]; then
		sudo emerge multitail
		sudo emerge tree
		sudo emerge joe
	elif [ $dtype == "mandriva" ]; then
		sudo urpmi multitail
		sudo urpmi tree
		sudo urpmi joe
	elif [ $dtype == "slackware" ]; then
		echo "No install support for Slackware"
	else
		echo "Unknown distribution"
	fi
}



update(){
    echo -e "\nstarting update\n"
    sudo apt-get update;
    echo -e "\nstarting upgrade\n"
    sudo apt-get upgrade;
    echo -e "\ncleaning the system\n"
    sudo apt-get autoremove;
    #sudo apt-get autoclean;
    echo -e "\nthe system is updated and cleaned\n"
}


# Show current network information
netinfo ()
{
	echo "--------------- Network Information ---------------"
	/sbin/ifconfig | awk /'inet addr/ {print $2}'
	echo ""
	/sbin/ifconfig | awk /'Bcast/ {print $3}'
	echo ""
	/sbin/ifconfig | awk /'inet addr/ {print $4}'

	/sbin/ifconfig | awk /'HWaddr/ {print $4,$5}'
	echo "---------------------------------------------------"
}


# IP address lookup
alias whatismyip="whatsmyip"
function whatsmyip ()
{
	# Dumps a list of all IP addresses for every device
	# /sbin/ifconfig |grep -B1 "inet addr" |awk '{ if ( $1 == "inet" ) { print $2 } else if ( $2 == "Link" ) { printf "%s:" ,$1 } }' |awk -F: '{ print $1 ": " $3 }';

	# Internal IP Lookup
	echo -n "Internal IP: " ; /sbin/ifconfig eth0 | grep "inet addr" | awk -F: '{print $2}' | awk '{print $1}'

	# External IP Lookup
	echo -n "External IP: " ; wget http://smart-ip.net/myip -O - -q
}


# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH
PATH=/opt/firefox/firefox:$PATH
# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi

unset rc

PATH=$PATH:/usr/local/bin
PATH=$PATH:$HOME/nodejs/bin

############# OLD CONFIGURATIONS ##########################

#usernamecolor=$(tput setaf 35);
#locationcolor=$(tput setaf 33);
#workingdirectorycolor=$(tput setaf 35);
#white=$(tput setaf 15);
#red=$(tput setaf 1);
#green=$(tput setaf 2);
#yellow=$(tput setaf 3);
#gitstatuscolor=$(tput setaf 220);
#bold=$(tput bold);
#reset=$(tput sgr0);
#PS1="\[\033]0;\w\007\]"; # Displays current working directory as title of the terminal
#PS1+="\[${bold}\]\n(\d) \T\n";
#PS1+="\[${usernamecolor}\]\u"; # Displays username
#PS1+="\[${white}\] at ";
#PS1+="\[${locationcolor}\]\h"; # Displays host/device
#PS1+="\[${white}\] in ";
#PS1+="\[${red}\]\n\T "
#PS1+="\[${workingdirectorycolor}\]\w"; # Displays base path of current working directory
#PS1+="\$(prompt_git \"\[${yellow}\] on \[${gitstatuscolor}\]\" \"\[${gitstatuscolor}\]\")"; # Displays git status
#PS1+="\n";
#PS1+="\[${red}\]kowalski # \[${reset}\]";
#export PS1;


########################## CUSTOM FUNCTIONS ##################


# Make a directory and jump right into it. Combination of mkdir and cd. Just use 'mkcdir folder_name'
# mkcdir()
# {
#     mkdir -vp -- "$1" &&
#     echo -e "Entred $1"
#         cd -P -- "$1"
# }


# currency()
# {
#     tempAppID=0e71a2430e4d43bdbc28e3b4282ca6a2
#         # Default: 1 USD to INR
#         # Usage: currency
#         if [ -z "$1" ]; then
#                 echo
#                 curval=$(curl -s -X GET https://openexchangerates.org/api/latest.json?app_id=${tempAppID} | jq -r '.rates.INR')
#                 echo "1 USD = "${curval}" INR"
#         else
#                 # A certain value to INR
#                 # Usage: currency 250
#                 if [ -z "$2" ]; then
#                         echo
#                         curval=$(curl -s -X GET https://openexchangerates.org/api/latest.json?app_id=${tempAppID} | jq -r ".rates.INR * "$1"")
#                         echo "$1 USD = "${curval}" INR" | lolcat
#                 else
#                         # Certain value to certain currency
#                         # Usage: currency 250 EUR
#                         echo
# curval=$(curl -s -X GET https://openexchangerates.org/api/latest.json?app_id=${tempAppID} | jq -r ".rates."$2" * "$1"")
#                         echo "$1 USD = "${curval}" $2" | lolcat
#                 fi
#         fi
# }
# news()
# {       COLUMNS=$(tput cols)
#     # Remove any source from below array if needed
#         declare -a sources=("google-news" "hacker-news" "mashable" "polygon" "techcrunch" "techradar" "the-next-web" "the-verge" "wired-de")
#         for i in "${sources[@]}"
#         do
#                 echo
#                 header="Source: "$i""
#                 printf "%*s\n" $(((${#header}+$COLUMNS)/2)) "$header"
#                 echo
#         # n=20 below displays 20 articles if available.
#                 curl getnews.tech/"$i"?n=20\&w="$(tput cols)"
#         done
# }
# Shows current weather, live currency and a random quote at terminal startup.
# Comment any or all below to disable startup runs for each.
# weather
# currency
# Update, upgrade and clean dnf packages in your system with just one command. Just type 'update' in terminal
#update () {
    #echo -e "\nStarting system update...\n"
    #echo -e "\nChecking for updates..."
    #echo -e "\nEnter the Secret passward..."
    #echo -e "\nUpdating the packages..."
    # sudo apt update -qq "for skipping the list of updates"
    #sudo apt update
    #echo -e "\nUpgrading packages to newer version..."
    #sudo apt upgrade
    #echo -e "\nRemoving packages no more needed as dependencies..."
    #sudo apt autoremove
    # echo -e "\nRemoving packages that can no longer be downloaded..."
    # sudo dnf autoclean
    # echo -e "\nClearing out local repository of retrieved package files..."
    # sudo dnf clean
    #echo -e "\nUpdate complete!"
#}
# Quickly check weather for your city right inside the terminal by typing 'weather'
# Remove 'm' from the url to use Fahrenheit instead of Celsius
# weather() {
#         if [ -z "$1" ]; then
#                 echo
#                 curl -s wttr.in/?0mq
#         else
#                 echo
#                 curl -s wttr.in/"$1"?0mq
#         fi
# }
# }


# View Apache logs
# apachelog ()
# {
# 	if [ -f /etc/httpd/conf/httpd.conf ]; then
# 		cd /var/log/httpd && ls -xAh && multitail --no-repeat -c -s 2 /var/log/httpd/*_log
# 	else
# 		cd /var/log/apache2 && ls -xAh && multitail --no-repeat -c -s 2 /var/log/apache2/*.log
# 	fi
# }

# # Edit the Apache configuration
# apacheconfig ()
# {
# 	if [ -f /etc/httpd/conf/httpd.conf ]; then
# 		sedit /etc/httpd/conf/httpd.conf
# 	elif [ -f /etc/apache2/apache2.conf ]; then
# 		sedit /etc/apache2/apache2.conf
# 	else
# 		echo "Error: Apache config file could not be found."
# 		echo "Searching for possible locations:"
# 		sudo updatedb && locate httpd.conf && locate apache2.conf
# 	fi
# }

# # Edit the PHP configuration file
# phpconfig ()
# {
# 	if [ -f /etc/php.ini ]; then
# 		sedit /etc/php.ini
# 	elif [ -f /etc/php/php.ini ]; then
# 		sedit /etc/php/php.ini
# 	elif [ -f /etc/php5/php.ini ]; then
# 		sedit /etc/php5/php.ini
# 	elif [ -f /usr/bin/php5/bin/php.ini ]; then
# 		sedit /usr/bin/php5/bin/php.ini
# 	elif [ -f /etc/php5/apache2/php.ini ]; then
# 		sedit /etc/php5/apache2/php.ini
# 	else
# 		echo "Error: php.ini file could not be found."
# 		echo "Searching for possible locations:"
# 		sudo updatedb && locate php.ini
# 	fi
# }

# # Edit the MySQL configuration file
# mysqlconfig ()
# {
# 	if [ -f /etc/my.cnf ]; then
# 		sedit /etc/my.cnf
# 	elif [ -f /etc/mysql/my.cnf ]; then
# 		sedit /etc/mysql/my.cnf
# 	elif [ -f /usr/local/etc/my.cnf ]; then
# 		sedit /usr/local/etc/my.cnf
# 	elif [ -f /usr/bin/mysql/my.cnf ]; then
# 		sedit /usr/bin/mysql/my.cnf
# 	elif [ -f ~/my.cnf ]; then
# 		sedit ~/my.cnf
# 	elif [ -f ~/.my.cnf ]; then
# 		sedit ~/.my.cnf
# 	else
# 		echo "Error: my.cnf file could not be found."
# 		echo "Searching for possible locations:"
# 		sudo updatedb && locate my.cnf
# 	fi
# }

# # For some reason, rot13 pops up everywhere
# rot13 () {
# 	if [ $# -eq 0 ]; then
# 		tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
# 	else
# 		echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
# 	fi
# }

# # Trim leading and trailing spaces (for scripts)
# trim()
# {
# 	local var=$@
# 	var="${var#"${var%%[![:space:]]*}"}"  # remove leading whitespace characters
# 	var="${var%"${var##*[![:space:]]}"}"  # remove trailing whitespace characters
# 	echo -n "$var"
# }


# function set_virtualenv () {
#   if test -z "$VIRTUAL_ENV" ; then
#       PYTHON_VIRTUALENV=""
#   else
#       PYTHON_VIRTUALENV="${BLUE}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE} "
#   fi
# }


# # determine git branch name
# function parse_git_branch(){
#   git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
# }

# # determine mercurial branch name
# function parse_hg_branch(){
#   hg branch 2> /dev/null | awk '{print " (" $1 ")"}'
# }

# # Determine the branch/state information for this git repository.
# function set_git_branch() {
#   # Get the name of the branch.
#   branch=$(parse_git_branch)
#   # if not git then maybe mercurial
#   if [ "$branch" == "" ]
#   then
#     branch=$(parse_hg_branch)
#   fi

#   # Set the final branch string.
#   BRANCH="${PURPLE}${branch}${COLOR_NONE} "
# }

#######################################################
# Set the ultimate amazing command prompt
#######################################################

# alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"
# function __setprompt
# {
# 	local LAST_COMMAND=$? # Must come first!

#   bold=$(tput bold)

# 	# Define colors
# 	local LIGHTGRAY="\033[0;37m"
# 	local WHITE="\033[1;37m"
# 	local BLACK="\033[0;30m"
# 	local DARKGRAY="\033[1;30m"
# 	local RED="\033[0;31m"
# 	local LIGHTRED="\033[1;31m"
# 	local GREEN="\033[0;32m"
# 	local LIGHTGREEN="\033[1;32m"
# 	local BROWN="\033[0;33m"
# 	local YELLOW="\033[1;33m"
# 	local BLUE="\033[0;34m"
# 	local LIGHTBLUE="\033[1;34m"
# 	local MAGENTA="\033[0;35m"
# 	local LIGHTMAGENTA="\033[1;35m"
# 	local CYAN="\033[0;36m"
# 	local LIGHTCYAN="\033[1;36m"
# 	local NOCOLOR="\033[0m"

# 	# Show error exit code if there is one
# 	if [[ $LAST_COMMAND != 0 ]]; then
# 		# PS1="\[${RED}\](\[${LIGHTRED}\]ERROR\[${RED}\])-(\[${LIGHTRED}\]Exit Code \[${WHITE}\]${LAST_COMMAND}\[${RED}\])-(\[${LIGHTRED}\]"
# 		PS1="\[${DARKGRAY}\](\[${LIGHTRED}\]ERROR\[${DARKGRAY}\])-(\[${RED}\]Exit Code \[${LIGHTRED}\]${LAST_COMMAND}\[${DARKGRAY}\])-(\[${RED}\]"
# 		if [[ $LAST_COMMAND == 1 ]]; then
# 			PS1+="General error"
# 		elif [ $LAST_COMMAND == 2 ]; then
# 			PS1+="Missing keyword, command, or permission problem"
# 		elif [ $LAST_COMMAND == 126 ]; then
# 			PS1+="Permission problem or command is not an executable"
# 		elif [ $LAST_COMMAND == 127 ]; then
# 			PS1+="Command not found"
# 		elif [ $LAST_COMMAND == 128 ]; then
# 			PS1+="Invalid argument to exit"
# 		elif [ $LAST_COMMAND == 129 ]; then
# 			PS1+="Fatal error signal 1"
# 		elif [ $LAST_COMMAND == 130 ]; then
# 			PS1+="Script terminated by Control-C"
# 		elif [ $LAST_COMMAND == 131 ]; then
# 			PS1+="Fatal error signal 3"
# 		elif [ $LAST_COMMAND == 132 ]; then
# 			PS1+="Fatal error signal 4"
# 		elif [ $LAST_COMMAND == 133 ]; then
# 			PS1+="Fatal error signal 5"
# 		elif [ $LAST_COMMAND == 134 ]; then
# 			PS1+="Fatal error signal 6"
# 		elif [ $LAST_COMMAND == 135 ]; then
# 			PS1+="Fatal error signal 7"
# 		elif [ $LAST_COMMAND == 136 ]; then
# 			PS1+="Fatal error signal 8"
# 		elif [ $LAST_COMMAND == 137 ]; then
# 			PS1+="Fatal error signal 9"
# 		elif [ $LAST_COMMAND -gt 255 ]; then
# 			PS1+="Exit status out of range"
# 		else
# 			PS1+="Unknown error code"
# 		fi
# 		PS1+="\[${DARKGRAY}\])\[${NOCOLOR}\]\n"
# 	else
# 		PS1=""
# 	fi

# 	# Date
# 	# PS1+="\[${DARKGRAY}\](\[${CYAN}\]\$(date +%a) $(date +%b-'%-m')" # Date
# 	# PS1+="${BLUE} ($(date +'%-I':%M:%S%P)\[${DARKGRAY}\])-" # Time
# 	# PS1+="${DARKGRAY}(\[${BLUE}$(date +'%-I':%M:%S%P)\[${DARKGRAY}\])-" # Time

# 	# CPU
# 	# PS1+="(\[${MAGENTA}\]CPU $(cpu)%"

# 	# Jobs
# 	# PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]\j"

# 	# Network Connections (for a server - comment out for non-server)
# 	# PS1+="\[${DARKGRAY}\]:\[${MAGENTA}\]Net $(awk 'END {print NR}' /proc/net/tcp)"

# 	#virenv
# 	set_virtualenv
# 	PS1+="\[${PYTHON_VIRTUALENV}\]"

# 	# PS1+="\[${DARKGRAY}\])-"
# 	PS1+="\[${DARKGRAY}\]"

# 	# User and server
# 	#local SSH_IP=`echo $SSH_CLIENT | awk '{ print $1 }'`
#   #local SSH2_IP=`echo $SSH2_CLIENT | awk '{ print $1 }'`
# 	#if [ $SSH2_IP ] || [ $SSH_IP ] ; then
# 	#	PS1+="(\[${RED}\]\u@\h"
# 	#else
# 	#	PS1+="(\[${RED}\]\u"
# 	#fi

# 	# Current directory
# 	# PS1+="\[${DARKGRAY}\]:\[${BROWN}\]\w\[${DARKGRAY}\])-"
# 	PS1+="(\[${RED}\]Mohammed"
#   PS1+="\[${DARKGRAY}\]:\[${BROWN}\]\W\[${DARKGRAY}\])"

# 	#git brach
# 	set_git_branch
# 	PS1+="\[${CYAN}\]\[${BRANCH}\]"


# 	# # Total size of files in current directory
# 	# PS1+="(\[${GREEN}\]$(/bin/ls -lah | /bin/grep -m 1 total | /bin/sed 's/total //')\[${DARKGRAY}\]:"

# 	# # Number of files
# 	# PS1+="\[${GREEN}\]\$(/bin/ls -A -1 | /usr/bin/wc -l)\[${DARKGRAY}\])"

# 	# Skip to the next line
# 	PS1+="\n"

# 	if [[ $EUID -ne 0 ]]; then
# 		PS1+="\[${GREEN}\]>\[${NOCOLOR}\] " # Normal user
# 	else
# 		PS1+="\[${RED}\]>\[${NOCOLOR}\] " # Root user
# 	fi

# 	# PS2 is used to continue a command using the \ character
# 	# PS2="\[${DARKGRAY}\]>\[${NOCOLOR}\] "

# 	# # PS3 is used to enter a number choice in a script
# 	# PS3='Please enter a number from above list: '

# 	# # PS4 is used for tracing a script in debug mode
# 	# PS4='\[${DARKGRAY}\]+\[${NOCOLOR}\] '
# }
# PROMPT_COMMAND='__setprompt'
