# Make sure the autocomplete lines are uncommented
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# Save bash_prompt to users home directory or this wont work..
. ~/.bash_prompt
