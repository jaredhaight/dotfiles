# Add timestamp to prompt
if [ "$color_prompt" = yes ]; then
    PS1='\n[\D{%F} \t][${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h]\n\[\033[00m\]\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\n[\D{%F} \t][${debian_chroot:+($debian_chroot)}\u@\h]\n\w\$ '
fi

# Log bash commands
export PROMPT_COMMAND='echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log;'