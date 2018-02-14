# Standard User Prompt: Place this above 'unset color_prompt force_color_prompt' in ~/.bashrc. Line ~65ish
if [ "$color_prompt" = yes ]; then
    PS1='\n[${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u@\h\[\033[00m\]:\[\033[00;36m\]\w\[\033[00m\]]\n\$ '
else
    PS1='\n[${debian_chroot:+($debian_chroot)}\u@\h]\w\n\$ '
fi


# Root User Prompt: Place this above 'unset color_prompt force_color_prompt' in /root/.bashrc. Line ~65ish
if [ "$color_prompt" = yes ]; then
    PS1='\n[${debian_chroot:+($debian_chroot)}\[\033[00;31m\]\u@\h\[\033[00m\]:\[\033[00;36m\]\w\[\033[00m\]]\n\$ '
else
    PS1='\n[${debian_chroot:+($debian_chroot)}\u@\h]\w\n\$ '
fi

# Log bash commands
export PROMPT_COMMAND='echo "$(date "+%Y-%m-%d.%H:%M:%S") $(pwd) $(history 1)" >> ~/.logs/bash-history-$(date "+%Y-%m-%d").log;'
