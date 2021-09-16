# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
# while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-11));echo -e "\e[31m`date +%r`\e[39m";tput rc;done &


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


usernamecolor=$(tput setaf 35);
locationcolor=$(tput setaf 33);
workingdirectorycolor=$(tput setaf 35);
white=$(tput setaf 9);
#white previous value 15
gitstatuscolor=$(tput setaf 220);
bold=$(tput bold);
reset=$(tput sgr0);

PS1="\[\033]0;\w\007\]"; # Displays current working directory as title of the terminal
#PS1+="\[${bold}\]\n(\d) \T\n";
#PS1+="\[${usernamecolor}\]\u"; # Displays username
#PS1+="\[${white}\] at ";
#PS1+="\[${locationcolor}\]\h"; # Displays host/device
#PS1+="\[${white}\] in ";
PS1+="\[${white}\]\n\T "
PS1+="\[${workingdirectorycolor}\]\w"; # Displays base path of current working directory
PS1+="\$(prompt_git \"\[${white}\] on \[${gitstatuscolor}\]\" \"\[${gitstatuscolor}\]\")"; # Displays git status
PS1+="\n";
PS1+="\[${white}\]kowalski # \[${reset}\]";
export PS1;

# Quickly find out external IP address for your device by typing 'xip'
#alias speedTest='echo; curl -o /dev/null http://speedtest.wdc01.softlayer.com/downloads/test10.zip';
alias xip='echo; curl -s ipinfo.io; echo;'
alias c='clear'
alias q='exit'
alias ll='ls --color=auto -l'
alias la='ls --color=auto -alF'
alias ls='ls --color=auto'
alias ..='cd ..'
alias ...='cd ../..';
alias rm='rm -vrfi --preserve-root';
alias rp='rm -rf';
alias rr='find . -name "*~" | xargs rm -vrf' ;
alias mv='mv -vi';
alias cp='cp -vip';
alias mkdir='mkdir -vp';
alias chmod='chmod -v';
alias grep='grep -n --color=auto';
alias du='du -sh';
alias df="df -h";
alias diff='diff --suppress-common-lines';
alias x='exit';
alias q='exit';
alias activate='source venv/bin/activate';
alias create_env='virtualenv venv && activate';
alias ping='ping 8.8.8.8';
alias python='python3';
alias pip='python3 -m pip';
alias sys_config='neofetch && df';
alias bashrc='vim ~/.bashrc'
alias vimrc='vim ~/.vimrc'
alias python_ignore='cp ~/Templates/python.gitigonre ./.gitignore';
alias gotocode="cd ~/user/code"

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

# Make a directory and jump right into it. Combination of mkdir and cd. Just use 'mkcdir folder_name'
mkcdir()
{
    mkdir -vp -- "$1" &&
    echo -e "Entred $1"
        cd -P -- "$1"
}


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

update(){
    echo -e "\nstarting update\n"
    sudo apt-get update;
    echo -e "\nstarting upgrade\n"
    sudo apt-get upgrade;
    echo -e "\ncleaning the system\n"
    sudo apt-get autoremove;
    #sudo apt-get autoclean;
    echo -e "\nthe system is update and cleaned\n"
}


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
