
export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

export PATH="$HOME/.cargo/bin:$PATH"

PATH="$HOME/bin:/usr/local/bin:$PATH"
export PATH
alias gmvault=/usr/local/bin/gmvault

set_python_2() {
    export PYTHONPATH=/usr/local/lib/python2.7/site-packages:~/Library/Python/2.7/lib/python/site-packages
    alias ipython="$(which ipython2)"
    alias python="$(which python2.7)"
    alias pip="$(which pip2.7)"
}

set_python_3() {
    unset PYTHONPATH
    alias ipython="$(which ipython3)"
    alias python="$(which python3)"
    alias pip="$(which pip3)"
}

set_python_2

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
